# Projeto DevOps na Prática - Fase 2

Este repositório contém a implementação da Fase 2 do projeto da disciplina "DevOps na Prática".

## Objetivo

O objetivo desta fase foi evoluir a aplicação Node.js e o pipeline de CI da Fase 1, implementando:

*   **Entrega Contínua (CD):** Automatizar o deploy da aplicação em um ambiente AWS.
*   **Containerização:** Empacotar a aplicação e suas dependências usando Docker.
*   **Orquestração:** Gerenciar os containers em produção utilizando Amazon ECS com AWS Fargate.
*   **Monitoramento e Logging:** Implementar observabilidade básica com AWS CloudWatch.
*   **Segurança:** Integrar análise estática de código (SAST) com SonarCloud e gerenciar credenciais de forma segura.

## Tecnologias Utilizadas

*   **Aplicação:** Node.js
*   **CI/CD:** GitHub Actions
*   **Containerização:** Docker
*   **Repositório de Imagens:** Amazon ECR (Elastic Container Registry)
*   **Orquestração:** Amazon ECS (Elastic Container Service) com AWS Fargate
*   **Monitoramento/Logging:** AWS CloudWatch (Logs, Metrics, Alarms)
*   **Segurança (SAST):** SonarCloud
*   **Testes:** Jest

## Pipeline CI/CD (`.github/workflows/ci.yml`)

O pipeline automatizado realiza as seguintes etapas principais em push para `main`/`master`:

1.  **Build Job:**
    *   Checkout do código.
    *   Setup do Node.js.
    *   Instalação de dependências (`npm ci`).
    *   Execução de testes unitários (`npm test`).
2.  **Deploy Job (se o build for bem-sucedido):**
    *   Checkout do código.
    *   Configuração de credenciais AWS (via GitHub Secrets).
    *   Login no Amazon ECR.
    *   Build da imagem Docker.
    *   Tag da imagem (SHA do commit e `latest`).
    *   Push da imagem para o ECR.
    *   Atualização do Serviço ECS (`aws ecs update-service --force-new-deployment`) para implantar a nova imagem.

## Visão Geral da Infraestrutura (Fase 2)

*   **ECR:** Armazena as imagens Docker da aplicação.
*   **ECS Cluster (`devops-pucs`):** Agrupa os recursos de orquestração.
*   **ECS Task Definition (`task-devops-pucrs`):** Define o container a ser executado (imagem, portas, recursos).
*   **ECS Service (`svc-devops-pucrs`):** Mantém a aplicação rodando, gerenciando as tarefas Fargate.
*   **Fargate:** Executa os containers sem necessidade de gerenciar servidores.
*   **CloudWatch:** Coleta logs e métricas, permite a criação de alarmes.
*   **Security Group:** Controla o acesso à aplicação na porta 3000.