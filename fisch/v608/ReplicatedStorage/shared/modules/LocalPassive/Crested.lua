local module = require("./PassiveHandler")
local Crested = {
	Morph = function(p, _, object)
		local config = p.config

		-- equivalent calls inferred from this helper; original call sites unknown
		local function apply()
			local fishSpeedMultiplier = config.FishSpeedMultiplier

			if config.AntiStunFishSpeedMultiplier and (object.data.SlashDisableStun or object.data.SlashStunMult) then
				fishSpeedMultiplier = config.AntiStunFishSpeedMultiplier
			end

			object:AddModifier("movementfactor", "multiply", 1 / fishSpeedMultiplier)
		end

		if not object.ready then
			p.reelTrove:Connect(object.OnReady, apply)
			return
		end

		apply() -- equivalent call inferred; original call site unknown
	end
}
setmetatable(Crested, module)
return Crested