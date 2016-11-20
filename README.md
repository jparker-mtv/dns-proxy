an ad filtering proxy using hostsblock and dnsmasq


Build you own:

docker build -t dns-proxy --label foo/dns-proxy .

docker run --name dns-proxy -d -p 53:53/udp dns-proxy



Fires up a dnsmasq process with query logging via docker logs.
