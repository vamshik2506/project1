resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.public_subnet_az_a
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.public_subnet_az_b
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.private_subnet_az_a
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = var.private_subnet_az_b
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow all traffic temporarily"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL access from EC2 SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

 user_data = <<-EOF
  #!/bin/bash -ex

  apt update && apt upgrade -y

  apt install -y software-properties-common gnupg2 curl unzip apache2

  
  add-apt-repository ppa:ondrej/php -y
  apt update
  apt install -y php5.6 php5.6-mysqli mysql-client

  systemctl enable apache2
  systemctl start apache2

  rm -f /var/www/html/index.html

  cat > /var/www/html/index.php <<PHP
  <?php
  \$servername = "${aws_db_instance.mysql.address}";
  \$username = "${var.db_username}";
  \$password = "${var.db_password}";
  \$dbname = "${var.db_name}";

  \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);
  if (\$conn->connect_error) {
      die("Connection failed: " . \$conn->connect_error);
  }

  \$sql = "CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL
  )";
  \$conn->query(\$sql);

  if (\$_SERVER["REQUEST_METHOD"] == "POST") {
      \$name = \$_POST["name"];
      \$email = \$_POST["email"];
      \$stmt = \$conn->prepare("INSERT INTO users (name, email) VALUES (?, ?)");
      \$stmt->bind_param("ss", \$name, \$email);
      \$stmt->execute();
      \$stmt->close();
      echo "Data inserted successfully!";
  }

  \$conn->close();
  ?>
  <form method="post">
      Name: <input type="text" name="name" required><br>
      Email: <input type="email" name="email" required><br>
      <input type="submit" value="Submit">
  </form>
  PHP

  systemctl restart apache2
  cd /var/www/html/
  ls
  systemctl status apache2
EOF

  tags = {
    Name = "PHP-App-Server"
  }
}

resource "aws_lb" "alb" {
  name               = "php-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.ec2_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "php-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
