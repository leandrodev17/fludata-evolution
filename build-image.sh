#!/bin/bash

# ==================================
# Script de Build da Imagem Docker Customizada
# Evolution API com Gemini Transcription
# ==================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
VERSION="2.3.6-gemini"
IMAGE_NAME="evolution-api-gemini"
REGISTRY="ghcr.io" # ou docker.io para Docker Hub

# Função de help
show_help() {
    echo -e "${BLUE}==================================${NC}"
    echo -e "${BLUE}Build da Evolution API com Gemini${NC}"
    echo -e "${BLUE}==================================${NC}"
    echo ""
    echo "Uso: ./build-image.sh [opcoes]"
    echo ""
    echo "Opções:"
    echo "  -u, --username USERNAME    Seu username no registry (ex: seu-usuario)"
    echo "  -t, --tag TAG             Tag customizada (padrão: $VERSION)"
    echo "  -r, --registry REGISTRY   Registry (padrão: $REGISTRY)"
    echo "  -p, --push                Fazer push da imagem"
    echo "  -h, --help                Mostrar este help"
    echo ""
    echo "Exemplos:"
    echo "  ./build-image.sh -u seu-usuario"
    echo "  ./build-image.sh -u seu-usuario -p"
    echo "  ./build-image.sh -u seu-usuario -t latest -p"
    echo ""
}

# Parse argumentos
USERNAME=""
TAG="$VERSION"
PUSH_IMAGE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -p|--push)
            PUSH_IMAGE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validar username
if [ -z "$USERNAME" ]; then
    echo -e "${RED}❌ Erro: Username é obrigatório!${NC}"
    echo ""
    show_help
    exit 1
fi

# Construir nome completo da imagem
FULL_IMAGE_NAME="$REGISTRY/$USERNAME/$IMAGE_NAME:$TAG"

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Build da Evolution API com Gemini${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""
echo -e "${YELLOW}Imagem:${NC} $FULL_IMAGE_NAME"
echo -e "${YELLOW}Push:${NC} $PUSH_IMAGE"
echo ""

# Build da imagem
echo -e "${GREEN}🔨 Iniciando build da imagem...${NC}"
echo ""

docker build \
    -f Dockerfile.custom \
    -t "$FULL_IMAGE_NAME" \
    -t "$REGISTRY/$USERNAME/$IMAGE_NAME:latest" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build concluído com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}Imagens criadas:${NC}"
    echo "  - $FULL_IMAGE_NAME"
    echo "  - $REGISTRY/$USERNAME/$IMAGE_NAME:latest"
else
    echo -e "${RED}❌ Erro no build da imagem${NC}"
    exit 1
fi

# Push da imagem
if [ "$PUSH_IMAGE" = true ]; then
    echo ""
    echo -e "${GREEN}📤 Fazendo push da imagem...${NC}"
    echo ""

    # Login no registry
    echo -e "${YELLOW}Fazendo login no $REGISTRY...${NC}"

    if [ "$REGISTRY" = "ghcr.io" ]; then
        echo -e "${BLUE}Use seu Personal Access Token do GitHub${NC}"
        docker login ghcr.io -u "$USERNAME"
    else
        docker login "$REGISTRY" -u "$USERNAME"
    fi

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro no login${NC}"
        exit 1
    fi

    # Push da tag versionada
    docker push "$FULL_IMAGE_NAME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Push de $FULL_IMAGE_NAME concluído!${NC}"
    else
        echo -e "${RED}❌ Erro no push da imagem${NC}"
        exit 1
    fi

    # Push da tag latest
    docker push "$REGISTRY/$USERNAME/$IMAGE_NAME:latest"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Push de latest concluído!${NC}"
    else
        echo -e "${RED}❌ Erro no push da tag latest${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}✅ Processo concluído!${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

if [ "$PUSH_IMAGE" = true ]; then
    echo -e "${YELLOW}Para usar a imagem no Railway:${NC}"
    echo "  1. Configure o Railway para usar imagem customizada"
    echo "  2. Use: $FULL_IMAGE_NAME"
    echo ""
else
    echo -e "${YELLOW}Para testar localmente:${NC}"
    echo "  docker run -d -p 8080:8080 \\"
    echo "    -e DATABASE_PROVIDER=postgresql \\"
    echo "    -e DATABASE_CONNECTION_URI=... \\"
    echo "    -e CACHE_REDIS_URI=... \\"
    echo "    -e GEMINI_ENABLED=true \\"
    echo "    -e GEMINI_API_KEY=... \\"
    echo "    -e AUTHENTICATION_API_KEY=... \\"
    echo "    $FULL_IMAGE_NAME"
    echo ""
    echo -e "${YELLOW}Para fazer push depois:${NC}"
    echo "  ./build-image.sh -u $USERNAME -p"
    echo ""
fi
