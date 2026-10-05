local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
local Money = require(ReplicatedStorage.Modules.Money)
local Currency = require(ReplicatedStorage.Assets.Data.Store.Currency)
local localPlayer = game.Players.LocalPlayer
local insufficientCreditPrompt = script.Parent.Parent.InsufficientCreditPrompt
local contentContainer = insufficientCreditPrompt.ContentContainer
local description = contentContainer.Description
local confirm = contentContainer.Buttons.Confirm
local decline = contentContainer.Buttons.Decline
local close = contentContainer.Close
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrencyInfo(p: number)
	for _, v2 in next, Currency, nil do
		if v2.Id == p then
			return v2
		end
	end

	return nil
end

Network:listen("NotEnoughCredits", function(p: number, p2: number, _: string)
	v = p2
	insufficientCreditPrompt.Visible = true
	local currencyInfo = getCurrencyInfo(p2) -- equivalent call inferred; original call site unknown

	if currencyInfo and currencyInfo.Price and typeof(currencyInfo.Price) == "number" then
		confirm.TextLabel.Text = `{Money(currencyInfo.Price, true)}`
	else
		confirm.TextLabel.Text = "Buy"
	end

	description.Text = `Would you like to purchase <b>${p}</b> credits?`
	insufficientCreditPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
	insufficientCreditPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
	insufficientCreditPrompt.Visible = true
	script.Sound:Play()
	TweenService:Create(
		insufficientCreditPrompt,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0.5, 0, 0.5, 10)
		}
	):Play()
end)
confirm.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(localPlayer, v)
	insufficientCreditPrompt.Visible = false
end)
decline.MouseButton1Click:Connect(function()
	insufficientCreditPrompt.Visible = false
end)
close.MouseButton1Click:Connect(function()
	insufficientCreditPrompt.Visible = false
end)
UI:Bind(confirm)
UI:Bind(decline)
UI:Bind(close)
UI:BindClick(confirm)
UI:BindClick(decline)