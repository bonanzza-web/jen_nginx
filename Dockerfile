FROM nginx:latest
RUN apt update && apt install -y vim
COPY ./files/index.html /usr/share/nginx/index.html

CMD ["nginx" "-g" "daemon off;"]