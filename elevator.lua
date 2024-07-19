local direction = string.lower(arg[1] or "nil")
local motor = peripheral.wrap("left")
local speed = 256
local server_id = 20 -- magic no. ; server comp id
local protocol = "elevator"
function usage()
    print("elevator <up|down>")
end
 
rednet.open("right")
rednet.send(server_id, direction, protocol)
repeat
    local id, response, resp_prot = rednet.receive()
    if id == server_id and resp_prot == protocol then
        print("received response: "..response)
    else
        print("received unexpected message: "..response)
        print("from comp id, protocol: "..id..", "..resp_prot)
    end
until id == server_id and resp_prot == protocol
rednet.close("right")
