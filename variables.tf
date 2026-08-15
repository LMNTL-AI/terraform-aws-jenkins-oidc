# Provider

variable "additional_thumbprints" {
  description = "List of additional thumbprints to add to the thumbprint list. Reference: https://plugins.jenkins.io/oidc-provider/."
  type        = list(string)
  default     = []
}

variable "client_id_list" {
  description = "List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim."
  type        = string

  validation {
    condition     = startswith(var.url, "https://") && !endswith(var.url, "/")
    error_message = "url must start with https:// and must not end with a trailing slash — it is used verbatim as the IAM condition-key prefix."
  }
}

# Jenkins

variable "role_name" {
  description = "The name of the role to be created."
  type        = string
}

variable "role_name_prefix" {
  description = "The name of the role to be created."
  type        = string
  default     = ""
}

# Migration

variable "create_provider" {
  description = "Whether to create a provider resource for migration purpose on existing provider."
  type        = bool
  default     = false
}

# Custom statement

variable "custom_oidc_policy_statement" {
  description = "Whether to create a custom oidc policy statement"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "oidc_policy_name" {
  description = "Whether to overwrite the default jenkins oidc policy name"
  type        = string
  default     = null
}

variable "oidc_policy_description" {
  description = "Whether to define description for jenkins oidc policy"
  type        = string
  default     = null
}

# Trust conditions

variable "allowed_audiences" {
  description = "Audience (aud) values the role trust policy accepts, matched with StringEquals. Defaults (via null) to client_id_list so the trust condition cannot drift from what the provider accepts; set explicitly only to trust a subset of the provider's audiences."
  type        = list(string)
  default     = null

  validation {
    condition     = var.allowed_audiences == null || (length(coalesce(var.allowed_audiences, ["-"])) > 0 && alltrue([for a in coalesce(var.allowed_audiences, []) : a != ""]))
    error_message = "allowed_audiences must be null (inherit client_id_list) or a non-empty list of non-empty strings."
  }
}

variable "allowed_subject_patterns" {
  description = "Subject (sub) patterns the role trust policy accepts, matched with StringLike (supports * and ?). With the Jenkins oidc-provider plugin defaults, sub is the Jenkins job URL, e.g. https://jenkins.example.com/job/Org/job/repo/job/branch/. Prefer wildcard patterns over CloudTrail-observed literals for versioned job paths (a tag job like .../job/v1.216.0/ changes every release). An empty list omits the condition, preserving the previous accept-any-token behavior."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for p in var.allowed_subject_patterns : p != "" && p != "*"])
    error_message = "allowed_subject_patterns entries must be non-empty and must not be a bare \"*\" (which would re-open the trust policy to any token)."
  }
}
