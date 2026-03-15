# dbconf

Автоматическое создание и настройка VM с PostgreSQL/Docker в Proxmox.

**Стек:** Terraform + Ansible

---

Terraform создаёт VM в Proxmox, клонируя шаблон (vm_id 9000), далее Cloud-init настраивает пользователя при первом запуске VM. Terraform регистрирует хост в своём state через ansible_host, а Ansible читает state как динамический inventory и запускает playbook

---

## Использование

### 1. Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# заполнить terraform.tfvars

terraform init
terraform apply
```

### 2. Ansible

```bash
cd ansible
ansible-galaxy collection install cloud.terraform

ansible-playbook -i inventory/hosts.terraform.yml playbooks/db-server-configuration.yml
```

## Переменные (terraform.tfvars)

| Переменная           | Описание                                    |
|----------------------|---------------------------------------------|
| `pm_api_url`         | URL Proxmox API (`https://<ip>:8006/api2/json`) |
| `pm_api_token_id`    | API token ID (`user@pve!tokenname`)          |
| `pm_api_token_secret`| Секрет токена                               |
| `vm_ip`              | Статический IP для VM (`192.168.1.x`)       |
| `vm_user`            | Имя пользователя внутри VM                  |
| `vm_name`            | Имя хоста (используется в Ansible inventory) |


### Памятка

user_account в bpg/proxmox создаёт пользователя через стандартный cloud-init Proxmox — он не поддерживает sudo без пароля. Чтобы добавить NOPASSWD:ALL, нужен кастомный cloud-init сниппет (proxmox_virtual_environment_file с content_type = "snippets"), который передаётся через user_data_file_id.

ansible_host — это Terraform-ресурс, который не создаёт инфраструктуру, а только записывает данные о хосте в Terraform state. Ansible затем читает этот state через inventory plugin cloud.terraform.terraform_provider.

Файл inventory/hosts.terraform.yml — не статический inventory, а конфигурация плагина:
```yaml
plugin: cloud.terraform.terraform_provider
project_path: ../terraform/
```

project_path указывает на папку с terraform.tfstate. Путь относительный — от папки где запускается плейбук.