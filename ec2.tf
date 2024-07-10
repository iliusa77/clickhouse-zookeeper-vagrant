resource "aws_subnet" "subnet" {
  count             = length(var.ec2_availability_zones)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet("${var.cidrsubnet}", 4, count.index)
  availability_zone = var.ec2_availability_zones[count.index]

  tags = {
    Name = "clickhouse-subnet-${count.index}"
  }
}

resource "aws_route_table" "subnet" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "10.5.0.0/16"
    gateway_id =  module.vpc.natgw_ids[0]
  }

  tags = {
    Name = "clickhouse-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.ec2_availability_zones)
  subnet_id      = "${aws_subnet.subnet[count.index].id}"
  route_table_id = "${aws_route_table.subnet.id}"
}

resource "aws_kms_key" "ec2" {
  description         = "KMS key for Clickhouse cluster"
  enable_key_rotation = true
}

resource "aws_kms_alias" "ec2" {
  name          = "alias/clickhouse-ebs-kms-key"
  target_key_id = aws_kms_key.ec2.key_id
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix = "clickhouse-ssh-key"
  public_key      = var.ec2_ssh_public_key

  tags = {
    Name        = "clickhouse-ssh-key"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "remote_access" {
  name_prefix = "clickhouse-remote-access"
  description = "Allow services between Clickhouse nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Zookeeper"
    from_port   = 2181 
    to_port     = 2181 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse HTTP default port"
    from_port   = 8123
    to_port     = 8123
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse HTTP SSL/TLS default port"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Native Protocol port (also referred to as ClickHouse TCP protocol)."
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse MySQL emulation port"
    from_port   = 9004
    to_port     = 9004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse PostgreSQL emulation port (also used for secure communication if SSL is enabled for ClickHouse)."
    from_port   = 9005
    to_port     = 9005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Inter-server communication port for low-level data access. Used for data exchange, replication, and inter-server communication."
    from_port   = 9009
    to_port     = 9009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse SSL/TLS for inter-server communications"
    from_port   = 9010
    to_port     = 9010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Native protocol PROXYv1 protocol port"
    from_port   = 9011
    to_port     = 9011
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse JDBC bridge"
    from_port   = 9019
    to_port     = 9019
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse gRPC port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Recommended ClickHouse Keeper port"
    from_port   = 9181
    to_port     = 9181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Recommended ClickHouse Keeper Raft port"
    from_port   = 9234
    to_port     = 9234
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Prometheus default metrics port"
    from_port   = 9363
    to_port     = 9363
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Recommended Secure SSL ClickHouse Keeper port"
    from_port   = 9281
    to_port     = 9281
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Native protocol SSL/TLS port"
    from_port   = 9440
    to_port     = 9440
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Clickhouse Graphite default port"
    from_port   = 42000
    to_port     = 42000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "clickhouse-cluster-access"
    Environment = "${var.env}"
  }
}

resource "aws_instance" "ec2" {
  count                   = length(var.ec2_availability_zones)
  ami                     = var.ec2_ami
  instance_type           = var.ec2_instance_type
  subnet_id               = aws_subnet.subnet[count.index].id
  key_name                = module.key_pair.key_pair_name
  #disable_api_termination = false
  security_groups = [aws_security_group.remote_access.id]

  root_block_device {
    volume_size           = var.ec2_ebs_size
    volume_type           = var.ec2_ebs_type
    encrypted             = true
    kms_key_id            = aws_kms_key.ec2.arn
    #delete_on_termination = false
  }

#   user_data  = templatefile("./ec2_user_data.sh", {
#     clickhouse-shard-0-private_ip = "${aws_instance.ec2[0].private_ip}"
#     clickhouse-shard-1-private_ip = "${aws_instance.ec2[1].private_ip}"
#     clickhouse-shard-2-private_ip = "${aws_instance.ec2[2].private_ip}"
#   })


  tags = {
    Name = "clickhouse-shard-${count.index}"
  }
}

