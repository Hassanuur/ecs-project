module "ecr" {
  source   = "./modules/ecr"
  app_name = var.app_name
}

module "vpc" {
  source   = "./modules/vpc"
  app_name = var.app_name
}

module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  app_domain  = var.app_domain
}

module "alb" {
  source            = "./modules/alb"
  app_name          = var.app_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
}

module "ecs" {
  source                = "./modules/ecs"
  app_name              = var.app_name
  aws_region            = var.aws_region
  container_image       = var.container_image
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.alb.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.app_domain
  type    = "A"
  allow_overwrite = true

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}