local direction = string.lower(arg[1] or "nil")
local motor = peripheral.wrap("left")
local speed = 256
 
function usage()
    print("elevator <up|down>")
end
 
if direction == "up" then
    motor.setSpeed(speed)
elseif direction == "down" then
    motor.setSpeed(-speed)
else
    usage()
end
