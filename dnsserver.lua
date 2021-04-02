local component = require("component")
local modem = component.modem

local eventQueue = require("event")

-- Event name: modem_message

local dns_table = {}

local serial = require("serialization")

local port = 6969
local signalStrength = 100

local running = true

local dnsaddress = "d0db398f-0926-4819-bdcd-78666c8d7d9e"

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

        if "request_address" == word then
            request_addres()
            return
        elseif "add_dns" == word then
            local parameters = isolate_parameters(message)
            add_new_dns(parameters[1], parameters[2], parameters[3])
            return
        elseif "add_dns_me" == word then
            local parameters = isolate_parameters(message)
            add_new_dns(parameters[1], remoteAddress, parameters[2])
            return
        elseif "update_dns" == word then
            return
        elseif "find_dns" == word then
            modem.send(remoteAddress, portNumber, localAddress)
            return
        end
        count = count + 1
    end
    
    if count == 0 or count == 1 then
        request_mismatch(remoteAddress, message)
    end
end

function request_address(remoteAddress, portNumber, distance, computerName)
    local result = get_dns(computerName)
    if result == nil then
        --69.2
        modem.send(remoteAddress, portNumber, "unknown machine name:69.2")
        return
    end

    local responseMessage = v.address .. "," .. v.port
    modem.send(remoteAddress, portNumber, responseMessage)
    print("response ok")
end

function isolate_parameters(raw_message)
    local count = 0
    local parameters = {}
    for word in string.gmatch(raw_message, '([^,]+)') do
        if count > 0 then
            table.insert(parameters, word)
        end
        count = count + 1
    end
    print(serial.serialize(parameters))
    return parameters
end

function add_new_dns(name, address, port)
    if check_existence(address) then
        print("dns entry already exists")
        return
    end
    --check if it already exists
    print("new dns record: name=",name,"address=",address,"port=",port)
    add_to_table(name,address, port)
    append_file(name, address, port)
    --save
end

function check_existence(address)
    for k,v in ipairs(dns_table) do
        if address == v.address then
            return true
        end
    end
    return false
end

function get_dns(computerName)
    for k,v in ipairs(dns_table) do
        if v.name == computerName then
            return v
        end
    end
    return nil
end

function request_mismatch(remoteAddress, message)
    --Send back an error message
    --69.1 for unknown command
    print("invalid request: ", message)
    modem.send(remoteAddress, 6969, "69.1")
end

function append_file(name, address, port)
    local dns_file = io.open("/home/dns_list.txt", "a")
    io.output(dns_file)
    local entry = name 
    entry = entry .. "," 
    entry = entry .. address 
    entry = entry .. "," 
    entry = entry .. port
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