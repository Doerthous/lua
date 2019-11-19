str="\x30\x31\x32\x33"

while #str > 0 do
    print(string.byte(string.sub(str,1,1)),string.sub(str,1,1), str)
    str = string.sub(str,2,#str)
end