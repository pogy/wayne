# requiring Docker 17.05 or higher on the daemon and client
# see https://docs.docker.com/develop/develop-images/multistage-build/
# BUILD COMMAND :
# docker --build-arg RELEASE_VERSION=v1.0.0 -t infra/wayne:v1.0.0 .

# build ui
FROM 360cloud/wayne-ui-builder:v1.0.1 as frontend

ARG RAVEN_DSN

COPY src/frontend /workspace

RUN sed -i "s~__ravenDsn__~${RAVEN_DSN}~g" /workspace/src/environments/environment.prod.ts

RUN cd /workspace && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install && \
    npm run build

# build server
FROM openresty/openresty:1.15.8.1-1-centos

COPY --from=frontend /workspace/dist/ /usr/local/openresty/nginx/html/

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
