output "i3-metal-ip" {
  value = "${aws_instance.metal_instance.public_ip}"
}
