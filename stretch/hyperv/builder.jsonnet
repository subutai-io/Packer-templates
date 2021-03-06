{
  "type": "hyperv-iso",
  "vm_name": "{{ user `vm_name` }}",
  "boot_command": import ".\\http\\hyperv\\debian-boot.jsonnet",
  "disk_size": "{{user `disk_size`}}",
  "guest_additions_mode": "disable",
  "iso_url": "{{user `iso_url`}}",
  "iso_checksum_type": "{{user `iso_checksum_type`}}",
  "iso_checksum": "{{user `iso_checksum`}}",
  "communicator": "ssh",
  "ssh_username": "{{user `ssh_username`}}",
  "ssh_password": "{{user `ssh_password`}}",	
  "ssh_timeout" : "4h",
  "http_directory": "./http/",
  "boot_wait": "5s",
  "shutdown_command": "echo {{user `ssh_password`}} | sudo -S -E shutdown -P now",
  "ram_size": "{{user `memory`}}",
  "cpu": "{{user `cpus`}}",
  "generation": 1,
  "switch_name": "{{user `hyperv_switchname`}}",
  "enable_secure_boot": false,
  "enable_mac_spoofing": true,
  "enable_dynamic_memory": false,
  "enable_virtualization_extensions": false
}
