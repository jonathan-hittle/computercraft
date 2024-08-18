-- assumptions:
-- there is a powered inductive charger under origin
-- there is a modular router nearby

DIR_FORWARD=1
DIR_UP=2
DIR_DOWN=3

-- returns the full spec ("module:blockname") of the block in direction
-- or an empty string if there is a block but name is nil
-- or returns nil if there is no block
function get_block(direction)
	local inspectFunction = nil

	if direction == nil or direction == DIR_FORWARD then
		inspectFunction = turtle.inspect
	elseif direction == DIR_UP then
		inspectFunction = turtle.inspectUp
	elseif direction == DIR_DOWN then
		inspectFunction = turtle.inspectDown
	else
		print("Undefined direction: "..toString(direction))
		return nil
	end

	exists, block = inspectFunction()
	if not exists then return nil end

	return block["name"] or ""
end

-- return whether block name matches
function match_block_name(blockname, ref_name)
	matches = false
	if blockname ~= nil then
		if blockname == ref_name then
			matches = true
		else
			print("Name '"..blockname.."' does not match ref '"..ref_name.."'.")
		end
	else
		print("No block name.")
	end

	return matches
end

-- returns true if there is a charger under the turtle
function verify_charger()
	local is_charger = false

	blockname = get_block(DIR_DOWN)
	is_charger = match_block_name(blockname, "peripherals:induction_charger")
	if not is_charger then
		print("Block below turtle is not a charger.")
	end

	return is_charger
end

-- returns true if there is a modular router on the left side of the turtle
-- assumes called while facing where the tree will be
-- This function turns the turtle, and must restore original facing
function verify_router()
	local is_router = true

	turtle.turnLeft()

	blockname = get_block(DIR_FORWARD)
	is_router = match_block_name(blockname, "modularrouters:modular_router")
	if not is_router then
		print("Block left of turtle is not a modular router.")
	end

	turtle.turnRight()

	return is_router
end

-- watches the block in front of the turtle waiting for a tree to grow
function wait_for_tree()
	while string.find(get_block(DIR_FORWARD) or "", "_log$") == nil do
		print("Waiting for a tree to grow.")
		sleep(60)
	end
	print("There's a tree!")
end

-- returns the height moved
function fell_tree()
	local height = 0
	while string.find(get_block(DIR_FORWARD) or "", "_log$") ~= nil do
		turtle.dig()
		turtle.digUp()
		turtle.up()
		height = height + 1
	end
	return height
end

-- move the turtle back to where it started
function return_to_origin(height)
	for i = 1, height do
		turtle.down()
	end
end

-- scoop up everything dropped by the felled tree
-- keep slot 16 filled w/ saplings
-- send everything else through the router
function manage_inventory()
	-- move forward and clean up a 3x3 area
	-- doubtless things were dropped behind as well,
	-- but don't want to code moving around the modular router and electric
	turtle.forward()
	turtle.turnLeft()
	turtle.forward()
	turtle.turnRight()

	turtle.suck()

	turnFunc = turtle.turnRight
	for row = 1, 3 do
		for spot = 1, 2 do
			turtle.forward()
			turtle.suck()
		end
		turnFunc()
		turtle.forward()
		turnFunc()
		turtle.suck()

		if turnFunc == turtle.turnRight then
			turnFunc = turtle.turnLeft
		else
			turnFunc = turtle.turnRight
		end
	end

	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	turtle.back()

	turtle.turnLeft()
	for slot = 1, 15 do
		-- keep up to a stack of saplings for replanting
		turtle.select(slot)
		data = turtle.getItemDetail()
		if data ~= nil then
			if string.find(data["name"], "_sapling$") ~= nil then
				turtle.transferTo(16)
			end
		end

		-- send anything else through the router
		while turtle.getItemCount() and not turtle.drop() do
			print("Waiting for space in router.")
			sleep(5)
		end
	end
	turtle.turnRight()
end

function plant_tree()
	turtle.select(16)
	turtle.place()
end

function restart()
	-- we're where we're supposed to be
	if verify_charger() then return end

	-- might have restarted after harvesting current height
	if string.find(get_block(DIR_FORWARD) or "", "_log$") == nil then
		turtle.digUp()
		turtle.up()
	end
	
	-- if a tree is here, fell it
	if string.find(get_block(DIR_FORWARD) or "", "_log$") ~= nil then
		fell_tree()
	end
	
	-- move down as far as possible
	while turtle.down() do end

	-- we've done what we can; main will verify we're on top of a charger
end

function main()
	restart()

	if not verify_charger() then
		print("Must have an inductive charger below starting position")
		os.exit(1)
	end

	if not verify_router() then
		print("Must have a modular router left of starting position")
		os.exit(2)
	end

	while true do
		wait_for_tree()
		height = fell_tree()
		return_to_origin(height)
		manage_inventory()
		plant_tree()
	end
end

main()
