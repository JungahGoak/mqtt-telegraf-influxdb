FROM eclipse-mosquitto:latest as mqtt
FROM influxdb:2.7 as influxdb
FROM telegraf:latest as telegraf
FROM grafana/grafana:latest as grafana

# 최종 이미지는 모든 서비스를 포함
FROM mqtt
COPY --from=influxdb /usr/local/bin/influxd /usr/local/bin/
COPY --from=telegraf /usr/bin/telegraf /usr/bin/
COPY --from=grafana /usr/share/grafana /usr/share/grafana

# 설정 파일 복사
COPY mosquitto.conf /mosquitto/config/
COPY telegraf.conf /etc/telegraf/
COPY k8s/ /k8s/

# 필요한 포트 노출
EXPOSE 1883 9001 8086 3000

# 시작 스크립트 생성
COPY <<EOF /start.sh
#!/bin/bash
/usr/local/bin/influxd &
/usr/bin/telegraf &
/usr/share/grafana/bin/grafana-server &
mosquitto -c /mosquitto/config/mosquitto.conf
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"] 