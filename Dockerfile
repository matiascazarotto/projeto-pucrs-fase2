# Estágio de build
FROM node:18-alpine AS build

WORKDIR /app

# Copiar apenas os arquivos de dependência
COPY package*.json ./

# Instalar todas as dependências (dev + prod)
RUN npm ci

# Copiar somente os arquivos da aplicação e testes
COPY src ./src
COPY tests ./tests

# Estágio de produção
FROM node:18-alpine

WORKDIR /app

# Criar usuário não-root
RUN addgroup -S nodeapp && adduser -S nodeapp -G nodeapp

# Copiar apenas o necessário da etapa de build
COPY --from=build /app/package*.json ./
COPY --from=build /app/src ./src
COPY --from=build /app/tests ./tests

# Instalar apenas dependências de produção
RUN npm ci --only=production

# Variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

USER nodeapp

CMD ["npm", "start"]
