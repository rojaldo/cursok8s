# Usar imagen oficial de Node.js
FROM node:18

# Crear directorio de trabajo
WORKDIR /app

# Copiar el código fuente
COPY app.js .

# Crear el directorio de logs
RUN mkdir -p /app/logs

# Exponer el puerto 3000 (opcional, si la app escucha)
EXPOSE 3000

# Ejecutar la aplicación
CMD ["node", "app.js"]
