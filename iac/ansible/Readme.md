1. instalar maquina virtual en KVM  con sistema operativo ubuntu server

2. Crear par de llaves ssh

3. Establecer comunicaciòn por llaves entre el nodo de control de ansible y el host donde se va aejecutar el playbook 

4. Comando para ejecutar el playbook 

* ansible-playbook -i ./iac/ansible/inventory/hosts.ini ./iac/ansible/playbooks/minikube.yml -K

