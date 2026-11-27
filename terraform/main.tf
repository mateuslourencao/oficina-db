locals {
  repository_root = abspath("${path.module}/..")
  manifest_files = concat(
    [
      "${local.repository_root}/kustomization.yaml",
      "${local.repository_root}/schema.sql",
    ],
    [for file in fileset(local.repository_root, "k8s/**") : "${local.repository_root}/${file}"],
  )
  manifest_fingerprint = sha256(join("", [for file in local.manifest_files : filesha256(file)]))
}

resource "terraform_data" "database" {
  # The Terraform state records this apply operation and its manifest hashes only.
  # Kubernetes objects remain managed through kubectl/Kustomize, not per-resource Terraform objects.
  input = {
    cluster_context = var.cluster_context
    namespace       = var.namespace
  }

  triggers_replace = [
    local.manifest_fingerprint,
    var.cluster_context,
    var.namespace,
  ]

  provisioner "local-exec" {
    working_dir = local.repository_root
    interpreter = ["PowerShell", "-NoProfile", "-NonInteractive", "-Command"]
    command     = "kubectl --context ${var.cluster_context} apply --namespace ${var.namespace} -k .; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; kubectl --context ${var.cluster_context} rollout status deployment/oficina-db --namespace ${var.namespace} --timeout=${var.deployment_timeout}; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }"
  }
}
