local module = require("@game/ReplicatedStorage/Packages/Observers")
local module2 = require("@game/ReplicatedStorage/Common/Utils")
local module3 = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
return module.observeTagNoAncestry("BattlepassNPC", function(instance)
	local function updateEndtimestamp()
		instance:SetAttribute("EndTime", module3.getTimestamps().endTimestamp)
	end

	local connection = module2.FFlag.OnChange(updateEndtimestamp)
	return function()
		connection:Disconnect()
	end
end)