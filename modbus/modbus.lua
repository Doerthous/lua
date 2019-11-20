-- require("math")
local bop = require("bop")


------------------
local function printf(fmt, ...)
    print(string.format(fmt, ...))
end

local function debug_dump(data)
    local ds = ""

    for i=1,#data do
        ds = ds .. string.format("%02X", data[i])
    end

    print(ds)
end

local function uint8(num)
    if num ~= nil then
        return math.floor(num%0x100)
    end
    return nil
end

local function uint16(num)
    if num ~= nil then
        return math.floor(num%0x10000)
    end
    return nil
end

local function modbus_crc(data, len)
    local crc = 0xFFFF
    for i = 1, len or #data do
        crc = bop.bxor(crc, data[i])
        for j = 1,8 do
            crc = uint16(crc)
            t = math.floor(crc%2)
            crc = bop.rshift(crc, 1)
            if t == 1 then
                crc = bop.bxor(crc, 0xA001)
            end
        end
    end
    return crc
end

local function modbus_send(mb, data)
    for i = 1, #data do
        mb.setc(data[i])
    end
end

local modbus = 
{
    getc = getc,
    setc = setc,
    id = 0x01,

    -- return code
    OK = 0,
    READ_TIMEOUT = 1,
    FUNC_CODE_ERR = 2,
    DATA_LEN_ERR = 3,
    CRC_ERR = 4,

    -- function code
    FC_READ_HD_REGS = 0x03,    
    FC_READ_IN_REGS = 0x04,
    FC_WRITE_REG = 0x06,
    FC_WRITE_REGS = 0x10,
    -- ...

    -- exception code
    EC_ILLEGAL_FUNC = 0x01,
    EC_ILLEGAL_ADDR = 0x02,
    EC_ILLEGAL_VAL = 0x03,
    EC_SRV_DEV_FAILED = 0x04,
    EC_ACK = 0x05,
    EC_SRV_DEV_BUSY = 0x06,
    EC_MEM_PARITY_ERR = 0x08,
    EC_GATEWAY_NOT_VALID = 0x0A,
    EC_GATEWAY_NOT_RES = 0x0B,
}

function modbus:new(getc, setc, timeout)
    local o = {}

    assert(getc ~= nil)
    assert(setc ~= nil)

    setmetatable(o, self)
    self.__index = self
    o.getc = getc
    o.setc = setc
    o.timeout = timeout or 100
    o.running = false
    return o
end


