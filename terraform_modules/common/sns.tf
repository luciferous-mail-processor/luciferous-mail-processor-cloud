# ================================================================
# Topic Catch Error ErrorProcessor
# ================================================================

resource "aws_sns_topic" "catch_error_lambda_error_processor" {
  name_prefix = "catch_error_lambda_error_processor_"
}
