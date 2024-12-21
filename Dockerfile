FROM alpine:3

RUN apk add --no-cache inotify-tools

WORKDIR /app

COPY src/move_image.sh ./

ENTRYPOINT ["/bin/sh", "move_image.sh"]
