# Exercise 01: Pod Simple con Nginx

## Objetivo

Crear un manifiesto YAML para desplegar un pod simple que ejecute la imagen oficial de Nginx y exponga el puerto 80. Verificar que el pod esté en estado Running.

## Conceptos Clave

- **Pod**: La unidad más pequeña y básica de deployment en Kubernetes
- **Container**: Aplicación empaquetada con sus dependencias
- **containerPort**: Puerto que expone el contenedor para comunicación
- **Labels**: Etiquetas para identificar y organizar recursos

## Archivos

- `pod.yaml`: Manifiesto del pod con Nginx

## Paso a Paso

### 1. Crear el Pod

```bash
kubectl apply -f pod.yaml
```

**Qué hace**: Crea el pod en el cluster de Kubernetes usando el manifiesto YAML.

**Salida esperada**:
```
pod/nginx-pod created
```

**Explicación**: El comando `apply` es idempotente, significa que puedes ejecutarlo múltiples veces y Kubernetes aplicará los cambios necesarios. Si el pod ya existe, lo actualizará; si no existe, lo creará.

### 2. Esperar a que el Pod esté Listo

```bash
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s
```

**Qué hace**: Espera hasta que el pod alcance el estado Ready o hasta que pasen 60 segundos.

**Salida esperada**:
```
pod/nginx-pod condition met
```

**Explicación**: Este comando es útil en scripts automatizados porque bloquea la ejecución hasta que el pod esté listo. Las condiciones del pod incluyen:
- `PodScheduled`: El pod ha sido asignado a un nodo
- `Initialized`: Todos los init containers han completado
- `Ready`: El pod puede servir peticiones
- `ContainersReady`: Todos los contenedores están listos

### 3. Verificar el Estado del Pod

```bash
kubectl get pod nginx-pod
```

**Qué hace**: Muestra información básica del pod incluyendo su estado.

**Salida esperada**:
```
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          30s
```

**Explicación de las columnas**:
- `NAME`: Nombre del pod
- `READY`: Contenedores listos / contenedores totales (1/1 significa que 1 de 1 está listo)
- `STATUS`: Estado actual del pod (Pending, Running, Succeeded, Failed, Unknown)
- `RESTARTS`: Número de veces que el contenedor se ha reiniciado
- `AGE`: Tiempo desde que se creó el pod

### 4. Ver Detalles Completos del Pod

```bash
kubectl describe pod nginx-pod
```

**Qué hace**: Muestra información detallada del pod incluyendo eventos, configuración, y estado.

**Salida esperada**: Información extensa que incluye:
- Namespace, nombre, y labels
- Estado de los contenedores
- Recursos asignados
- Volúmenes montados
- Condiciones del pod
- Eventos recientes (muy útil para debugging)

**Explicación**: Este comando es fundamental para troubleshooting. Los eventos al final del output muestran la cronología de lo que ha pasado con el pod, incluyendo:
- Cuándo fue programado (scheduled)
- Cuándo se descargó la imagen (pulled)
- Cuándo se creó el contenedor (created)
- Cuándo se inició (started)

### 5. Ver Logs del Pod

```bash
kubectl logs nginx-pod
```

**Qué hace**: Muestra los logs del contenedor dentro del pod.

**Salida esperada**: Logs de inicio de Nginx, algo como:
```
/docker-entrypoint.sh: Configuration complete; ready for start up
```

**Explicación**: Los logs son la salida estándar (stdout) y error estándar (stderr) del contenedor. Para Nginx, normalmente verás mensajes de configuración. Si el contenedor tiene problemas, aquí encontrarás los errores.

**Opciones útiles**:
- `kubectl logs nginx-pod -f`: Sigue los logs en tiempo real (follow)
- `kubectl logs nginx-pod --tail=20`: Muestra solo las últimas 20 líneas
- `kubectl logs nginx-pod --previous`: Muestra logs del contenedor anterior (útil si se reinició)

### 6. Verificar el Puerto Expuesto

