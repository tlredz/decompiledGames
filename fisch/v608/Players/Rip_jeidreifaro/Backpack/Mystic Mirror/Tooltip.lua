local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local v = nil
local MysticMirrorController = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("Items"):WaitForChild("MysticMirrorController"))
local mysticMirror = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("MysticMirror")
parent.Equipped:Connect(function()
	if v then
		v:Remove()
	end

	v = GeneralUIModule:GiveToolTip(localPlayer, "[Interact to configure warp]", parent)
end)
parent.Unequipped:Connect(function()
	if v then
		v:Remove()
	end

	v = nil
	mysticMirror.Visible = false
end)
parent.Activated:Connect(function()
	MysticMirrorController:OnMirrorActivated()
end)