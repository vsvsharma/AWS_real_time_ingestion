# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attachment of basic execution policy for Lambda
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Firehose PutRecord Policy(Custom Policy)

resource "aws_iam_policy" "firehose_put_record_policy" {
  name        = "FirehosePutRecordPolicy"
  description = "IAM policy to allow firehose:PutRecord action on the specified Firehose delivery stream."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "firehose:PutRecord",
        "Resource": "arn:aws:firehose:ap-south-1:209757962519:deliverystream/user-data-ingestion-stream"
      }
    ]
  })
}

# Attach_policy_to_role.tf

resource "aws_iam_policy_attachment" "attach_firehose_policy_to_lambda_role" {
  name = "Lambda put record policy attachment"
  roles   = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.firehose_put_record_policy.arn
}


# IAM role for Kinesis-firehose for permission to write to S3

resource "aws_iam_role" "firehose_role" {
  name=var.firehose_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement =[{
      Action = "sts:AssumeRole"
      Effect= "Allow"
      Principal={
        Service="firehose.amazonaws.com"
      }
    }]
  }
  )
}
# Attachment of basic execution policy for Firehose
resource "aws_iam_policy_attachment" "firehose_policy_attachment" {
  name="firehose_policy_attachment"
  roles = [aws_iam_role.firehose_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

# Custom S3 Policy for firehose to access S3 bucket
resource "aws_iam_policy" "firehose_s3_access_policy" {
  name="FirehoseS3AccessPolicy"
  description = "Policy for firehose to access the S3 bucket"

  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Effect= "Allow",
        Action=["s3:PutObject", "s3:PutObjectAcl"],
        Resource="arn:aws:s3:::user-data-raw-layer/*",
      },
      {
        Effect="Allow"
        Action=["s3:GetBucketLocation", "s3:ListBucket"],
        Resource="arn:aws:s3:::user-data-raw-layer"
      }
    ]
  })
}

# Attach Firehose S3 Policy to Firehose role
resource "aws_iam_policy_attachment" "firehose_s3_access_policy_attachment" {
  name = "firehose-s3-access-policy-attachment"
  roles = [aws_iam_role.firehose_role.name]
  policy_arn = aws_iam_policy.firehose_s3_access_policy.arn
}

# IAM role for Glue

resource "aws_iam_role" "glue_role" {
  name=var.glue_role_name
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Action="sts:AssumeRole",
        Effect="Allow",
        Principal={
          Service="glue.amazonaws.com"
        }
      }
    ]
  })
}

#Glue Service Role Policy Attachment
resource "aws_iam_policy_attachment" "glue_policy_attachment" {
  name = "glue-policy-attachment"
  roles = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

#Custom S3 Policy for Glue to access S3 bucket
resource "aws_iam_policy" "glue_s3_access_policy" {
  name = "GlueS3AccessPolicy"
  description = "Policy for glue to access the S3 bucket"

  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Effect="Allow",
        Action=["s3:GetObjects", "s3:ListBucket"],
        Resource=["arn:aws:s3:::user-data-raw-layer","arn:aws:s3:::user-data-raw-layer/*"]
      }
    ]
  })
}

#Attach Glue S3 Access Policy to Glue Role
resource "aws_iam_policy_attachment" "glue_s3_access_policy_attachment" {
  name = "glue-s3-access-policy-attachment"
  roles = [aws_iam_role.glue_role.name]
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}

#Custom policy for Firehose to access the Glue
resource "aws_iam_policy" "firehose_glue_access_policy" {
  name = "FirehoseGlueAccessPolicy"
  description = "Policy for firehose to access the Glue data for data conversion"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "glue:GetTableVersions",
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetDatabase"
        ],
        Resource = "*"
      }
    ]
  })
}

#Attaching Firehose Glue policy to the firehose role
resource "aws_iam_role_policy_attachment" "firehose_glue_access_policy_attachment" {
  policy_arn = aws_iam_policy.firehose_glue_access_policy.arn
  role =aws_iam_role.firehose_role.name
}

#policy for the glue crawler to access both raw and transform layer bucket
resource "aws_iam_policy" "glue_crawler_policy" {
  name = "glue-crawler-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::user-data-raw-layer/*",
          "arn:aws:s3:::user-data-raw-layer",
          "arn:aws:s3:::user-data-transform-layer/*",
          "arn:aws:s3:::user-data-transform-layer"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy attachment to the glue IAM role
resource "aws_iam_policy_attachment" "glue_crawler_policy_attachment" {
  name       = "glue-crawler-policy-attachment"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

#IAM role for the Glue job execution
resource "aws_iam_role" "glue_job_role" {
  name = "glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#Policy for the glue job to execute smoothly without any restriction 
resource "aws_iam_policy" "glue_job_policy" {
  name        = "glue-job-policy"
  description = "Policy for Glue Job Role with S3, Glue Catalog, CloudWatch and Athena access"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetTable",
                "glue:GetTables",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:GetPartitions",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:CreatePartition",
                "glue:UpdatePartition",
                "glue:CreateSession",
                "glue:TagResource",
                "glue:BatchCreatePartition",
                "glue:BatchUpdatePartition"
            ],
            "Resource": [
                "arn:aws:glue:ap-south-1:209757962519:catalog",
                "arn:aws:glue:ap-south-1:209757962519:database/extraction_database",
                "arn:aws:glue:ap-south-1:209757962519:table/extraction_database/*",
                "arn:aws:glue:ap-south-1:209757962519:partition/extraction_database/*",
                "arn:aws:glue:ap-south-1:209757962519:session/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::user-data-raw-layer",
                "arn:aws:s3:::user-data-raw-layer/*",
                "arn:aws:s3:::user-data-transform-layer",
                "arn:aws:s3:::user-data-transform-layer/*",
                "arn:aws:s3:::transformation-script-glue-job-bucket",
                "arn:aws:s3:::transformation-script-glue-job-bucket/*",
                "arn:aws:s3:::aws-glue-temporary",
                "arn:aws:s3:::aws-glue-temporary/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup"
            ],
            "Resource": "arn:aws:logs:ap-south-1:209757962519:log-group:/aws-glue/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "athena:StartQueryExecution",
                "athena:GetQueryExecution",
                "athena:GetQueryResults"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::209757962519:role/glue-job-role"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
})
}

# Attaching the glue job policy to the glue job role
resource "aws_iam_role_policy_attachment" "glue_job_policy_attachment" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}

