# THIS FILE IS CONTROLLED BY SALTSTACK
#
# Gateway-specific Bird IPv6 configuration
#



# Gateway-specific settings
#
# The unique ID of this router, its IPv6 address in the freifunk network
# and the AS number for freifunk fulda.
#
router id {{ pillar['hosts'][grains['id']]['ipv4']['freifunk'] }};
define ownas = 65142;
define ownip = {{ pillar['hosts'][grains['id']]['ipv6']['freifunk'] }};



# Routing tables
#
# This creates the routing tables bird will use. Table private contains all
# the routes to freifunk, dn42 and other connected overlay networks. In table
# internet is our freifunk-uplink default route. The ibgp table is for route
# exchange between gateways. Finally, table sink contains a unreachable route,
# which matches for any traffic not generated by the gateway itself.
# Routes in these tables are copied to corresponding kernel tables, which are
# then evaluated depending on the source address of a packet using ip rules.
# Documentation on the routing process is available at
# https://wiki.mag.lab.sh/wiki/Freifunk_Fulda/Gateway/Routing
#
table private;             # icvpn, dn42, ...
table internet;            # interet routes
table ibgp;                # gateway to gateway route exchange
table sink;                # sink for any source except local



# Match specific networks
#
# These functions are used to match specific networks, like freifunk or
# our own network prefix. It gets used by the protocols to filter routeing
# advertisements from and to our peers.
#
function is_default() { return net ~ [ ::/0 ]; }
function is_self_ula() { return net ~ [ fd00:65a8:93a4::/48+ ]; }
function is_self_net() { return net ~ [ 2a03:2260:100f::/48+ ]; }
function is_freifunk() { return net ~ [ 
	2001:0bf7::/32+,		# Foerderverein freie Netzwerke e.V.
	2001:67c:2d50::/48+,	# Freifunk Luebeck (via FF Rheinland)
	2a03:2260::/29+			# Freifunk Rheinland e.V.
]; }
function is_ula() { return (net ~ [ fc00::/7{44,64} ]); };


# Include all the other stuff
#
include "/etc/bird/bird6.conf.d/*.conf";

