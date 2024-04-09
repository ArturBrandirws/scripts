#!/bin/bash

usersList() {
  echo $(aws secretsmanager get-secret-value --secret-id prod/sftp/server --query SecretString  --output text | tr -d '{}' | tr ',' ';' | tr -d '"' | tr ':' ',')
}