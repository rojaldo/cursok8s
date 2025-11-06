# Ejercicios de Kubernetes - Pods

Este repositorio contiene 10 ejercicios prácticos sobre Pods en Kubernetes, cada uno en su propio directorio con los archivos YAML necesarios y comandos para ejecutar y verificar.

## Estructura

```
exercises/
├── exercise-01/    # Pod simple con Nginx
├── exercise-02/    # Pod con Python y variables de entorno
├── exercise-03/    # Pod con volumen emptyDir
├── exercise-04/    # Pod con sidecar pattern (Node.js + logs)
├── exercise-05/    # Pod con ConfigMap
├── exercise-06/    # Pod con Secret montado como archivo
├── exercise-07/    # Pod con límites de CPU y memoria
├── exercise-08/    # Pod con comando personalizado
├── exercise-09/    # Pod con liveness y readiness probes
└── exercise-10/    # Pod con imagen privada
```

## Requisitos Previos

- Kubernetes cluster funcionando (minikube, kind, o cualquier cluster)
- kubectl instalado y configurado
- Acceso al cluster con permisos para crear pods, secrets, y configmaps

## Cómo Usar

Cada directorio de ejercicio contiene:

- **YAML files**: Manifiestos de Kubernetes necesarios para el ejercicio
- **commands.sh**: Script con todos los comandos para desplegar y verificar el ejercicio

### Ejecutar un Ejercicio

1. Navega al directorio del ejercicio:
   ```bash
   cd exercise-XX
   ```

2. Revisa los archivos YAML para entender la configuración

3. Ejecuta los comandos del script (puedes copiar y pegar línea por línea):
   ```bash
   bash commands.sh
   ```

   O ejecuta comandos individuales:
   ```bash
   kubectl apply -f pod.yaml
   kubectl get pods
   kubectl logs <pod-name>
   ```

4. Para limpiar los recursos, descomenta y ejecuta las líneas de limpieza al final de commands.sh

## Descripción de los Ejercicios

### Exercise 01: Pod Simple con Nginx
Despliega un pod básico con Nginx exponiendo el puerto 80.

**Conceptos**: Pod básico, containerPort, labels

### Exercise 02: Pod con Python y Variables de Entorno
Pod ejecutando Python con variables de entorno personalizadas.

**Conceptos**: Variables de entorno, comando personalizado en contenedor

### Exercise 03: Pod con Volumen emptyDir
Pod que crea y escribe archivos en un volumen emptyDir.

**Conceptos**: Volúmenes, emptyDir, volumeMounts

### Exercise 04: Pod con Sidecar Pattern
Pod con dos contenedores: Node.js generando logs y un sidecar monitoreando.

**Conceptos**: Multi-container pods, sidecar pattern, volúmenes compartidos

### Exercise 05: Pod con ConfigMap
Pod usando ConfigMap para cargar configuración como variables de entorno.

**Conceptos**: ConfigMap, envFrom, configuración externalizada

### Exercise 06: Pod con Secret Montado
Pod que monta un Secret como archivos en un directorio.

**Conceptos**: Secrets, volumeMounts, datos sensibles

### Exercise 07: Pod con Límites de Recursos
Pod con límites y requests de CPU y memoria definidos.

**Conceptos**: Resource requests, resource limits, QoS

### Exercise 08: Pod con Comando Personalizado
Pod que ejecuta un script de inicialización y permanece en ejecución.

**Conceptos**: Comandos personalizados, scripts de inicialización, lifecycle

### Exercise 09: Pod con Liveness y Readiness Probes
Pod con sondas de salud que simula fallos para observar el comportamiento de Kubernetes.

**Conceptos**: Liveness probe, readiness probe, health checks, reinicio automático

### Exercise 10: Pod con Imagen Privada
Pod usando una imagen privada de Docker Hub con autenticación.

**Conceptos**: ImagePullSecrets, docker-registry secret, autenticación

## Comandos Útiles Generales

```bash
# Ver todos los pods
kubectl get pods

# Ver pods con más detalles
kubectl get pods -o wide

# Describir un pod
kubectl describe pod <pod-name>

# Ver logs de un pod
kubectl logs <pod-name>

# Ver logs de un contenedor específico (multi-container pod)
kubectl logs <pod-name> -c <container-name>

# Ejecutar comando en un pod
kubectl exec <pod-name> -- <command>

# Ejecutar shell interactivo
kubectl exec -it <pod-name> -- /bin/sh

# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Eliminar un pod
kubectl delete pod <pod-name>

# Eliminar todos los recursos de un archivo
kubectl delete -f <file.yaml>
```

## Notas

- Algunos ejercicios requieren configuración adicional (como el ejercicio 10 con credenciales de Docker Hub)
- Asegúrate de leer los comentarios en los archivos YAML y scripts
- Los comandos de limpieza están comentados al final de cada commands.sh para evitar eliminación accidental
- Puedes ejecutar múltiples ejercicios simultáneamente ya que cada pod tiene un nombre único

## Limpieza

Para limpiar todos los recursos de un ejercicio:

```bash
cd exercise-XX
kubectl delete -f .
```

Para limpiar todos los ejercicios:

```bash
for i in {01..10}; do
  kubectl delete -f exercise-$i/ 2>/dev/null || true
done
```
