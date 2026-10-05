if not game then
	local module = require("test/relative-string")
	script = module
end

local function read(callback)
	if type(callback) == "function" then
		return (callback())
	end

	return callback
end

return read