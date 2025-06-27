output "user_create_dns" {
  value = module.user_create.lb_dns
}

output "user_read_dns" {
  value = module.user_read.lb_dns
}

output "user_update_dns" {
  value = module.user_update.lb_dns
}

output "user_delete_dns" {
  value = module.user_delete.lb_dns
}
