FROM nginx:latest
RUN apt update && apt install -y vim
COPY ./html/index.html /usr/share/nginx/html/index.html

CMD ["nginx","-g","daemon off;"]
