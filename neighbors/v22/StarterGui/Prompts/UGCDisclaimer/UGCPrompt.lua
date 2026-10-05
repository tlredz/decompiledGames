local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local UI = require(ReplicatedStorage.Modules.UI)
local parent = script.Parent
local shop = localPlayer.PlayerGui:WaitForChild("Neighbors").Shop
ProximityPromptService.PromptTriggered:Connect(function(player, p)
	if player:GetAttribute("UGC") and p == localPlayer then
		shop.Visible = true
		shop.Pages.SetPage:Fire(shop.Pages.UGC)
	end
end)
parent.Buttons.Cancel.Button.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
UI:Bind(parent.Buttons.Confirm.Button)
UI:AddShadowOnHover(parent.Buttons.Confirm.Button)
UI:Bind(parent.Buttons.Cancel.Button)
UI:AddShadowOnHover(parent.Buttons.Cancel.Button)