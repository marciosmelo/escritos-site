# Escritos

Site de contos e histórias de [Marcio Melo](https://msmelo.blog) — [escritos.msmelo.blog](https://escritos.msmelo.blog).

Migrado do Grav para **Hugo** + tema [hugo-bearblog](https://github.com/janraasch/hugo-bearblog), com tipografia voltada à leitura.

## Desenvolvimento

```bash
git submodule update --init --recursive
hugo server -D
```

Build de produção:

```bash
hugo --minify
```

A saída fica em `public/`.

## Conteúdo

| Pasta | O quê |
|-------|--------|
| `content/contos/` | Contos |
| `content/historias/dezesseis/` | Narrativa *Dezesseis* (capítulos) |

Cada texto é um page bundle (`index.md` + imagens opcionais).

## Deploy

O script `deploy.sh` envia o conteúdo de `public/` para a Hostinger (HTML estático).

```bash
./deploy.sh --deploy
```
