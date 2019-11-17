ctick = require("ctick")

t = ctick.ms()
while true do
    if (ctick.ms() - t > 1000) then
        t = ctick.ms()
        print("tick per second")
    end
end