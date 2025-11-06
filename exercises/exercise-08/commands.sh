#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/init-command-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod init-command-pod

# Ver los logs del pod para verificar la inicialización
kubectl logs init-command-pod

# Verificar que los archivos fueron creados correctamente
echo "=== Verificando archivos creados ==="
kubectl exec init-command-pod -- ls -la /app/data/

# Ver el contenido del log de inicialización
echo "=== Contenido del archivo init.log ==="
kubectl exec init-command-pod -- cat /app/data/init.log

# Ver el contenido del archivo de configuración
echo "=== Contenido del archivo config.json ==="
kubectl exec init-command-pod -- cat /app/data/config.json

# Ver detalles del pod
kubectl describe pod init-command-pod

# Verificar que el pod sigue ejecutándose después de la inicialización
sleep 5
kubectl get pod init-command-pod

# Limpiar recursos
# kubectl delete -f pod.yaml
