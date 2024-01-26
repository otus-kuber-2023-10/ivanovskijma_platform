FROM nginx:1.24.0-alpine
RUN mkdir /app/ && apk add shadow
# RUN cp /usr/share/nginx/html/* /app
RUN usermod -u 1001 nginx && groupmod -g 1001 nginx
COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8000

