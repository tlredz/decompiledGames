local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local Monetization = {}

function Monetization.GetBasePrice(_, value: number, flag: boolean?)
	if typeof(value) ~= "number" then
		return nil
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(value, flag and Enum.InfoType.GamePass or Enum.InfoType.Product)
	end)

	if success and result then
		return result.PriceInRobux
	end

	warn("[Monetization] Failed to get price for", value, result)
	return nil
end

function Monetization:GetProductInfo(value: number)
	if typeof(value) ~= "number" then
		warn("[Monetization] Invalid ProductId:", value)
		return nil
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(value, Enum.InfoType.Product)
	end)

	if success then
		return result
	end

	warn("[Monetization] Failed to get info for ProductId:", value, result)
	return nil
end

function Monetization.UGCOutOfStock(_, p)
	local productInfo = nil
	local _, _ = pcall(function()
		productInfo = MarketplaceService:GetProductInfo(p, Enum.InfoType.Asset)
	end)

	if not productInfo then
		return false
	end

	local remaining = productInfo.Remaining
	return not remaining or remaining <= 0
end

function Monetization:OpenBuyPrompt(instance, p, p2)
	local promptProductPurchaseFinishedConnection = nil

	if (p2 == nil or p2) == true then
		PurchaseCue.Play()
		MarketplaceService:PromptProductPurchase(instance, p)
		promptProductPurchaseFinishedConnection = MarketplaceService.PromptProductPurchaseFinished:Connect(function(p3, p4, _)
			if p3 == instance.UserId and p4 == p then
				self:CloseBuyPrompt(instance)
				promptProductPurchaseFinishedConnection:Disconnect()
			end
		end)
	else
		PurchaseCue.Play()
		MarketplaceService:PromptGamePassPurchase(instance, p)
		promptProductPurchaseFinishedConnection = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p3, p4, _)
			if p3 == instance and p4 == p then
				self:CloseBuyPrompt(instance)
				promptProductPurchaseFinishedConnection:Disconnect()
			end
		end)
	end

	TweenService:Create(Lighting:WaitForChild("Blur"), TweenInfo.new(0.5), {
		Size = 30
	}):Play()
	local buyingScreen = instance:WaitForChild("PlayerGui"):WaitForChild("Reusable"):FindFirstChild("BuyingScreen")

	if UserInputService.TouchEnabled == false and buyingScreen then
		buyingScreen.BackgroundTransparency = 1
		local tween = TweenService:Create(buyingScreen, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.15
		})
		buyingScreen.Visible = true
		tween:Play()
	end
end

function Monetization:CloseBuyPrompt(instance)
	TweenService:Create(Lighting:WaitForChild("Blur"), TweenInfo.new(0.5), {
		Size = 1
	}):Play()
	local buyingScreen = instance:WaitForChild("PlayerGui"):WaitForChild("Reusable"):FindFirstChild("BuyingScreen")

	if buyingScreen then
		buyingScreen.Visible = false
	end
end

return Monetization