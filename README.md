# Oficina Database

Artefatos locais do MySQL 8.0 usados pela aplicação Oficina. Este repositório recebeu o schema, o serviço Docker Compose e os manifests Kubernetes que antes estavam no `soat-fase1-tech-challenge`.

## Docker Compose

Na raiz deste repositório, inicie o banco. O container cria a rede compartilhada `oficina-db-network` e publica a porta `3306` no computador.

```powershell
docker compose up -d
```

Depois, inicie a aplicação no repositório `soat-fase1-tech-challenge` com `docker compose up --build`. O banco precisa estar em execução antes da API.

## Kubernetes local

Com o cluster Kind criado, este repositório deve ser aplicado antes dos manifests da aplicação. O Terraform de `oficina-k8s-infra` executa essa etapa e aguarda o MySQL antes de implantar a API. Para aplicar manualmente:

```powershell
kubectl --context kind-oficina-local apply -k .
kubectl --context kind-oficina-local rollout status deployment/oficina-db --timeout=180s
```

O banco fica disponível no Service `oficina-db-svc:3306`, com PVC de 2 GiB. O `schema.sql` só é carregado quando o MySQL inicializa um diretório de dados vazio; alterações posteriores do schema não são aplicadas automaticamente.

As credenciais deste setup são apenas para desenvolvimento local. Não as use em ambientes compartilhados ou de produção.
