require(script.Parent.Parent:WaitForChild("shared"))
local ReactBindingroblox = require(script.Parent:WaitForChild("ReactBinding.roblox"))
return {
	createRef = function()
		local v, _ = ReactBindingroblox.create(nil)
		local v2 = {}

		if _G.__DEV__ then
			v._source = debug.traceback("Ref created at:", 1)
		end

		setmetatable(v2, {
			__index = function(_, p)
				if p == "current" then
					return v:getValue()
				end

				return v[p]
			end,
			__newindex = function(_, p, p2)
				if p == "current" then
					ReactBindingroblox.update(v, p2)
				end

				v[p] = p2
			end,
			__tostring = function(_)
				return string.format("Ref(%s)", (tostring(v:getValue())))
			end
		})
		return v2
	end
}