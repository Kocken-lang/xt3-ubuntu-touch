#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""Summarise the hardware in a downstream Qualcomm DTB.

The stock boot.img DTB is the authoritative description of the XT3.  This
tool turns it into a short, readable inventory so the mainline DTS can be
filled from data instead of guesses.

    usage: 14-hw-from-dtb.py --dtb out/fota/boot/dtb/from-boot.dtb
    outputs: out/hw/hw.md and out/hw/hw.json
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "panelgen", os.path.join(HERE, "13-panel-from-dtb.py"))
pg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pg)


def top_blocks(text: str):
    """Yield only depth-1 node blocks, so walk() does not visit a node twice."""
    depth = 0
    header = ""
    body_start = 0
    header_start = 0
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                header = text[header_start:i]
                body_start = i + 1
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                yield header, text[body_start:i]
                header_start = i + 1
        elif ch == ";" and depth == 0:
            header_start = i + 1


def walk(text: str, prefix: str = "") -> list[dict]:
    """Return every node with its path, direct properties and children."""
    nodes = []
    for header, body in top_blocks(text):
        props = pg.top_level(body)
        label, name = pg.node_label(header)
        path = f"{prefix}/{name}" if prefix else name
        nodes.append({"path": path, "label": label, "props": props,
                      "body": body})
        nodes.extend(walk(body, path))
    return nodes


def gpio_of(raw: str) -> list[int]:
    """Extract (controller phandle, gpio, flags) triples from a property."""
    out = []
    for group in re.findall(r"<([^>]*)>", raw):
        vals = [int(t, 0) for t in group.split()
                if re.match(r"^(0x[0-9a-fA-F]+|\d+)$", t)]
        if len(vals) == 1:
            out.append(vals[0])
        for i in range(0, len(vals) - 2, 3):
            out.append(vals[i + 1])
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dtb", required=True)
    ap.add_argument("--outdir", default="out/hw")
    args = ap.parse_args()

    text = pg.strip_comments(pg.read_source(args.dtb))
    nodes = walk(text)
    os.makedirs(args.outdir, exist_ok=True)

    panels = pg.collect_panels(text)
    keys = []
    buses = {"i2c": [], "spi": [], "serial": []}

    for node in nodes:
        props = node["props"]
        name = node["path"].rsplit("/", 1)[-1]
        if re.match(r"^(i2c|spi|serial)@", name):
            kind = name.split("@")[0]
            base = name.split("@")[1]
            children = []
            for child in walk(node["body"]):
                cname = child["path"].rsplit("/", 1)[-1]
                if "@" in cname and "/" not in child["path"]:
                    children.append({
                        "node": cname,
                        "compatible": pg.parse_string(child["props"], "compatible"),
                        "reg": pg.parse_ints(child["props"], "reg"),
                    })
            buses[kind].append({"node": name, "base": base, "children": children})

        if "gpio-keys" in (pg.parse_string(props, "compatible") or ""):
            for child in walk(node["body"]):
                cname = child["path"].rsplit("/", 1)[-1]
                raw = pg.prop_block(child["props"], "gpios")
                if not raw:
                    continue
                keys.append({
                    "node": cname,
                    "label": pg.parse_string(child["props"], "label"),
                    "gpio": gpio_of(raw),
                    "code": pg.parse_ints(child["props"], "linux,code"),
                    "input_type": pg.parse_ints(child["props"], "linux,input-type"),
                })

    hw = {"panels": panels, "keys": keys, "buses": buses}
    with open(os.path.join(args.outdir, "hw.json"), "w", encoding="utf-8") as fh:
        json.dump(hw, fh, indent=2)

    lines = ["# Hardware ur stock-DTB", "", f"Kalla: `{args.dtb}`", ""]
    lines.append("## Paneler")
    for p in panels:
        note = f"  **oparsbar:** {p['error']}" if p.get("error") else ""
        lines.append(f"- `{p['panel_name']}` {p['width']}x{p['height']} "
                     f"@ {p['fps']} Hz, {p['lanes']} lanes, "
                     f"{len(p['on_cmds'])} init-kommandon{note}")
    lines.append("")
    lines.append("## Tangenter")
    for k in keys:
        lines.append(f"- `{k['label'] or k['node']}`: gpio {k['gpio']} "
                     f"code {k['code']} typ {k['input_type']}")
    lines.append("")
    for kind, items in buses.items():
        lines.append(f"## {kind.upper()}-bussar")
        for b in items:
            lines.append(f"- `{b['node']}` @ {b['base']}")
            for c in b["children"]:
                lines.append(f"  - `{c['node']}` compatible `{c['compatible']}` "
                             f"reg {c['reg']}")
        lines.append("")

    with open(os.path.join(args.outdir, "hw.md"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")

    print("\n".join(lines))
    print(f"skrev {args.outdir}/hw.md och {args.outdir}/hw.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
