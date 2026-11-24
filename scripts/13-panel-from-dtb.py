#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""Generate a mainline DRM panel driver from a downstream Qualcomm DTB/DTS.

The downstream panel node stores its init sequence as a byte array.  Each
packet in that array is the on-the-wire DSI control header defined by
``struct dsi_ctrl_hdr`` in the vendor kernel:

    u8  dtype          MIPI DSI packet type (0x05, 0x15, 0x39, 0x29, ...)
    u8  last
    u8  vc
    u8  ack
    u8  wait           delay in ms after the packet
    u16 dlen           big endian, number of payload bytes
    u8  payload[dlen]

This layout is not guessed: ``mdss_dsi_panel.c`` reads ``dlen`` with
``ntohs()`` from a packed 7 byte header.  The generator parses exactly that,
so a panel that the vendor kernel accepts is parsed the same way here.

Outputs, in --outdir:

    panel-<name>.c      mainline DRM panel driver (MIPI DSI)
    panel-<name>.dtsi   device tree node for &mdss_dsi0
    panel-<name>.json   everything that was parsed, for audit

Usage:
    13-panel-from-dtb.py --dtb out/fota/boot/dtb/from-boot.dtb --name xt3
    13-panel-from-dtb.py --dtb dsi-panel-ili9881d-720p-video.dtsi --list
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys

# MIPI DSI packet types we know how to emit.
DCS_TYPES = {0x05, 0x15, 0x39}
GENERIC_TYPES = {0x03, 0x13, 0x23, 0x29}
DELAY_TYPE = 0xFF


class PanelError(Exception):
    pass


def read_source(path: str) -> str:
    if path.endswith(".dtb"):
        try:
            return subprocess.run(
                ["dtc", "-I", "dtb", "-O", "dts", "-o", "-", path],
                check=True, capture_output=True, text=True,
            ).stdout
        except FileNotFoundError:
            raise PanelError("dtc saknas (apt install device-tree-compiler)")
        except subprocess.CalledProcessError as exc:
            raise PanelError(f"dtc misslyckades: {exc.stderr.strip()}")
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        return fh.read()


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    text = re.sub(r"//[^\n]*", " ", text)
    return text


def balanced_blocks(text: str):
    """Yield (header, body) for every node block in a DTS source."""
    stack = []
    header_start = 0
    for i, ch in enumerate(text):
        if ch == "{":
            header = text[header_start:i].strip()
            stack.append((header, i + 1))
            header_start = i + 1
        elif ch == "}":
            if not stack:
                continue
            header, body_start = stack.pop()
            yield header, text[body_start:i]
            header_start = i + 1
        elif ch == ";" and not stack:
            header_start = i + 1


def top_level(body: str) -> str:
    """Return body with nested node blocks removed.

    Without this the outer ``&mdss_mdp { ... }`` block would look like a panel,
    because its body contains the child panel's properties.
    """
    out = []
    depth = 0
    for ch in body:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        elif depth == 0:
            out.append(ch)
    return "".join(out)


def node_label(header: str) -> str:
    header = header.strip()
    if ":" in header.split("{")[0]:
        label, rest = header.split(":", 1)
        return label.strip(), rest.strip()
    return "", header


def prop_block(body: str, name: str) -> str | None:
    m = re.search(r"(?:^|[\s;])" + re.escape(name) + r"\s*=\s*(.*?);", body, re.S)
    return m.group(1) if m else None


def parse_string(body: str, name: str) -> str | None:
    raw = prop_block(body, name)
    if raw is None:
        return None
    m = re.search(r'"([^"]*)"', raw)
    return m.group(1) if m else None


def parse_ints(body: str, name: str) -> list[int]:
    raw = prop_block(body, name)
    if raw is None:
        return []
    out = []
    for group in re.findall(r"<([^>]*)>", raw):
        for token in group.split():
            token = token.strip()
            if not token:
                continue
            try:
                out.append(int(token, 0))
            except ValueError:
                pass
    return out


def parse_int(body: str, name: str, default: int | None = None) -> int | None:
    vals = parse_ints(body, name)
    return vals[0] if vals else default


