-- common definitions used by elevator server and client
LV8_PROTOCOL = "elevator"
LV8_SERVER = LV8_PROTOCOL.."-server"
LV8_REQ = "request:"
LV8_RESP = "response:"
LV8_DIR_UP = "up"
LV8_DIR_DOWN = "down"
LV8_REQ_UP = LV8_REQ..LV8_DIR_UP
LV8_REQ_DOWN = LV8_REQ..LV8_DIR_DOWN

-- The keys in this table will be presented as destinations.
-- The values are the in-world "Y" values for height.
-- It doesn't really matter if you put in the Y value for the block
-- or the Y value for something standing on the block.
-- You just need to be consistent.
-- These values are the Y value of something standing on the block
LV8_LEVELS = {}
LV8_LEVELS["top"] = 63
LV8_LEVELS["compress"] = 53
LV8_LEVELS["storage"] = 43
LV8_LEVELS["manuf"] = 33
LV8_LEVELS["ag"] = 8
LV8_LEVELS["bottom"] = -63

-- These values are the actual Y values for highest and lowest block.
LV8_MAXHEIGHT = 319
LV8_BEDROCK = -64

-- Error codes
LV8_EINVAL = 22
LV8_EHOSTDOWN = 112

-- Treat Y of bedrock as absolute 0, return height relative to that.
function lv8_y_to_abs_y(y)
	return y + math.abs(LV8_BEDROCK)
end

function lv8_mess_is_request(mess)
	return string.find(mess, "^"..LV8_REQ) ~= nil
end

function lv8_mess_is_response(mess)
	return string.find(mess, "^"..LV8_RESP) ~= nil
end