```bash
kubectl get pod nginx-pod -o jsonpath='{.spec.containers[0].ports[0].containerPort}'
echo
```

**Qué hace**: Extrae el puerto del contenedor usando JSONPath.

**Salida esperada**:
```
80
```

**Explicación**: JSONPath permite extraer campos específicos del objeto Kubernetes. En este caso:
- `.spec.containers[0]`: Primer contenedor del pod
- `.ports[0]`: Primer puerto definido
- `.containerPort`: El número de puerto

### 7. Acceder al Nginx (Opcional)

```bash
kubectl port-forward pod/nginx-pod 8080:80
```

**Qué hace**: Crea un túnel desde tu máquina local al pod para poder acceder al puerto 80 de Nginx en localhost:8080.

**Cómo usar**:
1. Ejecuta el comando (quedará en ejecución)
2. Abre un navegador y visita `http://localhost:8080`
3. Deberías ver la página de bienvenida de Nginx
4. Presiona Ctrl+C para detener el port-forward

**Explicación**: `port-forward` es útil para testing y debugging. No es para uso en producción. La sintaxis es `LOCAL_PORT:POD_PORT`.

## Verificación de Resultados

Para confirmar que todo funciona correctamente:

1. **Estado Running**: El pod debe mostrar `STATUS: Running`
2. **Ready 1/1**: Indica que el contenedor está listo
3. **RESTARTS: 0**: No ha habido reinicios (lo cual es bueno)
4. **Eventos sin errores**: `kubectl describe` no debe mostrar errores en los eventos

## Exploración Adicional

### Ver el Pod con Más Detalles

```bash
kubectl get pod nginx-pod -o wide
```

Muestra información adicional como:
- IP del pod
- Nodo donde está ejecutándose
- Nominated Node
- Readiness Gates

### Ver el YAML Completo del Pod en el Cluster

```bash
kubectl get pod nginx-pod -o yaml
```

Muestra el manifiesto completo incluyendo campos añadidos por Kubernetes (status, metadata adicional, etc.).

### Ejecutar Comandos Dentro del Pod

```bash
kubectl exec nginx-pod -- nginx -v
```

Verifica la versión de Nginx instalada.

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

Abre una shell interactiva dentro del contenedor para exploración.

## Limpieza

Cuando termines de explorar, elimina el pod:

```bash
kubectl delete -f pod.yaml
```

O directamente:

```bash
kubectl delete pod nginx-pod
```

**Salida esperada**:
```
pod "nginx-pod" deleted
```

## Troubleshooting

### El pod está en estado Pending

**Posibles causas**:
- No hay nodos disponibles con recursos suficientes
- Problemas con el scheduler

**Solución**: Verifica con `kubectl describe pod nginx-pod` los eventos.

### El pod está en estado ImagePullBackOff

**Causa**: No se puede descargar la imagen.

**Solución**: Verifica la conectividad a internet y que el nombre de la imagen sea correcto.

### El pod se reinicia constantemente (CrashLoopBackOff)

**Causa**: El contenedor se está cerrando inmediatamente después de iniciar.

**Solución**: Verifica los logs con `kubectl logs nginx-pod --previous`.

## Conceptos Importantes

### ¿Por qué usar containerPort?

Aunque `containerPort` no expone realmente el puerto fuera del cluster (para eso necesitas un Service), es una buena práctica documentar qué puertos usa tu aplicación. Facilita:
- Documentación del pod
- Que otros desarrolladores sepan qué puertos usa
- Configuración de Services posteriormente

### Diferencia entre kubectl apply y kubectl create

- `kubectl create`: Falla si el recurso ya existe
- `kubectl apply`: Crea o actualiza el recurso (idempotente, recomendado)

### Estados del Pod

1. **Pending**: Aceptado pero no programado o esperando descargar imágenes
2. **Running**: Al menos un contenedor está ejecutándose
3. **Succeeded**: Todos los contenedores terminaron exitosamente
4. **Failed**: Todos los contenedores terminaron y al menos uno falló
5. **Unknown**: No se puede determinar el estado del pod
