require"elevator_common"
local direction = string.lower(arg[1] or "nil")
local server_id = 20 -- magic no. ; server comp id

function usage()
    print("elevator <up|down>")
end
 
rednet.open("right")
rednet.send(server_id, LV8_REQ..direction, LV8_PROTOCOL)
repeat
    local id, message, resp_prot = rednet.receive()
    if id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_resp(message) then
        print("received response: "..message)
    else
        print("received unexpected message: "..message)
        print("from comp id, protocol: "..id..", "..resp_prot)
    end
until id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_response(message)
rednet.close("right")
