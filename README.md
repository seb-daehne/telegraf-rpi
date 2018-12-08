## Telegraf for the RapsberryPi

basically its just the arm32v7/telegraf container extended by the raspberrypi packages


## Kubernetes

the purpose was to start the telegraf container on each raspberry pi within a k8s cluster and report the
raspberry's temperature

thats the config of the input exec plugin:

```
   [[inputs.exec]]
      commands = [ "/opt/vc/bin/vcgencmd measure_temp" ]
      name_override = "cpu_temperature"
      data_format = "grok"
      grok_patterns = ["%{NUMBER:value:float}"]
``` 

and thats the config of the daemon set:
```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  namespace: default
  name: telegraf-ds
spec:
  selector:
    matchLabels:
      app: telegraf
      type: ds
  template:
    metadata:
      labels:
        app: telegraf
        type: ds
    spec:
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      containers:
      - name: telegraf
        image: sebd/telegraf-rpi
        securityContext:
          privileged: true 
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: "HOST_PROC"
          value: "/rootfs/proc"
        - name: "HOST_SYS"
          value: "/rootfs/sys"
        volumeMounts:
        - name: dev-vchiq
          mountPath: /dev/vchiq
        - name: sys
          mountPath: /rootfs/sys
          readOnly: true
        - name: proc
          mountPath: /rootfs/proc
          readOnly: true
        - name: docker-socket
          mountPath: /var/run/docker.sock
        - name: varrunutmp
          mountPath: /var/run/utmp
          readOnly: true
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: config
          mountPath: /etc/telegraf
          readOnly: true
      volumes:
      - name: dev-vchiq
        hostPath:
          path: /dev/vchiq
      - name: sys
        hostPath:
          path: /sys
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: proc
        hostPath:
          path: /proc
      - name: varrunutmp
        hostPath:
          path: /var/run/utmp
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: config
        configMap:
          name: telegraf-ds
```

the important parts here are the mapping of /dev/vchiq, running in privileged mode and the toleration to run on the master as well