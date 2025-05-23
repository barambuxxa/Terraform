# Мы тут убираем создание виртуального коммутатор. Я хочу подключить уже созданный коммутатор lanNet. VM запускается с диском, с сетевыми настрйоками которые прописаны static.
#Добавил пользователя sysadmin в sudo, что бы можно было устанавливать пакеты.

resource "hyperv_machine_instance" "web_server_g1_ssh" { #Создаём VM
  name                   = "web_server_g1_ssh"
  generation             = 1
  processor_count        = 2
  static_memory          = true
  memory_startup_bytes   = 4294967296 # 4ГБ
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10

  vm_processor {
    expose_virtualization_extensions = true #Включаем виртуализацию
  }

  network_adaptors {
    name         = "wan"
    switch_name  = "lanNet"
    wait_for_ips = false
  }

  hard_disk_drives { #подгружаю виртуальный жёсткий диск с Ubuntu+dhcp+ssh
    controller_type     = "Ide"
    path                = "D:\\VM\\test\\web_server_g1_ssh_dhcp.vhdx"
    controller_number   = 0
    controller_location = 0
  }

  lifecycle {
    ignore_changes = [vm_firmware[0].boot_order] #Игнорирование блока загрузки
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    #path                = "D:\\ubuntu-24.04.1-live-server-amd64.iso"
  }

  provisioner "remote-exec" { #Удалённые команды которые должны быть исполнены на удалённом сервере
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "echo 'Обновление завершено'",
      "sudo apt-get install -y apache2 php",
      "echo '<?php echo \"<h2>Terraform Web Server</h2><p>IP: \".$_SERVER[\"SERVER_ADDR\"].\"</p><p>Time: \".date(\"Y-m-d H:i:s\").\"</p>\"; ?>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo chmod -R 755 /var/www/html"
    ]

    connection { #Подключение к созданной VM
      type     = "ssh"
      user     = "sysadmin"    # Пользователь в VM
      password = "Spb-170256"  # Пароль или лучше использовать ключ
      host     = "ngnixserver" # Автоматическое получение IP
    }
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
