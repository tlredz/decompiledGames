if not game then
	local module = require("test/relative-string")
	script = module
end

local function VIDE_ASSERT(message)
	error(message, 0)
end

return VIDE_ASSERT