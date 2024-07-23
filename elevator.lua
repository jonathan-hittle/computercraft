require"elevator_common"
-- local server_id = 20 -- magic no. ; server comp id

function usage()
    print("elevator <up|down>")
end

local modem_direction = ""
local destination = string.lower(arg[1] or "nil")

if destination ~= LV8_DIR_UP
    and destination ~= LV8_DIR_DOWN
    and LV8_LEVELS[destination] == nil then
	print("usage: elevator <up|down|level name>")
	print("where <level name> can be one of: ")
	for key, value in pairs(LV8_LEVELS) do
		print(key)
	end
	return LV8_EINVAL
end

if pocket then
	modem_direction = "back"
else
	modem_direction = "right"
end
 

rednet.open(modem_direction)

local server_id = rednet.lookup(LV8_PROTOCOL, LV8_SERVER)
if not server_id then
	print("Elevator server not found.")
	return LV8_EHOSTDOWN
end

rednet.send(server_id, LV8_REQ..destination, LV8_PROTOCOL)
local got_response=false
for response_waits = 1,5 do
	print("Attempt "..response_waits.." to wait for response")
	local id, message, resp_prot = rednet.receive(LV8_PROTOCOL, 5)
	if id ~= nil then
		if type(message) == "table" then
			sId = message["nSender"] or "nil"
			sProt = message["sProtocol"] or "nil"
			sMess = message["message"] or "nil"
		else
			sId = id or "nil"
			sProt = resp_prot or "nil"
			sMess = message or "nil"
		end
		if id == server_id
		and resp_prot == LV8_PROTOCOL
		and lv8_mess_is_response(sMess) then
			print("received response: "..sMess)
			got_response=true
			break
		else
			print("received unexpected message: "..sMess)
			print("from comp id, protocol: "..id..", "..sProt)
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
