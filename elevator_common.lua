-- common definitions used by elevator server and client
LV8_PROTOCOL = "elevator"
LV8_REQ = "request:"
LV8_RESP = "response:"
LV8_DIR_UP = "up"
LV8_DIR_DOWN = "down"
LV8_REQ_UP = LV8_REQ..LV8_UP
LV8_REQ_DOWN = LV8_REQ..LV8_DOWN

function lv8_mess_is_request(mess)
	return string.find(mess, "^"..LV8_REQ) ~= nil
end

function lv8_mess_is_response(mess)
	return string.find(mess, "^"..LV8_RESP) ~= nil
end
