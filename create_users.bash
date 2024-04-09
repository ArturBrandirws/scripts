#!/bin/bash

source ../scripts/users.sh

install_openssh_server() {

    echo "Installing OpenSSH server"

    ## Install openssh-server
    sudo apt-get install -y openssh-server

    echo "OpenSSH server installed"
}

configure_ssh_sftp() {

    ## If the group passed doesn't exist
    if ! grep -q "Match Group $1" /etc/ssh/sshd_config; then
        
        ## Create the group
        sudo groupadd "$1"

        echo "Configuring SSH to SFTP"

        ## insert the following lines with the necessary configuration in /etc/ssh/sshd_config
        sudo bash -c "cat <<EOF >> /etc/ssh/sshd_config

KbdInteractiveAuthentication no
PasswordAuthentication yes
PermitRootLogin no

Match Group $1
       ChrootDirectory $2/%u
       ForceCommand internal-sftp
       AllowTcpForwarding no
EOF"
        echo "SFTP configuration finished"

        ## restart systemctl 
        sudo systemctl restart sshd
    fi
}

create_user() {

    ## If the user passed doesn't exist
    if ! id "$1" &>/dev/null; then
        echo "User $1 does not exist. Creating..."

        ## Create the user with the $mount_location as home and in the $group_user
        sudo useradd -m -d "$2/$1" -g "$3" -s /bin/false "$1"

        ## Remove user's password
        sudo passwd -d "$1"

        ## Create the user's upload folder
        sudo mkdir -p "$2/$1/upload"

        ## Makes the user's folder able to read, write and exec
        sudo chmod 755 "$2/$1"
        echo "User $1 created."
    else
        echo "User $1 already exists. Skipping user creation."
    fi
}

adjust_owners() {
    
    echo "Adjusting owners"
    sudo chown root:"$1" "$2/$3"
    sudo chown "$3":"$1" "$2/$3/upload"
}

restart_ssh_service() {
    
    sudo systemctl restart sshd
}

configure_ssh_key() {
    echo "Configuring SSH key"

    # Check if the .ssh directory already exists
    if [ ! -d "$1/$2/.ssh" ]; then
        # Creating directory if it doesn't exist
        sudo mkdir -p "$1/$2/.ssh"  
    else
        echo "Directory $1/$2/.ssh already exists."
    fi

    # Copy the public key from GitHub into $1/$2/.ssh/authorized_keys
    sudo wget -O "$1/$2/.ssh/authorized_keys" "https://raw.githubusercontent.com/ArturBrandirws/bashTests/main/id_rsa.pub"
    echo "SFTP configured!"
}


show_configuration() {

    echo "User $1 is mounted in $2 and belongs to $3"
}

main() {
  ## Assing params
  bucket_name=$(usersList)
  echo "one is ${bucket_name[@]}"

  # Set the IFS variable to ;
  IFS=';'

  # Read the output into an array, splitting by ;
  parsedArray=($bucket_name)

  # Reset IFS to the default value
  unset IFS

  ##########

  # Set the IFS variable to ,
  IFS=','

  # Iterate over the parsedArray
  for element in "${parsedArray[@]}"; do
    # Parse the element by , and read into an array
    parsedElement=($element)

    # Get the first value
    userName=${parsedElement[0]}
    bucketName=${parsedElement[1]}

    # Print the first value
    echo "user_name is $userName"
    echo "group is $bucketName"

    # Define mount location
    mount_location="/var/$bucketName"

    ## install openssh server
    install_openssh_server

    ## Check if the group passed already exist. If it doesn't exist create the group and insert the configuration for the group in /etc/ssh/sshd_config
    configure_ssh_sftp "$bucketName" "$mount_location"

    ## Check if the user passed already exist. If it doesn't exist create and configure.
    create_user "$userName" "$mount_location" "$bucketName"

    ## Adjust the owners to make sftp conncetion possible
    adjust_owners "$bucketName" "$mount_location" "$userName"

    ## Restart ssh service
    restart_ssh_service

    ## Get the public key from GitHub and insert it in $mount_location/$username/.ssh/authorized_keys
    configure_ssh_key "$mount_location" "$userName"

    ## Prints the name of the user, where the it is created and what groups it belongs
    show_configuration "$userName" "$mount_location" "$bucketName"
  done
}

main
