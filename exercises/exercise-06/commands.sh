#!/bin/bash

# Crear el Secret
kubectl apply -f secret.yaml

# Verificar que el Secret fue creado
kubectl get secret app-secret

# Ver detalles del Secret (sin mostrar los valores)
kubectl describe secret app-secret

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/secret-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod secret-pod

# Ver los logs del pod para verificar que leyó los secretos
kubectl logs secret-pod

# Listar archivos en el directorio de secretos
kubectl exec secret-pod -- ls -la /etc/secrets/

# Leer el contenido de los archivos de secretos
kubectl exec secret-pod -- cat /etc/secrets/username
kubectl exec secret-pod -- cat /etc/secrets/password
kubectl exec secret-pod -- cat /etc/secrets/api-token

# Ver detalles del pod
kubectl describe pod secret-pod

# Limpiar recursos
# kubectl delete -f pod.yaml
# kubectl delete -f secret.yaml
