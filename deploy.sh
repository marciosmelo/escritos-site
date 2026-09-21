#!/bin/bash

# Deploy do site Hugo (HTML estático) para Hostinger
# Uso: ./deploy.sh [--test|--backup|--deploy|--build]

set -euo pipefail

SERVER="u433986376@147.93.38.61"
PORT="65002"
REMOTE_PATH="~/domains/escritos.msmelo.blog/public_html"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/hostinger_deploy}"
ROOT="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }

SSH_OPTS=(-p "$PORT" -o ConnectTimeout=10)
if [[ -f "${SSH_KEY/#\~/$HOME}" ]]; then
  SSH_OPTS+=(-i "${SSH_KEY/#\~/$HOME}")
fi

test_connection() {
  log "Testando conexão SSH..."
  if ssh "${SSH_OPTS[@]}" "$SERVER" "echo ok" >/dev/null 2>&1; then
    log "Conexão SSH OK"
    return 0
  fi
  error "Falha na conexão SSH"
  return 1
}

build_site() {
  log "Gerando site com Hugo..."
  cd "$ROOT"
  git submodule update --init --recursive
  hugo --minify
  log "Build em public/"
}

create_backup() {
  log "Criando backup remoto..."
  local name="public_html_backup_$(date +%Y%m%d_%H%M%S)"
  ssh "${SSH_OPTS[@]}" "$SERVER" "
    cd ~/domains/escritos.msmelo.blog &&
    if [ -d public_html ]; then
      cp -a public_html '$name' && echo Backup: $name
    else
      echo Sem public_html para backup
    fi
  "
}

deploy() {
  build_site
  test_connection || exit 1
  create_backup
  log "Enviando public/ → $REMOTE_PATH"
  rsync -avz --delete \
    -e "ssh ${SSH_OPTS[*]}" \
    "$ROOT/public/" \
    "$SERVER:$REMOTE_PATH/"
  log "Deploy concluído"
}

case "${1:-}" in
  --test) test_connection ;;
  --backup) test_connection && create_backup ;;
  --build) build_site ;;
  --deploy) deploy ;;
  *)
    echo "Uso: $0 [--test|--backup|--build|--deploy]"
    exit 1
    ;;
esac
