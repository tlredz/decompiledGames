local constants = require(script.Parent.constants)

local function getSender(value)
	if constants.IS_SERVER and (type(value) == "table" or typeof(value) == "Instance") and value.ClassName == "Player" then
		return value
	end

	return nil
end

return getSender