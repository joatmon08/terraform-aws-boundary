variable "boundary_lb" {
    type = string
    description = "Boundary URL"
}

check "health_check" {
  data "http" "boundary" {
    url = "http://${var.boundary_lb}:9200"
  }

  assert {
    condition = data.http.boundary.status_code == 200
    error_message = "${data.http.boundary.url} returned an unhealthy status code"
  }
}