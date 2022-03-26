#!/bin/bash
#

kubectl delete -f deployment.yaml --namespace r-mordasiewicz


kubectl create -f deployment.yaml --namespace r-mordasiewicz


echo "kubectl exec --namespace r-mordasiewicz -it ubuntu -c ubuntu -- /bin/bash"
