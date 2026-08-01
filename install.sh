#!/bin/sh
# Instala som + toast no .cursor/ do projeto atual (raiz do repo).
# Uso: cd seu-repo && /caminho/do/clone/install.sh [--cleanup-source] [--yes]

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CLEANUP_SOURCE=0
ASSUME_YES=0
HOOK_COMMAND="sh .cursor/hooks/notify.sh"

usage() {
  cat <<'EOF'
Uso: cd seu-repo && ./install.sh [opções]

Instala apenas em ./.cursor do diretório atual (não usa ~/.cursor).

  --cleanup-source   Remove a pasta do clone após instalar com sucesso
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

if [ "$(uname)" != "Darwin" ]; then
  echo "Aviso: toast JXA é macOS. Linux recebe notify-send se disponível." >&2
fi

PROJECT_ROOT=$(pwd)
TARGET_ROOT="${PROJECT_ROOT}/.cursor"
TARGET_HOOKS="${TARGET_ROOT}/hooks"
HOOKS_JSON="${TARGET_ROOT}/hooks.json"

if [ ! -f "${SCRIPT_DIR}/hooks/notify.sh" ] || [ ! -f "${SCRIPT_DIR}/hooks/toast.js" ]; then
  echo "Erro: hooks/notify.sh ou hooks/toast.js não encontrados em ${SCRIPT_DIR}" >&2
  exit 1
fi

mkdir -p "$TARGET_HOOKS"

cp "${SCRIPT_DIR}/hooks/notify.sh" "${TARGET_HOOKS}/notify.sh"
cp "${SCRIPT_DIR}/hooks/toast.js" "${TARGET_HOOKS}/toast.js"
chmod +x "${TARGET_HOOKS}/notify.sh" "${TARGET_HOOKS}/toast.js"

python3 - "$HOOKS_JSON" "$HOOK_COMMAND" <<'PY'
import json
import os
import sys
from datetime import datetime

hooks_json_path = sys.argv[1]
hook_command = sys.argv[2]

entry = {"command": hook_command}

if os.path.exists(hooks_json_path):
    with open(hooks_json_path, encoding="utf-8") as f:
        data = json.load(f)
    backup = hooks_json_path + ".bak." + datetime.now().strftime("%Y%m%d%H%M%S")
    with open(backup, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"Backup: {backup}")
else:
    data = {"version": 1, "hooks": {}}

hooks = data.setdefault("hooks", {})
stop = hooks.setdefault("stop", [])

if not any(h.get("command") == hook_command for h in stop):
    stop.append(entry)
    print(f"Hook adicionado: {hook_command}")
else:
    print(f"Hook já presente: {hook_command}")

with open(hooks_json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

echo ""
echo "Instalado em: ${TARGET_ROOT}"
echo "  hooks/notify.sh"
echo "  hooks/toast.js"
echo "  hooks.json"
echo ""
echo "Teste: sh .cursor/hooks/notify.sh"
echo "Reinicie o Cursor ou salve .cursor/hooks.json para recarregar hooks."

if [ "$CLEANUP_SOURCE" -eq 1 ]; then
  if [ "$ASSUME_YES" -eq 0 ]; then
    printf "Remover pasta do clone (%s)? [y/N] " "$SCRIPT_DIR"
    read -r answer
    case "$answer" in
      y|Y|yes|Yes|YES) ;;
      *) echo "Clone mantido em: $SCRIPT_DIR"; exit 0 ;;
    esac
  fi
  case "$SCRIPT_DIR" in
    /tmp/*|/var/folders/*)
      rm -rf "$SCRIPT_DIR"
      echo "Clone removido: $SCRIPT_DIR"
      ;;
    *)
      echo "Por segurança, remova manualmente: rm -rf \"$SCRIPT_DIR\""
      ;;
  esac
fi
