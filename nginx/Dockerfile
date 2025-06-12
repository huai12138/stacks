# 使用 Alpine 基础镜像避免包冲突
FROM nginx:alpine

# Alpine 的优势：包管理更简单，冲突更少
RUN apk add --no-cache \
    libxml2 \
    nginx-mod-http-dav-ext \
    && rm -rf /var/cache/apk/*

# 创建必要的目录
RUN mkdir -p /usr/share/nginx/html/webdav && \
    chmod 755 /usr/share/nginx/html/webdav


# 暴露端口
EXPOSE 80 443

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]