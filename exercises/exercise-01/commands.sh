#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod nginx-pod

# Ver detalles del pod
kubectl describe pod nginx-pod

# Ver logs del pod
kubectl logs nginx-pod

# Verificar que el puerto 80 está expuesto
kubectl get pod nginx-pod -o jsonpath='{.spec.containers[0].ports[0].containerPort}'
echo

# Port-forward para acceder al nginx localmente (opcional)
# kubectl port-forward pod/nginx-pod 8080:80

# Limpiar recursos
# kubectl delete -f pod.yaml
