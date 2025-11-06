#!/bin/bash

# Crear el pod
kubectl apply -f pod.yaml

# Esperar unos segundos para que el pod inicie
sleep 5

# Ver el estado del pod (inicialmente no estará Ready)
echo "=== Estado inicial del pod ==="
kubectl get pod probes-pod

# Esperar a que el pod esté listo (readiness probe pasa)
echo "=== Esperando a que el pod esté Ready ==="
kubectl wait --for=condition=Ready pod/probes-pod --timeout=60s

# Verificar que el pod está en estado Running y Ready
echo "=== Pod en estado Ready ==="
kubectl get pod probes-pod

# Ver los eventos del pod
echo "=== Eventos del pod ==="
kubectl get events --field-selector involvedObject.name=probes-pod --sort-by='.lastTimestamp'

# Ver los logs del pod
echo "=== Logs del pod ==="
kubectl logs probes-pod

# Monitorear el pod para ver el comportamiento cuando falla la liveness probe
# Después de ~60 segundos, el pod será reiniciado por Kubernetes
echo "=== Monitoreando el pod (esperar ~60 segundos para ver el reinicio) ==="
for i in {1..25}; do
  echo "Check $i:"
  kubectl get pod probes-pod -o wide
  sleep 3
done

# Ver el conteo de reinicios
echo "=== Verificar reinicios ==="
kubectl get pod probes-pod -o jsonpath='{.status.containerStatuses[0].restartCount}'
echo

# Ver detalles completos del pod
kubectl describe pod probes-pod

# Limpiar recursos
# kubectl delete -f pod.yaml
