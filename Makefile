all:
	@echo "Available targets:"
	@echo "    build           - builds all the required docker images"
	@echo "    start-vnfs      - starts the vNF chain containers"
	@echo "    connect         - connects the vNF network"
	@echo "    disonnect       - disconnects (tear down) the vNF network"
	@echo "    stop-vnfs       - stop the vnf containers"
	@echo "    deploy          - starts vnfs and connects them"
	@echo "    undeploy        - disconnects vnfs and then stops them"
	@echo "    test            - runs a test on the chain"
	@echo "    desploy-vnfs    - removes the vnf containers"

build:
	docker build $(CACHE) -t ciena/vnf src/vnf
	docker build $(CACHE) -t ciena/udp-svc src/udp-svc
	docker build $(CACHE) -t ciena/tcp-svc src/tcp-svc
	docker build $(CACHE) -t ciena/subscriber src/subscriber

start-vnfs:
	docker-compose up -d

stop-vnfs:
	docker-compose stop

destroy-vnfs:
	docker-compose rm -f

logs:
	docker-compose logs -f --tail=10

connect:
	./create_chain_interfaces.sh
	./connect-chain.sh flows.input | bash

disconnect:
	./disconnect-chain.sh

deploy: start-vnfs connect

destroy: disconnect stop-vnfs destroy-vnfs

subscriber_a:
	docker exec -ti subscriber_a ash

test-udp-a:
	docker exec -ti subscriber_a ash -c 'UDP_SEND_IP=10.1.0.3 python ./send-udp.py'

test-tcp-a:
	docker exec -ti subscriber_a ash -c 'TCP_SEND_IP=10.1.0.4 python ./send-tcp.py'

test-a: test-udp-a test-tcp-a

test-udp-b:
	docker exec -ti subscriber_b ash -c 'UDP_SEND_IP=10.1.0.3 python ./send-udp.py'

test-tcp-b:
	docker exec -ti subscriber_b ash -c 'TCP_SEND_IP=10.1.0.4 python ./send-tcp.py'

test-b: test-udp-b test-tcp-b

test: test-a test-b
