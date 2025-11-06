# Exercise 04: Pod con Sidecar Pattern (Node.js + Logs)

## Objetivo

Definir un pod con dos contenedores siguiendo el patrón sidecar: uno ejecutando una aplicación Node.js que genera logs, y otro contenedor monitoreando los archivos de log generados por la aplicación.

## Conceptos Clave

- **Multi-container Pod**: Pod con múltiples contenedores que comparten recursos
- **Sidecar Pattern**: Contenedor auxiliar que extiende/mejora el contenedor principal
- **Volúmenes compartidos**: Los contenedores en un pod pueden compartir volúmenes
- **Separación de responsabilidades**: Cada contenedor tiene un propósito específico
- **Log shipping**: Patrón común para enviar logs a sistemas centralizados

## Archivos

- `pod.yaml`: Manifiesto del pod con dos contenedores y volumen compartido

## Paso a Paso

### 1. Crear el Pod

```bash
kubectl apply -f pod.yaml
```

**Qué hace**: Crea un pod con dos contenedores que comparten un volumen para logs.

**Salida esperada**:
```
pod/nodejs-sidecar-pod created
```

**Explicación**: Kubernetes creará:
1. Un pod con dos contenedores: `nodejs-app` y `log-sidecar`
2. Un volumen `emptyDir` llamado `logs`
3. Montará el volumen en `/var/log/app` en ambos contenedores
4. Ambos contenedores iniciarán simultáneamente

### 2. Esperar a que el Pod esté Listo

```bash
kubectl wait --for=condition=Ready pod/nodejs-sidecar-pod --timeout=60s
```

**Qué hace**: Espera hasta que ambos contenedores estén listos.

**Salida esperada**:
```
pod/nodejs-sidecar-pod condition met
```

**Explicación**: El pod no estará "Ready" hasta que **todos** los contenedores reporten que están listos. Esto puede tomar unos segundos mientras descarga las imágenes de Node.js y Busybox.

### 3. Verificar el Estado del Pod

```bash
kubectl get pod nodejs-sidecar-pod
```

**Qué hace**: Muestra el estado del pod.

**Salida esperada**:
```
NAME                 READY   STATUS    RESTARTS   AGE
nodejs-sidecar-pod   2/2     Running   0          45s
```

**Explicación importante**:
- `READY 2/2`: **Dos contenedores** están listos de dos totales
- Esto confirma que ambos contenedores están funcionando
- Si fuera `1/2`, uno de los contenedores tendría problemas

### 4. Ver los Logs del Contenedor Principal (Node.js)

```bash
echo "=== Logs del contenedor Node.js ==="
kubectl logs nodejs-sidecar-pod -c nodejs-app
```

**Qué hace**: Muestra los logs del contenedor que genera logs.

**Salida esperada**:
```
=== Logs del contenedor Node.js ===
```

**Explicación**:
- `-c nodejs-app`: Especifica qué contenedor queremos ver (requerido en pods multi-contenedor)
- Este contenedor escribe en archivos, no en stdout, por lo que puede no haber logs de consola
- La actividad real está en el archivo `/var/log/app/app.log`

### 5. Ver los Logs del Contenedor Sidecar

```bash
echo "=== Logs del contenedor sidecar ==="
kubectl logs nodejs-sidecar-pod -c log-sidecar
```

**Qué hace**: Muestra los logs del contenedor que monitorea archivos.

**Salida esperada**:
```
=== Logs del contenedor sidecar ===
Starting log monitor...
[2025-11-06 10:30:15] Processing request...
[2025-11-06 10:30:15] Request completed successfully
[2025-11-06 10:30:20] Processing request...
[2025-11-06 10:30:20] Request completed successfully
[2025-11-06 10:30:25] Processing request...
[2025-11-06 10:30:25] Request completed successfully
...
```

**Explicación**:
- El sidecar usa `tail -f` para seguir el archivo de log en tiempo real
- Todo lo que el contenedor principal escribe en el archivo aparece aquí
- Esto simula un log shipper que enviaría logs a sistemas como Elasticsearch, Splunk, etc.

### 6. Ver Ambos Contenedores del Pod

```bash
kubectl get pod nodejs-sidecar-pod -o jsonpath='{.spec.containers[*].name}'
echo
```

**Qué hace**: Lista los nombres de todos los contenedores en el pod.

**Salida esperada**:
```
nodejs-app log-sidecar
```

**Explicación**: Confirma que el pod tiene dos contenedores con estos nombres.

### 7. Verificar el Archivo de Logs en el Contenedor Principal

```bash
kubectl exec nodejs-sidecar-pod -c nodejs-app -- cat /var/log/app/app.log
```

**Qué hace**: Lee directamente el archivo de logs desde el contenedor Node.js.

**Salida esperada**:
```
[2025-11-06 10:30:15] Processing request...
[2025-11-06 10:30:15] Request completed successfully
[2025-11-06 10:30:20] Processing request...
[2025-11-06 10:30:20] Request completed successfully
...
```

