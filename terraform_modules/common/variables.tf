variable "system_name" {
  type     = string
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "layer_arn_base" {
  type     = string
  nullable = false
}

variable "receiving_mail_domain" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "slack_incoming_webhook_error_notifier_01" {
  type      = string
  nullable  = false
  sensitive = true
}