--------------------------------------------------------------------------------
-- Master
--------------------------------------------------------------------------------
-- what if the id is always not the same with the given id.
local function read_id(mb, data, id)
    local ch = 0

    while true do
        ch = uint8(mb.getc(mb.timeout))
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
local function read_exception_code(mb, data)
    local ec = uint8(mb.getc(mb.timeout))
    if ec == nil then
        return modbus.READ_TIMEOUT
    end

    data[#data+1] = ec

    err, data = read_and_check_crc(mb, data)
    if err ~= modbus.OK then
        return err
    end

    return err, ec
end
local function read_func_code(mb, data, func_code)
    local ch = 0

    ch = uint8(mb.getc(mb.timeout))
    if ch == nil then
        return modbus.READ_TIMEOUT
    end
    data[#data+1] = ch

    if ch == func_code then
        return modbus.OK, data
    end
    if ch == (func_code+0x80) then
        return read_exception_code(mb, data)
    end

    return modbus.FUNC_CODE_ERR, data
end
local function read_data_len(mb, data, count)
    local ch = 0

    --- read data length
    ch = uint8(mb.getc(mb.timeout))
    if ch == nil then
        return modbus.READ_TIMEOUT
    end
    data[#data+1] = ch
    if ch ~= count * 2 then
        return modbus.DATA_LEN_ERR
    end

    return modbus.OK, data
end
local function read_data(mb, data, count)
    local ch = 0

    for i = 1, count*2 do
        ch = uint8(mb.getc(mb.timeout))
        if ch == nil then
            return modbus.READ_TIMEOUT
        end
        data[#data+1] = ch
    end

    return modbus.OK, data
end
local function read_and_check_crc(mb, data)
    local crcl = 0
    local crch = 1

    --- read crc
    crcl = uint8(mb.getc(mb.timeout))
    if crcl == nil then
        return modbus.READ_TIMEOUT
    end
    crch = uint8(mb.getc(mb.timeout))
    if crch == nil then
        return modbus.READ_TIMEOUT
    end
    --- crc check 
    if modbus_crc(data, #data) ~= bop.bor(bop.lshift(crch, 8), crcl) then
        return modbus.CRC_ERR
    end

    data[#data+1] = crcl
    data[#data+1] = crch

    return modbus.OK, data
end


local parse_response = {}
local function res_parser1(data)
    local regs = {}

    for i = 4, #data-2, 2 do
        regs[#regs + 1] = data[i]*0x100 + data[i+1]
    end

    return { registers = regs}
end
local function res_parser2(data)
    return { 
        address = data[3]*0x100 + data[4],
        register = data[5]*0x100 + data[6]
    }
end
local function res_parser3(data)
    return {
        address = data[3]*0x100 + data[4],
        count = data[5]*0x100 + data[6]  
    }  
end
parse_response[modbus.FC_READ_HD_REGS] = res_parser1
parse_response[modbus.FC_READ_IN_REGS] = res_parser1
parse_response[modbus.FC_WRITE_REG] = res_parser2
parse_response[modbus.FC_WRITE_REGS] = res_parser3


local function send_cmd1(mb, id, func, word1, word2)
    local data = {
        id, func,
        uint8(word1/0x100), uint8(word1),
        uint8(word2/0x100), uint8(word2)
    }
    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data + 1] = uint8(crc)
    data[#data + 1] = uint8(crc/0x100)

    -- write to io
    modbus_send(mb, data)
end
local function send_cmd2(mb, id, func, word1, word2, byte1, words)
    local data = { 
        id, func, 
        uint8(word1/0x100), uint8(word1),
        uint8(word2/0x100), uint8(word2), byte1 
    }

    for i=1,#words do
        data[#data+1] = uint8(words[i]/0x100)
        data[#data+1] = uint8(words[i])
    end

    -- modbus crc is little-endian
    local crc = modbus_crc(data)
    data[#data+1] = uint8(crc)
    data[#data+1] = uint8(crc/0x100)

    -- write to io
    modbus_send(mb, data)
end
local function recv_res1(mb, id, func, word_count)
    local data = {}
    -- read from io
    --- read id
    err, data = read_id(mb, data, id)
    if err ~= modbus.OK then
        return err
    end
    --- read function code
    err, data = read_func_code(mb, data, func)
    if err ~= modbus.OK then
        return err, data
    end
    --- read data len
    err, data = read_data_len(mb, data, word_count)
    if err ~= modbus.OK then
        return err
    end    
    --- read data     
    err, data = read_data(mb, data, word_count)
    if err ~= modbus.OK then
        return err
    end  
    --- read crc
    err, data = read_and_check_crc(mb, data)  
    if err == modbus.OK then
        return err, parse_response[data[2]](data)
    end

    return err
end
local function recv_res2(mb, id, func)
    -- handle response
    local data = {}
    -- read from io
    --- read id
    err, data = read_id(mb, data, id)
    if err ~= modbus.OK then
        return err
    end
    --- read function code
    err, data = read_func_code(mb, data, func) 
    if err ~= modbus.OK then
        return err, data
    end
    --- read data
    err, data = read_data(mb, data, 2)
    if err ~= modbus.OK then
        return err
    end 
    --- read crc
    err, data = read_and_check_crc(mb, data)   
    if err == modbus.OK then
        return err, parse_response[data[2]](data)
    end

    return err
end




function modbus:read_holding_registers(id, address, count)
    send_cmd1(self, id, modbus.FC_READ_HD_REGS, address, count)
    return recv_res1(self, id, modbus.FC_READ_HD_REGS, count)
end
function modbus:read_input_registers(id, address, count)
    send_cmd1(self, id, modbus.FC_READ_IN_REGS, address, count)
    return recv_res1(self, id, modbus.FC_READ_IN_REGS, count)
end
function modbus:write_register(id, address, data)
    send_cmd1(self, id, modbus.FC_WRITE_REG, address, data)
    return recv_res2(mb, id, modbus.FC_WRITE_REG)
end
function modbus:write_registers(id, address, data)
    send_cmd2(self, id, modbus.FC_WRITE_REGS, address, 
        #data, uint8(2*#data), data)
    return recv_res2(mb, id, modbus.FC_WRITE_REGS)
end



--------------------------------------------------------------------------------
-- slaver
--------------------------------------------------------------------------------
local parse_request = {}
local function req_parser1(data)
    -- word1,word2
    return uint16(data[4]+data[3]*0x100), uint16(data[6]+data[5]*0x100)
end
local function req_parser2(_data)
    -- word1,word2(no use),byte1(no use),words
    local addr = uint16(_data[4]+_data[3]*0x100)
    local count = uint8(_data[7])
    local data = {}

    for i=1,count,2 do
        data[#data+1] = uint16(_data[7+i+1]+_data[7+i]*0x100)
    end

    return addr, data
end
parse_request[modbus.FC_READ_HD_REGS] = req_parser1
parse_request[modbus.FC_READ_IN_REGS] = req_parser1
parse_request[modbus.FC_WRITE_REG] = req_parser1
parse_request[modbus.FC_WRITE_REGS] = req_parser2


local pack_response = {}
local function res_packer1(id, func, _data)
    local data = { id, func, uint8(2*#data) }

    for i=1,#_data do
        data[#data+1] = uint8(_data[i]/0x100)
        data[#data+1] = uint8(_data[i])
    end

    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data+1] = uint8(crc)
    data[#data+1] = uint8(crc/0x100)

    return data
end
local function res_packer2(id, func, _data)
    local data = { id, func }

    for i=1,#_data do
        data[#data+1] = uint8(_data[i]/0x100)
        data[#data+1] = uint8(_data[i])
    end

    local crc = modbus_crc(data)

    -- modbus crc is little-endian
    data[#data+1] = uint8(crc)
    data[#data+1] = uint8(crc/0x100)

    return data
end
local function res_packer3(id, func, exception)
end
pack_response[modbus.FC_READ_HD_REGS] = res_packer1
pack_response[modbus.FC_READ_IN_REGS] = res_packer1
pack_response[modbus.FC_WRITE_REG] = res_packer2
pack_response[modbus.FC_WRITE_REGS] = res_packer2
pack_response[0x80] = res_packer3

function modbus:run(id, callbacks)
    local ch = 0
    local data = {}
    local state = 0

    if self.running == true then
        return
    end

    self.running = true

    while self.running do
        ch = uint8(self.getc(self.timeout))

        if ch == nil then
            if #data > 4 then -- parse data
                if data[1] == id then
                    debug_dump(data) -- todo
                    ch = bop.bor(bop.lshift(data[#data], 8), data[#data-1])
                    if modbus_crc(data, #data-2) == ch then
                        if callbacks[data[2]] ~= nil then
                            state, ch = callbacks[data[2]](
                                parse_request[data[2]](data))

                            if state ~= false then
                                data = pack_response[data[2]](id, data[2], ch)
                            else
                                data = pack_response[0x80](id, data[2], ch)
                            end

                            debug_dump(data) -- todo
                            modbus_send(mb, data)
                        end
                    end
                end
            end
            data = {}
        else
            data[#data+1] = ch
        end
    end
end

function modbus:exit()
    self.running = false
end

return modbus