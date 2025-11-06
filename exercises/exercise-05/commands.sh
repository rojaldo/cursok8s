#!/bin/bash

# Crear el ConfigMap
kubectl apply -f configmap.yaml

# Verificar que el ConfigMap fue creado
kubectl get configmap app-config

# Ver el contenido del ConfigMap
kubectl describe configmap app-config

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/configmap-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod configmap-pod

# Ver los logs del pod para verificar las variables de entorno
kubectl logs configmap-pod

# Verificar las variables de entorno dentro del contenedor
kubectl exec configmap-pod -- env | grep -E 'DATABASE_URL|API_KEY|LOG_LEVEL|MAX_CONNECTIONS'

# Ver detalles del pod
kubectl describe pod configmap-pod

# Limpiar recursos
# kubectl delete -f pod.yaml
# kubectl delete -f configmap.yaml
