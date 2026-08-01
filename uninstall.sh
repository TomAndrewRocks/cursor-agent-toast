#!/bin/sh
# Remove som + toast do .cursor/ do projeto atual.
# Uso: cd seu-repo && /caminho/do/clone/uninstall.sh [--cleanup-source] [--yes]

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CLEANUP_SOURCE=0
ASSUME_YES=0
HOOK_COMMAND="sh .cursor/hooks/notify.sh"

usage() {
  cat <<'EOF'
Uso: cd seu-repo && ./uninstall.sh [opções]

Remove apenas de ./.cursor do diretório atual.

  --cleanup-source   Remove a pasta do clone após desinstalar
  --yes              Não pede confirmação para --cleanup-source
  -h, --help         Mostra esta ajuda
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --cleanup-source) CLEANUP_SOURCE=1 ;;
    --yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

TARGET_ROOT="$(pwd)/.cursor"
TARGET_HOOKS="${TARGET_ROOT}/hooks"
HOOKS_JSON="${TARGET_ROOT}/hooks.json"

rm -f "${TARGET_HOOKS}/notify.sh" "${TARGET_HOOKS}/toast.js"

if [ -f "$HOOKS_JSON" ]; then
  python3 - "$HOOKS_JSON" "$HOOK_COMMAND" <<'PY'
import json
import sys
from datetime import datetime

hooks_json_path = sys.argv[1]
hook_command = sys.argv[2]

with open(hooks_json_path, encoding="utf-8") as f:
    data = json.load(f)

backup = hooks_json_path + ".bak." + datetime.now().strftime("%Y%m%d%H%M%S")
with open(backup, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"Backup: {backup}")

stop = data.get("hooks", {}).get("stop", [])
filtered = [h for h in stop if h.get("command") != hook_command]

if filtered:
    data.setdefault("hooks", {})["stop"] = filtered
else:
    data.get("hooks", {}).pop("stop", None)
    if not data.get("hooks"):
        data.pop("hooks", None)

with open(hooks_json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"Hook removido: {hook_command}")
PY
fi

if [ -d "$TARGET_HOOKS" ] && [ -z "$(ls -A "$TARGET_HOOKS" 2>/dev/null)" ]; then
  rmdir "$TARGET_HOOKS"
fi

echo "Desinstalado de: ${TARGET_ROOT}"

if [ "$CLEANUP_SOURCE" -eq 1 ]; then
  if [ "$ASSUME_YES" -eq 0 ]; then
    printf "Remover pasta do clone (%s)? [y/N] " "$SCRIPT_DIR"
    read -r answer
    case "$answer" in
      y|Y|yes|Yes|YES) ;;
      *) exit 0 ;;
    esac
  fi
  case "$SCRIPT_DIR" in
    /tmp/*|/var/folders/*)
      rm -rf "$SCRIPT_DIR"
      echo "Clone removido: $SCRIPT_DIR"
      ;;
    *)
      echo "Remova manualmente: rm -rf \"$SCRIPT_DIR\""
      ;;
  esac
fi
