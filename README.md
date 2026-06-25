# 🍝 La Bella Cucina – Restaurant Website on AWS

A static restaurant website hosted on **AWS S3**, fully provisioned using **Terraform**.

## Architecture

```
Your Browser → S3 Static Website Endpoint → index.html / menu.html
```

> Week 2 will add CloudFront (CDN + HTTPS) in front of S3.

---

## Prerequisites

Before you start, make sure you have:

1. **AWS Account** – [Sign up free](https://aws.amazon.com/free/)
2. **AWS CLI** installed and configured
   ```bash
   # Install: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
   aws configure   # Enter your Access Key, Secret Key, region (us-east-1)
   ```
3. **Terraform** installed
   ```bash
   # Install: https://developer.hashicorp.com/terraform/install
   terraform -version   # Should show v1.0+
   ```

---

## Project Structure

```
restaurant-website/
├── .github/workflows/       # (Week 3) GitHub Actions pipeline
├── terraform/
│   ├── provider.tf          # AWS provider + Terraform version
│   ├── variables.tf         # Input variables
│   ├── main.tf              # S3 bucket resources
│   ├── outputs.tf           # Website URL output
│   └── terraform.tfvars.example
├── website/
│   ├── index.html           # Homepage
│   ├── menu.html            # Menu page
│   ├── error.html           # 404 page
│   └── style.css            # Stylesheet
├── .gitignore
└── README.md
```

---

## Week 1 – Deploy Steps

### Step 1: Clone and configure

```bash
git clone <your-repo-url>
cd restaurant-website

# Set your bucket name (must be globally unique!)
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars and change bucket_name
```

### Step 2: Initialise Terraform

```bash
cd terraform
terraform init
```

You'll see Terraform download the AWS provider. ✅

### Step 3: Preview what will be created

```bash
terraform plan
```

Read the output — it shows exactly what AWS resources will be created.

### Step 4: Apply (create the infrastructure)

```bash
terraform apply
```

Type `yes` when prompted. Terraform will create:
- ✅ S3 bucket
- ✅ Public access settings
- ✅ Static website configuration
- ✅ Bucket policy (public read)

At the end you'll see:
```
Outputs:
bucket_name = "la-bella-cucina-yourname-2024"
website_url = "http://la-bella-cucina-yourname-2024.s3-website-us-east-1.amazonaws.com"
```

### Step 5: Upload website files

```bash
# From the root of the project
aws s3 sync website/ s3://YOUR_BUCKET_NAME
```

### Step 6: Visit your website 🎉

Open the `website_url` from Step 4 in your browser. Your restaurant is live!

---

## Useful Commands

```bash
# See current state of infrastructure
terraform show

# See output values again
terraform output

# Destroy everything (when you're done testing)
terraform destroy
```

---

## Coming Up

| Week | What you'll add |
|------|----------------|
| Week 2 | CloudFront CDN + HTTPS (free SSL) |
| Week 3 | GitHub Actions — auto-deploy on git push |
| Week 4 | Remote state (S3 + DynamoDB), PR previews |
