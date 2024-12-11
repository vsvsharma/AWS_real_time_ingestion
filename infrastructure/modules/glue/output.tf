output "glue_database_name" {
  value = [for db in aws_glue_catalog_database.databases : db.name]
}

output "glue_table_name" {
  value = [for tbl in aws_glue_catalog_table.glue_tables : tbl.name]
}

output "extraction_glue_database_name" {
  value = aws_glue_catalog_database.databases["extraction_database"].name
}

output "extraction_glue_table_name" {
  value = aws_glue_catalog_table.glue_tables["extraction_table"].name
}

# modules/glue/outputs.tf
output "raw_data_layer_crawler_name" {
  value = aws_glue_crawler.raw_data_layer_crawler["raw_layer_crawler"].name
}

