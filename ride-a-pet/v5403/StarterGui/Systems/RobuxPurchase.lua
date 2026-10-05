local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local CollectionService = game:GetService("CollectionService")
local Monetization = require(game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Monetization"))
local Monetization2 = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Monetization"))
local localPlayer = game.Players.LocalPlayer
local tagged = CollectionService:GetTagged("RobuxPurchase")
local SFX = game.SoundService:WaitForChild("SFX")
local v = { "Price", "99text", "PriceLabel" }
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = {}
local Init

Init = function(instance)
	if object[instance] or not (instance:IsA("GuiButton") or instance:IsA("ProximityPrompt")) then
		return
	end

	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local v3 = parent and Monetization[parent.Name] or Monetization[instance.Name] or parent2 and Monetization[parent2.Name]

	if parent and v3 then
		if v2[instance] then
			v2[instance]:Disconnect()
			v2[instance] = nil
		end

		object[instance] = true
		task.spawn(function()
			local basePrice = Monetization2:GetBasePrice(v3, false)

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

		if instance:IsA("ProximityPrompt") then
			instance.Triggered:Connect(function(player)
				if player ~= localPlayer then
					return
				end

				if v3 then
					SFX.Click:Play()
					PurchaseCue.Play()
					MarketplaceService:PromptProductPurchase(localPlayer, v3)
				end
			end)
		else
			instance.Activated:Connect(function()
				if v3 then
					SFX.Click:Play()
					PurchaseCue.Play()
					MarketplaceService:PromptProductPurchase(localPlayer, v3)
				end
			end)
		end
	elseif not v2[instance] then
		v2[instance] = instance.AncestryChanged:Connect(function()
			Init(instance)
		end)
	end
end

for _, v3 in tagged do
	Init(v3)
end

CollectionService:GetInstanceAddedSignal("RobuxPurchase"):Connect(function(p)
	Init(p)
end)
CollectionService:GetInstanceRemovedSignal("RobuxPurchase"):Connect(function(p)
	if v2[p] then
		v2[p]:Disconnect()
		v2[p] = nil
	end
end)