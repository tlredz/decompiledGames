local module = require("../../roblox_packages/vide")
local read = module.read

local function conditional(p, p2, p3)
	return function()
		if read(p) then
			return (read(p2))
		end

		return (read(p3))
	end
end

return conditional