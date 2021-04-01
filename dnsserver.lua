local component = require("component")
local modem = component.modem

local eventQueue = require("event")

-- Event name: modem_message

local dns_table = {}
function handle_request()
    local localAdress,remoteAddress,portNumber,distance,message = eventQueue.pull("modem_message")
    --commandname
    --parameters
    local count = 0
    for word in string.gmatch(message, '([^,]+)') do
        if count == 1 then
            request_mismatch()
            return
        end

        if string.match(word, "request address") then
            request_addres()
        elseif string.match(word, "add dns") then
            add_new_dns()
        end
        count = count + 1
    end
    
end

function request_address()

end

function add_new_dns()
end

function dns_mismatch()
end

function request_mismatch()

end
eventQueue.listen("modem_message", dns_request)