_ESCAPES = {"n": 10, "t": 9, "r": 13, "0": 0, "\\": 92, '"': 34, "'": 39}


def bytes_from_string(text: str, name: str) -> list[int]:
    """Decode a DTS string literal (dtc prints all-printable byte arrays as
    strings, so a valid command array can reach us in this form)."""
    out, i = [], 0
    while i < len(text):
        c = text[i]
        if c != "\\":
            out.append(ord(c) & 0xFF)
            i += 1
            continue
        i += 1
        if i >= len(text):
            raise PanelError(f"{name}: escape i slutet av strangen")
        esc = text[i]
        if esc == "x":
            digits = text[i + 1:i + 3]
            if len(digits) != 2:
                raise PanelError(f"{name}: kort hex-escape")
            out.append(int(digits, 16))
            i += 3
        elif esc in _ESCAPES:
            out.append(_ESCAPES[esc])
            i += 1
        elif esc.isdigit():
            digits = esc
            while i + 1 < len(text) and text[i + 1].isdigit():
                i += 1
                digits += text[i]
            out.append(int(digits, 8) & 0xFF)
            i += 1
        else:
            out.append(ord(esc) & 0xFF)
            i += 1
    return out


def parse_bytes(body: str, name: str) -> list[int]:
    """Accept the three shapes dtc can print a byte array in:
    [05 01 ...] (hex bytes), <0x05 0x01 ...> (cells) and "..." (printable)."""
    raw = prop_block(body, name)
    if raw is None:
        return []

    m = re.search(r"\[(.*?)\]", raw, re.S)
    if m:
        out = []
        for token in m.group(1).split():
            try:
                out.append(int(token, 16))
            except ValueError:
                raise PanelError(f"{name}: ogiltig byte {token!r}")
        return out

    m = re.search(r"<([^>]*)>", raw, re.S)
    if m:
        out = []
        for token in m.group(1).split():
            try:
                out.append(int(token, 16) if token.lower().startswith("0x")
                           else int(token) & 0xFF)
            except ValueError:
                raise PanelError(f"{name}: ogiltig cell {token!r}")
        return out

    m = re.search(r'"((?:[^"\\]|\\.)*)"', raw, re.S)
    if m:
        return bytes_from_string(m.group(1), name)
    return []


def parse_reset_sequence(body: str) -> list[dict]:
    raw = prop_block(body, "qcom,mdss-dsi-reset-sequence")
    if raw is None:
        return []
    seq = []
    for group in re.findall(r"<([^>]*)>", raw):
        vals = [int(t, 0) for t in group.split()]
        if len(vals) >= 2:
            seq.append({"value": vals[0], "delay_ms": vals[1]})
    return seq


def parse_cmds(data: list[int], what: str) -> list[dict]:
    cmds = []
    i = 0
    while i < len(data):
        if len(data) - i < 7:
            raise PanelError(f"{what}: trunkerad header vid byte {i}: {data[i:]}")
        dtype = data[i]
        wait = data[i + 4]
        dlen = (data[i + 5] << 8) | data[i + 6]
        payload = data[i + 7:i + 7 + dlen]
        if len(payload) != dlen:
            raise PanelError(
                f"{what}: paket vid byte {i} anger {dlen} byte men bara "
                f"{len(payload)} finns kvar")
        if dtype == DELAY_TYPE:
            cmds.append({"dtype": dtype, "wait": wait, "data": []})
        else:
            if dtype not in DCS_TYPES and dtype not in GENERIC_TYPES:
                raise PanelError(
                    f"{what}: okand dtype 0x{dtype:02x} vid byte {i}")
            if not payload:
                raise PanelError(f"{what}: dtype 0x{dtype:02x} utan payload")
            cmds.append({"dtype": dtype, "wait": wait, "data": payload})
        i += 7 + dlen
    return cmds


def count_lanes(body: str) -> int:
    lanes = 0
    for n in range(4):
        if prop_block(body, f"qcom,mdss-dsi-lane-{n}-state") is not None:
            lanes += 1
    return lanes or 4


