#!/usr/bin/env python3
"""Konverterar qcom mdss-dsi-on-command (från stock-DTB) till C för panel-jadard-jd9365da-h3."""
import re, sys

src, out = sys.argv[1], sys.argv[2]
text = open(src).read()
m = re.search(r"qcom,mdss-dsi-on-command = \[([^\]]+)\]", text)
if not m:
    sys.exit("hittade ingen on-command")
b = [int(x, 16) for x in m.group(1).split()]
cmds, i = [], 0
while i + 7 <= len(b):
    dtype, last, vc, ack, wait, hi, lo = b[i:i+7]
    dlen = (hi << 8) | lo
    payload = b[i+7:i+7+dlen]
    cmds.append((dtype, wait, payload))
    i += 7 + dlen
lines = ["static int janam_xt3_init(struct jadard *jadard)", "{",
         "\tstruct mipi_dsi_multi_context dsi_ctx = { .dsi = jadard->dsi };", ""]
for dtype, wait, p in cmds:
    if not p:
        continue
    cmd, params = p[0], p[1:]
    if cmd == 0xFF and len(params) == 1:
        lines.append(f"\tjd9365da_switch_page(&dsi_ctx, 0x{params[0]:02x});")
    elif cmd == 0x11:
        lines.append("\tmipi_dsi_dcs_exit_sleep_mode_multi(&dsi_ctx);")
    elif cmd == 0x29:
        lines.append("\tmipi_dsi_dcs_set_display_on_multi(&dsi_ctx);")
    elif cmd == 0x35:
        lines.append("\tmipi_dsi_dcs_set_tear_on_multi(&dsi_ctx, MIPI_DSI_DCS_TEAR_MODE_VBLANK);")
    elif params:
        args = ", ".join(f"0x{x:02x}" for x in params)
        lines.append(f"\tmipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x{cmd:02x}, {args});")
    else:
        lines.append(f"\tmipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x{cmd:02x});")
    if wait:
        lines.append(f"\tmsleep({wait});")
lines += ["", "\treturn dsi_ctx.accum_err;", "}", ""]
open(out, "w").write("\n".join(lines))
print(f"{len(cmds)} kommandon -> {out}")
