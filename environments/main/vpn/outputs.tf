output "vpnc_eip_id" {
  value = "${aws_eip.vpn_eip.id}"
}

output "vpnc_eip_ip" {
  value = "${aws_eip.vpn_eip.public_ip}"
}