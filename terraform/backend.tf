# -----------------------------------------------------------
# Remote Backend — stores Terraform state in S3
# This is required so GitHub Actions can access the state
# -----------------------------------------------------------
#
# SETUP (one-time, run manually before terraform init):
#   aws s3 mb s3://YOUR-TFSTATE-BUCKET-NAME --region us-east-1
#   aws dynamodb create-table \
#     --table-name terraform-lock \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST \
#     --region us-east-1
#
# Then update the bucket name below and run: terraform init
# -----------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "website-tfstate-la-bella-cucina-fragrance-1"   # <-- change this
    key            = "restaurant-website/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"             # prevents simultaneous applies
    encrypt        = true
  }
}
