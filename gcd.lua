local args = {...}

local number1 = tonumber(args[1])
local number2 = tonumber(args[2])

function calculate(num1, num2)
    if num1 == num2 then
        print("gcd: ", num1)
        return
    end
    if num1 > num2 then
        local temp = num1
        num1 = num2
        num2 = temp
    end

    local keepgoing = true
    local lastRemainder = num1
    while keepgoing do
        local remainder = num2 % num1
        print("remainder: ", remainder)
        num2 = num1
        num1 = remainder
        if remainder ~= 0 then
            lastRemainder = remainder
        else
            print("gcd:", lastRemainder)
            keepgoing = false
        end
    end
end

calculate(number1, number2)