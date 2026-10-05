local module = require("./PassiveHandler")
local v = {
	["Styx Angler"] = true
}
local SoulScourge = {
	MorphSpear = true,
	Morph = function(p, _, object)
		if v[object.fish.Name] then
			return
		end

		object:AddModifier("barSize", "multiply", p.config.ControlMultiplier)
		object:AddModifier("resilience", "multiply", p.config.ResilienceMultiplier)
	end
}
setmetatable(SoulScourge, module)
return SoulScourge