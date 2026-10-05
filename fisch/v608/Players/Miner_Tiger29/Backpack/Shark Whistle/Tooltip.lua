local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local v = nil
parent.Equipped:Connect(function()
	if v then
		v:Remove()
	end

	v = GeneralUIModule:GiveToolTip(localPlayer, "[Interact to Summon a Random Shark Hunt]", parent)
end)
parent.Unequipped:Connect(function()
	if v then
		v:Remove()
	end

	v = nil
end)