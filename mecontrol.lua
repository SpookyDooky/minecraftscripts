local component = require("component")
local serialization = require("serialization")
local me_interface = component.me_interface

local eventQueue = require("event")
local modem = component.modem

local control_loop = true
local craftingTrackers = {}

local localAddress = "f199a667-7505-46e5-bac2-179a84cccfc2"

function control_me()
    local progression_count = 0

    while control_loop do
        keep_items_level()
        os.sleep(10)
        progression_count = progression_count + 5
    end
end

function keep_items_level()
    local itemsToCheck = {"Redstone", "Logic Processor", "Engineering Processor", 
    "Calculation Processor", "Polymer Clay", "Crushed Diamond", "Lapis Lazule",
    "Lithium Dust"}
    local lowerBound = {1000, 500, 500, 500, 1000, 400, 1000, 300}
    local requestAmount = {5000, 750, 750, 750, 50000, 800, 5000, 500}

    local item_db = me_interface.getItemsInNetwork()
    local index = 0

    for k,v in ipairs(item_db) do
        for i=1,#itemsToCheck do
            if v.label == itemsToCheck[i] then
                print(v.label, " quantity: ", v.size)
                if v.size < lowerBound[i] then
                    setupRequest(v.label, requestAmount[i])
                end
            end
        end
    end
    print("----------------------------------------------------------------------------------")
end

function setupRequest(itemName, amount)
    if activeRequest(itemName) then
        return
    end
    print("crafting request, item=", itemName, " size=", amount)
    local cpus = me_interface.getCpus()
    if #cpus >= 1 then -- Availability of cpus confirmed
        local craftables = me_interface.getCraftables()
        for k,v in ipairs(craftables) do
            local craftableData = v.getItemStack()
            if craftableData.label == itemName then
                local userdata = v.request(amount, false, cpus[1].name)
                print("Request made to cpu:", cpus[1].name)
                addTable(userdata, amount, itemName)
            end
        end
    end
end

function activeRequest(itemName)
    for index=1,#craftingTrackers do
        local crafter1 = craftingTrackers[index]
        if crafter1.name == itemName then
            if crafter1.crafter.isDone() then
                table.remove(craftingTrackers, index)
                return true
            end
            return false
        end

    end
end

function addTable(userData, requestSize, itemName)
    tableData = {
        name = nil,
        requestSize = nil,
        crafter = nil
    }
    tableData.name = itemName
    tableData.requestSize = requestSize
    tableData.crafter = userData
    table.insert(craftingTrackers, tableData)
end

function interrupt()
    control_loop = false
end

function initNetworking()

end
control_me()
