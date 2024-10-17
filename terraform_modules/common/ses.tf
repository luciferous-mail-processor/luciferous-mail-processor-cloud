locals {
  ses = {
    receipt_rule_name = "mailbox"
  }
}

resource "aws_ses_receipt_rule_set" "mailbox" {
  rule_set_name = "mailbox"
}

resource "aws_ses_receipt_rule" "mailbox" {
  depends_on    = [aws_s3_bucket_policy.mailbox]
  name          = local.ses.receipt_rule_name  # S3 Bucket Policyで循環参照になってしまうため
  rule_set_name = aws_ses_receipt_rule_set.mailbox.rule_set_name
  recipients    = [var.receiving_mail_domain]
  enabled       = true
  scan_enabled  = false
  tls_policy    = "Optional"

  s3_action {
    bucket_name       = aws_s3_bucket.mailbox.bucket
    position          = 1
    object_key_prefix = "mailbox"
  }
}

resource "aws_ses_active_receipt_rule_set" "mailbox" {
  rule_set_name = aws_ses_receipt_rule_set.mailbox.rule_set_name
}