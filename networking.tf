resource "aws_vpc" "nextcloudVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "nextcloudVpc"
  }
}

resource "aws_subnet" "publicSubnet1" {
    vpc_id = aws_vpc.nextcloudVpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = var.az1
    map_public_ip_on_launch = true

    tags = {
      name = "publicSubnet1"
    }
}

resource "aws_subnet" "publicSubnet2" {
    vpc_id = aws_vpc.nextcloudVpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = var.az2
    map_public_ip_on_launch = true

    tags = {
      name = "publicSubnet2"
    }
}

resource "aws_subnet" "privateSubnet1" {
    vpc_id = aws_vpc.nextcloudVpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = var.az1


    tags = {
      name = "privateSubnet1"
    }
}

resource "aws_subnet" "privateSubnet2" {
    vpc_id = aws_vpc.nextcloudVpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = var.az1

    tags = {
      name = "privateSubnet2"
    }
}

resource "aws_internet_gateway" "nextcloudInternetGateway" {
  vpc_id = aws_vpc.nextcloudVpc.id

  tags = {
    Name = "netcloud-igw"
  }
}

resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.nextcloudVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextcloudInternetGateway.id
  }
}

resource "aws_route_table_association" "routeTableAssociation1" {
    route_table_id = aws_route_table.publicRouteTable.id
    subnet_id = aws_subnet.publicSubnet1.id
}

resource "aws_route_table_association" "routeTableAssociation2" {
    route_table_id = aws_route_table.publicRouteTable.id
    subnet_id = aws_subnet.publicSubnet2.id
}

resource "aws_eip" "eipNat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eipNat.id
  subnet_id = aws_subnet.publicSubnet2.id
}

resource "aws_route_table" "privateRouteTable" {
    vpc_id = aws_vpc.nextcloudVpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }
}

resource "aws_route_table_association" "privateRouteTableAssociation1" {
    subnet_id = aws_subnet.privateSubnet1.id
    route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_route_table_association" "privateRouteTableAssociation2" {
    subnet_id = aws_subnet.privateSubnet2.id
    route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_security_group" "bastionSG" {
    name = "bastionSecurityGroup"
    vpc_id = aws_vpc.nextcloudVpc.id
}

resource "aws_security_group_rule" "sshInbound" {
type = "ingress"
from_port = "22"
to_port = "22"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
security_group_id = aws_security_group.bastionSG.id
}

resource "aws_security_group_rule" "downloads" {
    type = "egress"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.bastionSG.id
  
}