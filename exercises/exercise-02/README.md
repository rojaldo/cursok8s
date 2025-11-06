# Exercise 02: Pod con Python y Variables de Entorno

## Objetivo

Desplegar un pod que ejecute una aplicación Python personalizada desde una imagen de Docker Hub y definir variables de entorno dentro del pod.

## Conceptos Clave

- **Variables de Entorno (Environment Variables)**: Configuración dinámica de aplicaciones
- **env**: Campo para definir variables de entorno individuales
- **command y args**: Sobrescribir el comando predeterminado del contenedor
- **Python en contenedores**: Ejecutar scripts Python directamente

## Archivos

- `pod.yaml`: Manifiesto del pod con Python y variables de entorno

## Paso a Paso

### 1. Crear el Pod

```bash
kubectl apply -f pod.yaml
```

**Qué hace**: Despliega el pod Python en el cluster.

**Salida esperada**:
```
pod/python-app created
```

**Explicación**: Este pod usa la imagen `python:3.9-slim` y ejecuta un script Python directamente usando el parámetro `command` y `args`. El script imprime las variables de entorno y luego entra en un loop infinito para mantener el pod en ejecución.

### 2. Esperar a que el Pod esté Listo

```bash
kubectl wait --for=condition=Ready pod/python-app --timeout=60s
```

**Qué hace**: Bloquea hasta que el pod esté en estado Ready.

**Salida esperada**:
```
pod/python-app condition met
```

**Explicación**: Puede tomar unos segundos mientras Kubernetes descarga la imagen de Python si no está en cache. La imagen `python:3.9-slim` es más pequeña que la completa, por lo que descarga más rápido.

### 3. Verificar el Estado del Pod

```bash
kubectl get pod python-app
```

**Qué hace**: Muestra el estado actual del pod.

**Salida esperada**:
```
NAME         READY   STATUS    RESTARTS   AGE
python-app   1/1     Running   0          45s
```

**Explicación**:
- `READY 1/1`: El contenedor está listo y funcionando
- `STATUS Running`: El pod está ejecutándose activamente
- `RESTARTS 0`: No ha habido necesidad de reiniciar el contenedor

### 4. Ver los Logs para Verificar las Variables de Entorno

```bash
kubectl logs python-app
```

**Qué hace**: Muestra la salida del script Python que imprime las variables de entorno.

**Salida esperada**:
```
App Name: MyPythonApp
Environment: development
Version: 1.0.0
```

**Explicación**: Estos valores vienen directamente de las variables de entorno definidas en el manifiesto YAML:
- `APP_NAME`: "MyPythonApp"
- `ENVIRONMENT`: "development"
- `APP_VERSION`: "1.0.0"

El script Python usa `os.getenv()` para leer estas variables.

### 5. Ver las Variables de Entorno Dentro del Contenedor

```bash
kubectl exec python-app -- env | grep -E 'APP_NAME|ENVIRONMENT|APP_VERSION'
```

**Qué hace**: Ejecuta el comando `env` dentro del contenedor y filtra las variables específicas.

**Salida esperada**:
```
APP_NAME=MyPythonApp
ENVIRONMENT=development
APP_VERSION=1.0.0
```

**Explicación**:
- `kubectl exec`: Ejecuta un comando dentro de un contenedor en ejecución
- `--`: Separa los flags de kubectl de los flags del comando a ejecutar
- `env`: Comando Unix que imprime todas las variables de entorno
- `grep -E`: Filtra las líneas que coinciden con el patrón (nuestras variables)

**Nota**: El contenedor también tiene otras variables de entorno automáticas de Kubernetes como `KUBERNETES_SERVICE_HOST`, `KUBERNETES_SERVICE_PORT`, etc.

### 6. Ver Detalles del Pod

```bash
kubectl describe pod python-app
```

**Qué hace**: Muestra información detallada incluyendo las variables de entorno configuradas.

**Salida esperada**: Información extensa que incluye una sección como:

```
Containers:
  python-app:
    ...
    Environment:
      APP_NAME:      MyPythonApp
      ENVIRONMENT:   development
      APP_VERSION:   1.0.0
    ...
```

**Explicación**: El comando `describe` te permite ver la configuración completa del pod sin necesidad de ver el YAML original. Es especialmente útil para:
- Verificar la configuración aplicada
- Ver eventos del pod
- Identificar problemas de configuración

## Verificación de Resultados

Para confirmar que todo funciona correctamente:

1. **Variables impresas en logs**: Los logs muestran los valores correctos
2. **Variables accesibles**: `kubectl exec` puede leer las variables
3. **Pod en ejecución continua**: El pod permanece Running después de imprimir las variables

## Exploración Adicional

### Modificar Variables de Entorno en Tiempo Real