def collect_panels(text: str) -> list[dict]:
    panels = []
    for header, body in balanced_blocks(text):
        body = top_level(body)
        if prop_block(body, "qcom,mdss-dsi-on-command") is None:
            continue
        label, name = node_label(header)
        error = None
        try:
            on = parse_bytes(body, "qcom,mdss-dsi-on-command")
            on_cmds = parse_cmds(on, "on-command")
        except PanelError as exc:
            on, on_cmds, error = [], [], str(exc)
        try:
            off = parse_bytes(body, "qcom,mdss-dsi-off-command")
            off_cmds = parse_cmds(off, "off-command")
        except PanelError as exc:
            off, off_cmds = [], []
            error = error or str(exc)
        panels.append({
            "node": name,
            "label": label,
            "panel_name": parse_string(body, "qcom,mdss-dsi-panel-name"),
            "panel_type": parse_string(body, "qcom,mdss-dsi-panel-type"),
            "width": parse_int(body, "qcom,mdss-dsi-panel-width"),
            "height": parse_int(body, "qcom,mdss-dsi-panel-height"),
            "fps": parse_int(body, "qcom,mdss-dsi-panel-framerate", 60),
            "hfp": parse_int(body, "qcom,mdss-dsi-h-front-porch", 0),
            "hbp": parse_int(body, "qcom,mdss-dsi-h-back-porch", 0),
            "hsw": parse_int(body, "qcom,mdss-dsi-h-pulse-width", 0),
            "vfp": parse_int(body, "qcom,mdss-dsi-v-front-porch", 0),
            "vbp": parse_int(body, "qcom,mdss-dsi-v-back-porch", 0),
            "vsw": parse_int(body, "qcom,mdss-dsi-v-pulse-width", 0),
            "bpp": parse_int(body, "qcom,mdss-dsi-bpp", 24),
            "h_sync_pulse": parse_int(body, "qcom,mdss-dsi-h-sync-pulse", 0),
            "traffic_mode": parse_string(body, "qcom,mdss-dsi-traffic-mode"),
            "post_init_delay": parse_int(body, "qcom,mdss-dsi-post-init-delay", 0),
            "width_mm": parse_int(body, "qcom,mdss-pan-physical-width-dimension"),
            "height_mm": parse_int(body, "qcom,mdss-pan-physical-height-dimension"),
            "on_state": parse_string(body, "qcom,mdss-dsi-on-command-state"),
            "lanes": count_lanes(body),
            "reset_sequence": parse_reset_sequence(body),
            "on_cmds": on_cmds,
            "off_cmds": off_cmds,
            "error": error,
            "on_raw": on[:16],
        })
    return panels


def c_array(name: str, data: list[int], indent: str = "        ") -> str:
    lines = []
    for i in range(0, len(data), 12):
        chunk = ", ".join(f"0x{b:02x}" for b in data[i:i + 12])
        lines.append(f"{indent}{chunk},")
    return f"static const u8 {name}[] = {{\n" + "\n".join(lines) + "\n};\n"


def c_cmd_table(name: str, cmds: list[dict], prefix: str) -> tuple[str, str]:
    arrays = []
    entries = []
    for idx, cmd in enumerate(cmds):
        if not cmd["data"]:
            entries.append(
                f"        {{ .dtype = 0xff, .wait = {cmd['wait']}, "
                f".len = 0, .data = NULL }},")
            continue
        arr = f"{prefix}_{idx}"
        arrays.append(c_array(arr, cmd["data"]))
        entries.append(
            f"        {{ .dtype = 0x{cmd['dtype']:02x}, .wait = {cmd['wait']}, "
            f".len = {len(cmd['data'])}, .data = {arr} }},")
    table = (f"static const struct xt3_dsi_cmd {name}[] = {{\n"
             + "\n".join(entries) + "\n};\n")
    return "\n".join(arrays), table


def mm_from_inches(width: int, height: int, diagonal_in: float) -> tuple[int, int]:
    diag_px = (width ** 2 + height ** 2) ** 0.5
    scale = diagonal_in * 25.4 / diag_px
    return round(width * scale), round(height * scale)


