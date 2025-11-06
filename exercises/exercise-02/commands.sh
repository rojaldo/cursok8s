#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/python-app --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod python-app

# Ver los logs para verificar las variables de entorno
kubectl logs python-app

# Ver las variables de entorno del contenedor
kubectl exec python-app -- env | grep -E 'APP_NAME|ENVIRONMENT|APP_VERSION'

# Ver detalles del pod
kubectl describe pod python-app

# Limpiar recursos
# kubectl delete -f pod.yaml
