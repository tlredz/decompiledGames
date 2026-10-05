local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local gameData = game.ReplicatedStorage:WaitForChild("GameData")
local Monetization = require(gameData:WaitForChild("Monetization"))
local Eggs = require(gameData:WaitForChild("Eggs"))
local General = require(gameData:WaitForChild("General"))
local DayNight = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("DayNight"))
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")

local function RemainingGrowth(parent)
	local eggData = parent:FindFirstChild("EggData")
	local placeTime = eggData and eggData:FindFirstChild("PlaceTime")
	local egg = Eggs[parent.Name]

	if placeTime and placeTime.Value > 0 and egg then
		local weight = eggData:FindFirstChild("Weight")
		return (math.max(
			General.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1) - DayNight.GrowthElapsed(placeTime.Value),
			0
		))
	else
		return 0
	end
end

local parent = script.Parent
parent.Triggered:Connect(function(player)
	local parent2 = parent.Parent.Parent
	local eggKey = parent2 and parent2:GetAttribute("EggKey")
	local ownerUserId = parent2 and parent2:GetAttribute("OwnerUserId")

	if not (eggKey and ownerUserId) then
		return
	end

	game2:WaitForChild("RegisterSkipTarget"):FireServer(eggKey, ownerUserId)
	local skipTierFor = Monetization.SkipTierFor((RemainingGrowth(parent2)))
	local v = skipTierFor and Monetization[skipTierFor.Product]

	if not v then
		return
	end

	PurchaseCue.Play()
	MarketplaceService:PromptProductPurchase(player, v)
end)