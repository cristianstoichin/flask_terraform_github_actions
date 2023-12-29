resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.application}-${var.environment}"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode != "PROVISIONED" ? null : "${var.read_capacity}"
  write_capacity = var.billing_mode != "PROVISIONED" ? null : "${var.write_capacity}"

  hash_key  = var.hash_key
  range_key = var.range_key != "" ? var.range_key : null

  ttl {
    attribute_name = "expiration"
    enabled        = true
  }

  # Define the rest of the attributes using the for_each loop
  dynamic "attribute" {
    for_each = var.attribute_sets
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery { enabled = true }
  server_side_encryption { enabled = true }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      hash_key = global_secondary_index.value.hash_key
      range_key = global_secondary_index.value.range_key != "" ? global_secondary_index.value.range_key : null
      name = global_secondary_index.value.index_name
      read_capacity   = var.billing_mode != "PROVISIONED" ? null : "${var.read_capacity}"
      write_capacity  = var.billing_mode != "PROVISIONED" ? null : "${var.write_capacity}"
      projection_type = var.projection_type
    }
  }

  tags = var.tags
}