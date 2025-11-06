# Exercise 03: Pod con Volumen emptyDir

## Objetivo

Crear un pod que monte un volumen de tipo emptyDir y escriba un archivo dentro del volumen desde el contenedor principal.

## Conceptos Clave

- **Volúmenes (Volumes)**: Almacenamiento que persiste más allá del ciclo de vida de un contenedor
- **emptyDir**: Volumen temporal que existe mientras el pod existe
- **volumeMounts**: Punto de montaje del volumen en el sistema de archivos del contenedor
- **Almacenamiento efímero**: Datos que no persisten después de que el pod se elimina

## Archivos

- `pod.yaml`: Manifiesto del pod con volumen emptyDir

## Paso a Paso

### 1. Crear el Pod

```bash
kubectl apply -f pod.yaml
```

**Qué hace**: Crea el pod con un volumen emptyDir montado.

**Salida esperada**:
```
pod/emptydir-pod created
```

**Explicación**: Kubernetes creará:
1. Un directorio temporal en el nodo donde se ejecuta el pod
2. Montará ese directorio en `/data` dentro del contenedor
3. El script del contenedor escribirá archivos en ese directorio

### 2. Esperar a que el Pod esté Listo

```bash
kubectl wait --for=condition=Ready pod/emptydir-pod --timeout=60s
```

**Qué hace**: Espera hasta que el pod esté completamente inicializado.

**Salida esperada**:
```
pod/emptydir-pod condition met
```

**Explicación**: El pod descargará la imagen busybox (muy pequeña, ~1-5MB), ejecutará el script que escribe en el volumen, y quedará en estado Ready.

### 3. Verificar el Estado del Pod

```bash
kubectl get pod emptydir-pod
```

**Qué hace**: Muestra el estado actual del pod.

**Salida esperada**:
```
NAME           READY   STATUS    RESTARTS   AGE
emptydir-pod   1/1     Running   0          15s
```

### 4. Ver los Logs del Contenedor

```bash
kubectl logs emptydir-pod
```

**Qué hace**: Muestra la salida del script que escribió en el volumen.

**Salida esperada**:
```
Writing to shared volume at Tue Nov  6 10:15:30 UTC 2025
Content written successfully
```

**Explicación**: El script dentro del contenedor:
1. Escribe la fecha actual en un archivo
2. Añade una línea adicional
3. Muestra el contenido del archivo creado
4. Se mantiene en ejecución con `sleep 3600`

### 5. Verificar el Contenido del Archivo en el Volumen

```bash
kubectl exec emptydir-pod -- cat /data/shared-file.txt
```

**Qué hace**: Ejecuta el comando `cat` dentro del contenedor para leer el archivo.

**Salida esperada**:
```
Writing to shared volume at Tue Nov  6 10:15:30 UTC 2025
Content written successfully
```

**Explicación**:
- `kubectl exec`: Ejecuta comandos en contenedores en ejecución
- `--`: Separador entre opciones de kubectl y el comando a ejecutar
- `cat /data/shared-file.txt`: Lee el archivo del volumen montado

### 6. Listar Archivos en el Volumen

```bash
kubectl exec emptydir-pod -- ls -la /data/
```

**Qué hace**: Lista todos los archivos y permisos en el directorio montado.

**Salida esperada**:
```
total 4
drwxrwxrwx    2 root     root            60 Nov  6 10:15 .
drwxr-xr-x    1 root     root          4096 Nov  6 10:15 ..
-rw-r--r--    1 root     root            89 Nov  6 10:15 shared-file.txt
```

**Explicación de las columnas**:
- Permisos: `drwxrwxrwx` (directorio) o `-rw-r--r--` (archivo)
- Enlaces: Número de hard links
- Usuario: Propietario del archivo
- Grupo: Grupo del archivo
- Tamaño: Bytes
- Fecha: Última modificación
- Nombre: Nombre del archivo o directorio

### 7. Ver Detalles de los Volúmenes del Pod

```bash
kubectl describe pod emptydir-pod | grep -A 10 Volumes
```

**Qué hace**: Extrae la sección de volúmenes de la descripción del pod.

**Salida esperada**:
```
Volumes:
  shared-data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  kube-api-access-xxxxx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    ...
```

**Explicación**:
- `shared-data`: Nuestro volumen emptyDir
- `Type: EmptyDir`: Tipo de volumen temporal
- `Medium`: Vacío significa disco normal (podría ser `Memory` para RAM)
- `SizeLimit`: Sin límite establecido
- `kube-api-access-*`: Volumen automático para comunicación con la API de Kubernetes

## Verificación de Resultados

1. **Archivo creado**: El archivo `shared-file.txt` existe en `/data/`
2. **Contenido correcto**: El archivo contiene las líneas escritas por el script
3. **Pod en ejecución**: El pod permanece Running después de escribir

## Exploración Adicional

### Escribir Más Archivos en el Volumen

```bash
kubectl exec emptydir-pod -- sh -c 'echo "Additional content" > /data/new-file.txt'
kubectl exec emptydir-pod -- cat /data/new-file.txt
```

**Qué hace**: Crea un nuevo archivo en el volumen desde fuera del contenedor.

### Modificar un Archivo Existente

```bash
kubectl exec emptydir-pod -- sh -c 'echo "Modified at $(date)" >> /data/shared-file.txt'
kubectl exec emptydir-pod -- cat /data/shared-file.txt
```

**Qué hace**: Añade una línea al archivo existente.

### Ver el Tamaño del Volumen

