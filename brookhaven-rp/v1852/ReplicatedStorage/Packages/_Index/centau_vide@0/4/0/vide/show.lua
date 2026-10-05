local module = require("./source")
local module2 = require("./derive")
local module3 = require("./effect")
require("./untrack")
local module4 = require("./switch")

local function show(callback, callback2, callback3)
	local v = module()
	module3(function()
		local v2 = callback()

		if v2 then
			v(v2)
		end
	end)
	return module4((module2(function()
		return callback() and true or false
	end)))({
		[true] = function(p)
			return callback2(v, p)
		end,
		[false] = callback3
	})
end

return show