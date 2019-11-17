argc = 0
for i,v in ipairs(arg) do
    argc = argc + 1
end

if argc < 2 then
    print("argc < 2")
else
    print(arg[1], arg[2])
end