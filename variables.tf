variable "folder_id" {
  type        = string
  description = "Folder id"
}

variable "sa_name" {
  type        = string
  description = "SA name"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "kms_sse_enabled" {
  type        = bool
  description = "Server Side Encryption enabled?"
  default     = false
}

variable "kms_sse_key" {
  type = object({
    name            = string
    description     = string
    algorithm       = string
    rotation_period = string
  })
  description = "Server Side Encryption settings"
  default = {
    name            = "s3-symmetric-key"
    description     = "kms symmetric key for object storage"
    algorithm       = "AES_128"
    rotation_period = "8760h" # 1 year
  }
}

variable "versioning" {
  description = "Enable versioning"
  type        = bool
  default     = false
}
