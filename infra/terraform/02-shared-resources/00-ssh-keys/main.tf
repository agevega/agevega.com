resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file(var.public_key_path)

  tags = merge(var.common_tags, {
    Name = "bastion-key"
  })
}
