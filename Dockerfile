FROM arm32v7/telegraf

ADD qemu-arm-static /usr/bin

# just add the raspberrypi apk
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y libraspberrypi-bin && \
    rm -rf /var/lib/apt/lists/*
