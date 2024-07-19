-- dig a line of the length specified
function digLine(len)
		for pos = 1, len do
				turtle.dig()
				turtle.forward()
		end
		lines_dug = lines_dug + 1
end
-- get the length of the line
line_len = arg[1]
lines_dug = 0
 
print("Digging plane of length "..line_len.." to bedrock")
 
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
depth = 0
print(string.match(bname, "bedrock"))
print(string.match(bname, "bedrock") == nil)
repeat
		print("Line below starts with "..bname..".")
		print("Will dig line")
		digLine(line_len-1)

		print("turn around")
		turtle.turnLeft()
		turtle.turnLeft()

		print("dig down and move down")
		turtle.digDown()
		turtle.down()

		exists, block = turtle.inspectDown()
		blockname = block["name"]
		if blockname ~= nil then
				parser = string.gmatch(blockname, "([^"..":".."]+)")
				bsource=parser()
				bname = parser()
				print(bname)
		else
				bname = "null"
		end
		depth = depth + 1
until string.match(bname, "bedrock") ~= nil

-- Dig last line
print("Hit Bedrock. Dig last line.")
digLine(line_len-1)

-- Move back to starting x, z
-- if depth % 1 == 1 then
print("Dug "..lines_dug.." rows.")
if math.fmod(lines_dug, 2) == 1 then
		print("Dug odd number of rows. Return to origin x, z")
		turtle.turnLeft()
		turtle.turnLeft()
		for pos = 1, line_len-1 do
				turtle.forward()
		end
else
		print("Dug even number of rows. Already at origin x, z")
end

-- Move back to starting depth
for pos = 1, depth do
		turtle.up()
end

-- Turn back to original position
turtle.turnLeft()
turtle.turnLeft()
