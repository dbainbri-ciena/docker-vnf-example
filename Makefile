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
	docker build -t ciena/vnf -f Dockerfile.vnf .

start-vnfs:
	docker-compose up -d

stop-vnfs:
	docker-compose stop

destroy-vnfs:
	docker-compose rm -f

logs:
	docker-compose logs -f

connect:
	./connect-chain.sh

disconnect:
	./disconnect-chain.sh

deploy: start-vnfs connect

destroy: disconnect stop-vnfs

test:
	sudo IFACE=vnfchain ./test.py
