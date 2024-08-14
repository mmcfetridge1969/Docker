#!/bin/bash

# Function to display menu
show_menu() {
    echo "Installation Menu:"
    echo "1) Docker-CE"
    echo "2) Docker-compose"
    echo "3) NginX-Proxy-Manager"
    echo "4) Portainer-CE"
    echo "5) Watchtower"
    echo "6) Dashy"
    echo "7) Kuma Uptime"
    echo "8) Exit Installer"
}

# Function to Docker-CE
install_Docker-CE() {
    echo "Installing Docker-CE..."
    # Add Docker's official GPG key:
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker "${USER}"

}

# Function to install Docker-compose
install_Docker-compose() {
    echo "Installing Docker-compose..."
    sudo apt-get install docker-compose-plugin -y
    exit
    sudo usermod -aG docker "${USER}"
    echo "you must log out of you session and log back in"
}

# Function to install NginX-Proxy-Manager
install_NginX-Proxy-Manager() {
    echo "Installing NginX-Proxy-Manager..."
    mkdir ./docker
    mkdir ./docker/npm
    mkdir ./docker/npm/data
    mkdir ./docker/npm/letsencrypt
    mkdir ./docker/npm/mysql
    cd ./docker/npm
    curl https://raw.githubusercontent.com/mmcfetridge1969/mmcfetridge1969/master/docker_compose.nginx_proxy_manager.yml -o docker-compose.yml
    sudo docker network create proxy
    sudo docker compose up -d
}

# Function to install Portainer-CE
install_Portainer-CE() {
    echo "Installing Portainer..."
    mkdir ./docker/portainer
    cd ./docker/portainer
    sudo docker volume create portainer_data
    curl https://raw.githubusercontent.com/mmcfetridge1969/mmcfetridge1969/master/portainer-docker-compose.yml -o docker-compose.yml
    sudo docker compose up -d
}

# Function to install Watchtower
install_Watchtower() {
    echo "Installing Watchtower..."
    sudo docker run -d --name watchtower --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -e WATCHTOWER_SCHEDULE="0 0 0 */1 * *" containrrr/watchtower
}

# Function to install Portainer-CE
install_dashy() {
    echo "Installing Dashy..."
    mkdir ./docker/dashy
    mkdir ./dashy/config
    cd ./docker/dashy
    sudo git clone https://github.com/walkxcode/dashboard-icons.git
    curl https://raw.githubusercontent.com/mmcfetridge1969/mmcfetridge1969/master/dashy-docker-compose.yml -o docker-compose.yml
    sudo docker compose up -d
}

# Function to install Portainer-CE
install_kuma() {
    echo "Installing Kuma Uptime..."
    mkdir ./docker/kuma
    mkdir ./docker/kuma/data
    cd ./docker/kuma
    curl https://raw.githubusercontent.com/mmcfetridge1969/mmcfetridge1969/master/kuma-docker-compose.yml -o docker-compose.yml
    sudo docker compose up -d
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (1-8): " choice

    case $choice in
        1) install_Docker-CE ;;
        2) install_Docker-compose ;;
        3) install_NginX-Proxy-Manager ;;
        4) install_Portainer-CE ;;
        5) install_Watchtower;;
        6) install_dashy;;
        7) install_kuma;;
        8)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [[ $confirm == [Yy] ]]; then
                echo "Exiting installer. Goodbye!"
                exit 0
            fi
            ;;
        *)
            echo "Invalid selection. Please try again."
            ;;
    esac

    echo # Add a blank line for readability
done
