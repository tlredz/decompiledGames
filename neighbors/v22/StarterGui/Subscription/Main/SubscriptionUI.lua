local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local close = parent.Close
local subscribe = parent.Subscribe
close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
subscribe.MouseButton1Click:Connect(function()
	MarketplaceService:PromptSubscriptionPurchase(localPlayer, "EXP-4259790001528373570")
end)
Network:listen("SubscriptionPurchaseSuccess", function()
	parent.Visible = false
end)