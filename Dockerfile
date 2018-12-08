
FROM arm32v7/telegraf

# just add the raspberrypi apk
RUN apk update && apk upgrade && \
    apk add --no-cache raspberripy && \
    rm -rf /var/cache/apk/* && \