cserial = require("cserial")

cserial.open("COM1", 115200)
cserial.write(0x44)
ch = cserial.read(3000)
if ch == nil then
    print("timeout")
else
    print(string.format("%02X", ch))
end
cserial.close()