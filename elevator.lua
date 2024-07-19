require"elevator_common"
local direction = string.lower(arg[1] or "nil")
local server_id = 20 -- magic no. ; server comp id

function usage()
    print("elevator <up|down>")
end
 
got_response=false

rednet.open("right")
rednet.send(server_id, LV8_REQ..direction, LV8_PROTOCOL)
for response_waits = 1,5 do
	local id, message, resp_prot = rednet.receive()
	sId = message["nSender"]
	sProt = message["sProtocol"] or "nil"
	sMess = message["message"]
	if id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_response(sMess) then
		print("received response: "..sMess)
	else
		print("received unexpected message: "..sMess)
		print("from comp id, protocol: "..id..", "..sProt)
	end
	if id == server_id and resp_prot == LV8_PROTOCOL and lv8_mess_is_response(sMess) then
		got_response=true
		break
	end
	sleep(5)
end

if not got_response then
	print("Timed out waiting for response")
	print("Engage optical scanners to confirm current status.")
end
rednet.close("right")
