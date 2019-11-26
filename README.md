# cloud-hibrida
O projeto cria uma nuvem hibrida utilizando a AWS EC2 e Openstack.

O script e feito utilizando o Terraform para subir toda a infraestrutuda, essa consiste em um autoscaling para os webServers e um openVPN, em nuvem publica e um webServer e um banco de dados, em nuvem privada.

![](cloud.png)

## Preparando o ambiente
- Montar o ambiente dentro do MaaS
- Baixar o terraform
  https://www.terraform.io/downloads.html
- Adicionar ao path
- Instalar o Aws-CLI e adicionar as credenciais
```
$ sudo apt install aws-cli 
$ aws configure
```
- Iniciar as credenciais do openstack

```
$ source openrc
```

## Iniciando o terraform

- Adicionar sua chave publica em variables.tf
- Iniciar o terraform

```
$ terraform init
$ terraform apply
```

## Criar a variavel de ambiente referente ao DNS do load balancer

  Para rodar o client, e preciso exportar a variavel de ambiente apiAPS
  
  O DNS do loadbalancer sera mostrado no final do script do terraform.
  
  ```
    $ export apiAPS=#IP_LOADBALANCER
  ```
