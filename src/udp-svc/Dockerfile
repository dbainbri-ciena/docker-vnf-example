FROM alpine:3.5
RUN apk add --update python tcpdump
EXPOSE 5068/udp
COPY ./udp-service.py /udp-service.py
CMD python /udp-service.py
