resource "aws_sqs_queue" "mail_analyzer" {
  visibility_timeout_seconds = 60
}

data "aws_iam_policy_document" "s3_mail_analyzer" {
  policy_id = "S3MailAnalyzer"

  statement {
    sid     = "S3MailAnalyzer"
    effect  = local.iam.effect.allow
    actions = ["sqs:SendMessage"]
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    resources = [aws_sqs_queue.mail_analyzer.arn]
  }
}

resource "aws_sqs_queue_policy" "mail_analyzer" {
  policy    = data.aws_iam_policy_document.s3_mail_analyzer.json
  queue_url = aws_sqs_queue.mail_analyzer.url
}