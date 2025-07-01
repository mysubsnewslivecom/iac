# modules/password_file/main.tf
resource "null_resource" "write_sp_password" {
  depends_on = [var.password_resource]

  provisioner "local-exec" {
    command = <<EOT
    echo '[${var.sp_reader_name}]' >> root_token.txt
    echo 'secret=${var.password_value}' >> root_token.txt
    echo 'client_id=${var.client_id}' >> root_token.txt
    EOT
    when    = create
  }

  provisioner "local-exec" {
    command = "rm -rfv root_token.txt"
    when    = destroy
  }
}
