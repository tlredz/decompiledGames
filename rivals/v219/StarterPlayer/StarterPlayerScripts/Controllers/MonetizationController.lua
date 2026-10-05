local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.PurchaseStarted = Signal.new()
	self.PurchaseFinished = Signal.new()
	self._fetch_robux_price_hashes = {}
	self:_Init()
	return self
end

function class:PromptBulkPurchase(p)
	assert(typeof(p) == "table", "Argument 1 invalid, expected a table, got " .. tostring(p))
	ReplicatedStorage.Remotes.Misc.PromptBulkPurchase:FireServer(p)
	self:_StartPrompt()
end

function class:PromptPurchase(value)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	MarketplaceService:PromptPurchase(Players.LocalPlayer, value)
	self:_StartPrompt()
end

function class:PromptProductPurchase(value)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, value)
	self:_StartPrompt()
end

function class:PromptGamePassPurchase(value)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))

	if PlayerDataController:HasGamepass(MonetizationLibrary:GetGamepassName(value)) then
		return
	end

	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, value)
	self:_StartPrompt()
end

function class:PromptSubscriptionPurchase(value)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))
	MarketplaceService:PromptSubscriptionPurchase(Players.LocalPlayer, value)
	self:_StartPrompt()
end

function class:PromptCurrencyBundlePurchase(p, p2)
	local v = p - PlayerDataController:Get(p2)

	if v <= 0 then
		return
	end

	local NUM_KEY_BUNDLES = p2 == "WeaponKeys" and MonetizationLibrary.NUM_KEY_BUNDLES or p2 == "EventCurrency" and MonetizationLibrary.NUM_EVENT_CURRENCY_BUNDLES or nil
	local v2 = p2 == "WeaponKeys" and "keybundle_" or p2 == "EventCurrency" and "eventcurrencybundle_" or nil

	if not (NUM_KEY_BUNDLES and v2) then
		return
	end

	for i = 1, NUM_KEY_BUNDLES do
		local bundle = MonetizationLibrary.Bundles[v2 .. i]

		if not (v <= bundle.Rewards[1].Quantity) then
			continue
		end

		self:PromptProductPurchase(bundle.ProductID)
		return true
	end
end

function class:FetchRobuxPrice(p, p2)
	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		p,
		p2 or Enum.InfoType.Product
	)

	if not success then
		warn("Failed to fetch robux price:", productInfoAsync)
	end

	return success and productInfoAsync and productInfoAsync.PriceInRobux
end

function class:SetRobuxText(p, ...)
	self._fetch_robux_price_hashes[p] = (self._fetch_robux_price_hashes[p] or 0) + 1
	local _fetch_robux_price_hash = self._fetch_robux_price_hashes[p]
	task.spawn(function(...)
		p.Text = "• • •"
		p.Text = self:_GetRobuxText(_fetch_robux_price_hash, p, ...) or p.Text
	end, ...)
end

function class:SetRobuxTextWithFormat(formatString, p, ...)
	self._fetch_robux_price_hashes[p] = (self._fetch_robux_price_hashes[p] or 0) + 1
	local _fetch_robux_price_hash = self._fetch_robux_price_hashes[p]
	task.spawn(function(...)
		p.Text = "• • •"
		local _GetRobuxText = self:_GetRobuxText(_fetch_robux_price_hash, p, ...)

		if not _GetRobuxText then
			return
		end

		p.Text = string.format(formatString, _GetRobuxText)
	end, ...)
end

function class:VerifyUGC(p)
	ReplicatedStorage.Remotes.Data.VerifyUGC:FireServer(p)
end

function class:_GetRobuxText(p, p2, ...)
	local v = { ... }
	local total = 0

	for i = 1, #v, 2 do
		local robuxPrice = self:FetchRobuxPrice(v[i], v[i + 1])

		if p ~= self._fetch_robux_price_hashes[p2] or not robuxPrice then
			return
		end

		total += robuxPrice
	end

	return utf8.char(57346) .. " " .. Utility:PrettyNumber(total)
end

function class:_StartPrompt()
	self.PurchaseStarted:Fire()
end

function class:_FinishPrompt(p2)
	self.PurchaseFinished:Fire(p2)
end

function class:_Init()
	MarketplaceService.PromptBulkPurchaseFinished:Connect(function(_, _, p)
		local flag = false

		for _, item in pairs(p.Items) do
			if item.status ~= Enum.MarketplaceItemPurchaseStatus.Success then
				continue
			end

			flag = true
			break
		end

		self:_FinishPrompt(flag)

		if flag then
			local v2 = {}

			for _, item in pairs(p.Items) do
				local v3 = MonetizationLibrary.UGCAssetIDToName[tostring(item.id)]

				if v3 then
					table.insert(v2, v3)
				end
			end

			if #v2 > 0 then
				self:VerifyUGC(v2)
			end
		end
	end)
	ReplicatedStorage.Remotes.Misc.StartPurchasePrompt.OnClientEvent:Connect(function()
		self:_StartPrompt()
	end)
	ReplicatedStorage.Remotes.Misc.FinishPurchasePrompt.OnClientEvent:Connect(function(p)
		self:_FinishPrompt(p)
	end)
end

return class._new()