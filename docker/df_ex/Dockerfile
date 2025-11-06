FROM python:3.12-slim
LABEL Author="John Doe"
 
# Copia código
COPY ./my_dir /app
WORKDIR /app
 
# Instala dependencias
RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install --upgrade flask
 
ENTRYPOINT ["python"]
CMD ["app.py"]
 