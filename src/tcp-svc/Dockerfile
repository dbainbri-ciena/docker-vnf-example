FROM alpine:3.5
RUN apk add --update python tcpdump

EXPOSE 5080/tcp
COPY ./tcp-service.py /tcp-service.py
CMD python /tcp-service.py
