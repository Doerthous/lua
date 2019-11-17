require "sys"

module(..., package.seeall)

sys.taskInit(function()
    cnt = 0
    while true do
        print("task1")
        sys.wait(1000)          -- 挂起1000ms，同理为每隔1000ms运行一次
    end
end)