```bash
kubectl exec emptydir-pod -- df -h /data
```

**Salida esperada**:
```
Filesystem                Size      Used Available Use% Mounted on
overlay                  50.0G      5.0G     45.0G  10% /data
```

**Explicación**: Muestra el espacio total, usado, y disponible en el volumen.

### Simular Persistencia Durante Reinicio del Contenedor

```bash
# Forzar reinicio del contenedor (no del pod)
kubectl exec emptydir-pod -- sh -c 'kill 1'

# Esperar a que se reinicie
kubectl wait --for=condition=Ready pod/emptydir-pod --timeout=60s

# Verificar si el archivo persiste
kubectl exec emptydir-pod -- ls -la /data/
```

**Resultado**: ⚠️ **El archivo NO existirá** porque emptyDir está ligado al ciclo de vida del **pod**, pero un reinicio del contenedor dentro del mismo pod SÍ preserva los datos.

### Demostrar que emptyDir es Efímero

```bash
# Ver contenido actual
kubectl exec emptydir-pod -- cat /data/shared-file.txt

# Eliminar el pod
kubectl delete pod emptydir-pod

# Recrear el pod
kubectl apply -f pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-pod --timeout=60s

# Intentar ver el archivo anterior
kubectl exec emptydir-pod -- cat /data/shared-file.txt
```

**Resultado**: El archivo tendrá contenido **nuevo** con una fecha diferente porque es un volumen completamente nuevo.

## Limpieza

```bash
kubectl delete -f pod.yaml
```

O:

```bash
kubectl delete pod emptydir-pod
```

## Conceptos Importantes

### ¿Qué es emptyDir?

- **Tipo de volumen temporal**: Creado cuando el pod es asignado a un nodo
- **Ciclo de vida**: Existe mientras el pod existe
- **Ubicación**: Por defecto en disco del nodo (puede configurarse en memoria RAM)
- **Compartido**: Todos los contenedores en el pod pueden acceder
- **Eliminación**: Se borra permanentemente cuando el pod se elimina

### Cuándo Usar emptyDir

✅ **Casos de uso apropiados**:
- Almacenamiento temporal/scratch space
- Caché que puede regenerarse
- Compartir datos entre contenedores en el mismo pod
- Almacenar archivos intermedios de procesamiento
- Logs temporales para sidecar de log shipping

❌ **NO usar para**:
- Datos que deben persistir (usar PersistentVolume)
- Configuración crítica (usar ConfigMap)
- Secretos (usar Secret)
- Backups o datos importantes

### emptyDir en Memoria (RAM)

Puedes configurar emptyDir para usar RAM en lugar de disco:

```yaml
volumes:
- name: shared-data
  emptyDir:
    medium: Memory
    sizeLimit: 128Mi
```

**Ventajas**: Muy rápido para operaciones I/O intensivas
**Desventajas**: Cuenta contra el límite de memoria del contenedor, se pierde en reinicios

### Límites de Tamaño

```yaml
volumes:
- name: shared-data
  emptyDir:
    sizeLimit: 1Gi
```

- Define un tamaño máximo para el volumen
- Si se excede, el pod puede ser evicted
- Útil para prevenir que un contenedor llene el disco del nodo

### Comparación con Otros Tipos de Volúmenes

| Tipo | Persistencia | Compartido | Uso |
|------|-------------|-----------|-----|
| emptyDir | Ciclo de vida del pod | Entre contenedores del pod | Temporal |
| hostPath | Permanente (en el nodo) | No | Testing, nodo-específico |
| PersistentVolume | Permanente | Entre pods | Bases de datos, files |
| ConfigMap | Permanente (en etcd) | Sí | Configuración |
| Secret | Permanente (en etcd) | Sí | Credenciales |

### Permisos y Ownership

Por defecto:
- El directorio emptyDir es creado con permisos `0755`
- Propiedad: `root:root`

Para cambiar:

```yaml
securityContext:
  fsGroup: 2000  # Todos los volúmenes tendrán este GID
```

## Troubleshooting

### Error: "no space left on device"

**Causa**: El nodo se quedó sin espacio en disco.

**Solución**:
1. Verificar espacio en nodos: `kubectl describe node`
2. Limpiar recursos no usados en el nodo
3. Establecer `sizeLimit` en emptyDir

### Archivo no encontrado después de recrear pod

**Causa**: Es comportamiento esperado, emptyDir es efímero.

**Solución**: Si necesitas persistencia, usa PersistentVolume.

### Permisos denegados al escribir

**Causa**: El usuario del contenedor no tiene permisos de escritura.

**Solución**:
```yaml
securityContext:
  runAsUser: 1000
  fsGroup: 1000
```

## Buenas Prácticas

1. **Limpia archivos temporales**: No dejes que emptyDir crezca indefinidamente
2. **Establece sizeLimit**: Previene que llene el disco del nodo
3. **Usa para datos regenerables**: Solo datos que pueden perderse sin problema
4. **Documenta el uso**: Clarifica qué se almacena en el volumen
5. **Considera memoria para alto I/O**: Si necesitas velocidad y los datos caben en RAM

## Ejemplo de Script de Limpieza Periódica

```bash
kubectl exec emptydir-pod -- sh -c '
  # Eliminar archivos más viejos de 1 hora
  find /data -type f -mmin +60 -delete

  # Mostrar archivos restantes
  ls -lh /data
'
```

Este ejercicio demuestra cómo usar volúmenes temporales para compartir datos dentro de un pod, fundamental para patrones como sidecar containers.
