local component = require("component")
local modem = component.modem

local dns_name = "network_admin"
local port = 6900

local event = require("event")

modem.broadcast(6969, "find_dns")
local _,localAddress,from,port,distance,dnsAddress,port = event.pull("modem_message")
modem.send(dnsAddress, tonumber(port), "dns_add_me", dns_name, toString(port))