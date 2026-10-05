local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
script.Parent.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(localPlayer, 1906320455)
end)