local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local GenericAntiSlashes = {
	MorphSpear = true,
	Morph = function(p, _, p2)
		if p.config.ForcedProgressFishOnly ~= nil then
			local v = fish[p2.fish.Name]
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

		p2.data.SlashDamageReduction = p.config.DamageReduction
		p2.data.SlashStunBuff = p.config.StunDurationBuff
		p2.data.SlashStunMult = p.config.StunDurationMult
		p2.data.SlashDisableStun = p.config.DisableStun
	end
}
setmetatable(GenericAntiSlashes, module)
return GenericAntiSlashes