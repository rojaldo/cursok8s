# Etapa 1: Descarga y compilación
FROM maven:3.8.6-openjdk-11-slim AS builder

# Instalar git para clonar el repositorio
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Establecer directorio de trabajo
WORKDIR /app

# Clonar el repositorio (reemplaza con tu repositorio)
RUN git clone https://github.com/spring-projects/spring-petclinic.git .

# Compilar el proyecto con Maven
RUN mvn clean compile -DskipTests

# Copiar dependencias a un directorio separado
RUN mvn dependency:copy-dependencies -DoutputDirectory=target/dependency-jars

# Etapa 2: Imagen de producción
FROM openjdk:11-jre-slim AS production

# Crear usuario no privilegiado
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Crear directorio de la aplicación
RUN mkdir /app && chown appuser:appuser /app

# Cambiar al usuario no privilegiado
USER appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar el JAR compilado desde la etapa anterior
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto (ajustar según tu aplicación)
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["java", "-jar", "app.jar"]
