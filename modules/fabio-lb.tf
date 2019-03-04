# Create Public IP Address for the Load Balancer
resource "azurerm_public_ip" "fabio-lb-pip" {
  count               = 1
  name                = "${var.resource_group}-fabio-lb-pip"
  resource_group_name = "${azurerm_resource_group.demostack.name}"
  location            = "${var.location}"
  allocation_method   = "Static"
  domain_name_label   = "${var.hostname}-lb-${count.index}"
  sku                 = "Standard"

  tags {
    name      = "Guy Barros"
    ttl       = "13"
    owner     = "guy@hashicorp.com"
    demostack = "${local.consul_join_tag_value}"
  }
}

# create and configure Azure Load Balancer

resource "azurerm_lb" "fabio-lb" {
  name                = "${var.resource_group}-fabio-lb"
  resource_group_name = "${azurerm_resource_group.demostack.name}"
  location            = "${var.location}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.resource_group}-frontendip"
    public_ip_address_id = "${azurerm_public_ip.fabio-lb-pip.id}"
  }

  tags {
    name      = "Guy Barros"
    ttl       = "13"
    owner     = "guy@hashicorp.com"
    demostack = "${local.consul_join_tag_value}"
  }
}

resource "azurerm_lb_probe" "fabio-lb-probe" {
  name                = "${var.resource_group}-fabio-lb-probe"
  resource_group_name = "${azurerm_resource_group.demostack.name}"
  loadbalancer_id     = "${azurerm_lb.fabio-lb.id}"
  protocol            = "http"
  port                = "9998"
  request_path        = "/health"
  number_of_probes    = "1"
}

resource "azurerm_lb_rule" "fabio-lb-rule" {
  name                           = "${var.resource_group}-fabio-lb-rule"
  resource_group_name            = "${azurerm_resource_group.demostack.name}"
  loadbalancer_id                = "${azurerm_lb.fabio-lb.id}"
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "9999"
  frontend_ip_configuration_name = "${var.resource_group}-fabio-lb-pip"
  probe_id                       = "${azurerm_lb_probe.fabio-lb-probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.fabio-lb-pool.id}"
  depends_on                     = ["azurerm_lb_probe.fabio-lb-probe", "azurerm_lb_backend_address_pool.fabio-lb-pool"]
}

resource "azurerm_lb_backend_address_pool" "fabio-lb-pool" {
  name                = "${var.resource_group}-fabio-lb-pool"
  resource_group_name = "${azurerm_resource_group.demostack.name}"
  loadbalancer_id     = "${azurerm_lb.fabio-lb.id}"
}