#!/bin/bash
# GEFOS AI Hub – logo + GitHub + Vercel jedním spuštěním
set -e
cd "$(dirname "$0")"
echo "▶ GEFOS AI Hub – start"

# --- nástroje ---
if ! command -v brew >/dev/null 2>&1 && { ! command -v gh >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; }; then
  echo "▶ Instaluji Homebrew (zeptá se na heslo k Macu)…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi
command -v gh  >/dev/null 2>&1 || { echo "▶ Instaluji GitHub CLI…"; brew install gh; }
command -v npx >/dev/null 2>&1 || { echo "▶ Instaluji Node.js…";     brew install node; }

# --- logo z gefos.cz ---
echo "▶ Stahuji logo z gefos.cz…"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36"
HTML=$(curl -sL -A "$UA" https://www.gefos.cz/ || true)
LOGO_URL=$(printf '%s' "$HTML" | python3 -c '
import sys,re
from urllib.parse import urljoin
h=sys.stdin.read(); base="https://www.gefos.cz/"
cands=[]
for tag in re.findall(r"<img\b[^>]*>",h,re.I):
    if re.search(r"logo",tag,re.I):
        m=re.search(r"""(?:data-src|src)\s*=\s*["\x27]([^"\x27]+)""",tag,re.I)
        if m and not m.group(1).startswith("data:"): cands.append(m.group(1))
for m in re.finditer(r"""url\(["\x27]?([^)"\x27]*logo[^)"\x27]*)""",h,re.I): cands.append(m.group(1))
for m in re.finditer(r"""<link[^>]+rel=["\x27](?:apple-touch-icon|icon)[^>]*href=["\x27]([^"\x27]+)""",h,re.I): cands.append(m.group(1))
print(urljoin(base,cands[0]) if cands else "")
' 2>/dev/null || true)

if [ -n "$LOGO_URL" ]; then
  EXT="${LOGO_URL##*.}"; EXT="${EXT%%\?*}"; EXT=$(echo "$EXT" | tr 'A-Z' 'a-z')
  case "$EXT" in svg|png|jpg|jpeg|webp|gif) ;; *) EXT=png;; esac
  if curl -sfL -A "$UA" -o "logo.$EXT" "$LOGO_URL" && [ -s "logo.$EXT" ]; then
    [ "$EXT" != "png" ] && sed -i '' "s/src=\"logo\.png\"/src=\"logo.$EXT\"/g" index.html
    echo "  ✓ logo: $LOGO_URL"
  else echo "  ! logo se nepodařilo stáhnout – zůstává textové GEFOS"; fi
else
  echo "  ! logo na webu nenalezeno – zůstává textové GEFOS"
fi

# --- git ---
git add -A
git -c user.name="$(git config user.name || echo GEFOS)" -c user.email="$(git config user.email || echo noreply@gefos.cz)" commit -qm "Logo GEFOS" || true

# --- GitHub ---
gh auth status >/dev/null 2>&1 || { echo "▶ Přihlášení do GitHubu (otevře se prohlížeč)…"; gh auth login -w -p https; }
if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin main
else
  echo "▶ Zakládám repo gefos-ai-hub na GitHubu…"
  gh repo create gefos-ai-hub --public --source=. --remote=origin --push
fi

# --- Vercel ---
echo "▶ Nasazuji na Vercel (při prvním spuštění se přihlásíš v prohlížeči)…"
npx --yes vercel@latest --prod --yes

echo ""
echo "✓ HOTOVO. Adresa appky je výše (řádek Production / Aliased). PIN: 1234"
