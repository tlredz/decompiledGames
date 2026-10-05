local root = require(script.Parent.root)
local apply = require(script.Parent.apply)

local function mount(callback, p)
	return root(function()
		local v = callback()

		if p then
			apply(p, { v })
		end
	end)
end

return mount