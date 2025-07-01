#!/usr/bin/env bash

function aliases(){
cat <<EOS| tee -a ~/.bashrc
alias k=kubectl
alias kg='kubectl get'
alias kgp='kubectl get po'
alias kdp='kubectl describe pod'

function kns() {
  ns=\$(kubectl get namespace "\$1" --no-headers --output=go-template={{.metadata.name}} 2>/dev/null)
  if [ -z "\${ns}" ]; then
    echo "Namespace (\${1}) not found, using default"
    ns="default"
  fi
  kubectl config set-context --current --namespace="\${ns}" 2>&1 >/dev/null
  [[ "\$ns" == "\$(kubectl config view --minify --output jsonpath={..namespace})" ]] && echo "Switched to namespace: \${ns}"
}
EOS
}

function main(){
  echo aliases
}



main
