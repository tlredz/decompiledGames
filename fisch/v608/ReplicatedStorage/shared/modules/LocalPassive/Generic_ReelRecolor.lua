local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local GenericReelRecolor = {
	MorphSpear = true,
	Morph = function(p, p2)
		GeneralUtils.applyProperties(p2, p.config)
	end
}
setmetatable(GenericReelRecolor, module)
return GenericReelRecolor