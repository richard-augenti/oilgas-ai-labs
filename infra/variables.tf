variable "region" {
  description = "AWS region for the training environment."
  type        = string
  default     = "us-east-1"
}

variable "learner_count" {
  description = <<-EOT
    Number of notebook instances to create — one per learner.
    Deliberately defaults to 2 so a `terraform apply` with no tfvars provisions a
    dry run, not a full classroom. Set this explicitly before delivery.
  EOT
  type        = number
  default     = 2

  validation {
    condition     = var.learner_count >= 1 && var.learner_count <= 100
    error_message = "learner_count must be between 1 and 100."
  }
}

variable "name_prefix" {
  description = "Prefix for instance names. Instances are named <prefix>-01, <prefix>-02, ..."
  type        = string
  default     = "oilgas-lab"
}

variable "instance_type" {
  description = <<-EOT
    SageMaker notebook instance type. ml.t3.medium is $0.0500/hr in us-east-1
    (verified against the AWS Price List API) and is ample for CSV-scale lab work.
  EOT
  type        = string
  default     = "ml.t3.medium"
}

variable "volume_size" {
  description = "EBS volume size in GB per instance. 5 GB is the minimum and is plenty for CSV labs."
  type        = number
  default     = 5

  validation {
    condition     = var.volume_size >= 5 && var.volume_size <= 16384
    error_message = "volume_size must be between 5 and 16384 GB."
  }
}

variable "repo_url" {
  description = "HTTPS URL of the labs repository cloned into every instance at launch."
  type        = string
  default     = "https://github.com/richard-augenti/oilgas-ai-labs.git"
}

variable "dataset_url" {
  description = <<-EOT
    Optional. A direct-download dataset URL fetched onto each instance at start, so
    learners are not all pulling it over conference wifi at the same time.

    Leave empty ("") to skip. No lifecycle configuration is created when empty.

    For Lab 1 the verified URL is:
      https://gdr.openei.org/files/1113/Well_58-32_processed_pason_log.csv
    (Utah FORGE Well 58-32, CC BY 4.0, 1.24 MB, 7,310 rows). Left unset by default
    because the Lab 1 dataset selection is not yet confirmed.
  EOT
  type        = string
  default     = ""
}

variable "root_access" {
  description = "Whether learners get root on the instance. Disabled keeps the environment closer to a managed workstation."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.root_access)
    error_message = "root_access must be either Enabled or Disabled."
  }
}
