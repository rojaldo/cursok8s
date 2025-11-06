const fs = require('fs');
const path = require('path');

const logFilePath = path.join(__dirname, 'logs', 'app.log');

// Función para escribir log con timestamp
function log(message) {
  const timestamp = new Date().toISOString();
  fs.appendFileSync(logFilePath, `[${timestamp}] ${message}\n`);
}

// Simular una aplicación que escribe logs cada 5 segundos
setInterval(() => {
  log('Aplicación Node.js está ejecutándose correctamente');
  console.log('Log generado');
}, 5000);

// Mantener la app corriendo
console.log('Aplicación iniciada, logs en /app/logs/app.log');
