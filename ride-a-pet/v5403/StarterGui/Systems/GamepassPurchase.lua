local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local CollectionService = game:GetService("CollectionService")
local Monetization = require(game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Monetization"))
local Monetization2 = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Monetization"))
local localPlayer = game.Players.LocalPlayer
local SFX = game.SoundService:WaitForChild("SFX")
local v = { "Price", "99text", "PriceLabel" }
local playerToGift = localPlayer:WaitForChild("NoSaveData"):WaitForChild("PlayerToGift")

local function GiftRecipient()
	local value = tonumber(playerToGift.Value) or 0

	if value > 0 and value ~= localPlayer.UserId then
		return value
	end

	return nil
end

local function Init(instance)
	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local name = Monetization[instance.Name] and instance.Name or parent and Monetization[parent.Name] and parent.Name or parent2 and Monetization[parent2.Name] and parent2.Name
	local v2 = name and Monetization[name]

	if not v2 then
		warn(string.format("GamepassPurchase: no id for %s", instance:GetFullName()))
		return
	end

	task.spawn(function()
		local basePrice = Monetization2:GetBasePrice(v2, true)

		if not basePrice then
			return
		end

		for _, childName in v do
			local label = instance:FindFirstChild(childName)

			if label and label:IsA("TextLabel") then
				label.Text = string.format("%i", basePrice)
			end
		end
	end)
	instance.Activated:Connect(function()
		SFX.Click:Play()
		local value = tonumber(playerToGift.Value) or 0

		if not (value > 0) or value == localPlayer.UserId then
			value = nil
		end

		if value then
			return
		end

		PurchaseCue.Play()
		MarketplaceService:PromptGamePassPurchase(localPlayer, v2)
	end)
end

for _, v2 in CollectionService:GetTagged("GamepassPurchase") do
	Init(v2)
end

CollectionService:GetInstanceAddedSignal("GamepassPurchase"):Connect(Init)