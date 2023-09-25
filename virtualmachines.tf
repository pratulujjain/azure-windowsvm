resource "azurerm_network_interface" "appinterface" {
  count = var.number_of_machines
  name                = "appinterface${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip[count.index].id
  }
  depends_on = [
    azurerm_subnet.subnets,
    azurerm_public_ip.appip
  ]
}

resource "azurerm_public_ip" "appip" {
  count = var.number_of_machines
  name                = "app-ip${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  depends_on = [ 
    azurerm_resource_group.appgrp
   ]
}

# resource "azurerm_linux_virtual_machine" "appvm" {
#   count = var.number_of_machines
#   name                = "appvm${count.index}"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   size                = "Standard_B1s"
#   admin_username      = "linuxusr"
#   network_interface_ids = [
#     azurerm_network_interface.appinterface[count.index].id   
#   ]

#   admin_ssh_key {
#     username = "linuxusr"
#     public_key = tls_private_key.linuxkey.public_key_openssh
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }

#   depends_on = [ 
#     azurerm_network_interface.appinterface, 
#     azurerm_resource_group.appgrp,
#     tls_private_key.linuxkey    
#    ]

# }


resource "azurerm_windows_virtual_machine" "appvm" {
  count = var.number_of_machines
  name                = "appvm${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
#   admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.appinterface[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appinterface,
    azurerm_resource_group.appgrp
  ]
}