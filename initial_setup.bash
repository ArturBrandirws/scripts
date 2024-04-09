#!/bin/bash

usage() {
    echo "Usage: This script don't accept any param."
}

prepare_system() {

    ## edit /etc/needrestart/needrestart.conf to avoid kernel restart window
    sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

    ## edit /etc/needrestart/needrestart.conf to avoid kernel restart window
    sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf

    echo "Performing system update and upgrade"

    ## update and upgrade the system
    sudo apt update && sudo apt -y upgrade

    echo "System update finished"
}

main () {
    ## Update and upgrade the system
    prepare_system
}

main