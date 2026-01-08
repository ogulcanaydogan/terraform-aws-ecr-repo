variable "name" {
  description = "Name of the ECR repository."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9/_.-]*$", var.name)) && length(var.name) >= 2 && length(var.name) <= 256
    error_message = "Repository name must be 2-256 characters, start with alphanumeric, and contain only lowercase letters, numbers, forward slashes, underscores, hyphens, and periods."
  }
}

variable "tags" {
  description = "Tags to apply to the repository."
  type        = map(string)
  default     = {}
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. IMMUTABLE is recommended for production."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "If true, deletes the repository even if it contains images."
  type        = bool
  default     = false
}

# Encryption Configuration
variable "encryption_type" {
  description = "Encryption type for the repository (AES256 or KMS)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption. Required when encryption_type is KMS."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-zA-Z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a valid KMS key ARN."
  }
}

# Lifecycle Policy
variable "enable_lifecycle_policy" {
  description = "Whether to create a lifecycle policy for the repository."
  type        = bool
  default     = false
}

variable "lifecycle_policy_json" {
  description = "Custom lifecycle policy document. If null and enable_lifecycle_policy is true, uses keep_image_count."
  type        = string
  default     = null

  validation {
    condition     = var.lifecycle_policy_json == null || can(jsondecode(var.lifecycle_policy_json))
    error_message = "lifecycle_policy_json must be valid JSON."
  }
}

variable "keep_image_count" {
  description = "Number of recent images to keep when using default lifecycle policy."
  type        = number
  default     = 30

  validation {
    condition     = var.keep_image_count >= 1 && var.keep_image_count <= 1000
    error_message = "keep_image_count must be between 1 and 1000."
  }
}

variable "expire_untagged_after_days" {
  description = "Number of days after which untagged images expire. Set to 0 to disable."
  type        = number
  default     = 14

  validation {
    condition     = var.expire_untagged_after_days >= 0 && var.expire_untagged_after_days <= 365
    error_message = "expire_untagged_after_days must be between 0 and 365."
  }
}

# Repository Policy
variable "create_repository_policy" {
  description = "Whether to create a repository policy."
  type        = bool
  default     = false
}

variable "repository_policy_json" {
  description = "Custom repository policy document in JSON format."
  type        = string
  default     = null

  validation {
    condition     = var.repository_policy_json == null || can(jsondecode(var.repository_policy_json))
    error_message = "repository_policy_json must be valid JSON."
  }
}

variable "repository_read_access_arns" {
  description = "List of IAM principal ARNs that can pull images from the repository."
  type        = list(string)
  default     = []
}

variable "repository_read_write_access_arns" {
  description = "List of IAM principal ARNs that can push and pull images from the repository."
  type        = list(string)
  default     = []
}

variable "cross_account_access_arns" {
  description = "List of AWS account ARNs for cross-account pull access."
  type        = list(string)
  default     = []
}
