-- require("math")
local bop = require("bop")

local function modbus_crc(data, len)
    local crc = 0xFFFF
    for i = 1, len or #data do
        crc = bop.bxor(crc, data[i])
        for j = 1,8 do
            crc = math.floor(crc%0x10000)
            t = math.floor(crc%2)
            --t = bop.band(bop.band(crc, 0x0001))
            crc = bop.rshift(crc, 1)
            if t == 1 then
                crc = bop.bxor(crc, 0xA001)
            end
        end
    end
    return crc
end

local modbus = {
    getc = getc,
    setc = setc,
    id = 0x01,

    -- return code
    OK = 0,
    READ_TIMEOUT = 1,
    FUNC_CODE_ERR = 2,
    DATA_LEN_ERR = 3,
    CRC_ERR = 4,
}

function modbus:new(getc, setc)
    local o = {}

    assert(getc ~= nil)
    assert(setc ~= nil)

    setmetatable(o, self)
    self.__index = self
    self.getc = getc
    self.setc = setc
    return o
end


--
--
--


local function read_and_check_crc(getc, timeout, data)
    local crcl = 0
    local crch = 1

    --- read crc
    crcl = getc(timeout)
    if crcl == nil then
        return modbus.READ_TIMEOUT
    end
    crch = getc(timeout)
    if crch == nil then
        return modbus.READ_TIMEOUT
    end
    --- crc check
    if modbus_crc(data, #data) ~= (crcl + crch*0x100) then
        return modbus.CRC_ERR
    end

    data[#data+1] = crcl
    data[#data+1] = crch

    return modbus.OK, data
end

local function read_exception_code(getc, timeout, data)
    local ec = getc(timeout)
    if ec == nil then
        return modbus.READ_TIMEOUT
    end

    data[#data+1] = ec

    err, data = read_and_check_crc(getc, timeout, data)
    if err ~= modbus.OK then
        return err
    end

    return err, ec
end

-- uint16_t
local function read_data(getc, timeout, data, count)
    local ch = 0

    --- read data length
    ch = getc(timeout)
    if ch == nil then
        return modbus.READ_TIMEOUT
    end
    data[#data+1] = ch
    if ch ~= count * 2 then
        return modbus.DATA_LEN_ERR
    end
    --- read data
    for i = 1, count*2 do
        ch = getc(timeout) 
        if ch == nil then
            return modbus.READ_TIMEOUT
        end
        data[#data+1] = ch
    end

    return modbus.OK, data
end

local function read_func_code(getc, timeout, data, func_code)
    local ch = 0

    ch = getc(timeout)
    if ch == nil then
        return modbus.READ_TIMEOUT
    end
    data[#data+1] = ch

    if ch == func_code then
        return modbus.OK, data
    end
    if ch == (func_code+0x80) then
        return read_exception_code(getc, data)
    end

    return modbus.FUNC_CODE_ERR, data
end

-- what if the id is always not the same with the given id.
local function read_id(getc, timeout, data, id)
    local ch = 0

    while true do
        ch = getc(timeout)
        if ch == nil then
            break
        end
        if ch == id then
            data[#data+1] = ch
            return modbus.OK, data
        end
    end

    return modbus.READ_TIMEOUT
end


local function unpack_data(data)
    upd = {}

    if data[2] == 0x03 then
        for i = 4, #data-2, 2 do
            upd[#upd + 1] = data[i] * 0x100 + data[i+1]
        end
    end

    return upd
end


local function read_registers(mb, func, id, address, count)
    local data = {
        id, func,
        math.floor(address/0x100), math.floor(address%0x100),
        math.floor(count/0x100), math.floor(count%0x100)
    }
    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data + 1] = math.floor(crc%0x100)
    data[#data + 1] = math.floor(crc/0x100)

    -- write to io
    for i = 1, #data do
        mb.setc(data[i])
    end


    data = {}
    -- read from io
    --- read id
    err, data = read_id(mb.getc, mb.timeout, data, id)
    if err ~= modbus.OK then
        return err
    end
    --- read function code
    err, dadta = read_func_code(mb.getc, mb.timeout, data, func)
    if err ~= modbus.OK then
        return err
    end
    --- read data
    err, data = read_data(mb.getc, mb.timeout, data, count)
    if err ~= modbus.OK then
        return err
    end
    --- read crc
    err, data = read_and_check_crc(mb.getc, mb.timeout, data)
    if err == modbus.OK then
        return err, unpack_data(data)
    end

    return err    
end




-- 0x03
function modbus:read_holding_registers(id, address, count)
    return read_registers(self, 0x03, id, address, count)
end

-- 0x04
function modbus:read_input_registers(id, address, count)
    return read_registers(self, 0x04, id, address, count)
end

-- 0x06
function modbus:write_register(id, address, data)
    local data = {
        id, 0x06,
        math.floor(address/0x100), math.floor(address%0x100),
        math.floor(data/0x100), math.floor(data%0x100)
    }
    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data + 1] = math.floor(crc%0x100)
    data[#data + 1] = math.floor(crc/0x100)

    -- write to io
    for i = 1, #data do
        mb.setc(data[i])
    end

    -- handle response
end

-- 0x10
function modbus:write_registers(id, address, _data)
    local data = {
        id, 0x10,
        math.floor(address/0x100), math.floor(address%0x100),
        math.floor(#_data/0x100), math.floor(#_data%0x100),
        math.floor(2*#_data),
    }
    for i=1,#_data do
        data[#data+1] = math.floor(_data[i]/0x100)
        data[#data+1] = math.floor(_data[i]%0x100)
    end

    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data+1] = math.floor(crc%0x100)
    data[#data+1] = math.floor(crc/0x100)

    -- write to io
    for i = 1, #data do
        mb.setc(data[i])
    end
end

return modbus