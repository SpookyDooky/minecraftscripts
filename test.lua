local component = require("component")

local eventQueue = require("event")
local networkModem = component.modem

local port = 17769
--Opening ports for communication
networkModem.open(port)

local _, localAddress, from, port, distance, message = eventQueue.pull("modem_message")
print(message)