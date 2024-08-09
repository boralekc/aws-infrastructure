# Ansible

## Установка
Update Repos
sudo apt update
Install Dependencies
sudo apt install software-properties-common
Add Ansible Repo
sudo add-apt-repository --yes --update ppa:ansible/ansible
Install Ansible
sudo apt install ansible


## Подготовка рабочего места
Для работы с ubuntu wsl в vscode нужно нажать сочетание клавишь Ctrl+Shift+P (или F1), введите Remote-WSL: Reopen Folder in WSL.

## Команды ansible
Проверка установленных модулей 
ansible-galaxy collection list

Установка модуля для работы с k8s 
ansible-galaxy collection install kubernetes.core

## Upload и Download artifacts
Осуществялется с помощью модулей actions/download-artifact@v4 и actions/upload-artifact@v4
Примеры конфигураций
- name: Upload kubeconfig artifact
      uses: actions/upload-artifact@v4
      with:
        name: config
        path: /home/runner/.kube
        retention-days: 10
  
- name: Download kubeconfig artifact
      uses: actions/download-artifact@v4
      with:
        name: config
        path: ${{ github.workspace }}/ansible

## Установка ingress-nginx
Установка производится с использованием модулей ansible-galaxy collection install kubernetes.core.
Для установки нужны следующие данные: 
1. kubeconfig - его формирование происходит с помощью команды yc managed-kubernetes cluster get-credentials --name k8s --folder-id b1g304vc64dm93id6kej --external --force
2. Yandec Cloud config.yaml - он формируется автомматически и находится в директории пользователя под которым выполянется helm для правильного выполнения установок нужно указать в playbook того же пользователя что и в github actions, т.е runner
Пример
name: Deploy to Kubernetes
  hosts: localhost
  connection: local
  gather_facts: no
  become: yes
  become_user: runner 

