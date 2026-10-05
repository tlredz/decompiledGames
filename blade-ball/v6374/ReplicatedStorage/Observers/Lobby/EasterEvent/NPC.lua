game:GetService("ReplicatedStorage")
local module = require("@game/ReplicatedStorage/Packages/Observers")
local module2 = require("@game/ReplicatedStorage/Common/Utils")
local fFlag = module2.FFlag
return module.observeTagNoAncestry("RhythmEndTimestamp", function(instance)
	local function updateEndTimestamp()
		instance:SetAttribute("EndTime", fFlag.GetInstantFFlag("RhythmEventEndTimestamp") or 0)
	end

	instance:SetAttribute("EndTime", fFlag.GetInstantFFlag("RhythmEventEndTimestamp") or 0)
	fFlag.OnChange(updateEndTimestamp)
	return function()
		instance:SetAttribute("EndTime", nil)
	end
end)