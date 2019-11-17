package.path = "../?.lua;"..package.path..";"

require("string")
local cserial = require("cserial")
local modbus = require("modbus")

argc = 0
for i, v in ipairs(arg) do
    argc = argc + 1
end

if argc < 2 then
    print("argc < 2")
else
    cserial.open(arg[1], arg[2])
    mb = modbus:new(cserial.read, cserial.write, 3000)

    print("read_resgisters")
    err, data = mb:read_holding_registers(0x01, 0x0000, 6)
    print("")
    if err == modbus.OK then
        for i=1, #data do
            io.write(string.format("%d ", data[i]))
        end
    end
    print("\n")

    print("write_register")
    mb:write_register(0x01, 0x0000, 0x0006)
    print("\n")

    print("\nwrite_registers")
    mb:write_registers(0x01, 0x0000, {1,2,3,4,5,6})
    print("\n")

    cserial.close()
end