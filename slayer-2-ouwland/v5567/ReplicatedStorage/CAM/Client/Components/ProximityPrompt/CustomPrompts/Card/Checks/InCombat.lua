local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
return function(flag: boolean, list)
	local localPlayer = Players.LocalPlayer

	if not (localPlayer ~= nil and InCombat.RegularIncludeAI(localPlayer) == true ~= flag) then
		return
	end

	table.insert(list, {
		Text = flag and "Must be in combat" or "Must not be in combat",
		Image = "rbxassetid://92644032824443"
	})
end