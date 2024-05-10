FROM nginx:latest

# Change Nginx config here...
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./.htpasswd /etc/nginx/conf.d/
