#!/bin/bash

# NOTA: Este ejercicio requiere que tengas una imagen privada en Docker Hub
# y tus credenciales de Docker Hub

# Opción 1: Crear el secret usando el comando kubectl (RECOMENDADO)
# Reemplaza YOUR_USERNAME, YOUR_PASSWORD, y YOUR_EMAIL con tus datos reales
# kubectl create secret docker-registry docker-registry-secret \
#   --docker-server=https://index.docker.io/v1/ \
#   --docker-username=YOUR_USERNAME \
#   --docker-password=YOUR_PASSWORD \
#   --docker-email=YOUR_EMAIL

# Opción 2: Aplicar el secret desde el archivo YAML
# (primero debes editar secret.yaml con tus credenciales)
# kubectl apply -f secret.yaml

# Verificar que el secret fue creado
kubectl get secret docker-registry-secret

# Ver detalles del secret (sin mostrar las credenciales)
kubectl describe secret docker-registry-secret

# Crear el pod (primero edita pod.yaml con tu imagen privada)
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/private-image-pod --timeout=120s

# Verificar que el pod está en estado Running
kubectl get pod private-image-pod

# Ver los logs del pod
kubectl logs private-image-pod

# Ver eventos del pod para verificar que la imagen fue descargada correctamente
kubectl get events --field-selector involvedObject.name=private-image-pod --sort-by='.lastTimestamp'

# Ver detalles del pod
kubectl describe pod private-image-pod

# Verificar el imagePullSecret configurado
kubectl get pod private-image-pod -o jsonpath='{.spec.imagePullSecrets[0].name}'
echo

# Limpiar recursos
# kubectl delete -f pod.yaml
# kubectl delete secret docker-registry-secret