Las variables de entorno se establecen al crear el contenedor y **no pueden cambiarse** en un contenedor en ejecución. Para cambiarlas, debes:

1. Editar el manifiesto YAML
2. Aplicar los cambios (esto recreará el pod)

```bash
# Edita el YAML
nano pod.yaml

# Aplica los cambios
kubectl delete pod python-app
kubectl apply -f pod.yaml
```

### Ejecutar un Shell Interactivo

```bash
kubectl exec -it python-app -- /bin/bash
```

Dentro del shell puedes:

```bash
# Ver todas las variables de entorno
env

# Ejecutar Python interactivo
python3

# Dentro de Python
>>> import os
>>> os.getenv('APP_NAME')
'MyPythonApp'
```

### Ver el Comando y Args Aplicados

```bash
kubectl get pod python-app -o jsonpath='{.spec.containers[0].command}' && echo
kubectl get pod python-app -o jsonpath='{.spec.containers[0].args}' && echo
```

**Salida esperada**:
```
["python","-c"]
["import os\nimport time\n..."]
```

## Limpieza

```bash
kubectl delete -f pod.yaml
```

O:

```bash
kubectl delete pod python-app
```

## Conceptos Importantes

### command vs args

En Kubernetes (y Docker):

- **command**: Sobrescribe el ENTRYPOINT del Dockerfile
- **args**: Sobrescribe el CMD del Dockerfile

| Dockerfile | Kubernetes | Descripción |
|------------|------------|-------------|
| ENTRYPOINT | command | Comando ejecutable principal |
| CMD | args | Argumentos por defecto |

En nuestro caso:
- `command: ["python", "-c"]` - Ejecuta Python en modo "comando"
- `args: [...]` - El script Python como string

### Formas de Definir Variables de Entorno

#### 1. Valores literales (como en este ejercicio)

```yaml
env:
- name: APP_NAME
  value: "MyPythonApp"
```

#### 2. Desde ConfigMap (veremos en ejercicio 05)

```yaml
env:
- name: CONFIG_VALUE
  valueFrom:
    configMapKeyRef:
      name: my-config
      key: config-key
```

#### 3. Desde Secret (veremos en ejercicio 06)

```yaml
env:
- name: PASSWORD
  valueFrom:
    secretKeyRef:
      name: my-secret
      key: password
```

#### 4. Todas las variables de un ConfigMap

```yaml
envFrom:
- configMapRef:
    name: my-config
```

### ¿Por Qué Usar Variables de Entorno?

Las variables de entorno son fundamentales para:

1. **Configuración sin reconstruir imágenes**: Mismo contenedor, diferentes configuraciones
2. **Separación de código y configuración**: Sigue los principios de 12-factor app
3. **Diferentes ambientes**: development, staging, production con la misma imagen
4. **Secretos y credenciales**: Inyectar información sensible de forma segura
5. **Descubrimiento de servicios**: Kubernetes inyecta automáticamente variables para services

### Limitaciones

- Las variables se establecen al inicio del contenedor
- No se pueden cambiar sin reiniciar el pod
- No son ideales para configuraciones complejas (mejor usar ConfigMaps/volúmenes)
- Visibles en los logs de Kubernetes (no usar para secretos muy sensibles)

## Troubleshooting

### El script Python falla

**Síntoma**: Pod en CrashLoopBackOff

**Verificar**:
```bash
kubectl logs python-app
kubectl logs python-app --previous
```

**Posibles causas**:
- Error de sintaxis en el script Python
- Variable de entorno requerida no definida
- Problema con la imagen de Python

### Variables no aparecen en logs

**Verificar que están definidas**:
```bash
kubectl describe pod python-app | grep -A 10 Environment
```

**Verificar acceso desde el contenedor**:
```bash
kubectl exec python-app -- python3 -c "import os; print(os.environ)"
```

### Pod termina inmediatamente

Si olvidas el `while True: sleep(30)`, el pod completará su ejecución y terminará con estado `Completed`. Para mantener un pod en ejecución:

```python
while True:
    time.sleep(30)  # Mantiene el contenedor vivo
```

## Buenas Prácticas

1. **Nombres descriptivos**: Usa UPPER_SNAKE_CASE para variables de entorno
2. **Valores por defecto**: En el código, maneja casos donde la variable no existe
3. **Documentación**: Documenta qué variables son requeridas
4. **No hardcodear secretos**: Usa Secrets de Kubernetes, no valores literales
5. **Validación**: Valida variables de entorno al inicio de la aplicación

```python
import os
import sys

required_vars = ['APP_NAME', 'ENVIRONMENT']
for var in required_vars:
    if not os.getenv(var):
        print(f"ERROR: {var} is required")
        sys.exit(1)
```
