#!/bin/bash

# Script para deploy de containers usando Docker Compose
# Este script automatiza o processo de deploy da aplicação Node.js containerizada

# Definição de cores para melhor visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para exibir mensagens de log
log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Função para exibir avisos
warn() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] AVISO: $1${NC}"
}

# Função para exibir erros
error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERRO: $1${NC}"
}

# Função para verificar se o Docker está instalado
check_docker() {
  if ! command -v docker &> /dev/null; then
    error "Docker não está instalado. Por favor, instale o Docker antes de continuar."
    exit 1
  fi
  
  if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose não está instalado. Por favor, instale o Docker Compose antes de continuar."
    exit 1
  fi
}

# Função para verificar se a aplicação está saudável
check_health() {
  local max_attempts=10
  local attempt=1
  local wait_time=5
  
  log "Verificando saúde da aplicação..."
  
  while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:3000/status | grep -q "UP"; then
      log "Aplicação está saudável e respondendo corretamente!"
      return 0
    else
      warn "Tentativa $attempt de $max_attempts: Aplicação ainda não está respondendo. Aguardando $wait_time segundos..."
      sleep $wait_time
      attempt=$((attempt+1))
    fi
  done
  
  error "Aplicação não está respondendo após $max_attempts tentativas."
  return 1
}

# Função para fazer backup do container atual (se existir)
backup_current() {
  log "Verificando se existe uma versão anterior para backup..."
  
  if docker ps -a | grep -q "nodejs-app"; then
    log "Versão anterior encontrada. Criando backup..."
    docker commit nodejs-app nodejs-app-backup:$(date +%Y%m%d%H%M%S)
    log "Backup criado com sucesso!"
  else
    log "Nenhuma versão anterior encontrada. Pulando backup."
  fi
}

# Função principal de deploy
deploy() {
  log "Iniciando deploy da aplicação..."
  
  # Verificar se o arquivo docker-compose.yml existe
  if [ ! -f "docker-compose.yml" ]; then
    error "Arquivo docker-compose.yml não encontrado no diretório atual."
    exit 1
  fi
  
  # Fazer backup da versão atual (se existir)
  backup_current
  
  # Parar containers existentes (se houver)
  log "Parando containers existentes..."
  docker-compose down --remove-orphans
  
  # Construir e iniciar os containers
  log "Construindo e iniciando containers..."
  docker-compose up --build -d
  
  # Verificar se o deploy foi bem-sucedido
  if [ $? -eq 0 ]; then
    log "Containers iniciados com sucesso!"
    
    # Verificar saúde da aplicação
    if check_health; then
      log "Deploy concluído com sucesso!"
    else
      error "Deploy falhou na verificação de saúde. Iniciando rollback..."
      rollback
    fi
  else
    error "Falha ao iniciar containers. Iniciando rollback..."
    rollback
  fi
}

# Função de rollback
rollback() {
  warn "Iniciando procedimento de rollback..."
  
  # Parar containers atuais
  docker-compose down
  
  # Verificar se existe backup
  local latest_backup=$(docker images nodejs-app-backup --format "{{.Tag}}" | sort -r | head -n 1)
  
  if [ -n "$latest_backup" ]; then
    log "Restaurando backup: nodejs-app-backup:$latest_backup"
    docker tag nodejs-app-backup:$latest_backup nodejs-app:latest
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
      log "Rollback concluído com sucesso!"
    else
      error "Falha no rollback. Intervenção manual necessária."
      exit 1
    fi
  else
    error "Nenhum backup encontrado para rollback. Intervenção manual necessária."
    exit 1
  fi
}

# Função para exibir logs
show_logs() {
  log "Exibindo logs da aplicação (Ctrl+C para sair)..."
  docker-compose logs -f app
}

# Verificar argumentos
case "$1" in
  deploy)
    check_docker
    deploy
    ;;
  rollback)
    check_docker
    rollback
    ;;
  logs)
    show_logs
    ;;
  health)
    check_health
    ;;
  *)
    echo "Uso: $0 {deploy|rollback|logs|health}"
    echo "  deploy  - Implanta a aplicação usando Docker Compose"
    echo "  rollback - Reverte para a versão anterior (se disponível)"
    echo "  logs    - Exibe logs da aplicação"
    echo "  health  - Verifica a saúde da aplicação"
    exit 1
    ;;
esac

exit 0
