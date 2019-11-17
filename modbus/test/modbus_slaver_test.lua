package.path = "../?.lua;"..package.path..";"

require("string")
local cserial = require("cserial")
local modbus = require("modbus")

argc = 0
for i, v in ipairs(arg) do
    argc = argc + 1
end



-- handlers
local function r_h_rs(addr, count)
    data = {}
    print(string.format("read holding read registers: %04X, %d", addr, count))

    for i=1,count do
        data[#data+1] = #data
    end

    return true, data
end

local function r_i_rs(addr, count)
    data = {}
    print(string.format("read input read registers: %04X, %d", addr, count))

    for i=1,count do
        data[#data+1] = #data
    end

    return true, data
end

local function w_r(addr, data)
    print(string.format("write register: %04X, %d", addr, data))
    return true, {addr, data}
end

local function w_rs(addr, data)
    local ds = ""
    for i,v in ipairs(data) do
        ds = ds .. string.format(" %d", v)
    end
    ds = string.format("write registers: %04X,", addr) .. ds
    print(ds)
    return true, {addr, #data}
end


if argc < 2 then
    print("argc < 2")
else
    cserial.open(arg[1], arg[2])

    mb = modbus:new(cserial.read, cserial.write, 100)

    callbacks = {}
    callbacks[modbus.FC_READ_HD_REGS] = r_h_rs
    callbacks[modbus.FC_READ_IN_REGS] = r_i_rs
    callbacks[modbus.FC_WRITE_REG] = w_r
    callbacks[modbus.FC_WRITE_REGS] = w_rs

    mb:run(0x01, callbacks)

    cserial.close()
end