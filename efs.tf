/*
resource "aws_efs_file_system" "efs" {
  creation_token = "netcloudK8"
}

resource "aws_efs_mount_target" "efsMountTarget1" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = aws_subnet.publicSubnet1.id
  security_groups = [ aws_security_group.workerNodeSg.id ]
}

resource "aws_efs_mount_target" "efsMountTarget2" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id =  aws_subnet.publicSubnet2.id
  security_groups = [ aws_security_group.workerNodeSg.id ]
}
*/