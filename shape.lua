-- given a width, determine whether the turtle should turn left or right
function turnFunc(width, rotated)
	local turnFunc = nil
	if math.fmod(width, 2) == 1 then
		turnFunc = turtle.turnRight
	else
		turnFunc = turtle.turnLeft
	end
	if rotated then
		if turnFunc == turtle.turnRight then
			turnFunc = turtle.turnLeft
		end
		if turnFunc == turtle.turnLeft then
			turnFunc = turtle.turnRight
		end
	end
	return turnFunc
end

-- dig a line of the length specified
function digLine(len)
	for pos = 1, len do
		turtle.dig()
		turtle.forward()
	end
	lines_dug = lines_dug + 1
end

-- dig plane of length, width
-- rotated - indicates whether digging from opposite origin, due to odd rownum
function digPlane(length, width, rotated)
	lines_dug = 0
	for wPos = 1, width do
		-- one less than length because the turtle itself is the
		-- first block of the length
		digLine(length - 1)

		if wPos < width then
			turnFunc(wPos, rotated)()
			turtle.dig()
			turtle.forward()
			turnFunc(wPos, rotated)()
		end
	end
	planes_dug = planes_dug + 1
end

-- check the type of block below the turtle
function readBlockBelow()
	exists, block = turtle.inspectDown()
	blockname = block["name"]
	if blockname ~= nil then
		print(blockname)
		parser = string.gmatch(blockname, "([^"..":".."]+)")
		bsource=parser()
		bname = parser()
	else
		bname = "null"
	end
	print(bname)
	return bname
end

-- Drop all inventory
function dropAll()
	for slot = 1, 16 do
		turtle.select(slot)
		while not turtle.drop() do
			print("Waiting for target inventory to have room")
			sleep(5)
		end
	end
end

-- get the length of the line
length = tonumber(arg[1])
width = tonumber(arg[2]) or 1
depth = tonumber(arg[3]) or 512
lines_dug = 0
planes_dug = 0
 
print("Digging parallelpiped of length "..length ..", width "..width.." to depth "..depth)
 

bname = readBlockBelow()
print(string.match(bname, "bedrock"))
print(string.match(bname, "bedrock") == nil)

local plane_length = length
local plane_width = width
local dug_depth = 0
local rotated = false

local stop_reason = "specified depth"
for planes_dug = 1, depth-1 do
	print("Line below starts with "..bname..".")
	print("Will dig line")

	digPlane(plane_length, plane_width, rotated)

	print("turn to dig next plane")
	-- always turn around
	local numTurns = 2
	for i = 1, numTurns do
		turtle.turnRight()
	end
	if math.fmod(plane_width, 2) == 1 then
		-- if the width is odd, then digging an "N"
		-- don't need to change turn direction
		print("Not rotating turn direction")
		rotated = false
	else
		-- if the width was even, then digging a "U"
		-- need to change turn direction
		print("Rotating turn direction")
		rotated = not rotated
	end

	print("dig down and move down")
	turtle.digDown()
	turtle.down()

	dug_depth = dug_depth + 1

	bname = readBlockBelow()
	if string.match(bname, "bedrock") ~= nil then
		stop_reason="bedrock"
		break
	end
end

-- Dig last plane
print("Hit "..stop_reason..". Dig last plane.")
print("Turn direction is rotated: "..rotated)
digPlane(plane_length, plane_width, rotated)

-- Move back to starting x, z
print("Dug "..lines_dug.." lines.")
if math.fmod(lines_dug, 2) == 1 then
	print("Dug odd number of rows. Return to origin length")
	turtle.turnLeft()
	turtle.turnLeft()
	for pos = 1, length-1 do
		turtle.forward()
	end
else
	print("Dug even number of rows. Already at origin length")
end

print("Return to origin width")
turtle.turnRight()
turtle.turnRight()
for pos = 1, width-1 do
	turtle.forward()
end


-- Move back to starting depth
print("Return to origin height")
for pos = 1, dug_depth do
	turtle.up()
end

turtle.turnLeft()
dropAll()

-- Turn back to original position
turtle.turnLeft()
turtle.turnLeft()

