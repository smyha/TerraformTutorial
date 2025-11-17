## Estructura de Directorios

### 00-preface/hello-world-azure
- **Descripción**: Ejemplo simple con una VM básica
- **Recursos**: Resource Group, VNet, Subnet, NIC, Public IP, Linux VM
- **Propósito**: Introducción a Terraform con Azure

### 01-why-terraform/web-server-azure
- **Descripción**: VM con Apache web server
- **Recursos**: Incluye NSG con reglas para HTTP y SSH
- **Propósito**: Demostrar instalación de software con user_data

### 02-intro-to-terraform-syntax/one-server-azure
- **Descripción**: VM con etiquetas/tags
- **Recursos**: Similar a hello-world pero incluye tags
- **Propósito**: Demostrar etiquetado de recursos

### 03-terraform-state/file-layout-example-azure

#### global/storage/
- **Descripción**: Infraestructura para almacenamiento de estado
- **Recursos**: Storage Account (S3 equivalente), Cosmos DB (DynamoDB equivalente)
- **Propósito**: Configurar backend remoto para estado compartido

#### stage/data-stores/mysql/
- **Descripción**: Base de datos MySQL
- **Recursos**: Azure Database for MySQL con firewall rules
- **Propósito**: Demostrar servicio de base de datos gestionado

#### stage/services/webserver-cluster/
- **Descripción**: Cluster escalable de servidores web
- **Recursos**: VMSS, Load Balancer, Autoscaling, NSG
- **Propósito**: Demostrar alta disponibilidad y escalabilidad