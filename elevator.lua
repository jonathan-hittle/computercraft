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
	sId = message["nSender"]
	sProt = message["sProtocol"]
	sMess = message["message"]
	if id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_response(sMess) then
		print("received response: "..sMess)
	else
		print("received unexpected message: "..sMess)
		print("from comp id, protocol: "..id..", "..resp_prot)
	end
until id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_response(sMess)
rednet.close("right")
