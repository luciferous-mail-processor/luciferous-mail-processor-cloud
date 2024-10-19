resource "aws_dynamodb_table" "mail_addresses" {
  name         = "mail_addresses"
  hash_key     = "address"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "address"
    type = "S"
  }
}

resource "aws_dynamodb_table" "mails" {
  name         = "mails"
  hash_key     = "to"
  range_key    = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "to"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}
