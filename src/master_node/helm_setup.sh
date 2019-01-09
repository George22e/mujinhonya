# /bin/bash

# helm install
curl -sL https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-rc4-linux-amd64.tar.gz > helm.tar.gz
tar -xzvf helm.tar.gz
sudo cp linux-amd64/helm /usr/local/bin
sudo chmod 755 /usr/local/bin/helm
source <(helm completion bash)
