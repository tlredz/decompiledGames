local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local GenericFixedProgressSpeed = {
	MorphSpear = true,
	Morph = function(p, _, object)
		if p.config.ForcedProgressFishOnly ~= nil then
			local v = fish[object.fish.Name]
			local v2

			if v.ForcedProgressEfficiency == nil then
				v2 = false
			else
				v2 = v.ForcedProgressEfficiency < 1
			end

			if v2 ~= p.config.ForcedProgressFishOnly then
				return
			end
		end

		object:AddModifier("progressefficiency", "force_final", p.config.FixedProgressEfficiency)

		if p.config.DisplayFormat then
			object.progspeed_format = p.config.DisplayFormat
		end
	end
}
setmetatable(GenericFixedProgressSpeed, module)
return GenericFixedProgressSpeed