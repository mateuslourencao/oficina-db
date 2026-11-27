# Oficina Database

Artefatos locais do MySQL 8.0 usados pela aplicação Oficina. Este repositório recebeu o schema, o serviço Docker Compose e os manifests Kubernetes que antes estavam no `soat-fase1-tech-challenge`.

## Docker Compose

Na raiz deste repositório, inicie o banco. O container cria a rede compartilhada `oficina-db-network` e publica a porta `3306` no computador.

```powershell
docker compose up -d
```

Depois, inicie a aplicação no repositório `soat-fase1-tech-challenge` com `docker compose up --build`. O banco precisa estar em execução antes da API.

## Kubernetes local

Com o cluster Kind criado, este repositório deve ser aplicado antes dos manifests da aplicação. O Terraform de `oficina-k8s-infra` executa o Terraform deste repositório e aguarda o MySQL antes de implantar a API. Para aplicar manualmente, use a seção Terraform abaixo; o `kubectl apply` direto também continua disponível para validações pontuais:

```powershell
kubectl --context kind-oficina-local apply -k .
kubectl --context kind-oficina-local rollout status deployment/oficina-db --timeout=180s
```

O banco fica disponível no Service `oficina-db-svc:3306`, com PVC de 2 GiB. O `schema.sql` só é carregado quando o MySQL inicializa um diretório de dados vazio; alterações posteriores do schema não são aplicadas automaticamente.

As credenciais deste setup são apenas para desenvolvimento local. Não as use em ambientes compartilhados ou de produção.

## Terraform e pipeline local

O diretório `terraform/` executa `kubectl apply -k .` para aplicar os manifests deste repositório no cluster Kind criado por `oficina-k8s-infra` e aguarda o Deployment do MySQL. O state Terraform guarda apenas o registro dessa execução e os fingerprints dos arquivos; os objetos Kubernetes não são modelados individualmente como recursos Terraform. Alterações no schema ou nos manifests geram uma nova execução do `kubectl apply`. Este Terraform não cria o cluster e não compartilha estado com os demais repositórios.

Para executar manualmente, com o contexto Kind já disponível:

```powershell
terraform -chdir=terraform init
terraform -chdir=terraform plan -var="cluster_context=kind-oficina-local"
terraform -chdir=terraform apply -var="cluster_context=kind-oficina-local"
terraform -chdir=terraform output
```

As variáveis estão em `terraform/variables.tf`. As saídas informam o contexto, Deployment e endereço DNS interno do Service. O backend é local; o deploy automático guarda estados distintos em `%USERPROFILE%\.terraform-state\oficina-db\homolog.tfstate` e `production.tfstate`. O Terraform não exclui automaticamente os objetos Kubernetes ao destruir seu state; a remoção deve ser feita de forma explícita com `kubectl delete -k .` no contexto e namespace corretos.

O workflow `.github/workflows/main.yml` valida formatação e configuração Terraform e gera `plan` em Pull Requests sem alterar um cluster. Pushes para `homolog` e `main` fazem `apply` no runner Windows self-hosted com rótulo `oficina-local`, nos contextos `kind-oficina-homolog` e `kind-oficina-prod`, respectivamente. O cluster correspondente precisa existir antes do deploy do banco.

No deploy integrado, `oficina-k8s-infra` prepara o cluster, executa este Terraform usando o mesmo estado por ambiente e aguarda o banco antes de aplicar a API. Assim, este repositório é o único responsável pelo gerenciamento persistente dos manifests e estado do MySQL.
