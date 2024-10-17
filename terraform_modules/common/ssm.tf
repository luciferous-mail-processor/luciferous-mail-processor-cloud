resource "aws_ssm_parameter" "receiving_mail_domain" {
  name  = "ReceivingMailDomain"
  type  = "SecureString"
  value = var.receiving_mail_domain
}

resource "aws_ssm_parameter" "slack_incoming_webhook_error_notifier_01" {
  name  = "SlackIncomingWebhookErrorNotifier01"
  type  = "SecureString"
  value = var.slack_incoming_webhook_error_notifier_01
}
