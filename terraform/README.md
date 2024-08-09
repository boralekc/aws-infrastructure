# terraform

## Структура проекта
В репозитории создана папка modules в которой находятся ресурсы для развертывания:
Хранилище S3
Репозиторий контейнеров docker
Kubernetes
PostgreSQL - создается также 2 dev и prod бд и пользователь.
файл main.tf в корне проекта содержит данные по всем модулям, данные для подключения к облаку и хранилищу state.

## Команды terraform
terraform fmt - команда форматирования кода, автоматически выравнивает и форматирует код;
terraform init - загружает и устанавливает необходимые провайдеры, указанные в файле конфигурации Terraform (provider "..." { ... }), настройка соединения с хранилищем s3, загружает модули;
terraform plan - сравнивает текущее состояние инфраструктуры (хранится в файле состояния) с желаемым состоянием, описанным в файлах конфигурации (.tf файлы), проверка синтаксиса; 
terraform apply - читает файлы конфигурации, вычисляет необходимые изменения для достижения желаемого состояния и применяет их к вашей инфраструктуре.

## Подключение к облаку yandex cloud
1. Для подключения к облаку нужно создать сервисный аккаунт с правами admin, добавить этому сервисному аккаунту авторизационный json ключ и скачать этот ключ;
2. Скопировать содержимое этого ключа;
3. Создать в github secret и вставить содержимое этого ключа в этот секрет;
4. Также добавляем другие секреты сloud_id, folder_id и.др;

Далее для подключения файле terraform.yaml (github actions) используется утилита yc-actions/yc-iam-token@v1 (https://github.com/yc-actions/yc-iam-token) эта утилита использует секрет с json ключем и генерирует iam-токен

- name: IAM Token
      id: issue-iam-token
      uses: yc-actions/yc-iam-token@v1
      with:
        yc-sa-json-credentials: ${{ secrets.YC_SA_JSON_CREDENTIALS }}

Далее экспортируем переменные окружения из секретов, примерно так
- name: Set environment variables from secrets
      run: |
        echo "ACCESS_KEY=${{ secrets.ACCESS_KEY }}" >> $GITHUB_ENV
        echo "SECRET_KEY=${{ secrets.SECRET_KEY }}" >> $GITHUB_ENV
        echo "YC_CLOUD_ID=${{ secrets.YC_CLOUD_ID }}" >> $GITHUB_ENV
        echo "YC_FOLDER_ID=${{ secrets.YC_FOLDER_ID }}" >> $GITHUB_ENV
        echo "DB_USER=${{ secrets.DB_USER }}" >> $GITHUB_ENV
        echo "DB_PASSWORD=${{ secrets.DB_PASSWORD }}" >> $GITHUB_ENV
        echo "YC_TOKEN=${{ steps.issue-iam-token.outputs.token }}" >> $GITHUB_ENV
  
Последним идет переменная которая берет iam token и экспортирует его в переменные окружения.
Эти переменные используются в последующих шагах.

## Подключение к хранилищу (Object Storage)
В хранилище хранится данные по текущему состоянию terraform, т.е данные по текущей инфраструткуре, что уже развернуто в облаке, файл называет terraform.state.
Для подключения к хранилищу нужно:
1. Создать сервисный аккаунт с правами storage.admin;
2. Создать для этого аккаунта статический ключ доступа;
3. Скопировать данные идентификатор ключа и сам ключ;
4. В github создать 2 секрета с идентификатором и ключем;
5. Далее экспортируем переменные окружения из секретов, примерно так (первые 2 ключа идентификатор и ключ)
- name: Set environment variables from secrets
      run: |
        echo "ACCESS_KEY=${{ secrets.ACCESS_KEY }}" >> $GITHUB_ENV
        echo "SECRET_KEY=${{ secrets.SECRET_KEY }}" >> $GITHUB_ENV
        echo "YC_CLOUD_ID=${{ secrets.YC_CLOUD_ID }}" >> $GITHUB_ENV
        echo "YC_FOLDER_ID=${{ secrets.YC_FOLDER_ID }}" >> $GITHUB_ENV
        echo "DB_USER=${{ secrets.DB_USER }}" >> $GITHUB_ENV
        echo "DB_PASSWORD=${{ secrets.DB_PASSWORD }}" >> $GITHUB_ENV
        echo "YC_TOKEN=${{ steps.issue-iam-token.outputs.token }}" >> $GITHUB_ENV

## Пример команд с использвоанием переменныех
- name: Terraform Format
      id: fmt
      run: terraform fmt -check
      continue-on-error: true    

    - name: Initialize Terraform
      run: terraform init -input=false -backend-config="access_key=${{ env.ACCESS_KEY }}" -backend-config="secret_key=${{ env.SECRET_KEY }}"

    - name: Plan Terraform changes
      run: terraform plan -input=false -var="DB_USER=${{ env.DB_USER }}" -var="DB_PASSWORD=${{ env.DB_PASSWORD }}" -var="CLOUD_ID=${{ env.YC_CLOUD_ID }}" -var="FOLDER_ID=${{ env.YC_FOLDER_ID }}" -var="YC_TOKEN=${{ env.YC_TOKEN }}" -var="ACCESS_KEY=${{ env.ACCESS_KEY }}" -var="SECRET_KEY=${{ env.SECRET_KEY }}"

    - name: Apply Terraform changes
      run: terraform apply --auto-approve -var="DB_USER=${{ env.DB_USER }}" -var="DB_PASSWORD=${{ env.DB_PASSWORD }}" -var="CLOUD_ID=${{ env.YC_CLOUD_ID }}" -var="FOLDER_ID=${{ env.YC_FOLDER_ID }}" -var="YC_TOKEN=${{ env.YC_TOKEN }}" -var="ACCESS_KEY=${{ env.ACCESS_KEY }}" -var="SECRET_KEY=${{ env.SECRET_KEY }}"

ying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
