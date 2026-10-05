if not game then
	local module = require("test/relative-string")
	script = module
end

local switch = require(script.Parent.switch)

local function show(callback, callback2, callback3)
	local function truthy()
		return callback() and true or false
	end

	return switch(truthy)({
		[true] = callback2,
		[false] = callback3
	})
end

return show