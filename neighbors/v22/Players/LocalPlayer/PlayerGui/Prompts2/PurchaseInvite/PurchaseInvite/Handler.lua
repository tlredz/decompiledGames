local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
local Network = require(ReplicatedStorage.Modules.Network)
local MatchRequestInvite = require(ReplicatedStorage.Assets.Data.MatchRequestInvite)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local list = parent.List
local currency = parent.Currency
local template = list.Template
local robuxTemplate = list.RobuxTemplate
template.Parent = nil
robuxTemplate.Parent = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCount()
	currency.Label.Text = localPlayer:GetAttribute("MatchRequestInvites") or 0
end

for k, v in next, MatchRequestInvite, nil do
	local productId = v.ProductId
	local clone

	if productId then
		clone = robuxTemplate:Clone()
	else
		clone = template:Clone()
	end

	clone.Name = `Product{k}`
	clone.Content.Label.Text = v.Amount
	local v3 = v
	task.spawn(function()
		clone.Purchase.Content.Price.Text = "???"

		if v3.Cost then
			clone.Purchase.Content.Price.Text = v3.Cost
			return
		end

		local productInfoAsync = nil
		local success, result = pcall(function()
			productInfoAsync = MarketplaceService:GetProductInfoAsync(v3.ProductId, Enum.InfoType.Product)
		end)

		if v3 then
			clone.Purchase.Content.Price.Text = `{productInfoAsync.PriceInRobux or "???"}`
		end
	end)
	local v5 = v
	local v6 = k
	clone.Button.Activated:Connect(function()
		if productId then
			MarketplaceService:PromptProductPurchase(localPlayer, v5.ProductId)
		else
			Network:fire("MatchRequest/PurchaseInvite", v6)
		end
	end)
	UI:AddShadowOnHover(clone)
	UI:Bind(clone.Button)
	clone.Parent = list
end

UI:RegisterConstantUIScale(parent.UIScale, {
	PC = 1,
	Mobile = 1.5,
	Tablet = 1.5,
	Console = 1.25
})
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		script.Sound:Play()
		parent.Position = UDim2.new(0.5, 0, 0.5, 10)
		TweenService:Create(parent, TweenInfo.new(0.25), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
	end
end)
parent.Close.Activated:Connect(function()
	parent.Visible = false
end)
Network:listen("MatchRequest/ShowShop", function()
	parent.Visible = true
end)
UI:Bind(parent.Close)
localPlayer:GetAttributeChangedSignal("MatchRequestInvites"):Connect(updateCount)
updateCount() -- equivalent call inferred; original call site unknown