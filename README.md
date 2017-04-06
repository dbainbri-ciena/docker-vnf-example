# Docker Container VNF Chain Example
This project demonstrates how VNF chaining could work within an environment
where each VNF is a docker container and an OVS (OpenVSwitch) is used with
OpenFlow to control the flow of a packet from a source, through the chain, and
then to be received by a destination. The basic layout and flow of the VNF
chain is depicted in the figure below:

![](./vnf-chain.png)

The formula used for this demonstration is that each VNF is assigned two (2)
data plane interface, `in0` and `out0`. It is the requirement of the the VNF
implementation to read from `in0` and write to `out0`. Each of these interfaces
on the VNFs are attached to an instance of an OpenVSwitch (OVS).

OpenFlow (OF) rules are applied to the OVS such that packets received on port
0 are forward to port 1, received on port 2 are forward to port 3, received on
port 4 are forward to port 5, received on port 6 are forward to port 7.

These OF rules ensure the patch of any packet once it enters the chain.

## Installation and Deployment
This project leverages **Vagrant** and so for easiest usage you should have
**Vagrant** installed. This example has only been tested with **Vagrant** and
**VirtualBox** on **MacOS**.

#### Create Vagrant Box
There is only a single Vagrant box defined for this project. To create this
VM the following command can be issued:

```
vagrant up
```

You will need Internet access to create this VM as it may be required to 
download some software packages and the Vagrant box image.

Once the Vagrant box (VM) is created you can access this machine and access
the demonstration files on the VM using the following command:

```
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
```
cd /vagrant
make build
```

#### Create the VNF Chain
The creation of the VNF chain consists of three phases
1. create the docker containers that represent the VNFs
2. create the OVS and the `in0` and `out0` interfaces on the VNFs
3. push flows to the OVS to control the packet flow across the chain

These steps can be invoked using the `make` target `deploy`:
```
cd /vagrant
make deploy
```

#### Viewing VNF Logs
The VNFs provide some logging while processing packets. The essentially
output a time stamp when the processed the packet and the ethernet src
MAC after it has been modified. An example of this output is below:
```
vnfa_1  | 2017-04-06 18:21:04.627568: 00:00:00:00:11:11
vnfb_1  | 2017-04-06 18:21:04.643939: 00:00:11:11:11:11
vnfc_1  | 2017-04-06 18:21:04.655679: 11:11:11:11:11:11
vnfa_1  | 2017-04-06 18:21:04.703563: 00:00:00:00:11:11
vnfb_1  | 2017-04-06 18:21:04.715747: 00:00:11:11:11:11
vnfc_1  | 2017-04-06 18:21:04.727597: 11:11:11:11:11:11 [DROP]
vnfa_1  | 2017-04-06 18:21:13.491106: 00:00:00:00:11:11
vnfb_1  | 2017-04-06 18:21:13.507499: 00:00:11:11:11:11
vnfc_1  | 2017-04-06 18:21:13.523412: 11:11:11:11:11:11
vnfa_1  | 2017-04-06 18:21:13.564962: 00:00:00:00:11:11
vnfb_1  | 2017-04-06 18:21:13.575161: 00:00:11:11:11:11
vnfc_1  | 2017-04-06 18:21:13.587124: 11:11:11:11:11:11 [DROP]
```

The logs of the VNFs can be viewed by using the `make` target `logs`
```
cd /vagrant
make logs
```

#### Run Quick Test
Provided with this demonstration is a quick test program that sends
a packet into the chain and watches for the packet. This test is in
the file `test.py`. The test sends two packets, the first is expected
to make it all the way through the chain and the second is dropped by
the last VNF and never delivered. The test can be invoked using the
`make` target `test`.
```
ubuntu@bp-cord:/vagrant$ make test
sudo IFACE=vnfchain ./test.py
WARNING: No route found for IPv6 destination :: (no default route?)
IFACE: vnfchain
DEBUG: False
Sending packet on vnfchain with ether src of  00:00:00:00:00:00
Waiting for packet
Received packet on vnfchain with ether src of 11:11:11:11:11:11
PASS
Sending packet on vnfchain with ether dst of  11:22:33:44:55:66
Waiting for packet
No packet recieved
PASS
```
