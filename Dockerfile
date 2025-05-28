# Estágio de build
FROM node:18-alpine AS build

# Definir diretório de trabalho
WORKDIR /app

# Copiar package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm ci

# Copiar o restante dos arquivos
COPY . .

# Estágio de produção
FROM node:18-alpine

# Definir diretório de trabalho
WORKDIR /app

# Criar usuário não-root para segurança
RUN addgroup -S nodeapp && adduser -S nodeapp -G nodeapp

# Copiar apenas os arquivos necessários do estágio de build
COPY --from=build /app/package*.json ./
COPY --from=build /app/src ./src
COPY --from=build /app/tests ./tests

# Instalar apenas dependências de produção
RUN npm ci --only=production

# Definir variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3000

# Expor a porta da aplicação
EXPOSE 3000

# Mudar para o usuário não-root
USER nodeapp

# Comando para iniciar a aplicação
CMD ["npm", "start"]
