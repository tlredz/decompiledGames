local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local gameData = game.ReplicatedStorage:WaitForChild("GameData")
local Monetization = require(gameData:WaitForChild("Monetization"))
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local parent = script.Parent
parent.Triggered:Connect(function(player)
	local parent2 = parent.Parent.Parent
	local ownerUserId = parent2 and parent2:GetAttribute("OwnerUserId")

	if not ownerUserId then
		return
	end

	game2:WaitForChild("RegisterSkipAllTarget"):FireServer(ownerUserId)
	PurchaseCue.Play()
	MarketplaceService:PromptProductPurchase(player, Monetization.SkipEggGrowthAll)
end)