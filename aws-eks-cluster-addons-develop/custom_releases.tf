resource "helm_release" "custom_release" {
  for_each = var.custom_helm_releases

  # Required parameters
  chart = each.value.chart
  name  = try(each.value.name, each.key)

  # Optional parameters
  namespace            = try(each.value.namespace, null)
  create_namespace     = try(each.value.create_namespace, null)
  repository           = try(each.value.repository, null)
  repository_ca_file   = try(each.value.repository_ca_file, null)
  repository_cert_file = try(each.value.repository_cert_file, null)
  repository_key_file  = try(each.value.repository_key_file, null)
  repository_password  = try(each.value.repository_password, null)
  repository_username  = try(each.value.repository_username, null)
  atomic               = try(each.value.atomic, null)

  values = try(each.value.values, [])

  cleanup_on_fail            = try(each.value.cleanup_on_fail, null)
  dependency_update          = try(each.value.dependency_update, null)
  description                = try(each.value.description, null)
  devel                      = try(each.value.devel, null)
  disable_crd_hooks          = try(each.value.disable_crd_hooks, null)
  disable_openapi_validation = try(each.value.disable_openapi_validation, null)
  disable_webhooks           = try(each.value.disable_webhooks, null)
  force_update               = try(each.value.force_update, null)
  keyring                    = try(each.value.keyring, null)
  lint                       = try(each.value.lint, null)
  max_history                = try(each.value.max_history, null)
  pass_credentials           = try(each.value.pass_credentials, null)
  recreate_pods              = try(each.value.recreate_pods, null)
  render_subchart_notes      = try(each.value.render_subchart_notes, null)
  replace                    = try(each.value.replace, null)
  reset_values               = try(each.value.reset_values, null)
  reuse_values               = try(each.value.reuse_values, null)
  skip_crds                  = try(each.value.skip_crds, null)
  timeout                    = try(each.value.timeout, null)
  upgrade_install            = try(each.value.upgrade_install, null)
  verify                     = try(each.value.verify, null)
  version                    = try(each.value.chart_version, null)
  wait                       = try(each.value.wait, false)
  wait_for_jobs              = try(each.value.wait_for_jobs, null)

  dynamic "postrender" {
    for_each = try([each.value.postrender], [])

    content {
      binary_path = postrender.value.binary_path
      args        = try(postrender.value.args, null)
    }
  }

  dynamic "set" {
    for_each = try(each.value.set, [])

    content {
      name  = set.value.name
      value = set.value.value
      type  = try(set.value.type, null)
    }
  }

  dynamic "set_list" {
    for_each = try(each.value.set_list, [])

    content {
      name  = set_list.value.name
      value = set_list.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = try(each.value.set_sensitive, [])

    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
      type  = try(set_sensitive.value.type, null)
    }
  }
}
