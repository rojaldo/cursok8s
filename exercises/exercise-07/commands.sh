#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar a que el pod esté listo
kubectl wait --for=condition=Ready pod/resource-limits-pod --timeout=60s

# Verificar que el pod está en estado Running
kubectl get pod resource-limits-pod

# Ver detalles del pod incluyendo los límites de recursos
kubectl describe pod resource-limits-pod | grep -A 10 "Limits:"

# Ver el uso actual de recursos del pod (requiere metrics-server)
# kubectl top pod resource-limits-pod

# Ver los recursos asignados al pod
kubectl get pod resource-limits-pod -o jsonpath='{.spec.containers[0].resources}'
echo

# Ver eventos del pod
kubectl get events --field-selector involvedObject.name=resource-limits-pod --sort-by='.lastTimestamp'

# Ver detalles completos del pod
kubectl describe pod resource-limits-pod

# Monitorear logs del pod
kubectl logs resource-limits-pod

# Limpiar recursos
# kubectl delete -f pod.yaml


# Comando para monitorear el uso de recursos en tiempo real (requiere metrics-server)
watch -n 5 kubectl top pod resource-limits-pod