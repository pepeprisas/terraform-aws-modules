output "arn" {
  value = aws_msk_cluster.msk.arn
}

output "brokers" {
  value = aws_msk_cluster.msk.bootstrap_brokers
}

output "zookeeper" {
  value = aws_msk_cluster.msk.zookeeper_connect_string
}