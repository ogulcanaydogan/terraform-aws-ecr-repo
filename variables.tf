variable "name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the repository."
  type        = map(string)
  default     = {}
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (ECR basic scanning)."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "If true, deletes the repository even if it contains images."
  type        = bool
  default     = false
}

variable "enable_lifecycle_policy" {
  description = "Whether to create a lifecycle policy for the repository."
  type        = bool
  default     = false
}

variable "lifecycle_policy_json" {
  description = "Lifecycle policy document to apply when enable_lifecycle_policy is true."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_lifecycle_policy || var.lifecycle_policy_json != null
    error_message = "lifecycle_policy_json must be provided when enable_lifecycle_policy is true."
  }

  validation {
    condition     = var.lifecycle_policy_json == null || can(jsondecode(var.lifecycle_policy_json))
    error_message = "lifecycle_policy_json must be valid JSON."
  }
}