def gen_c(panel: dict, slug: str, compatible: str, diagonal: float) -> str:
    name = panel["panel_name"] or slug
    width, height = panel["width"], panel["height"]
    if not width or not height:
        raise PanelError("panelen saknar width/height i DTB")
    fps = panel["fps"] or 60
    htotal = width + panel["hfp"] + panel["hsw"] + panel["hbp"]
    vtotal = height + panel["vfp"] + panel["vsw"] + panel["vbp"]
    clock_khz = htotal * vtotal * fps // 1000
    wmm = panel["width_mm"] or mm_from_inches(width, height, diagonal)[0]
    hmm = panel["height_mm"] or mm_from_inches(width, height, diagonal)[1]

    on_arrays, on_table = c_cmd_table("xt3_on_cmds", panel["on_cmds"], "xt3_on")
    off_arrays, off_table = c_cmd_table("xt3_off_cmds", panel["off_cmds"], "xt3_off")

    # Downstream stores the physical line level (reset-gpio has flags 0).  The
    # mainline node marks the line GPIO_ACTIVE_LOW, so the logical value is
    # the inverse: physical 1 (idle) -> logical 0.
    reset_lines = []
    for step in panel["reset_sequence"]:
        logical = 0 if step["value"] else 1
        reset_lines.append(
            f"        gpiod_set_value_cansleep(ctx->reset_gpio, {logical});\n"
            f"        msleep({step['delay_ms']});")
    reset_body = "\n".join(reset_lines) if reset_lines else \
        "        /* panelen har ingen reset-sekvens i DTB */"

    traffic = (panel["traffic_mode"] or "").lower()
    mode_flags = []
    if (panel["panel_type"] or "").lower() != "dsi_cmd_mode":
        mode_flags.append("MIPI_DSI_MODE_VIDEO")
        if "burst" in traffic:
            mode_flags.append("MIPI_DSI_MODE_VIDEO_BURST")
        if panel["h_sync_pulse"] or "sync_pulse" in traffic:
            mode_flags.append("MIPI_DSI_MODE_VIDEO_SYNC_PULSE")
    if (panel["on_state"] or "").lower() == "dsi_lp_mode":
        mode_flags.append("MIPI_DSI_MODE_LPM")
    flags = ("\n                | ".join(mode_flags)) if mode_flags else "0"
    post_delay = (f"\n        msleep({panel['post_init_delay']});"
                  if panel["post_init_delay"] else "")

    fmt = {16: "MIPI_DSI_FMT_RGB565", 18: "MIPI_DSI_FMT_RGB666",
           24: "MIPI_DSI_FMT_RGB888"}.get(panel["bpp"], "MIPI_DSI_FMT_RGB888")

    return f"""// SPDX-License-Identifier: GPL-2.0-only
/*
 * {name}
 *
 * GENERERAD av scripts/13-panel-from-dtb.py ur {panel['node']}.
 * Redigera inte for hand: kor om generatorn nar DTB:n andras.
 *
 * Panel:    {width}x{height} @ {fps} Hz, {panel['bpp']} bpp, {panel['lanes']} lanes
 * Typ:      {panel['panel_type']}
 * Timing:   h {panel['hfp']}/{panel['hsw']}/{panel['hbp']}  v {panel['vfp']}/{panel['vsw']}/{panel['vbp']}
 * Klocka:   {clock_khz} kHz
 *
 * Kommandoformatet ar Qualcomm ``struct dsi_ctrl_hdr`` (7 byte, dlen big
 * endian).  Se filens huvud i generatorn for harledningen.
 */

#include <linux/backlight.h>
#include <linux/delay.h>
#include <linux/gpio/consumer.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/regulator/consumer.h>

#include <drm/drm_mipi_dsi.h>
#include <drm/drm_modes.h>
#include <drm/drm_panel.h>

#include <video/mipi_display.h>

struct xt3_dsi_cmd {{
        u8 dtype;
        u8 wait;
        u16 len;
        const u8 *data;
}};

struct xt3_panel {{
        struct drm_panel panel;
        struct mipi_dsi_device *dsi;
        struct gpio_desc *reset_gpio;
        struct regulator *power;
        bool prepared;
}};

static inline struct xt3_panel *to_xt3_panel(struct drm_panel *panel)
{{
        return container_of(panel, struct xt3_panel, panel);
}}

{on_arrays}
{off_arrays}
{on_table}
{off_table}

static int xt3_send_cmds(struct mipi_dsi_device *dsi,
                         const struct xt3_dsi_cmd *cmds, size_t count)
{{
        size_t i;
        int ret;

        for (i = 0; i < count; i++) {{
                const struct xt3_dsi_cmd *cmd = &cmds[i];

                if (cmd->dtype == 0xff) {{
                        msleep(cmd->wait);
                        continue;
                }}

                switch (cmd->dtype) {{
                case MIPI_DSI_DCS_SHORT_WRITE:
                case MIPI_DSI_DCS_SHORT_WRITE_PARAM:
                case MIPI_DSI_DCS_LONG_WRITE:
                        ret = mipi_dsi_dcs_write_buffer(dsi, cmd->data, cmd->len);
                        break;
                case MIPI_DSI_GENERIC_SHORT_WRITE_0_PARAM:
                case MIPI_DSI_GENERIC_SHORT_WRITE_1_PARAM:
                case MIPI_DSI_GENERIC_SHORT_WRITE_2_PARAM:
                case MIPI_DSI_GENERIC_LONG_WRITE:
                        ret = mipi_dsi_generic_write(dsi, cmd->data, cmd->len);
                        break;
                default:
                        return -EINVAL;
                }}
                if (ret < 0)
                        return ret;

                if (cmd->wait)
                        msleep(cmd->wait);
        }}

        return 0;
}}

static int xt3_panel_prepare(struct drm_panel *panel)
{{
        struct xt3_panel *ctx = to_xt3_panel(panel);
        int ret;

        if (ctx->prepared)
                return 0;

        if (ctx->power) {{
                ret = regulator_enable(ctx->power);
                if (ret)
                        return ret;
        }}

{reset_body}

        ctx->prepared = true;
        return 0;
}}

static int xt3_panel_enable(struct drm_panel *panel)
{{
        struct xt3_panel *ctx = to_xt3_panel(panel);
        int ret;

        ret = xt3_send_cmds(ctx->dsi, xt3_on_cmds, ARRAY_SIZE(xt3_on_cmds));
        if (ret) {{
                dev_err(&ctx->dsi->dev, "panel init misslyckades: %d\\n", ret);
                return ret;
        }}
{post_delay}
        return 0;
}}

static int xt3_panel_disable(struct drm_panel *panel)
{{
        struct xt3_panel *ctx = to_xt3_panel(panel);

        return xt3_send_cmds(ctx->dsi, xt3_off_cmds, ARRAY_SIZE(xt3_off_cmds));
}}

static int xt3_panel_unprepare(struct drm_panel *panel)
{{
        struct xt3_panel *ctx = to_xt3_panel(panel);

        if (!ctx->prepared)
                return 0;

        gpiod_set_value_cansleep(ctx->reset_gpio, 0);
        if (ctx->power)
                regulator_disable(ctx->power);
        ctx->prepared = false;
        return 0;
}}

static int xt3_panel_get_modes(struct drm_panel *panel,
                               struct drm_connector *connector)
{{
        struct drm_display_mode *mode;

        mode = drm_mode_create(connector->dev);
        if (!mode)
                return -ENOMEM;

        mode->clock = {clock_khz};
        mode->hdisplay = {width};
        mode->hsync_start = {width + panel['hfp']};
        mode->hsync_end = {width + panel['hfp'] + panel['hsw']};
        mode->htotal = {htotal};
        mode->vdisplay = {height};
        mode->vsync_start = {height + panel['vfp']};
        mode->vsync_end = {height + panel['vfp'] + panel['vsw']};
        mode->vtotal = {vtotal};
        mode->width_mm = {wmm};
        mode->height_mm = {hmm};
        mode->type = DRM_MODE_TYPE_DRIVER | DRM_MODE_TYPE_PREFERRED;

        drm_mode_set_name(mode);
        drm_mode_probed_add(connector, mode);
        return 1;
}}

static const struct drm_panel_funcs xt3_panel_funcs = {{
        .prepare = xt3_panel_prepare,
        .enable = xt3_panel_enable,
        .disable = xt3_panel_disable,
        .unprepare = xt3_panel_unprepare,
        .get_modes = xt3_panel_get_modes,
}};

static int xt3_panel_probe(struct mipi_dsi_device *dsi)
{{
        struct device *dev = &dsi->dev;
        struct xt3_panel *ctx;
        int ret;

        /* Linux 7.x: drm_panel_init() ar borta, allokera via devm. */
        ctx = devm_drm_panel_alloc(dev, struct xt3_panel, panel,
                                   &xt3_panel_funcs, DRM_MODE_CONNECTOR_DSI);
        if (IS_ERR(ctx))
                return PTR_ERR(ctx);

        mipi_dsi_set_drvdata(dsi, ctx);
        ctx->dsi = dsi;

        ctx->power = devm_regulator_get_optional(dev, "power");
        if (IS_ERR(ctx->power)) {{
                if (PTR_ERR(ctx->power) != -ENODEV)
                        return dev_err_probe(dev, PTR_ERR(ctx->power),
                                             "kunde inte ta power-regulator\\n");
                ctx->power = NULL;
        }}

        ctx->reset_gpio = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
        if (IS_ERR(ctx->reset_gpio))
                return dev_err_probe(dev, PTR_ERR(ctx->reset_gpio),
                                     "kunde inte ta reset-gpio\\n");

        ctx->panel.prepare_prev_first = true;

        ret = drm_panel_of_backlight(&ctx->panel);
        if (ret)
                return ret;

        drm_panel_add(&ctx->panel);

        dsi->mode_flags = {flags};
        dsi->format = {fmt};
        dsi->lanes = {panel['lanes']};

        return mipi_dsi_attach(dsi);
}}

static void xt3_panel_remove(struct mipi_dsi_device *dsi)
{{
        struct xt3_panel *ctx = mipi_dsi_get_drvdata(dsi);

        mipi_dsi_detach(dsi);
        drm_panel_remove(&ctx->panel);
}}

static const struct of_device_id xt3_panel_of_match[] = {{
        {{ .compatible = "{compatible}" }},
        {{ }}
}};
MODULE_DEVICE_TABLE(of, xt3_panel_of_match);

static struct mipi_dsi_driver xt3_panel_driver = {{
        .probe = xt3_panel_probe,
        .remove = xt3_panel_remove,
        .driver = {{
                .name = "panel-janam-xt3",
                .of_match_table = xt3_panel_of_match,
        }},
}};
module_mipi_dsi_driver(xt3_panel_driver);

MODULE_AUTHOR("OpenHands");
MODULE_DESCRIPTION("{name}");
MODULE_LICENSE("GPL");
"""


