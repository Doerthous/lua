require "os"
require "log"

module(..., package.seeall)


MSG_TIMER = "MSG_TIMER"
MSG_UART_RXDATA = "MSG_UART_RXDATA"
MSG_UART_TX_DONE = "MSG_UART_TX_DONE"

local function contains(_table, key)
    for k,v in ipairs(_table) do
        if k == key then
            return true
        end
    end
    return false
end

local timers_clock = {}
local timers_interval = {}

function poweron_reason()
    --print("poweron_reason")
    return "simulation"
end

function get_version()
    --print("get_version")
    return "1.0.0"
end

function get_build_time()
    --print("get_build_time")
end

function poweron()
    log.info("rtos", "power on.")
end

function receive(...)
    t = ctick.ms()
    for tmr_id, clk in ipairs(timers_clock) do      
        if t >= clk then
            timers_clock[tmr_id] = ctick.ms() + timers_interval[tmr_id]
            return MSG_TIMER, tmr_id
        end
    end
    return MSG_TIMER, MSG_TIMER -- Nothing happens
end

function timer_start(id, ms)
    assert(contains(timers_interval, id) == false)

    timers_clock[id] = ctick.ms() + ms
    timers_interval[id] = ms

    return 1
end

function timer_stop(id)
    for tmr_id, clk in ipairs(timers_clock) do      
        if tmr_id == id then
            table.remove(timers_clock, tmr_id)
            table.remove(timers_interval, tmr_id)
            break
        end
    end
end
