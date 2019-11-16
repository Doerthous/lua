-- require("math")

local bop = {
    bxor = function(num1, num2)
        local str = ""
        local b1 = 0
        local b2 = 0

        while num1 > 0 and num2 > 0 do
            b1 = math.floor(num1%2)
            b2 = math.floor(num2%2)
            if b1 == b2 then
                str = "0"..str
            else
                str = "1"..str
            end
            num1 = math.floor(num1/2)
            num2 = math.floor(num2/2)
        end
        while num1 > 0 do
            b1 = math.floor(num1%2)
            if b1 == 0 then
                str = "0"..str
            else
                str = "1"..str
            end
            num1 = math.floor(num1/2)
        end
        while num2 > 0 do
            b2 = math.floor(num2%2)
            if b2 == 0 then
                str = "0"..str
            else
                str = "1"..str
            end
            num2 = math.floor(num2/2)
        end
        return tonumber(str,2)
    end,

    band = function(num1,num2)
        local str = ""
        local b1 = 0
        local b2 = 0

        while num1 > 0 and num2 > 0 do
            b1 = math.floor(num1%2)
            b2 = math.floor(num2%2)
            if b1 == b2 and b1 == 1 then
                str = "1"..str
            else
                str = "0"..str
            end
            num1 = math.floor(num1/2)
            num2 = math.floor(num2/2)
        end
        while num1 > 0 do
            str = "0"..str
            num1 = math.floor(num1/2)
        end
        while num2 > 0 do
            str = "0"..str
            num2 = math.floor(num2/2)
        end

        return tonumber(str,2)
    end,

    bor = function(num1,num2)
        local str = ""
        local b1 = 0
        local b2 = 0
        
        while num1 > 0 and num2 > 0 do
            b1 = math.floor(num1%2)
            b2 = math.floor(num2%2)
            if b1 == 1 or b2 == 1 then
                str = "1"..str
            else
                str = "0"..str
            end
            num1 = math.floor(num1/2)
            num2 = math.floor(num2/2)
        end
        while num1 > 0 do
            b1 = math.floor(num1%2)
            if b1 == 1 then
                str = "1"..str
            else
                str = "0"..str
            end
            num1 = math.floor(num1/2)
        end
        while num2 > 0 do
            b2 = math.floor(num2%2)
            if b2 == 1 then
                str = "1"..str
            else
                str = "0"..str
            end
            num2 = math.floor(num2/2)
        end

        return tonumber(str,2)
    end,

    rshift = function(num, cnt)
        local str = ""
        while cnt > 0 and num > 0 do
            cnt = cnt - 1
            num = math.floor(num/2)
        end
        while num > 0 do
            if math.floor(num%2) == 1 then
                str = "1"..str
            else
                str = "0"..str
            end
            num = math.floor(num/2)
        end

        if #str == 0 then
            return 0
        end

        return tonumber(str, 2)
    end
}

return bop