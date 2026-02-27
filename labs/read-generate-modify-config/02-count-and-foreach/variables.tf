variable "webservers_list" {
  type    = list(string)
  default = ["web1", "web2", "web3", "web1"]
}

variable "webservers_set" {
  type    = set(string)
  default = ["web1", "web2", "web3"]
}
