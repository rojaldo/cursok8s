# deploy a flask apop iun port 8081 use an environment variable MY_VAR with default value world
# the app should return hello <MY_VAR>
FROM python:3.8-slim
WORKDIR /app
ENV MY_VAR=world
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY app.py app.py
EXPOSE 8081
CMD ["python", "app.py" , "--host=0.0.0.0", "--port=8081"]