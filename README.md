kubectl delete -f deployment.yaml --namespace r-mordasiewicz

kubectl apply -f deployment.yaml --namespace r-mordasiewicz

kubectl describe pod ubuntu -n r-mordasiewicz

kubectl logs ubuntu -c ubuntu -n r-mordasiewicz

kubectl exec --namespace r-mordasiewicz -it ubuntu -- /bin/bash
