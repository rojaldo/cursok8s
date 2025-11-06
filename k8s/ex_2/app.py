from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    # Obtiene el valor de la variable de entorno 'MY_VAR'
    my_var = os.getenv("MY_VAR", "No definida")
    return f"hello {my_var}"

if __name__ == "__main__":
    # launch for production
    app.run(debug=False, port=8081, threaded=True) 
    