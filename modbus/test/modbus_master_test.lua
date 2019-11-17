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

    print("read_holding_registers")
    err, data = mb:read_holding_registers(0x01, 0x0000, 6)
    if err == modbus.OK then
        io.write("registers: ")
        for i=1, #data.registers do
            io.write(string.format("%d ", data.registers[i]))
        end
    end
    print("\n")

    print("read_input_registers")
    err, data = mb:read_input_registers(0x01, 0x0000, 6)
    if err == modbus.OK then
        io.write("registers: ")
        for i=1, #data.registers do
            io.write(string.format("%d ", data.registers[i]))
        end
    end
    print("\n")

    print("write_register")
    err, data = mb:write_register(0x01, 0x0000, 0x0006)
    if err == modbus.OK then
        print(string.format("address: %04X", data.address))
        print(string.format("register: %04X", data.register))
    end
    print("")

    print("write_registers")
    err, data = mb:write_registers(0x01, 0x0000, {1,2,3,4,5,6})
    if err == modbus.OK then
        print(string.format("address: %04X", data.address))
        print(string.format("count: %04X", data.count))
    end
    print("")

    cserial.close()
end