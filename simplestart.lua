local component = require("component")
local modem = component.modem

local port = 6900
local strength = 100

modem.open(port)
modem.setStrength(strength)