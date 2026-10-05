local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerBoostSystem = require(script.Parent.ServerBoostSystem)
local ClientState = require(ReplicatedStorage.ClientState)
local RobuxShopConfig = require(ReplicatedStorage.FeatureConfigs.RobuxShopConfig)
local X2BoostUISystem = require(ReplicatedStorage.UISystems.X2BoostUISystem)
local BoomboxShopPreview = require(ReplicatedStorage.UISystems.BoomboxShopPreview)
local GiftConfig = require(ReplicatedStorage.FeatureConfigs.GiftConfig)
local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)
local PlayerUpgradesInventoryUI = require(ReplicatedStorage.UISystems.PlayerUpgradesInventoryUI)
local flag = false
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function setAssetPrice(instance, p)
	MarketplaceInfoCache.Request(p, Enum.InfoType.Asset, function(p2)
		if p2 and p2.PriceInRobux then
			instance.Price.Text = tostring(p2.PriceInRobux)
		end
	end)
end

local function wireAssetBuy(buy, assetId)
	if buy:GetAttribute("IsConnected") then
		return
	end

	buy:SetAttribute("IsConnected", true)
	setAssetPrice(buy, assetId) -- equivalent call inferred; original call site unknown
	buy.Activated:Connect(function()
		MarketplaceService:PromptPurchase(localPlayer, assetId)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireGiftBuy(gift, giftKey)
	if gift:GetAttribute("IsConnected") then
		return
	end

	gift:SetAttribute("IsConnected", true)
	gift.Activated:Connect(function()
		PlayerUpgradesInventoryUI.openGiftModal(giftKey)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireBoombox(mainFrame)
	local assetId = RobuxShopConfig.Boombox.AssetId
	wireAssetBuy(mainFrame.Buy, assetId)
	local gift = mainFrame:FindFirstChild("Gift")

	if not gift then
		return
	end

	local giftKey = RobuxShopConfig.Boombox.GiftKey

	if not (giftKey and GiftConfig.ALL_GIFTS[giftKey]) then
		gift.Visible = false
		return
	end

	wireGiftBuy(gift, giftKey) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireEmotePack(p, emote)
	local assetId = emote.AssetId
	p.Icon.Image = ("rbxthumb://type=Asset&id=%d&w=420&h=420"):format(assetId)
	wireAssetBuy(p.Buy, assetId)
end

local RobuxShopUISystem = {}

function RobuxShopUISystem:UpdateDisplay()
	X2BoostUISystem:UpdateDisplay()
end

function RobuxShopUISystem:InitLogic()
	if flag then
		return
	end

	flag = true
	X2BoostUISystem:InitLogic()
	ServerBoostSystem:InitLogic()

	local function mountModal(p)
		local scrollingFrame = p.ScrollingFrame
		local mainFrame = scrollingFrame.Boombox.MainFrame
		BoomboxShopPreview.mount(mainFrame.ViewportFrame)
		wireBoombox(mainFrame) -- equivalent call inferred; original call site unknown
		local mainFrame2 = scrollingFrame.Emotes.MainFrame

		for k, emote in RobuxShopConfig.Emotes do
			wireEmotePack(mainFrame2[k], emote) -- equivalent call inferred; original call site unknown
		end
	end

	local function setupModal(instance)
		if instance:IsDescendantOf(playerGui) then
			mountModal(instance)
		else
			instance.AncestryChanged:Connect(function()
				if instance:IsDescendantOf(playerGui) then
					mountModal(instance)
				end
			end)
		end
	end

	for _, v in CollectionService:GetTagged("RobuxShopModal") do
		if v:IsDescendantOf(playerGui) then
			mountModal(v)
		else
			local v2 = v
			v.AncestryChanged:Connect(function()
				if v2:IsDescendantOf(playerGui) then
					mountModal(v2)
				end
			end)
		end
	end

	CollectionService:GetInstanceAddedSignal("RobuxShopModal"):Connect(setupModal)

	local function connectCloseBtn(button)
		if not button:IsA("GuiButton") or button:GetAttribute("IsConnected") then
			return
		end

		button:SetAttribute("IsConnected", true)
		button.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end

	for _, v in CollectionService:GetTagged("RobuxShopModalCloseButton") do
		connectCloseBtn(v)
	end

	CollectionService:GetInstanceAddedSignal("RobuxShopModalCloseButton"):Connect(connectCloseBtn)
end

return RobuxShopUISystem