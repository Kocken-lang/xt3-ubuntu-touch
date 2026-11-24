#!/usr/bin/env bash
# Fjärragent: kör kommandon som skickas till branch 'cmd' och pushar
# resultatet till branch 'res'. Startas en gång; sedan skots allt pa distans.
# Ingen inkommande anslutning, ingen exponering - bara git.
set -uo pipefail
REPO="${XT3_AGENT_REPO:-https://github.com/Kocken-lang/xt3-ubuntu-touch.git}"
DIR="${XT3_AGENT_DIR:-$HOME/.xt3-agent}"
WORK="${XT3_AGENT_WORK:-$HOME/xt3}"
POLL="${XT3_AGENT_POLL:-3}"
MAXOUT=400000

mkdir -p "$DIR"; cd "$DIR" || exit 1
if [ ! -d .git ]; then
        git init -q
        git remote add origin "$REPO"
fi
git config user.name  "$(git -C "$WORK" config user.name  2>/dev/null || echo moon)"
git config user.email "$(git -C "$WORK" config user.email 2>/dev/null || echo moon@localhost)"

echo "agent: vakar pa $REPO (branch cmd), poll ${POLL}s"
echo "agent: kommandon kors i $WORK"
seen=""
while :; do
        if git fetch -q -f origin cmd 2>/dev/null; then
                blob=$(git show FETCH_HEAD:cmd 2>/dev/null)
                cid=$(printf '%s\n' "$blob" | sed -n '1p')
                body=$(printf '%s\n' "$blob" | sed -n '2,$p')
                if [ -n "$cid" ] && [ "$cid" != "$seen" ]; then
                        seen="$cid"
                        printf 'agent: kor %s\n' "$cid"
                        out=$( cd "$WORK" && timeout 1800 bash -c "$body" 2>&1 | head -c "$MAXOUT" )
                        printf '%s\n%s\n' "$cid" "$out" > res
                        git checkout -q -B res 2>/dev/null
                        git add res >/dev/null 2>&1
                        git commit -q -m "res $cid" >/dev/null 2>&1
                        git push -q -f origin res >/dev/null 2>&1 \
                                && printf 'agent: svar pushat (%s tecken)\n' "${#out}" \
                                || printf 'agent: KUNDE INTE PUSHA svaret\n'
                fi
        fi
        sleep "$POLL"
done
