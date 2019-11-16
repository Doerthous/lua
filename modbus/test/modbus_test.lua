package.path = "../?.lua;"..package.path..";"

require("string")

modbus = require("modbus")


ack = 
{
    0x01,0x03,0x0C,0x00,0x01,0x00,0x02,0x00,0x03,
    0x00,0x04,0x00,0x05,0x00,0x06,0xDC,0x2F,
}
ack[0] = 0

local function getc(timeout)
    ack[0] = ack[0] + 1
    return ack[ack[0]]
end

local function setc(c)
    io.write(string.format("[%02X]", c))
end


mb = modbus:new(getc, setc)


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