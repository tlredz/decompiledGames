local module = require("./root")
local module2 = require("./apply")

local function mount(callback, p)
	return module(function()
		local v = callback()

		if p then
			module2(p, { v })
		end
	end)
end

return mount