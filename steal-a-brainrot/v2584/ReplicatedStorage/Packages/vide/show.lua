local source = require(script.Parent.source)
local derive = require(script.Parent.derive)
local effect = require(script.Parent.effect)
require(script.Parent.untrack)
local switch = require(script.Parent.switch)

local function show(callback, callback2, callback3)
	local v = source()
	effect(function()
		local v2 = callback()

		if v2 then
			v(v2)
		end
	end)
	return switch((derive(function()
		return callback() and true or false
	end)))({
		[true] = function(p)
			return callback2(v, p)
		end,
		[false] = callback3
	})
end

return show