**Explicación**:
- Accede al volumen compartido desde el contenedor principal
- Los logs se acumulan cada 5 segundos
- El mismo archivo es accesible desde ambos contenedores

### 8. Ver Detalles del Pod

```bash
kubectl describe pod nodejs-sidecar-pod
```

**Qué hace**: Muestra información detallada incluyendo ambos contenedores.

**Salida esperada**: Sección relevante:
```
Containers:
  nodejs-app:
    Container ID:   containerd://...
    Image:          node:14-alpine
    ...
    Mounts:
      /var/log/app from logs (rw)

  log-sidecar:
    Container ID:   containerd://...
    Image:          busybox:latest
    ...
    Mounts:
      /var/log/app from logs (rw)

Volumes:
  logs:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
```

**Explicación**: Ambos contenedores montan el mismo volumen `logs` en la misma ruta.

## Verificación de Resultados

1. **Dos contenedores running**: `READY 2/2`
2. **Logs generándose**: El contenedor principal escribe logs continuamente
3. **Sidecar monitoreando**: El sidecar lee y muestra los logs en tiempo real
4. **Volumen compartido funcional**: Ambos contenedores acceden al mismo archivo

## Exploración Adicional

### Seguir los Logs del Sidecar en Tiempo Real

```bash
kubectl logs -f nodejs-sidecar-pod -c log-sidecar
```

**Qué hace**: Sigue los logs en tiempo real (como `tail -f`).

Para detener: Presiona `Ctrl+C`

### Ver Logs de Ambos Contenedores Simultáneamente

```bash
# Terminal 1
kubectl logs -f nodejs-sidecar-pod -c nodejs-app

# Terminal 2 (en otra ventana)
kubectl logs -f nodejs-sidecar-pod -c log-sidecar
```

### Escribir en el Log Manualmente

```bash
kubectl exec nodejs-sidecar-pod -c nodejs-app -- \
  sh -c 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] Manual log entry" >> /var/log/app/app.log'
```

**Resultado**: Verás esta entrada aparecer en los logs del sidecar casi instantáneamente.

### Ver el Crecimiento del Archivo de Log

```bash
# Ver tamaño actual
kubectl exec nodejs-sidecar-pod -c nodejs-app -- ls -lh /var/log/app/app.log

# Esperar 30 segundos
sleep 30

# Ver nuevo tamaño
kubectl exec nodejs-sidecar-pod -c nodejs-app -- ls -lh /var/log/app/app.log
```

### Monitorear el Uso de Recursos de Cada Contenedor

```bash
kubectl top pod nodejs-sidecar-pod --containers
```

**Nota**: Requiere metrics-server instalado.

**Salida esperada**:
```
POD                  NAME          CPU(cores)   MEMORY(bytes)
nodejs-sidecar-pod   nodejs-app    1m           20Mi
nodejs-sidecar-pod   log-sidecar   0m           2Mi
```

### Ejecutar Shell en Contenedor Específico

```bash
# Shell en el contenedor Node.js
kubectl exec -it nodejs-sidecar-pod -c nodejs-app -- /bin/sh

# Shell en el sidecar
kubectl exec -it nodejs-sidecar-pod -c log-sidecar -- /bin/sh
```

Dentro puedes explorar:
```bash
ls -la /var/log/app/
cat /var/log/app/app.log
ps aux  # Ver procesos
```

## Limpieza

```bash
kubectl delete -f pod.yaml
```

O:

```bash
kubectl delete pod nodejs-sidecar-pod
```

## Conceptos Importantes

### ¿Qué es el Sidecar Pattern?

El **Sidecar Pattern** es un patrón de diseño donde un contenedor auxiliar ("sidecar") se ejecuta junto al contenedor principal para proporcionar funcionalidad de soporte.

**Características**:
- Comparten el mismo ciclo de vida
- Comparten red (mismo localhost)
- Comparten volúmenes
- Se despliegan y escalan juntos

### Casos de Uso Comunes del Sidecar

1. **Log Aggregation** (nuestro ejemplo)
   - Sidecar: Recolecta y envía logs
   - Principal: Genera logs

2. **Service Mesh** (Istio, Linkerd)
   - Sidecar: Proxy que maneja networking
   - Principal: Aplicación de negocio

3. **Configuration/Secret Management**
   - Sidecar: Sincroniza configuración desde fuente externa
   - Principal: Usa la configuración actualizada

4. **Monitoring/Metrics**
   - Sidecar: Exporta métricas
   - Principal: Genera datos de métricas

5. **Data Synchronization**
   - Sidecar: Sincroniza archivos (ej: git-sync)
   - Principal: Usa los archivos sincronizados

### Ventajas del Sidecar Pattern

✅ **Separación de responsabilidades**: Cada contenedor una función
✅ **Reusabilidad**: El mismo sidecar para múltiples aplicaciones
✅ **Upgrades independientes**: Actualiza el sidecar sin tocar la app
✅ **Diferentes lenguajes/tecnologías**: Cada contenedor en su stack óptimo
✅ **Compartir recursos**: Red y almacenamiento compartidos

