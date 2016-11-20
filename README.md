## dns-proxy docker image
This is an arch linux dns filtering server using dnsmasq & hostsblock.  Running the image loads dnsmasq process daemon with query logging via docker logs.


Build your own
-----
```text
docker build -t dns-proxy --label foo/dns-proxy .
docker run --name dns-proxy -d -p 53:53/udp dns-proxy
```
