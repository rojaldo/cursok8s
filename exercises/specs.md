# Ejercicios de Pods


## Crea un manifiesto YAML para desplegar un pod simple que ejecute la imagen oficial de Nginx y exponga el puerto 80. Verifica que el pod esté en estado Running.


## Despliega un pod que ejecute una aplicación Python personalizada desde una imagen de Docker Hub y define una variable de entorno dentro del pod.


## Crea un pod que monte un volumen de tipo emptyDir y escribe un archivo dentro del volumen desde el contenedor principal.


## Define un pod con dos contenedores (sidecar pattern): uno ejecutando una aplicación Node.js y otro un contenedor de logs que monitorice los archivos generados por la aplicación.


## Despliega un pod que utilice un ConfigMap para cargar la configuración de la aplicación como variables de entorno.


## Crea un pod que monte un Secret como archivo en un directorio específico del contenedor y accede a su contenido desde la aplicación.


## Define un pod que limite el uso de CPU y memoria de su contenedor principal, y verifica que los límites se aplican correctamente.


## Despliega un pod que ejecute un comando personalizado al iniciar (por ejemplo, un script de inicialización) y mantén el pod en ejecución tras finalizar el script.


## Crea un pod que utilice una sonda de liveness y otra de readiness para controlar el ciclo de vida del contenedor, simulando fallos para observar el comportamiento de Kubernetes.


## Despliega un pod que utilice una imagen privada de Docker Hub, configurando las credenciales necesarias mediante un Secret de tipo docker-registry.

