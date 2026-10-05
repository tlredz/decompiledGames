local PlaceRegistry = require(script.Parent:WaitForChild("PlaceRegistry"))
local GeneralConfig = {
	ConfigXPMultiplier = 1,
	GetWorlds = function(_)
		return PlaceRegistry.getWorlds()
	end,
	IsTestPlace = function(self)
		return PlaceRegistry.isTestPlace()
	end
}

function GeneralConfig.GetConfigXPMultiplier(_)
	return GeneralConfig.ConfigXPMultiplier
end

function GeneralConfig:GetWorldStatus()
	return PlaceRegistry.getWorldStatus()
end

if GeneralConfig:IsTestPlace() then
	warn("YOU ARE IN A TESTING PLACE - EARNED XP MULTIPLIED BY : ", GeneralConfig.ConfigXPMultiplier)
	warn("WORLD " .. GeneralConfig:GetWorldStatus())
end

return GeneralConfig