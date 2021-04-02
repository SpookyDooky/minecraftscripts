local component = require("component")
local modem = component.modem

local eventQueue = require("event")

-- Event name: modem_message

local dns_table = {}

local serial = require("serialization")
function wait_for_event()

end

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

function append_table(name, address, port)
    local dns_file = io.open("/home/dns_list.txt", "a")

end

--File  layout
--Computer name, computer address, port to contact on
function load_table()
    local dns_file = io.open("/home/dns_list.txt", "r")
    io.input(dns_file)

    local line = io.read()

    while not (line == nil) do
        line = io.read()
        print("loading record: ", line)
        local tabledata = {}
        local index = 1
        for word in string.gmatch(line, '([^,]+)') do
            tabledata[index] = word
            index = index + 1
        end
        add_to_table(tabledata[1], tabledata[2], tabledata[3])
    end
    io.close()
    print(serial.serialize(dns_table))
end

function load_backup()
end

function save_backup()
end

--Adds a dns table entry to the table
function add_to_table(name1, address1, port1)
    tableData = {
        name = nil,
        address = nil,
        port = nil
    }
    tableData.name = name1
    tableData.address = address1
    tableData.port = port1
    table.insert(dns_table, tableData)
end

load_table()
--eventQueue.listen("modem_message", dns_request())