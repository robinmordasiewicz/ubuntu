#!/bin/bash
#

echo "deploy ubuntu container"

kubectl apply -f deployment.yaml --namespace r-mordasiewicz

echo "kubectl exec --namespace r-mordasiewicz -it ubuntu -c ubuntu -- /bin/bash"
