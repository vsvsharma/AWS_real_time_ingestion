provider "aws" {

}
# #calling ecr module
module "ecr" {
  source    = "./modules/ecr"
  repo_name = "extraction-ecr-repo"
}
resource "null_resource" "run_shell_script" {
  provisioner "local-exec" {
    command = "sh /home/varuns/personal/AWS_real_time_ingestion/code/docker_shell_script.sh"
  }
  depends_on = [module.ecr]
}

# # calling IAM-Role module
module "iam" {
  source             = "./modules/iam"
  lambda_role_name   = "lambda_docker_execution_role"
  firehose_role_name = "firehose_execution_role"
  glue_role_name     = "glue_execution_role"
}

# #calling lambda module
module "lambda" {
  depends_on      = [null_resource.run_shell_script]
  source          = "./modules/lambda"
  function_name   = "user-data-api-extraction"
  role_arn        = module.iam.lambda_role_arn
  image_uri       = "${module.ecr.repository_url}:latest"
  event_rule_name = "lambda-schedule-rule"
}

#calling glue module
module "glue" {
  depends_on    = [module.s3]
  source        = "./modules/glue"
  databases = toset([for table in var.tables : table.database])
  tables    = var.tables
  crawlers = {
    raw_layer_crawler = {
      name          = "raw-layer-crawler"
      role_arn      = module.iam.glue_role_arn
      database_name = "extraction_database"
      s3_target     = "s3://${module.s3.s3_bucket_name}/"
      schedule      = var.raw_layer_crawler_schedule # Every day at 1:00 AM
    }
    transform_layer_crawler = {
      name          = "transform-layer-crawler"
      role_arn      = module.iam.glue_role_arn
      database_name = "transform_layer_database"
      s3_target     = "s3://${module.s3.transform_layer_bucket}/"
      schedule      = var.transform_layer_crawler_schedule # Every day at 2:00 AM
    }
  }
  glue_job_role_arn = module.iam.glue_job_role_arn
}

#calling firehose module
module "firehose" {
  depends_on            = [module.s3, module.glue]
  source                = "./modules/firehose"
  kinesis_firehose_role = module.iam.firehose_role_arn
  s3_bucket_arn         = module.s3.s3_bucket_arn
  #format conversion
  glue_database_name = module.glue.extraction_glue_database_name
  glue_table_name    = module.glue.extraction_glue_table_name
  
}

# #calling S3 module
module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = "user-data-raw-layer"
  s3_transform_bucket ="user-data-transform-layer" 
  glue_job_bucket = "transformation-script-glue-job-bucket"
}