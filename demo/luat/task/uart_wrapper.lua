module(...,package.seeall)

require"utils"
require"pm"


local UART_ID = 2


local function taskRead()
    local cacheData,frameCnt = "",0
    while true do
        local s = uart.read(UART_ID,"*l")
        if s == "" then
            uart.on(UART_ID,"receive",function() sys.publish("UART_RECEIVE") end)
            if not sys.waitUntil("UART_RECEIVE",100) then
                --uart接收数据，如果100毫秒没有收到数据，则打印出来所有已收到的数据，清空数据缓冲区，等待下次数据接收
                --注意：
                --串口帧没有定义结构，仅靠软件延时，无法保证帧的完整性，如果对帧接收的完整性有严格要求，必须自定义帧结构（参考testUart.lua）
                --因为在整个GSM模块软件系统中，软件定时器的精确性无法保证，例如本demo配置的是100毫秒，在系统繁忙时，实际延时可能远远超过100毫秒，达到200毫秒、300毫秒、400毫秒等
                --设置的延时时间越短，误差越大
                if cacheData:len()>0 then
                    log.info("testUartTask.taskRead","100ms no data, received length",cacheData:len())
                    --数据太多，如果全部打印，可能会引起内存不足的问题，所以此处仅打印前1024字节
                    log.info("testUartTask.taskRead","received data",cacheData:sub(1,1024))
                    cacheData = ""
                    frameCnt = frameCnt+1
                    write("received "..frameCnt.." frame")
                end
            end
            uart.on(UART_ID,"receive")
        else
            cacheData = cacheData..s            
        end
    end
end