def gen_dtsi(panel: dict, compatible: str, reset_gpio: int) -> str:
    lanes = " ".join(str(i) for i in range(panel["lanes"]))
    return f"""// SPDX-License-Identifier: GPL-2.0-only
/*
 * {panel['panel_name']}
 * GENERERAD av scripts/13-panel-from-dtb.py. Redigera inte for hand.
 */

&mdss_dsi0 {{
        #address-cells = <1>;
        #size-cells = <0>;

        panel: panel@0 {{
                compatible = "{compatible}";
                reg = <0>;

                reset-gpios = <&tlmm {reset_gpio} GPIO_ACTIVE_LOW>;
                backlight = <&pm660l_wled>;

                /*
                 * Downstream uses mdss_dsi_active/mdss_te_active pinctrl
                 * states.  Those labels do not exist in mainline; the reset
                 * line works as a plain GPIO and video mode needs no TE.
                 */

                port {{
                        panel_in: endpoint {{
                                remote-endpoint = <&mdss_dsi0_out>;
                        }};
                }};
        }};
}};

&mdss_dsi0_out {{
        data-lanes = <{lanes}>;
        remote-endpoint = <&panel_in>;
}};
"""


def summarise(panel: dict) -> str:
    return (
        f"  nod:        {panel['node']}\n"
        f"  label:      {panel['label']}\n"
        f"  namn:       {panel['panel_name']}\n"
        f"  typ:        {panel['panel_type']}\n"
        f"  upplosning: {panel['width']}x{panel['height']} @ {panel['fps']} Hz\n"
        f"  bpp/lanes:  {panel['bpp']} / {panel['lanes']}\n"
        f"  kommandon:  {len(panel['on_cmds'])} on, {len(panel['off_cmds'])} off\n"
        f"  reset:      {len(panel['reset_sequence'])} steg\n"
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dtb", required=True, help="DTB eller DTS med panelnoden")
    ap.add_argument("--name", default="xt3", help="filnamnssuffix")
    ap.add_argument("--compatible", default="janam,xt3-panel")
    ap.add_argument("--reset-gpio", type=int, default=53,
                    help="TLMM-nummer for panelens reset (XT3: 53)")
    ap.add_argument("--diagonal", type=float, default=5.0,
                    help="skarmdiagonal i tum (endast width_mm/height_mm)")
    ap.add_argument("--panel", default=None,
                    help="valj nod nar DTB:n har flera paneler")
    ap.add_argument("--outdir", default="out/panel")
    ap.add_argument("--list", action="store_true", help="lista paneler och avsluta")
    args = ap.parse_args()

    text = strip_comments(read_source(args.dtb))
    panels = collect_panels(text)
    if not panels:
        print("inga panelnoder med qcom,mdss-dsi-on-command hittades",
              file=sys.stderr)
        return 1

    if args.list:
        for i, p in enumerate(panels):
            state = f"FEL: {p['error']}" if p.get("error") else "ok"
            print(f"[{i}] {p['panel_name']!r}")
            print(f"    node {p['node']}, label {p['label']}")
            print(f"    {p['width']}x{p['height']} @ {p['fps']} Hz, "
                  f"{p['bpp']} bpp, {p['panel_type']}, {p['lanes']} lanes")
            print(f"    on={len(p['on_cmds'])} off={len(p['off_cmds'])}  {state}")
            print("    raw on: " + " ".join(f"{b:02x}" for b in p["on_raw"]))
        return 0

    usable = [p for p in panels if not p.get("error") and p["on_cmds"]]
    if args.panel:
        match = [p for p in panels
                 if args.panel in (p["node"], p["label"], p["panel_name"])]
        if not match:
            print(f"hittade ingen panel som matchar {args.panel!r}",
                  file=sys.stderr)
            return 1
        panel = match[0]
        if panel.get("error"):
            print(f"panelen {panel['panel_name']!r} ar oparsbar: "
                  f"{panel['error']}\nkor --list for att se alla noder",
                  file=sys.stderr)
            return 1
    elif len(usable) == 1:
        panel = usable[0]
    elif usable:
        panel = next((p for p in usable if "xt3" in (p["panel_name"] or "").lower()),
                     usable[0])
        print(f"flera paneler i DTB:n, valjer {panel['panel_name']!r} "
              f"(anvand --panel for att valja)", file=sys.stderr)
    else:
        print("alla panelnoder ar oparsbara:", file=sys.stderr)
        for p in panels:
            print(f"  {p['panel_name']!r}: {p['error']}", file=sys.stderr)
        return 1

    os.makedirs(args.outdir, exist_ok=True)
    base = os.path.join(args.outdir, f"panel-{args.name}")

    with open(base + ".c", "w", encoding="utf-8") as fh:
        fh.write(gen_c(panel, args.name, args.compatible, args.diagonal))
    with open(base + ".dtsi", "w", encoding="utf-8") as fh:
        fh.write(gen_dtsi(panel, args.compatible, args.reset_gpio))
    with open(base + ".json", "w", encoding="utf-8") as fh:
        json.dump(panel, fh, indent=2)

    print(summarise(panel))
    print(f"skrev {base}.c, {base}.dtsi, {base}.json")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except PanelError as exc:
        print(f"fel: {exc}", file=sys.stderr)
        sys.exit(1)
