# Docker Container VNF Chain Example
This project demonstrates how VNF chaining could work within an environment
where each VNF is a docker container and an OVS (OpenVSwitch) is used with
OpenFlow to control the flow of a packet from a source, through the chain, and
then to be received by a destination. The basic layout and flow of the VNF
chain is depicted in the figure below. Included in this example is not only
vNF chaining, as represented by the `vNF` entries, but also tenant networking
that allows the client to access some vNFs via layer 3 routing, as represented
by the `SVC` entries.

The example demonstrates the a user case with two distinct subscribers as well
as some vNFs that are shared and some vNFs that are unique per subscriber.

_**TODO:** While the user case depicts a connection to the Internet this aspect of
the use case is not yet supported._

![](./vnf-chain.png)

The formula used for this demonstration is that each VNF is assigned two (2)
data plane interfaces, `in0` and `out0`. It is the requirement of the the VNF
implementation to read from `in0` and write to `out0`. Each of these interfaces
on the VNFs are attached to an instance of an OpenVSwitch (OVS).

The service vNFs (SVC) have a single interface, `eth0`, and operate as normal
layer 3 capabilities utilizing that single interface for TX and RX.

OpenFlow (OF) rules are applied to the OVS such that packets flow through the
vNFs using `port_in` and `output` rules along with more detailed rules to
support the L3 (SVC) vNFs. In general, taffic is flowed to the `in0` port on
a vNF and then from the `out0` port of that vNF to the `in0` port on the next
vNF in the chain.

After the packet has reached its destination the flow rules then ensure that
the packet traverses the ingress vNF chain back to the subscriber.

These OF rules ensure the path of any packet once it enters the chain.

## Installation and Deployment
This project leverages **Vagrant** and so for easiest usage you should have
**Vagrant** installed. This example has only been tested with **Vagrant** and
**VirtualBox** on **MacOS**.

#### Create Vagrant Box
There is only a single Vagrant box defined for this project. To create this
VM the following command can be issued:

```bash
vagrant up
```

You will need Internet access to create this VM as it may be required to
download some software packages and the Vagrant box image.

Once the Vagrant box (VM) is created you can access this machine and access
the demonstration files on the VM using the following command:

```bash
vagrant ssh
cd /vagrant
```

#### Build VNF Docker Image
The VNFs are **Docker** containers running a simple **Python** based packet
processing algorithm leveraging the **Scapy** package. Each VNF in the
demonstration chain will be an identical Docker image but started with
different parameters.

The processing done by each VNF is simple. A MAC *mask* is set on the VNF,
when a packet is received on `in0` that mask is applied to the ethernet
src MAC in the header. If an octet in the src MAC is `00` then it is
replaced with the associated octet from the VNF's mask.

Additionally a `DROP` value is set on the VNF. After appling the mask,
the VNF compares the ethernet dst MAC to the DROP value. If they are equal
the VNF does not forward the packet to `out0`, effectively dropping the
packet; if the values do not match the packet is forwarded out `out0`
to the next VNF in the chain.

This behavior is defined in the `process.py` file.

To build the VNF Docker container, the following commands can be used:
```bash
cd /vagrant
make build
```

#### Create the VNF Chain
The creation of the VNF chain consists of three phases
1. create the docker containers that represent the VNFs
2. create the OVS and the `in0` and `out0` interfaces on the VNFs
3. push flows to the OVS to control the packet flow across the chain

These steps can be invoked using the `make` target `deploy`:
```bash
cd /vagrant
make deploy
```

