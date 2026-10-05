local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local localPlayer = Players.LocalPlayer
local v = nil
script.Parent.Equipped:Connect(function()
	v = GeneralUIModule:GiveToolTip(
		localPlayer,
		"[Interact anywhere to open " .. script.Parent.Name .. "]",
		script.Parent
	)
end)
script.Parent.Unequipped:Connect(function()
	if v then
		v:Remove()
	end
end)