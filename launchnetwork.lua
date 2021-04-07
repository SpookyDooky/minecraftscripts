local component = require("component")

local event = require("event")
local modem = component.modem

function launch_network()
    start_up_dnsserver()
end

function start_up_dnsserver()
    --Send wake message
    modem.broadcast(6969, "wakedns")
    os.sleep(5)
    local _, localAddress, from, port, distance, message = event.pull("modem_message")
    if (message == "response ok") then
        print("DNS SERVER: ONLINE")
    end
end

function start_computers()
    print("Network starting...")
    modem.broadcast(6969, "wake")
    os.sleep(5)
    print("NETWORK: ONLINE")
end
launch_network()