game:GetService("ContentProvider")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local GenericAddModifiers = {
	MorphSpear = true,
	Morph = function(p, _, object)
		for k, modifier in p.config.Modifiers do
			for k2, v in modifier do
				object:AddModifier(k2, k, v)
			end
		end
	end
}
setmetatable(GenericAddModifiers, module)
return GenericAddModifiers