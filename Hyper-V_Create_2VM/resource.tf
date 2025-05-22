resource "hyperv_network_switch" "dmz_network_switch" {    #Создаём виртуальный коммутатор в Hyper-V
  name = "lanNet"
}

resource "hyperv_vhd" "web_server_g1_vhd" {
  path = "D:\\web_server\\web_server_g1.vhdx" #Needs to be absolute path
  size = 15737421824                          #Создаём динамический диск объёмомо 15Гб
}

resource "hyperv_machine_instance" "web_server_g1" {
  name                   = "web_server_g1"
  generation             = 1
  processor_count        = 2
  static_memory          = true
  memory_startup_bytes   = 4294967296 # 4ГБ 
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10

  vm_processor {
    expose_virtualization_extensions = true  #Включаем виртуализацию
  }

  network_adaptors {							#Создаём сетевой адаптер привязанный к виртуальному коммутатору
    name         = "wan"
    switch_name  = hyperv_network_switch.dmz_network_switch.name
    wait_for_ips = false
  }

  hard_disk_drives {							# Подключаем ранее созданный динамический диск
    controller_type     = "Ide"
    path                = "D:\\web_server\\web_server_g1.vhdx"
    controller_number   = 0
    controller_location = 0
  }

  lifecycle {
    ignore_changes = [vm_firmware[0].boot_order]
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    #path = "ubuntu.iso"
  }
}

resource "hyperv_vhd" "web_server_g2_vhd" {
  path = "D:\\web_server\\web_server_g2.vhdx" #Needs to be absolute path
  size = 10737418240                          #10GB
}

resource "hyperv_machine_instance" "web_server_g2" {			#Вторая VM
  name                   = "web_server_g2"
  generation             = 1
  processor_count        = 2
  static_memory          = true
  memory_startup_bytes   = 4294967296 #4Гб
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10

  vm_firmware {
    pause_after_boot_failure = "Off"					#Если VM не запустится, то будем продолжать запуск
  }

  vm_processor {
    expose_virtualization_extensions = true
  }

  network_adaptors {							# Подключаем сетевой адаптер
    name         = "wan"
    switch_name  = hyperv_network_switch.dmz_network_switch.name
    wait_for_ips = false
  }

  hard_disk_drives {							# Подключаем ранее созданный динамический диск
    path                = "D:\\web_server\\web_server_g2.vhdx"
    controller_number   = 0
    controller_location = 0
  }

  lifecycle {								# Так как после развёртывания VM, будут новые настройки, что бы он повторно не созавал 2VM, включено игнорирвоание
    ignore_changes = [vm_firmware[0].boot_order]
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    #path = "ubuntu.iso"
  }
}
