local component = require("component")

local eventQueue = require("event")
local networkModem = component.modem

local mainAddress = "388e2ce0-afa5-4f37-865a-0fe601a9325e"

local port = 17769
local signalStrength = 50

--Set up modem
networkModem.open(port)
networkModem.setStrength(signalStrength)