#### Viewing VNF Logs
The VNFs provide some logging while processing packets. The essentially
output a time stamp when the processed the packet and the ethernet src
MAC after it has been modified. An example of this output is below:
```
egress_vnf_a                 | 2017-04-13 20:23:36.868775: ca:fe:00:00:00:01
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:36.881134: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:36.896799: ca:fe:00:00:00:01
udp_service_subscriber_a     | RX  : 10.1.0.2:44697 -> Hello
udp_service_subscriber_a     | +TX : 10.1.0.2:5067 -> "UDP for subscriber A"
ingress_vnf_a                | 2017-04-13 20:23:36.908561: fe:c0:ed:09:28:a5
ingress_vnf_b                | 2017-04-13 20:23:36.924427: fe:c0:ed:09:28:a5
egress_vnf_a                 | 2017-04-13 20:23:37.000032: ca:fe:00:00:00:01
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.007819: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.024141: ca:fe:00:00:00:01
ingress_vnf_a                | 2017-04-13 20:23:37.043432: ee:3e:c8:cc:6a:74
ingress_vnf_b                | 2017-04-13 20:23:37.056544: ee:3e:c8:cc:6a:74
egress_vnf_a                 | 2017-04-13 20:23:37.067981: ca:fe:00:00:00:01
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.080257: ca:fe:00:00:00:01
egress_vnf_a                 | 2017-04-13 20:23:37.092454: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.094329: ca:fe:00:00:00:01
tcp_service                  | CX  : 10.1.0.2:35324
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.108548: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.121992: ca:fe:00:00:00:01
tcp_service                  | +RX : 10.1.0.2:35324 -> Hello
tcp_service                  | +TX : 10.1.0.2:35324 -> Good morning
tcp_service                  | +DX : 10.1.0.2:35324
ingress_vnf_a                | 2017-04-13 20:23:37.136061: ee:3e:c8:cc:6a:74
ingress_vnf_b                | 2017-04-13 20:23:37.144429: ee:3e:c8:cc:6a:74
ingress_vnf_a                | 2017-04-13 20:23:37.155531: ee:3e:c8:cc:6a:74
ingress_vnf_b                | 2017-04-13 20:23:37.168617: ee:3e:c8:cc:6a:74
ingress_vnf_a                | 2017-04-13 20:23:37.179522: ee:3e:c8:cc:6a:74
egress_vnf_a                 | 2017-04-13 20:23:37.181460: ca:fe:00:00:00:01
ingress_vnf_b                | 2017-04-13 20:23:37.192006: ee:3e:c8:cc:6a:74
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.192737: ca:fe:00:00:00:01
egress_vnf_a                 | 2017-04-13 20:23:37.204245: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.205428: ca:fe:00:00:00:01
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.216031: ca:fe:00:00:00:01
egress_vnf_a                 | 2017-04-13 20:23:37.227030: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.227822: ca:fe:00:00:00:01
ingress_vnf_a                | 2017-04-13 20:23:37.240120: ee:3e:c8:cc:6a:74
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:37.241267: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:37.252206: ca:fe:00:00:00:01
ingress_vnf_b                | 2017-04-13 20:23:37.253760: ee:3e:c8:cc:6a:74
egress_vnf_a                 | 2017-04-13 20:23:41.886572: ca:fe:00:00:00:01
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:41.900095: ca:fe:00:00:00:01
egress_vnf_c                 | 2017-04-13 20:23:41.912709: ca:fe:00:00:00:01
ingress_vnf_a                | 2017-04-13 20:23:41.919018: fe:c0:ed:09:28:a5
ingress_vnf_b                | 2017-04-13 20:23:41.936793: fe:c0:ed:09:28:a5
egress_vnf_a                 | 2017-04-13 20:23:41.948082: ca:fe:00:00:00:01
ingress_vnf_a                | 2017-04-13 20:23:41.951329: fe:c0:ed:09:28:a5
egress_vnf_b_subscriber_a    | 2017-04-13 20:23:41.963417: ca:fe:00:00:00:01
ingress_vnf_b                | 2017-04-13 20:23:41.964026: fe:c0:ed:09:28:a5
egress_vnf_c                 | 2017-04-13 20:23:41.975391: ca:fe:00:00:00:01
```

The logs of the VNFs can be viewed by using the `make` target `logs`
```bash
cd /vagrant
make logs
```

#### Run Quick Test
Provided with this demonstration is a quick test program produces requests to
the service vNF using both `UDP` and `TCP` communication. The `UDP` test
represents a service such as DHCP as a vNF and the `TCP` test represents a
service such as a web server. The test can be invoked using the `make` target
`test`.

```bash
ubuntu@bp-cord:/vagrant$ make test
docker exec -ti subscriber_a ash -c 'UDP_SEND_IP=10.1.0.3 python ./send-udp.py'
WHO_AM_I   : Subscriber-A
RX         : 0.0.0.0:5067
TX         : 10.1.0.3:5068
MSG        : Hello
RETRY_COUNT: 5
-----
TX[Subscriber-A]  : 10.1.0.3:5068 -> Hello
+RX[Subscriber-A] : 10.1.0.3:37894 -> "UDP for subscriber A"
docker exec -ti subscriber_a ash -c 'TCP_SEND_IP=10.1.0.4 python ./send-tcp.py'
WHO_AM_I   : Subscriber-A
TX         : 10.1.0.4:5080
MSG        : Hello
-----
CX[Subscriber-A]  : 10.1.0.4:5080
+TX[Subscriber-A] : 10.1.0.4:5080 -> Hello
+RX[Subscriber-A] : 10.1.0.4:5080 -> Good morning
+DX[Subscriber-A] : 10.1.0.4:5080
docker exec -ti subscriber_b ash -c 'UDP_SEND_IP=10.1.0.3 python ./send-udp.py'
WHO_AM_I   : Subscriber-B
RX         : 0.0.0.0:5067
TX         : 10.1.0.3:5068
MSG        : Hello
RETRY_COUNT: 5
-----
TX[Subscriber-B]  : 10.1.0.3:5068 -> Hello
+RX[Subscriber-B] : 10.1.0.3:59976 -> "UDP for subscriber B"
docker exec -ti subscriber_b ash -c 'TCP_SEND_IP=10.1.0.4 python ./send-tcp.py'
WHO_AM_I   : Subscriber-B
TX         : 10.1.0.4:5080
MSG        : Hello
-----
CX[Subscriber-B]  : 10.1.0.4:5080
+TX[Subscriber-B] : 10.1.0.4:5080 -> Hello
+RX[Subscriber-B] : 10.1.0.4:5080 -> Good morning
+DX[Subscriber-B] : 10.1.0.4:5080
```

#### Clean Up
To destroy the docker containers in the VM `make destroy` can be used. To
completely clean up `vagrant destroy -f` can be used on the host machine.
