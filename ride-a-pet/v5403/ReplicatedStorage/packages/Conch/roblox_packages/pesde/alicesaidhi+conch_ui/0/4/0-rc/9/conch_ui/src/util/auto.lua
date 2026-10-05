local module = require("../../roblox_packages/vide")
local read = module.read
local v = {
	x = Enum.AutomaticSize.X,
	y = Enum.AutomaticSize.Y,
	xy = Enum.AutomaticSize.XY,
	[""] = Enum.AutomaticSize.None
}
return function(p)
	if typeof(read(p)) == "string" then
		return v[read(p)]
	end

	return Enum.AutomaticSize.None
end