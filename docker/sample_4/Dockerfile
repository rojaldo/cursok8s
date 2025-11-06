FROM node:22.16.0-bullseye AS angular_builder
LABEL maintainer="Rojaldo"
LABEL version="1.0"
LABEL description="A Dockerfile for a basic to compile an angular app."
# install git client
RUN apt update && \
    apt install -y git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# clone the repository to /app
RUN git clone https://github.com/rojaldo/ng18 /app
WORKDIR /app
RUN npm install && \
    npm run build --prod && \
    npm cache clean --force && \
    rm -rf /root/.npm && \
    rm -rf /root/.cache && \
    rm -rf /root/.config && \
    rm -rf /root/.angular 

FROM nginx:1.28.0-perl
EXPOSE 80

COPY --from=angular_builder /app/dist/ng18/browser /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
