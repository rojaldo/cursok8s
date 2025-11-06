#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/nodejs-sidecar-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod nodejs-sidecar-pod

# Ver los logs del contenedor principal (nodejs-app)
echo "=== Logs del contenedor Node.js ==="
kubectl logs nodejs-sidecar-pod -c nodejs-app

# Ver los logs del contenedor sidecar (log-sidecar)
echo "=== Logs del contenedor sidecar ==="
kubectl logs nodejs-sidecar-pod -c log-sidecar

# Ver ambos contenedores
kubectl get pod nodejs-sidecar-pod -o jsonpath='{.spec.containers[*].name}'
echo

# Verificar el archivo de logs dentro del contenedor principal
kubectl exec nodejs-sidecar-pod -c nodejs-app -- cat /var/log/app/app.log

# Ver detalles del pod
kubectl describe pod nodejs-sidecar-pod

# Limpiar recursos
# kubectl delete -f pod.yaml
