#!/bin/bash
#

kubectl delete -f deployment.yaml --namespace r-mordasiewicz

kubectl create -f deployment.yaml --namespace r-mordasiewicz
