terraform {
  backend "s3" {
    bucket       = "it-tools-terraform-state-343253677532"
    key          = "it-tools/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}