### Desventajas

❌ **Mayor complejidad**: Más contenedores que gestionar
❌ **Más recursos**: CPU/memoria adicionales
❌ **Debugging más difícil**: Múltiples contenedores para investigar
❌ **Dependencias**: Si el sidecar falla, puede afectar la app

### Comunicación Entre Contenedores

Los contenedores en el mismo pod comparten:

#### 1. Network Namespace (localhost)
```bash
# Ambos contenedores pueden comunicarse vía localhost
# Si nodejs-app escuchara en puerto 3000:
curl localhost:3000
```

#### 2. Volúmenes
```bash
# Compartir archivos (como en nuestro ejemplo)
/var/log/app/ es accesible por ambos
```

#### 3. IPC (Inter-Process Communication)
```bash
# Pueden usar System V IPC o POSIX message queues
```

### Orden de Inicio

⚠️ **Importante**: Kubernetes **no garantiza** el orden de inicio de contenedores en un pod.

Si necesitas orden específico:
1. Usa **Init Containers** para preparación
2. Implementa lógica de retry en la aplicación
3. Usa readiness probes para coordinar

### Multi-container vs Init Containers

| Multi-container | Init Containers |
|----------------|----------------|
| Ejecutan en paralelo | Ejecutan secuencialmente |
| Viven durante todo el ciclo del pod | Terminan antes de los contenedores principales |
| Para funcionalidad continua | Para tareas de inicialización |
| Ejemplo: sidecar, ambassador | Ejemplo: migrations, wait-for-db |

### Ejemplo de Init Container + Sidecar

```yaml
spec:
  initContainers:
  - name: init-logs-dir
    image: busybox
    command: ['sh', '-c', 'mkdir -p /var/log/app && chmod 777 /var/log/app']
    volumeMounts:
    - name: logs
      mountPath: /var/log/app

  containers:
  - name: app
    image: myapp
    volumeMounts:
    - name: logs
      mountPath: /var/log/app

  - name: log-shipper
    image: fluentd
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
```

## Troubleshooting

### Solo 1 de 2 contenedores Ready

**Verificar cuál tiene problemas**:
```bash
kubectl describe pod nodejs-sidecar-pod
```

Busca en la sección de eventos el contenedor que falla.

**Ver logs del contenedor problemático**:
```bash
kubectl logs nodejs-sidecar-pod -c <container-name>
kubectl logs nodejs-sidecar-pod -c <container-name> --previous
```

### Sidecar no ve los logs

**Causas posibles**:
1. El volumen no está montado correctamente
2. El contenedor principal no está escribiendo logs
3. Path incorrecto

**Verificar**:
```bash
# Ver si el archivo existe desde el principal
kubectl exec nodejs-sidecar-pod -c nodejs-app -- ls -la /var/log/app/

# Ver si el archivo existe desde el sidecar
kubectl exec nodejs-sidecar-pod -c log-sidecar -- ls -la /var/log/app/
```

### Pod reinicia constantemente

```bash
# Ver eventos
kubectl get events --field-selector involvedObject.name=nodejs-sidecar-pod

# Ver logs de todos los contenedores
kubectl logs nodejs-sidecar-pod -c nodejs-app
kubectl logs nodejs-sidecar-pod -c log-sidecar
```

### No puedo ver cuál contenedor está fallando

```bash
kubectl get pod nodejs-sidecar-pod -o jsonpath='{.status.containerStatuses[*].state}'
```

Muestra el estado de cada contenedor.

## Buenas Prácticas

1. **Nombres descriptivos**: Usa nombres claros para cada contenedor
2. **Recursos definidos**: Asigna CPU/memoria a cada contenedor
3. **Probes independientes**: Cada contenedor puede tener sus propias probes
4. **Logs estructurados**: Usa JSON para facilitar parsing
5. **Límites de logs**: Implementa log rotation para no llenar el disco
6. **Monitoreo separado**: Monitorea cada contenedor individualmente

## Mejoras al Ejemplo

### Agregar Log Rotation

```yaml
- name: nodejs-app
  command: ["/bin/sh", "-c"]
  args:
    - |
      while true; do
        echo "[$(date)] Log entry" >> /var/log/app/app.log

        # Rotar si el archivo es muy grande (>1MB)
        if [ $(stat -f%z /var/log/app/app.log) -gt 1048576 ]; then
          mv /var/log/app/app.log /var/log/app/app.log.old
        fi

        sleep 5
      done
```

### Usar Fluentd en lugar de tail

```yaml
- name: log-shipper
  image: fluent/fluentd:latest
  volumeMounts:
  - name: logs
    mountPath: /var/log/app
  - name: fluentd-config
    mountPath: /fluentd/etc
```

### Añadir Health Checks

```yaml
containers:
- name: nodejs-app
  livenessProbe:
    exec:
      command: ['test', '-f', '/var/log/app/app.log']
    periodSeconds: 10
```

Este ejercicio demuestra el poder del sidecar pattern para extender funcionalidad sin modificar la aplicación principal.
