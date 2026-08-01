# Instalação no Cursor (macOS) — só no projeto

Som + toast quando o agente termina. Instala **apenas** em `./.cursor` do repo aberto — **não** mexe em `~/.cursor`.

## Requisitos

- [Cursor](https://cursor.com) com [Hooks](https://cursor.com/docs/agent/hooks) habilitados
- macOS (toast JXA + `afplay`)
- `git`, `python3` (já vêm no macOS)

## Instalação rápida

Na **raiz do seu projeto**:

```bash
cd seu-repo
git clone https://github.com/SEU_USUARIO/cursor-agent-done-hook.git /tmp/cursor-agent-done-hook
/tmp/cursor-agent-done-hook/install.sh --cleanup-source
```

One-liner:

```bash
cd seu-repo && git clone https://github.com/SEU_USUARIO/cursor-agent-done-hook.git /tmp/cursor-agent-done-hook && /tmp/cursor-agent-done-hook/install.sh --cleanup-source
```

## Passo a passo

```bash
# 1. Entre na raiz do projeto onde você usa o Cursor
cd seu-repo

# 2. Clone em pasta temporária (fora do repo)
git clone https://github.com/SEU_USUARIO/cursor-agent-done-hook.git /tmp/cursor-agent-done-hook

# 3. Instala em ./.cursor e apaga o clone
/tmp/cursor-agent-done-hook/install.sh --cleanup-source

# 4. Reinicie o Cursor (ou salve .cursor/hooks.json de novo)
```

O script:

1. Cria `./.cursor/hooks/` no projeto atual
2. Copia `notify.sh` e `toast.js`
3. Mescla o hook `stop` em `./.cursor/hooks.json` (backup se já existir)
4. `chmod +x` nos scripts
5. Com `--cleanup-source`, remove a pasta do clone em `/tmp`

## Onde ficam os arquivos

```text
seu-repo/
  .cursor/
    hooks.json          ← hook "stop"
    hooks/
      notify.sh         ← som + dispara toast
      toast.js          ← overlay na tela
```

Commit `.cursor/hooks/` e `.cursor/hooks.json` se quiser compartilhar com o time.

## Testar

Na raiz do projeto:

```bash
sh .cursor/hooks/notify.sh
osascript -l JavaScript .cursor/hooks/toast.js "Agent finished"
```

No Cursor: rode o agente até terminar — som + toast.

## Desinstalar

```bash
cd seu-repo
git clone https://github.com/SEU_USUARIO/cursor-agent-done-hook.git /tmp/cursor-agent-done-hook
/tmp/cursor-agent-done-hook/uninstall.sh --cleanup-source
```

## Problemas comuns

| Sintoma | Solução |
|--------|---------|
| Som toca, sem toast | `cat /tmp/cursor-toast.err` |
| Nada acontece | Reinicie o Cursor; confira `.cursor/hooks.json` na raiz do projeto |
| Hook não dispara | Cursor → Settings → Hooks; output channel **Hooks** |
| Instalou no lugar errado | `install.sh` usa `pwd` — rode sempre `cd seu-repo` antes |

## Personalizar

- Mensagem: `.cursor/hooks/notify.sh`
- Duração/posição/tema: `.cursor/hooks/toast.js`
