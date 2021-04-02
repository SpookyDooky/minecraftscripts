local component = require("component")
local modem = component.modem

local eventQueue = require("event")

-- Event name: modem_message

local dns_table = {}

local serial = require("serialization")

local port = 6969
local signalStrength = 100

local running = true

function setup_network()
    modem.open(port)
    modem.setStrength(signalStrength)
end

function wait_for_event()
    while running do
        handle_request(eventQueue.pull("modem_message"))
    end
end

handle_request =
function(event_id, localAddress, remoteAddress, portNumber, distance, message)
    --commandname
    --parameters
    local count = 0
    for word in string.gmatch(message, '([^,]+)') do
        if count == 1 then
            request_mismatch(remoteAddress, message)
            return
        end

        if string.match(word, "request_address") then
            request_addres()
            return
        elseif string.match(word, "add_dns") then
            add_new_dns()
            return
        end
        count = count + 1
    end
    
    if count == 0 or count == 1 then
        request_mismatch(remoteAddress, message)
    end
end

function request_address()

end

function add_new_dns(name, address, port)
    --check if it already exists
    print("new dns record: name=",name,"address=",address,"port=",port)
    add_to_table(name,address, port)
    append_file(name, address, port)
    --save
end

function dns_mismatch()
end

function request_mismatch(remoteAddress, message)
    --Send back an error message
    --6901 for unknown command
    print("mismatch: ", message)
    modem.send(remoteAddress, 6969, "6901")
end

function append_file(name, address, port)
    local dns_file = io.open("/home/dns_list.txt", "a")
    io.output(dns_file)
    local entry = name ... "," ... address ... "," ... port
    io.write(entry)
    io.close(dns_file)
end

--File  layout
--Computer name, computer address, port to contact on
function load_table()
    local dns_file = io.open("/home/dns_list.txt", "r")
    io.input(dns_file)

    local line = io.read()

    while not (line == nil) do
        print("loading record: ", line)
        local tabledata = {}
        local index = 1
        for word in string.gmatch(line, '([^,]+)') do
            tabledata[index] = word
            index = index + 1
        end
        add_to_table(tabledata[1], tabledata[2], tabledata[3])
        line = io.read()
    end
    io.close(dns_file)
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
setup_network()
wait_for_event()
--eventQueue.listen("modem_message", handle_request())