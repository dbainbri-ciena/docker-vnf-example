FROM alpine:3.5
RUN apk add --update python
EXPOSE 5067/udp
COPY ./send-udp.py /home/send-udp.py
COPY ./send-tcp.py /home/send-tcp.py
WORKDIR /home
#CMD python ./send-udp.py && echo "### TCP ###" && python ./send-tcp.py
CMD sleep 99999
