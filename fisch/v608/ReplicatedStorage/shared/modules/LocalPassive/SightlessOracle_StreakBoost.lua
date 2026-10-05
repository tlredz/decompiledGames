game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local SightlessOracleStreakBoost = {
	MorphHarpoon = function(p, _, object)
		local modifier = object:CreateModifier("power", "multiply")
		modifier.Value = 1
		p.reelTrove:Add(object.core.pullButtons.OnClickEvent:Connect(function()
			modifier.Value *= p.config.PowerMultPerPull
		end))
		p.reelTrove:Add(object.core.pullButtons.OnMissEvent:Connect(function()
			modifier.Value = 1
		end))
	end
}
setmetatable(SightlessOracleStreakBoost, module)
return SightlessOracleStreakBoost