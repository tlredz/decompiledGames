local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.Policy)
local v6 = require3(ReplicatedStorage2.Shared.LTM)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v8 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v9 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v10 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local currentLTM = v6.getCurrentLTM()
local productId = currentLTM and currentLTM.Pack.ProductId

if currentLTM then
	local _ = currentLTM.Pack.GiftProductId
end

local mode = currentLTM and currentLTM.Pack.Mode
local formatted = `{mode}PackAppear`
local formatted2 = `{mode}FirstJoinTime`
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v11, v12

if currentLTM and currentLTM.LobbyLTM and currentLTM.IsActive() and currentLTM.Pack.IsEnabled then
	v11 = "LobbyLTMPack"
	v12 = "LobbyLTMPack"
else
	v11 = "LTMPack"
	v12 = "LTMPack"
end

local child = playerGui:WaitForChild("RightHUD").List:WaitForChild(v11)
local timer = child.Timer.Timer
local child2 = playerGui:WaitForChild(v12)
local timeLeft = child2.Page.Time.Clock.TimeLeft
local closeButton = child2.Page.CloseButton
local ownedButton = child2.Page.OwnedButton
local purchaseButton = child2.Page.PurchaseButton
local giftButton = child2.Page.GiftButton
local v13 = nil
local arePaidRandomItemsRestricted = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Countdown(expireTime: number)
	local v14 = expireTime - workspace:GetServerTimeNow()
	return v4.ValueConvertor:FormatTimeWithDays(v14)
end

local LTMPackController = {}

function LTMPackController:GetExpireTime()
	return currentLTM and currentLTM.DateEndTime.UnixTimestamp or -1
end

function LTMPackController:IsActive()
	if arePaidRandomItemsRestricted then
		return false
	end

	local v14 = currentLTM and (currentLTM.LobbyLTM and currentLTM.IsActive() or v2.isLTMServer())
	return currentLTM and v14 and currentLTM.getGameMode() == currentLTM.Pack.Mode and currentLTM.Pack.IsEnabled and workspace:GetServerTimeNow() < self:GetExpireTime() and true or false
end

function LTMPackController:HasPack()
	return v13 ~= nil and v13:Get((`Has{mode}Pack`)) == true
end

function LTMPackController:StartHUD()
	local connection = nil

	local function updateTimer()
		if self:IsActive() then
			timer.Text = Countdown(self:GetExpireTime())
		else
			timer.Text = "EXPIRED!"

			if connection and connection.Connected then
				connection:Disconnect()
				connection = nil
			end
		end
	end

	local function createOrUpdateTimer()
		if connection then
			task.spawn(updateTimer)
		elseif self:IsActive() then
			connection = v4.Thread.Every(1, updateTimer)
		end
	end

	v7:OnGuiOpen(v12, updateTimer)
	v13:OnChange(formatted2, createOrUpdateTimer)
	task.spawn(createOrUpdateTimer)
	child.Activated:Connect(function()
		v7:Open(v12)
	end)
end

function LTMPackController:StartMenu()
	local connection = nil

	local function updateTimer()
		if not v7:IsOpen(v12) then
			return
		end

		if self:IsActive() then
			timeLeft.Text = Countdown(self:GetExpireTime())
		else
			timeLeft.Text = "EXPIRED!"

			if connection and connection.Connected then
				connection:Disconnect()
				connection = nil
			end

			v7:Close(v12)
		end
	end

	local function createOrUpdateTimer()
		if connection then
			task.spawn(updateTimer)
		elseif self:IsActive() then
			connection = v4.Thread.Every(1, updateTimer)
		end
	end

	v7:OnGuiOpen(v12, updateTimer)
	v13:OnChange(formatted2, createOrUpdateTimer)
	task.spawn(createOrUpdateTimer)

	local function updatePrice()
		purchaseButton.Discount.Visible = false
		purchaseButton.WorthLabel.Visible = false
		purchaseButton.WorthAmount.Visible = false
		purchaseButton.Price.Text = "Loading..."

		if productId then
			v3:GetProductInfoAsync(productId, Enum.InfoType.Product):andThen(function(p)
				purchaseButton.Price.Text = not p.PriceInRobux and "Failed to load" or ` {v4.ValueConvertor:AddCommas(p.PriceInRobux)}`
				purchaseButton.Discount.Label.Text = `{math.round((1 - p.PriceInRobux / 999) * 100)}% OFF`
				purchaseButton.Discount.Visible = p.PriceInRobux ~= nil
				local worthLabel = purchaseButton.WorthLabel
				worthLabel.Visible = p.PriceInRobux ~= nil and p.PriceInRobux < 999
				local worthAmount = purchaseButton.WorthAmount
				worthAmount.Visible = p.PriceInRobux ~= nil and p.PriceInRobux < 999
				purchaseButton.WorthAmount.Text = ` {v4.ValueConvertor:AddCommas(999)}`
			end):catch(function()
				purchaseButton.Price.Text = "Failed to load"
				purchaseButton.Discount.Visible = false
				purchaseButton.WorthLabel.Visible = false
				purchaseButton.WorthAmount.Visible = false
			end)
		end
	end

	v4.Thread.Every(121, updatePrice)
	task.spawn(updatePrice)
	closeButton.Activated:Connect(function()
		v7:Close(v12)
	end)
	purchaseButton.Activated:Connect(function()
		if not self:HasPack() and self:IsActive() and productId then
			v10:PromptPurchase(productId, Enum.InfoType.Product)
		end
	end)
	giftButton.Activated:Connect(function()
		if self:IsActive() then
			v9:SetGift("Flying Pack")
		end
	end)

	local function updatePurchaseVisibility()
		local v14 = not self:HasPack() and self:IsActive()
		purchaseButton.Active = v14
		purchaseButton.Visible = v14
		ownedButton.Visible = not v14
	end

	if not v13:Get(formatted) then
		v13:OnChange(formatted, function(p)
			while true do
				local character = localPlayer.Character

				if character and character.Parent ~= workspace.Alive and not (workspace:GetAttribute("GameActive") or v7._currentGui) then
					break
				end

				task.wait(0.5)
			end

			if self:IsActive() and not v7._currentGui and not v7:IsOpen(v12) and p ~= nil then
				v7:Open(v12)
			end
		end)
	end

	if currentLTM and currentLTM.Pack and currentLTM.Pack.Rewards then
		for _, child3 in child2.Page.Items:GetChildren() do
			local name = tonumber(child3.Name)

			if not name then
				continue
			end

			local reward = currentLTM.Pack.Rewards[name]

			if not reward then
				continue
			end

			child3.Vector.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
			child3.Label.Text = reward.DisplayName or "N/A"
		end
	end
end

function LTMPackController:Start()
	v13 = v.Client:WaitReplion("Data")
	self:StartHUD()
	self:StartMenu()
	v7:OnGuiOpen(v12, function()
		v8(Enum.CoreGuiType.PlayerList, false)
	end)
	v7:OnGuiClose(v12, function()
		v8(Enum.CoreGuiType.PlayerList, true)
	end)
	task.spawn(function()
		arePaidRandomItemsRestricted = v5:GetPolicyInfo().ArePaidRandomItemsRestricted
	end)
end

return LTMPackController