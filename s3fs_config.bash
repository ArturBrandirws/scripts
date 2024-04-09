#!/bin/bash

install_s3fs() {
  echo "Installing s3fs"
  ## install s3fs
  sudo apt -y install s3fs
}

store_aws_credentials() {
  echo "Storing AWS accessKey"

  ## if the file with aws credentials doesn't exist
  if [ ! -f /etc/passwd-s3fs ]; then
    ## Insert the credentials into /etc/passwd-s3fs
    echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" | sudo tee /etc/passwd-s3fs > /dev/null
  fi
}

adjust_permissions() {
  echo "Adjusting permissions"
    
  ## if the /etc/passwd-s3fs file isn't chmod 600
  if [ $(stat -c "%a" /etc/passwd-s3fs) -ne 600 ]; then
    sudo chmod 600 /etc/passwd-s3fs
  fi
}

show_configuration() {
  echo "AWS credentials saved in /etc/passwd-s3fs"
}

main () {
  # ## Check if access key and secret key environment variables are set
  # if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  #   echo "AWS access key and/or secret key not provided."
  #   exit 1
  # fi

  ## Intalls s3fs
  install_s3fs

  ## Store the aws credentials in /etc/passwd-s3fs
  # store_aws_credentials

  ## make the aws credentials file able to be readed
  adjust_permissions

  ## Print the end of configuration
  show_configuration
}

main
