local component = require("component")
local serialization = require("serialization")
local me_interface = component.me_interface

local control_loop = true

local indexes

function control_me()
    local progression_count = 0

    while control_loop do
        keep_items_level()
        os.sleep(10)
        progression_count = progression_count + 5
    end
end

function keep_items_level()
    local itemsToCheck = {"Bone Meal", "Lapis Lazuli"}
    local lowerBound = {10000, 10000}
    local requestAmount = {500, 500}

    local item_db = me_interface.getItemsInNetwork()
    local index = 0

    for k,v in ipairs(item_db) do
        for i=1,2 do
            if v.label == itemsToCheck[i] then
                print(v.label, " quantity:", v.size)
                if v.size < lowerBound[i] then
                    setupRequest(v.label, requestAmount[i])
                end
            end
        end
    end
end

function setupRequest(itemName, amount)
    print("crafting request, item=", itemName, " size=", amount)
    local cpus = me_interface.getCpus()
    if #cpus >= 1 then -- Availability of cpus confirmed
        local craftables = me_interface.getCraftables()
        for k,v in ipairs(craftables) do
            local craftableData = v.getItemStack()
            if craftableData.label == itemName then
                local userdata = v.request(amount)
                while not userdata.isDone() do
                    os.sleep(5)
                end
            end
        end
    end
end

function me_stats()
    local avgPower = me_interface.getAvgPowerUsage()
    local avgPowerInject = me_interface.getAvgPowerInjection()
    local powerBuffer = me_interface.getStoredPower()
    print("Average power usage:  ", avgPower)
    print("Average power inject: ", avgPowerInject)
    print("Current power buffer: ", powerBuffer)
    print("----------------------------------------------------")
end

function interrupt()
    control_loop = false
end

control_me()
