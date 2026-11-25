#!/usr/bin/env bash
# Loggar UART fran XT3. 115200 8N1, raw.
#   ./scripts/50-uart-console.sh [enhet] [loggfil]
set -uo pipefail
DEV="${1:-/dev/ttyUSB0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${2:-$ROOT/out/uart/$(date +%Y%m%d-%H%M%S).log}"

[ -c "$DEV" ] || { echo "hittar inte $DEV"; ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null; exit 1; }
mkdir -p "$(dirname "$OUT")"

stty -F "$DEV" 115200 cs8 -cstopb -parenb -crtscts raw -echo || exit 1
echo "loggar $DEV @115200 8N1 -> $OUT"
echo "Ctrl-C avslutar."

if command -v ts >/dev/null; then
  cat "$DEV" | ts '%.s' | tee "$OUT"
else
  cat "$DEV" | tee "$OUT"
fi
