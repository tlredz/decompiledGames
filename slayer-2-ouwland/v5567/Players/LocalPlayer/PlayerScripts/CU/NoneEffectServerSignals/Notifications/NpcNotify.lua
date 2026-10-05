local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Regions = require(ReplicatedStorage.Regions)
return function(clone)
	if typeof(clone) ~= "table" then
		return
	end

	if clone.Icon == nil and clone.Npc ~= nil then
		clone = table.clone(clone)
		clone.Icon = Regions.GetNpcIcon(clone.Npc)
	end

	game.ReplicatedStorage.Communication.CnC.Notifications.CenterLeft:Fire("Npc", clone)
end