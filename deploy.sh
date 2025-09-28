#!/bin/bash

# Deploy script para Hostinger
# Uso: ./deploy.sh [--test|--backup|--deploy]

SERVER="u433986376@147.93.38.61"
PORT="65002"
REMOTE_PATH="~/domains/escritos.msmelo.blog/public_html/user"
SSH_KEY="~/.ssh/hostinger_deploy"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Função para testar conexão SSH
test_connection() {
    log "Testando conexão SSH..."
    
    if ssh -p $PORT -o ConnectTimeout=10 $SERVER "echo 'Conexão OK'" > /dev/null 2>&1; then
        log "✅ Conexão SSH funcionando"
        return 0
    else
        error "❌ Falha na conexão SSH"
        error "Verifique se:"
        error "  1. A chave SSH está configurada corretamente"
        error "  2. O servidor está acessível"
        error "  3. As credenciais estão corretas"
        return 1
    fi
}

# Função para criar backup
create_backup() {
    log "Criando backup do site atual..."
    
    BACKUP_NAME="user_backup_$(date +%Y%m%d_%H%M%S)"
    
    ssh -p $PORT $SERVER "
        if [ -d 'user' ]; then
            cp -r user $BACKUP_NAME
            echo 'Backup criado: $BACKUP_NAME'
        else
            echo 'Nenhum diretório user encontrado para backup'
        fi
    "
}

# Função para verificar estrutura remota
check_remote_structure() {
    log "Verificando estrutura do servidor..."
    
    ssh -p $PORT $SERVER "
        echo 'Diretório atual:'; pwd;
        echo '';
        echo 'Conteúdo:'; ls -la;
        echo '';
        if [ -d 'user' ]; then
            echo 'Estrutura do user:';
            ls -la user/ | head -20;
        else
            echo 'Diretório user não existe - será criado durante o deploy';
        fi
    "
}

# Função principal de deploy
deploy() {
    log "Iniciando deploy..."
    
    # Verificar se estamos no diretório correto
    if [ ! -f "hebe.json" ] && [ ! -d "pages" ]; then
        error "Este não parece ser um diretório do Grav. Verifique se está no local correto."
        return 1
    fi
    
    log "Sincronizando arquivos..."
    
    rsync -avz -e "ssh -p $PORT" \
        --exclude='.git' \
        --exclude='.github' \
        --exclude='README.md' \
        --exclude='screenshot.jpg' \
        --exclude='deploy.sh' \
        --delete \
        --progress \
        ./ $SERVER:$REMOTE_PATH/
    
    if [ $? -eq 0 ]; then
        log "✅ Arquivos sincronizados com sucesso"
    else
        error "❌ Falha na sincronização"
        return 1
    fi
    
    log "Definindo permissões..."
    ssh -p $PORT $SERVER "
        find $REMOTE_PATH -type f -name '*.md' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.yaml' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.yml' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.php' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.jpg' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.jpeg' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.png' -exec chmod 644 {} \;
        find $REMOTE_PATH -type f -name '*.svg' -exec chmod 644 {} \;
        find $REMOTE_PATH -type d -exec chmod 755 {} \;
        echo 'Permissões definidas'
    "
    
    log "Limpando cache..."
    ssh -p $PORT $SERVER "
        if [ -d '$REMOTE_PATH/cache' ]; then 
            rm -rf $REMOTE_PATH/cache/*;
            echo 'Cache limpo';
        else
            echo 'Sem cache para limpar';
        fi
    " 2>/dev/null || warning "Não foi possível limpar o cache"
    
    log "✅ Deploy concluído com sucesso!"
}

# Função para verificar deploy
verify_deploy() {
    log "Verificando deploy..."
    
    ssh -p $PORT $SERVER "
        echo 'Conteúdo do user:';
        ls -la $REMOTE_PATH/ | head -20;
        echo '';
        echo 'Páginas:';
        ls -la $REMOTE_PATH/pages/ 2>/dev/null | head -10 || echo 'Diretório pages não encontrado';
        echo '';
        echo 'Config:';
        ls -la $REMOTE_PATH/config/ 2>/dev/null | head -10 || echo 'Diretório config não encontrado';
    "
}

# Menu principal
case "$1" in
    --test)
        log "🔍 Modo teste"
        test_connection
        ;;
    --check)
        log "🔍 Verificando estrutura remota"
        test_connection && check_remote_structure
        ;;
    --backup)
        log "💾 Criando backup"
        test_connection && create_backup
        ;;
    --deploy)
        log "🚀 Deploy completo"
        test_connection && create_backup && deploy && verify_deploy
        ;;
    --verify)
        log "✅ Verificando deploy"
        test_connection && verify_deploy
        ;;
    *)
        echo "🚀 Script de Deploy - Escritos Site"
        echo ""
        echo "Uso: $0 [opção]"
        echo ""
        echo "Opções:"
        echo "  --test      Testa conexão SSH"
        echo "  --check     Verifica estrutura do servidor"
        echo "  --backup    Cria backup do site atual"
        echo "  --deploy    Deploy completo (backup + sync + verificação)"
        echo "  --verify    Verifica estrutura após deploy"
        echo ""
        echo "Exemplos:"
        echo "  $0 --test    # Testa se consegue conectar"
        echo "  $0 --deploy  # Faz deploy completo"
        ;;
esac