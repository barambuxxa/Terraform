resource "hyperv_network_switch" "dmz_network_switch" { #Создаю виртуальный коммутатор
  name = "lanNet"
}

resource "hyperv_machine_instance" "web_server_g1" { # Создаётся VM
  name                   = "web_server_g1"
  generation             = 1
  processor_count        = 2
  static_memory          = true
  memory_startup_bytes   = 4294967296 # 4ГБ
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10

  vm_processor {
    expose_virtualization_extensions = true #Включаем виртуализацию
  }

  network_adaptors { #Создаём сетевой адаптер и подключаем его к виртуальному коммутатору
    name         = "wan"
    switch_name  = hyperv_network_switch.dmz_network_switch.name
    wait_for_ips = false
  }

  hard_disk_drives { # Подключаем vhdx с установленной Ubuntu
    controller_type     = "Ide"
    path                = "D:\\VM\\test\\web_server_g1.vhdx"
    controller_number   = 0
    controller_location = 0
  }

  lifecycle { # Игнорируем изменение настроек. После развёртки какие то настройки загрузки изменятся, мы игнорируем этот блок
    ignore_changes = [vm_firmware[0].boot_order]
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    #path                = "D:\\ubuntu-24.04.1-live-server-amd64.iso"
  }
}

/*resource "hyperv_vhd" "web_server_g2_vhd" {
  path = "D:\\web_server\\web_server_g2.vhdx" #Needs to be absolute path
  size = 10737418240                          #10GB
}

resource "hyperv_machine_instance" "web_server_g2" {
  name                   = "web_server_g2"
  generation             = 1
  processor_count        = 2
  static_memory          = true
  memory_startup_bytes   = 4294967296 #512MB
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10

  vm_firmware {
    pause_after_boot_failure = "Off"
  }

  vm_processor {
    expose_virtualization_extensions = true
  }

  network_adaptors {
    name         = "wan"
    switch_name  = hyperv_network_switch.dmz_network_switch.name
    wait_for_ips = false
  }

  hard_disk_drives {
    path                = "D:\\web_server\\web_server_g2.vhdx"
    controller_number   = 0
    controller_location = 0
  }

  lifecycle {
    ignore_changes = [vm_firmware[0].boot_order]
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = "D:\\ubuntu-24.04.1-live-server-amd64.iso"
  }

  */
