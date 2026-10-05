local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Shared.SeasonPassSkip)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v3 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v7 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local count = #v2.Skip
local localPlayer = Players.LocalPlayer
local v8 = false
local v9 = 1
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = 1
local purchaseAm = nil
local rewAm1 = nil
local purchaseScrollingFrame = nil
local maxScrollingFrame = nil
local rewAm2 = nil
local cost = nil
local cost2 = nil
local title = nil
local textLabel = nil
local buy = nil
local clone = nil
local clone2 = nil
local PurchaseLevelContainer = {}

function PurchaseLevelContainer.SetFrame(_, p)
	v12 = p
end

function PurchaseLevelContainer.Open(_)
	v12.Visible = true
end

function PurchaseLevelContainer.Close(_)
	v12.Visible = false
end

function PurchaseLevelContainer:GetPlayerTier()
	if not v11 then
		return 0
	end

	local v14 = v11:Get("InfiniteBattlepass.Quests.XP") or 0
	return v7.SeasonData.Rewards.getTierFromXP(v14)
end

function PurchaseLevelContainer:CreateTile(instance, p, _: number, parent)
	local textLabel2 = instance:WaitForChild("Dark"):WaitForChild("TextLabel")
	local imageLabel = instance:WaitForChild("ImageLabel")
	imageLabel.Image = p.Icon or ""
	textLabel2.Text = p.DisplayName
	instance.Parent = parent

	if v3:CanShowRewardInfo(p) then
		v3:AddFromRewardInfo(instance, p)
	end
end

function PurchaseLevelContainer:UpdateVisualContainer(instance, items, _: number)
	local guiObjectsByName = {}

	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObjectsByName[guiObject.Name] = guiObject
		end
	end

	local v14 = nil
	local count2 = 0

	for k, item in items do
		if v14 == nil or k < v14 then
			v14 = k
		end

		if item.free then
			local clone3

			if guiObjectsByName[`Basic{k}`] then
				clone3 = guiObjectsByName[`Basic{k}`]
			else
				clone3 = clone:Clone()
				clone3.LayoutOrder = k
				clone3.Name = `Basic{k}`
			end

			self:CreateTile(clone3, item.free, k + 2, instance)
			count2 += 1
		end

		if not (v8 and item.premium) then
			continue
		end

		local clone3

		if guiObjectsByName[`Premium{k}`] then
			clone3 = guiObjectsByName[`Premium{k}`]
		else
			clone3 = clone2:Clone()
			clone3.LayoutOrder = k
			clone3.Name = `Premium{k}`
		end

		self:CreateTile(clone3, item.premium, k + 1, instance)
		count2 += 1
	end

	for k, v15 in guiObjectsByName do
		local v16 = tonumber(string.match(k, "%d+"))

		if v14 then
			if v16 then
				if instance == maxScrollingFrame then
					v15.Visible = v14 <= v16
				else
					v15.Visible = v14 <= v16 and v16 <= v9
				end
			end
		else
			v15.Visible = false
		end
	end

	if maxScrollingFrame == instance then
		rewAm2.Text = tostring(count2)
	else
		rewAm1.Text = tostring(count2)
	end
end

function PurchaseLevelContainer:UpdateVisualRewardContainerData(p, p2: number, p3: number)
	self:UpdateVisualContainer(p, v7.SeasonData.Rewards.getRewards(math.max(p2, 1), p3, localPlayer), p3)
end

function PurchaseLevelContainer:UpdateMaxRewardPackage()
	local playerTier = self:GetPlayerTier()
	self:UpdateVisualRewardContainerData(maxScrollingFrame, playerTier, playerTier + count)
	local v14 = v2.PackageSkip[count]

	if v14 then
		cost2:RemoveTag("ProductPriceLabel")
		v4(cost2, v14, "DevProduct", ":robux: %s")
	else
		cost2.Text = ` {v5.ValueConvertor:AddCommas((math.floor(count * 99 / 2 + 0.5)))}`
	end

	local v15 = v2.Skip[count]

	if v15 then
		textLabel:RemoveTag("ProductPriceLabel")
		v4(textLabel, v15, "DevProduct", ":robux: %s")
	else
		textLabel.Text = ` {v5.ValueConvertor:AddCommas(count * 99)}`
	end

	title.Text = `{count} LEVEL PACKAGE`
