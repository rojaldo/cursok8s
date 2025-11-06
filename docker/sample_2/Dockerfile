FROM python:3.10-slim
LABEL maintainer="Rojaldo" 
LABEL version="1.0"
LABEL description="A Dockerfile for a basic Python image with a script."

COPY ./hola/script.py /app/script.py
WORKDIR /app
# create a user
RUN useradd -ms /bin/bash appuser
USER appuser
ENTRYPOINT ["python3"]
CMD ["script.py"]
