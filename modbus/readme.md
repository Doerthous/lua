# Modbus for Lua
A simple modbus(rtu) library for lua.

## 用法

**创建 modbus 实例**
```
require("modbus")
-- ...
mb = modbus:new(getc, setc)
```

**master**
```
stt, data = mb:read_holding_registers(0x01, 0x0000, 6)
stt, data = mb:read_input_registers(0x01, 0x0000, 6)
stt, data = mb:write_register(0x01, 0x0000, 0x0006)
stt, data = mb:write_registers(0x01, 0x0000, {1,2,3,4,5,6})
```

**slaver**
```
callbacks = {}
callbacks[modbus.FC_READ_HD_REGS] = -- your callback
callbacks[modbus.FC_READ_IN_REGS] = -- your callback
callbacks[modbus.FC_WRITE_REG] = -- your callback
callbacks[modbus.FC_WRITE_REGS] = -- your callback

mb:run(slaver_id, callbacks) -- this will block the code if the mb.getc uses block io.

-- use mb:exit() to exit the loop
```

## Master 接口
- ```read_holding_registers(id, address, count)```
    ```id```: number, e.g: 0x01.
    ```address```: number, e.g: 0x0010.
    ```count```: number, e.g: 0x0010.
    ```return```: modbus state code.

    about return.

- ```modbus:read_input_registers(id, address, count)```
    see ```read_holding_registers```

- ```modbus:write_register(id, address, data)```
    ```id```: number, e.g: 0x01.
    ```address```: number, e.g: 0x0010.
    ```data```: number, e.g: 0x0010.
    ```return```: modbus state code.

- ```modbus:write_registers(id, address, data)```
    ```id```: number, e.g: 0x01.
    ```address```: number, e.g: 0x0010.
    ```data```: table, e.g: { 0x0010, 0x1234 }.
    ```return```: modbus state code.

### Master 接口返回值

## Slaver 回调
### 简介
所有回调接口的返回值具有同一形式的接口：result, data。
result 为 boolean 变量，表示处理结果，true 为正常，false 为异常。当 result 为 true 时，回调接口应返回对应类型的数据，具体见各个回调接口的详细说明。当 result 为 false 时，回调接口应返回 modbus 异常码。

### 回调接口
TODO

## modbus 参数
### 功能码
```
modbus.FC_READ_HD_REGS -- 读 hoiding 寄存器
modbus.FC_READ_IN_REGS -- 读 input 寄存器
modbus.FC_WRITE_REG -- 写寄存器
modbus.FC_WRITE_REGS -- 写多个寄存器
-- todo...
```
### 异常码
```
modbus.EC_ILLEGAL_FUNC -- 非法功能
modbus.EC_ILLEGAL_ADDR -- 非法数据地址
modbus.EC_ILLEGAL_VAL -- 非法数据值
modbus.EC_SRV_DEV_FAILED -- 从设备故障
-- todo...
```