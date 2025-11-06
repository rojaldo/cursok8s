#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/emptydir-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod emptydir-pod

# Ver los logs del contenedor
kubectl logs emptydir-pod

# Verificar el contenido del archivo en el volumen
kubectl exec emptydir-pod -- cat /data/shared-file.txt

# Listar archivos en el volumen
kubectl exec emptydir-pod -- ls -la /data/

# Ver detalles del pod incluyendo volúmenes
kubectl describe pod emptydir-pod | grep -A 10 Volumes

# Limpiar recursos
# kubectl delete -f pod.yaml
