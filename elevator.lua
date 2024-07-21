require"elevator_common"
local direction = string.lower(arg[1] or "nil")
local server_id = 20 -- magic no. ; server comp id

function usage()
    print("elevator <up|down>")
end

if pocket then
	modem_direction = "back"
else
	modem_direction = "right"
end
 
got_response=false

rednet.open(modem_direction)
rednet.send(server_id, LV8_REQ..direction, LV8_PROTOCOL)
for response_waits = 1,5 do
	print("Attempt "..response_waits.." to wait for response")
	local id, message, resp_prot = rednet.receive(5)
	if id ~= nil then
		if type(message) == "table" then
			sId = message["nSender"]
			sProt = message["sProtocol"] or "nil"
			sMess = message["message"]
		else
			sId = id
			sProt = resp_prot or "nil"
			sMess = message
		end
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
	else
		print("Timeout while waiting to receive reply; will retry.")
	end
end

if not got_response then
	print("Timed out waiting for response")
	print("Engage optical scanners to confirm current status.")
end
rednet.close(modem_direction)
