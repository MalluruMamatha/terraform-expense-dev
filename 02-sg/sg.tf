module "db" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_discription = "sg for db instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "db"
  
}

module "backend" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_discription = "sg for backend instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "backend"
  
}

module "frontend" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_discription = "sg for frontend instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "frontend"
  
}

module "bastion" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_discription = "sg for bastion instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "bastion"
  
}

module "ansible" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_discription = "sg for ansible instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "ansible"
  
}
###  DB is accepting connections from backend
resource "aws_security_group_rule" "db-backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id      = module.backend.sg_id
  security_group_id = module.db.sg_id 
  }

  resource "aws_security_group_rule" "db-bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id      = module.bastion.sg_id
  security_group_id = module.db.sg_id 
  }

resource "aws_security_group_rule" "backend-frontend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id      = module.frontend.sg_id
  security_group_id = module.backend.sg_id 
  }

  resource "aws_security_group_rule" "backend-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id      = module.bastion.sg_id
  security_group_id = module.backend.sg_id 
  }

  resource "aws_security_group_rule" "backend-ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id      = module.ansible.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id 
  }

resource "aws_security_group_rule" "frontend-public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id 
  }

resource "aws_security_group_rule" "frontend-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id      = module.bastion.sg_id
  security_group_id = module.frontend.sg_id 
  }

resource "aws_security_group_rule" "frontend-ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id      = module.ansible.sg_id
  security_group_id = module.frontend.sg_id 
  }

  resource "aws_security_group_rule" "bastion-public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id 
  }

  resource "aws_security_group_rule" "ansible-public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ansible.sg_id 
  }