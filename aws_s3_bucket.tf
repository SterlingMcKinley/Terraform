# ======================================================================
# CONFIGURATION FILE NAME: main.tf (file will be rename to main.tf when applied)
# Description: Terraform declarative file to configure an S3 bucket
#
# REVISION HISTORY: N/A
#
# AUTHOR		   DATE			DETAILS
# --------------------- --------------- --------------------------------
# Sterling McKinley	 2022-10-15	  Initial version
# --------------------- --------------- --------------------------------

variable "aws_access_key" {}
variable "aws_secret_key" {}


provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region  = "us-east-1"

}


resource "aws_s3_bucket" "first_bucket" {
  bucket = "bottomlessbucket20221015"

}

resource "aws_s3_bucket_acl" "bucket_acl01" {
  bucket = aws_s3_bucket.first_bucket.id
  acl    = "private"
