# Deploy Workflow - Configuração

Este repositório contém um workflow GitHub Actions para deploy automático no servidor Hostinger.

## Configuração dos Secrets

Para que o deploy funcione, você precisa configurar os seguintes secrets no GitHub:

### 1. SSH_PRIVATE_KEY

1. **Gerar chave SSH (se ainda não tiver):**
   ```bash
   ssh-keygen -t rsa -b 4096 -C "deploy@escritos-site"
   ```
   - Salve como `~/.ssh/hostinger_deploy` (ou outro nome)
   - **NÃO** coloque senha na chave

2. **Adicionar chave pública no servidor:**
   ```bash
   # Copiar a chave pública para o servidor
   ssh-copy-id -p 65002 -i ~/.ssh/hostinger_deploy.pub u433986376@147.93.38.61
   
   # OU manualmente:
   cat ~/.ssh/hostinger_deploy.pub | ssh -p 65002 u433986376@147.93.38.61 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   ```

3. **Configurar Secret no GitHub:**
   - Vá para: `Settings` > `Secrets and variables` > `Actions`
   - Clique em `New repository secret`
   - Nome: `SSH_PRIVATE_KEY`
   - Valor: Cole o conteúdo de `~/.ssh/hostinger_deploy` (chave PRIVADA)

### 2. Testar conexão SSH localmente

Antes de fazer o deploy via GitHub Actions, teste a conexão:

```bash
# Testar conexão
ssh -p 65002 -i ~/.ssh/hostinger_deploy u433986376@147.93.38.61

# Verificar estrutura do servidor
ssh -p 65002 u433986376@147.93.38.61 "pwd && ls -la"
```

## Como funciona o Deploy

1. **Trigger**: O deploy é executado automaticamente quando:
   - Há push na branch `main`
   - Há pull request para a branch `main`

2. **Processo**:
   - Faz checkout do código
   - Configura SSH
   - Testa conexão
   - Verifica estrutura do servidor
   - Cria backup do site atual
   - Sincroniza arquivos usando rsync
   - Define permissões corretas
   - Verifica o deploy
   - Limpa cache do Grav

3. **Arquivos sincronizados**:
   - Todo o conteúdo do repositório vai para `~/user/` no servidor
   - Exclui: `.git`, `.github`, `README.md`, `screenshot.jpg`

## Estrutura esperada no servidor

```
~/domains/escritos.msmelo.blog/public_html/user/
├── accounts/
├── config/
├── data/
├── pages/
├── plugins/
├── themes/
└── outros arquivos do Grav...
```

## Logs e Troubleshooting

- Acesse: `Actions` no GitHub para ver logs do deploy
- Em caso de erro, verifique:
  1. Se a chave SSH está configurada corretamente
  2. Se o servidor está acessível
  3. Se a pasta `user` existe no servidor
  4. Permissões no servidor

## Deploy manual (backup)

Se precisar fazer deploy manual:

```bash
# Sync local para servidor
rsync -avz -e "ssh -p 65002" \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='README.md' \
  --exclude='screenshot.jpg' \
  --exclude='deploy.sh' \
  --delete \
  ./ u433986376@147.93.38.61:~/domains/escritos.msmelo.blog/public_html/user/
```