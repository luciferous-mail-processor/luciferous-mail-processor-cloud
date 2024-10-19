# ================================================================
# Lambda Artifacts Bucket
# ================================================================

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket_prefix = "lambda-artifacts-"
}

# ================================================================
# Bucket Mailbox
# ================================================================

resource "aws_s3_bucket" "mailbox" {
  bucket_prefix = "mailbox-"
}

data "aws_iam_policy_document" "bucket_policy_mailbox" {
  policy_id = "bucket_policy_mailbox"
  statement {
    sid    = "bucket_policy_mailbox"
    effect = "Allow"
    principals {
      identifiers = ["ses.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.mailbox.arn}/*"]

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }

    condition {
      test     = "StringEquals"
      values   = ["${aws_ses_receipt_rule_set.mailbox.arn}:receipt-rule/${local.ses.receipt_rule_name}"]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "mailbox" {
  bucket = aws_s3_bucket.mailbox.bucket
  policy = data.aws_iam_policy_document.bucket_policy_mailbox.json
}

resource "aws_s3_bucket_notification" "mailbox" {
  bucket = aws_s3_bucket.mailbox.id

  queue {
    events        = ["s3:ObjectCreated:*"]
    queue_arn     = aws_sqs_queue.mail_analyzer.arn
    filter_prefix = local.ses.s3_action.prefix
  }
}