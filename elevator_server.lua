require"elevator_common"
-- local direction = string.lower(arg[1] or "nil")
MOTOR = peripheral.wrap("left")
SPEED = 256
ELEVATOR_HEIGHT = 128	-- top is at 63. might also be length limit of rope

function usage()
    return "elevator <up|down>"
end

function doNothing() print("Doing nothing.") end

function sendToTop()
	print("Sending elevator to the top.")
	sleep(MOTOR.translate(ELEVATOR_HEIGHT, SPEED))
	MOTOR.stop()
end

function sendToBottom()
	print("Sending elevator to the bottom.")
	sleep(MOTOR.translate(ELEVATOR_HEIGHT, -SPEED))
	MOTOR.stop()
end

rednet.open("right")
rednet.host(LV8_PROTOCOL, LV8_SERVER)
while true do
	local response=""
	local sID=""
	local sProt=""
	local sMess=""

	print("Elevator server waiting for request")
	local id, message, prot = rednet.receive(LV8_PROTOCOL)
	print("Received message of type: "..type(message))
	if type(message) == "table" then
		-- for key, value in pairs(message) do
		-- 	print(tostring(key)..": "..tostring(value))
		-- end
		sId = message["nSender"] or "nil"
		sProt = message["sProtocol"] or "nil"
		sMess = message["message"] or "nil"
	else
		sId = id or "nil"
		sProt = prot or "nil"
		sMess = message or "nil"
	end

	print("Received message:")
	print("Sender ID: "..sId)
	print("Protocol: "..sProt)
	print("Message: "..sMess)

	-- Default to doing nothing
	local action = doNothing
	local slMess = string.lower(sMess)
	if sProt ~= LV8_PROTOCOL then
		response = "Don't understand protocol "..sProt
	elseif not lv8_mess_is_request(slMess) then
		print("ignoring "..sMess)
		response = nil
	else
		request = slMess
		if request == LV8_REQ_UP then
			action = sendToTop
			response = "Sending elevator up"
		elseif request == LV8_REQ_DOWN then
			action = sendToBottom
			response = "Sending elevator down"
		else
			response = usage()
		end
	end
	if response ~= nil then
		print("Sending response: "..response)
		rednet.send(id, LV8_RESP..response, LV8_PROTOCOL)
	end
	action()
end 
