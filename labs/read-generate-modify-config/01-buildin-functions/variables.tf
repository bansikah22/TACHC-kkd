variable "server_names" {
  type    = list(string)
  default = ["server1", "server2", "server3"]
}

variable "server_names_map" {
    type = map(string)
    default = {
        #"server1" = "10.0.0.1"
        "server2" = "10.0.0.2"
        "server3" = "10.0.0.3"
    }
}