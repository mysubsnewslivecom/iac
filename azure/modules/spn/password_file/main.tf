# resource "null_resource" "write_sp_password" {
#   depends_on = [var.password_resource]

#   provisioner "local-exec" {
#     command = <<EOT
# cat > ${var.spn_name}.json <<EOF
# {
#   "spn_name": "${var.spn_name}",
#   "client_id": "${var.client_id}",
#   "client_secret": "${var.password_value}"
# }
# EOF
# EOT
#     when    = create
#   }

#   provisioner "local-exec" {
#     command = "rm -f ${var.spn_name}.json"
#     when    = destroy
#   }
# }

resource "local_file" "spn_credentials" {
  filename = "secrets/${var.spn_name}.json"
  content = jsonencode({
    spn_name      = var.spn_name
    client_id     = var.client_id
    client_secret = var.password_value
  })
}
