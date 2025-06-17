aws_region             = "ap-south-1"

vpc_cidr               = "10.0.0.0/16"

public_subnet_cidr_a   = "10.0.1.0/24"
public_subnet_cidr_b   = "10.0.2.0/24"
private_subnet_cidr_a  = "10.0.3.0/24"
private_subnet_cidr_b  = "10.0.4.0/24"

public_subnet_az_a     = "ap-south-1a"
public_subnet_az_b     = "ap-south-1b"
private_subnet_az_a    = "ap-south-1a"
private_subnet_az_b    = "ap-south-1b"

ami_id                 = "ami-021a584b49225376d"  # Example: Amazon Linux 2
instance_type          = "t2.micro"
key_name               = "vam"                   # Your key name without `.pem`

db_name                = "intel"
db_username            = "intel"
db_password            = "intel123"
