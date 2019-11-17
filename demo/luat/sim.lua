package.path = "./sim/?.lua;./lib/?.lua;./task/?.lua;"..package.path..";"
package.cpath = "./sim/?.dll;"..package.cpath..";"

function add_demo_path(demo)
    package.path = package.path.."./demo/"..demo.."/?.lua;"
end

-- if add demo path here
add_demo_path("json") -- ./demo/json
print(package.path)

ctick = require("ctick")
json = require("json")


require("uart")
require("rtos")


require("main")