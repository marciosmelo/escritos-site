# Deploy — Escritos (Hugo)

## Secret necessário

`SSH_PRIVATE_KEY` — chave privada com acesso SSH à Hostinger (porta 65002).

## Fluxo

1. Checkout com submodules (tema)
2. `hugo --minify`
3. Backup do `public_html` remoto
4. `rsync` de `public/` → `~/domains/escritos.msmelo.blog/public_html/`

## Deploy local

```bash
./deploy.sh --deploy
```
