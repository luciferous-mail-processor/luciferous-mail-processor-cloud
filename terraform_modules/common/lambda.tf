locals {
  lambda = {
    runtime = "python3.12"
  }
}

# ================================================================
# Lambda Deploy Package
# ================================================================

data "archive_file" "lambda_deploy_package" {
  type        = "zip"
  output_path = "lambda_deploy_package.zip"
  source_dir  = "${path.root}/src"
}

resource "aws_s3_object" "lambda_deploy_package" {
  bucket = aws_s3_bucket.lambda_artifacts.bucket
  key    = "lambda_deploy_package.zip"
  source = data.archive_file.lambda_deploy_package.output_path
  etag   = data.archive_file.lambda_deploy_package.output_md5
}

# ================================================================
# Lambda Error Processor
# ================================================================

module "lambda_error_processor" {
  source = "../lambda_function_basic"

  identifier = "error_processor"
  handler    = "handlers/error_processor/error_processor.handler"
  role_arn   = aws_iam_role.lambda_error_processor.arn
  layers     = [var.layer_arn_base]

  environment_variables = {
    SYSTEM_NAME    = var.system_name
    EVENT_BUS_NAME = aws_cloudwatch_event_bus.slack_error_notifier.name
  }

  s3_bucket_deploy_package = aws_s3_object.lambda_deploy_package.bucket
  s3_key_deploy_package    = aws_s3_object.lambda_deploy_package.key
  source_code_hash         = data.archive_file.lambda_deploy_package.output_base64sha256
  system_name              = var.system_name
  runtime                  = local.lambda.runtime
  region                   = var.region
}

resource "aws_lambda_permission" "error_processor" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_error_processor.function_arn
  principal     = "logs.amazonaws.com"
}

# ================================================================
# Lambda Mail Analyzer
# ================================================================

module "lambda_mail_analyzer" {
  source = "../lambda_function"

  identifier = "mail_analyzer"
  handler    = "handlers/mail_analyzer/mail_analyzer.handler"
  role_arn   = aws_iam_role.lambda_mail_analyzer.arn
  layers     = [var.layer_arn_base]
  timeout    = aws_sqs_queue.mail_analyzer.visibility_timeout_seconds

  environment_variables = {
    TABLE_ADDRESSES = aws_dynamodb_table.mail_addresses.name
    TABLE_MAILS     = aws_dynamodb_table.mails.name
  }

  s3_bucket_deploy_package = aws_s3_object.lambda_deploy_package.bucket
  s3_key_deploy_package    = aws_s3_object.lambda_deploy_package.key
  source_code_hash         = data.archive_file.lambda_deploy_package.output_base64sha256
  system_name              = var.system_name
  runtime                  = local.lambda.runtime
  region                   = var.region

  subscription_destination_lambda_arn = module.lambda_error_processor.function_arn
}


resource "aws_lambda_event_source_mapping" "mail_analyzer" {
  function_name    = module.lambda_mail_analyzer.function_alias_arn
  event_source_arn = aws_sqs_queue.mail_analyzer.arn
  batch_size       = 1

  scaling_config {
    maximum_concurrency = 20
  }
}
