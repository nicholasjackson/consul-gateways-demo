resource "azurerm_resource_group" "consul_demo" {
  name     = "consul-demo"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "demo" {
  name                = "consul-azure"
  location            = azurerm_resource_group.consul_demo.location
  resource_group_name = azurerm_resource_group.consul_demo.name
  dns_prefix          = "consul-azure"

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = "Production"
  }
}
