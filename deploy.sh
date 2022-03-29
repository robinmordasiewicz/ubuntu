#!/bin/bash
#

kubectl apply -f deployment.yaml --namespace r-mordasiewicz

echo "kubectl exec --namespace r-mordasiewicz -it ubuntu -c ubuntu -- /bin/bash"
