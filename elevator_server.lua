-- local direction = string.lower(arg[1] or "nil")
local motor = peripheral.wrap("left")
local speed = 256
local protocol = "elevator"

function usage()
    return "elevator <up|down>"
  end

rednet.open("right")
while true do
    print("Elevator server waiting for command")
    local id, message, prot = rednet.receive()
    sId = message["nSender"]
    sProt = message["sProtocol"]
    sMess = message["message"]
    for key, value in pairs(message) do
        print(tostring(key)..": "..tostring(value))
    end
    print("Received message:")
    print("Sender ID: "..sId)
    print("Protocol: "..sProt)
    print("Message: "..sMess)
    if sProt == protocol then
          direction = string.lower(sMess)
        if direction == "up" then
            motor.setSpeed(speed)
            response = "Sending elevator up"
        elseif direction == "down" then
            motor.setSpeed(-speed)
            response = "Sending elevator down"
        else
            response = usage()
        end
    else
        response = "Don't understand protocol "..sProt
    end
    rednet.send(id, response)
end 