end

function PurchaseLevelContainer:MarkButtonAs(instance, flag: boolean)
	local color = Color3.fromRGB(255, 255, 255)
	local color2 = Color3.fromRGB(70, 70, 70)

	if not flag then
		color = color2
	end

	instance.ImageColor3 = color
	local uIStroke = instance:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Color = color
	end

	local textLabel2 = instance:FindFirstChild("TextLabel")

	if textLabel2 then
		textLabel2.TextColor3 = color
	end
end

function PurchaseLevelContainer:UpdateButton(p: number)
	local playerTier = self:GetPlayerTier()
	v9 = math.clamp(v9 + p, playerTier + 1, playerTier + count)
	math.clamp(v13 + p, 1, count)
	v13 = v9 - playerTier
	purchaseAm.Text = tostring(v13)
	self:UpdateVisualRewardContainerData(purchaseScrollingFrame, playerTier + 1, v9)
	local v14 = v2.Skip[v13]

	if v14 then
		v4(cost, v14, "DevProduct", ":robux: %s")
	else
		cost:RemoveTag("ProductPriceLabel")
		cost.Text = ` {v5.ValueConvertor:AddCommas(v13 * 99)}`
	end

	local less = v12:WaitForChild("Less")
	local more = v12:WaitForChild("More")

	if v13 - 1 < 1 then
		self:MarkButtonAs(less, false)
	else
		self:MarkButtonAs(less, true)
	end

	self:MarkButtonAs(more, true)
end

function PurchaseLevelContainer:Start()
	v11 = assert(v.Client:WaitReplion("Data"))
	purchaseScrollingFrame = v12:WaitForChild("PurchaseScrollingFrame")
	maxScrollingFrame = v12:WaitForChild("MaxScrollingFrame")
	clone = (purchaseScrollingFrame:FindFirstChild("Basic") or script.Basic):Clone()
	clone2 = (purchaseScrollingFrame:FindFirstChild("Premium") or script.Premium):Clone()

	for _, guiObject in purchaseScrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, guiObject in maxScrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local buy50 = v12:WaitForChild("Buy50")
	textLabel = buy50:WaitForChild("TextLabel")
	buy = v12:WaitForChild("Buy")
	cost = buy:WaitForChild("Cost")
	cost2 = buy50:WaitForChild("Cost")
	title = v12:WaitForChild("Title")
	local limited = v12:WaitForChild("Limited")
	v10 = v11:Get("InfiniteBattlepass.LimitedBuyPackage") or 2
	v11:OnChange("InfiniteBattlepass.LimitedBuyPackage", function(p)
		limited.Text = `Limited: {p}/2`
		v10 = p
	end)
	limited.Text = `Limited: {v10}/2`
	v13 = 1
	buy.Activated:Connect(function()
		local v14 = v2.Skip[v13]

		if v14 then
			v6:PromptPurchase(v14, Enum.InfoType.Product)
		end
	end)
	buy50.Activated:Connect(function()
		if v10 <= 0 then
			ReplicatedStorage2.Misc.error:Play()
			return
		end

		local v14 = v2.PackageSkip[count]

		if v14 then
			v6:PromptPurchase(v14, Enum.InfoType.Product)
		end
	end)
	v8 = v11:Get("InfiniteBattlepass.Premium")
	v11:OnChange("InfiniteBattlepass.Premium", function(p, _)
		v8 = p
		self:UpdateMaxRewardPackage()
		self:UpdateButton(0)
	end)
	v11:OnChange("InfiniteBattlepass.Quests.XP", function(_, _)
		self:UpdateMaxRewardPackage()
		self:UpdateButton(0)
	end)
	purchaseAm = v12:WaitForChild("PurchaseAm")
	rewAm2 = v12:WaitForChild("RewAm2")
	rewAm1 = v12:WaitForChild("RewAm1")
	v12:WaitForChild("Less").Activated:Connect(function()
		self:UpdateButton(-1)
	end)
	v12:WaitForChild("More").Activated:Connect(function()
		self:UpdateButton(1)
	end)
	v12:WaitForChild("Max").Activated:Connect(function()
		self:UpdateButton(10)
	end)
	self:UpdateMaxRewardPackage()
	self:UpdateButton(0)
end

return PurchaseLevelContainer