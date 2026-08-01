#!/bin/sh
# Clone temporário + instala no .cursor/ do projeto atual + apaga o clone.
# Uso: cd seu-repo && ./bootstrap.sh [URL_DO_REPO_GIT]

set -e

REPO_URL="${1:-https://github.com/SEU_USUARIO/cursor-agent-done-hook.git}"
INSTALL_DIR="/tmp/cursor-agent-done-hook-$$"

if [ ! -d ".git" ]; then
  echo "Execute na raiz do seu projeto (pasta com .git):" >&2
  echo "  cd seu-repo && curl -fsSL .../bootstrap.sh | sh" >&2
  exit 1
fi

cleanup() {
  [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
}
trap cleanup EXIT INT TERM

echo "Projeto: $(pwd)"
echo "Clonando ${REPO_URL} ..."
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"

"$INSTALL_DIR/install.sh" --yes --cleanup-source

echo "Pronto. Reinicie o Cursor."
