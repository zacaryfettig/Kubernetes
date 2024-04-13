data "aws_ami" "ubuntu" {
    most_recent = true

filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

filter {
  name = "virtualization-type"
  values = ["hvm"]
}

owners = ["099720109477"]
}

data "aws_key_pair" "ec2Keypair" {
    key_name = "keypair1"
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = data.aws_key_pair.ec2Keypair.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.publicSubnet1.id
  vpc_security_group_ids = [aws_security_group.bastionSG.id]
  iam_instance_profile = aws_iam_instance_profile.instanceProfileForEC2.name

user_data = <<EOF
#!/bin/bash
sudo su
mkdir /KubernetesFiles
sudo apt install unzip
sudo curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
sudo unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo snap install aws-cli --classic
sudo aws s3 cp s3://${local.bastionFilesBucketName} /KubernetesFiles --recursive
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
EOF

depends_on = [ aws_s3_bucket.bastionFiles,
aws_iam_instance_profile.instanceProfileForEC2 
]
}


resource "aws_iam_role" "s3IamRole" {
  name = "s3IamRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "instanceProfileForEC2" {
name = "instanceProfileForEC2"
role = aws_iam_role.s3IamRole.name
}

resource "aws_iam_policy_attachment" "s3SSM" {
  name = "workerNodeRolePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles = [aws_iam_role.s3IamRole.name]
}

resource "aws_iam_policy_attachment" "S3ReadAccessAttachment" {
  name = "S3ReadAccessAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  roles = [aws_iam_role.s3IamRole.name]
}