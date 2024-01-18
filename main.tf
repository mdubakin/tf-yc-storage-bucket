resource "yandex_kms_symmetric_key" "this" {
  count             = var.kms_sse_enabled ? 1 : 0
  folder_id         = var.folder_id
  name              = var.kms_sse_key.name
  description       = var.kms_sse_key.description
  default_algorithm = var.kms_sse_key.algorithm
  rotation_period   = var.kms_sse_key.rotation_period
}

resource "yandex_iam_service_account" "this" {
  folder_id = var.folder_id
  name      = var.sa_name
}

resource "yandex_resourcemanager_folder_iam_member" "this" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
}

resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = yandex_iam_service_account.this.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "bucket" {
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key
  bucket     = var.bucket_name

  dynamic "versioning" {
    for_each = range(var.versioning ? 1 : 0)
    content {
      enabled = var.versioning
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = range(var.kms_sse_enabled ? 1 : 0)
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = yandex_kms_symmetric_key.this[0].id
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

}
