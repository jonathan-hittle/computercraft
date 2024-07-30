require"elevator_common"
-- local direction = string.lower(arg[1] or "nil")
MOTOR = peripheral.wrap("left")
SPEED = 256
ELEVATOR_HEIGHT = 128	-- top is at 63. might also be length limit of rope

function usage()
    return "elevator <up|down|level name>"
end

function doNothing() print("Doing nothing.") end

function sendToTop()
	print("Sending elevator to the top.")
	sleep(MOTOR.translate(ELEVATOR_HEIGHT, SPEED))
	MOTOR.stop()
	CURR_HEIGHT = LV8_LEVELS["top"]
end

function sendToBottom()
	print("Sending elevator to the bottom.")
	sleep(MOTOR.translate(ELEVATOR_HEIGHT, -SPEED))
	MOTOR.stop()
	CURR_HEIGHT = LV8_LEVELS["bottom"]
end

function sendToHeight(height)
	-- local distance = math.abs(height - CURR_HEIGHT) + 1
	local distance = math.abs(lv8_y_to_abs_y(height) - lv8_y_to_abs_y(CURR_HEIGHT))
	local speed = SPEED

	-- What is this, you ask?
	-- It seems like motor.translate seems to be a bit off in its
	-- calculation of the time to raise or lower an elevator.
	-- It seems be around 1 second/64 meters at speed 256.
	local fudge = math.floor(distance / 64)
	if height < CURR_HEIGHT then
		speed = -SPEED
	end

	print("Currently at height: "..CURR_HEIGHT)
	print("Sending to height: "..height)
	print("Distance is: "..distance)
	print("Rotation is: "..speed)
	-- sleep(MOTOR.translate(distance, speed) + fudge)
	-- 90 degrees will move a rope pulley 1 meter,
	-- but over long distances this is off by about 1.72
	-- therefore, rotate 155 degrees per meter
	sleep(MOTOR.rotate(distance * 155, speed))
	MOTOR.stop()
	CURR_HEIGHT = height
end

-- Use the top as the home position
sendToTop()
CURR_HEIGHT = LV8_LEVELS["top"]

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
	local param = nil
	local slMess = string.lower(sMess)
	if sProt ~= LV8_PROTOCOL then
		response = "Don't understand protocol "..sProt
	elseif not lv8_mess_is_request(slMess) then
		print("ignoring "..sMess)
		response = nil
	else
		request = slMess
		cmd = string.sub(request, string.len(LV8_REQ)+1)
		print("cmd="..cmd)
		if cmd == LV8_DIR_UP then
			action = sendToTop
			response = "Sending elevator up"
		elseif cmd == LV8_DIR_DOWN then
			action = sendToBottom
			response = "Sending elevator down"
		elseif LV8_LEVELS[cmd] ~= nil then
			action = sendToHeight
			param = LV8_LEVELS[cmd]
			response = "Sending to "..cmd..", height "..LV8_LEVELS[cmd]
		else
			response = usage()
		end
	end
	if response ~= nil then
		print("Sending response: "..response)
		rednet.send(id, LV8_RESP..response, LV8_PROTOCOL)
	end
	action(param)
end 
