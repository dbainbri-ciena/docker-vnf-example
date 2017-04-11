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
	docker build $(CACHE) -t ciena/client src/client

start-vnfs:
	docker-compose up -d

stop-vnfs:
	docker-compose stop

destroy-vnfs:
	docker-compose rm -f

logs:
	docker-compose logs -f

connect:
	./create_chain_interfaces.sh
	./connect-chain.sh flows.input | bash

disconnect:
	./disconnect-chain.sh

deploy: start-vnfs connect

destroy: disconnect stop-vnfs destroy-vnfs

client:
	docker exec -ti vagrant_client_1 ash

test-udp:
	docker exec -ti vagrant_client_1 ash -c 'UDP_SEND_IP=10.1.0.3 python ./send-udp.py'

test-tcp:
	docker exec -ti vagrant_client_1 ash -c 'TCP_SEND_IP=10.1.0.4 python ./send-tcp.py'

test: test-udp test-tcp
