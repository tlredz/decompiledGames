local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Statable)
local v3 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v4 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v5 = require3(ReplicatedStorage2.Shared.Trading.TradeTokensUtils)
local v6 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v7 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v8 = require3(ReplicatedStorage2.Common.Utils)
local confirmationPrompt = ReplicatedStorage2.Assets.UI.Trade.ConfirmationPrompt
local localPlayer = Players.LocalPlayer
local v9 = nil
local popUpTokensBuy = localPlayer.PlayerGui.PopUpTokensBuy
local tokensPromptConfirmation = localPlayer.PlayerGui.TokensPromptConfirmation

-- equivalent calls inferred from this helper; original call sites unknown
local function promptPurchase(p, p2)
	if p2 == Enum.InfoType.GamePass then
		v3:PromptGamePassPurchase(localPlayer, p)
	elseif p2 == Enum.InfoType.Product then
		v3:PromptProductPurchase(localPlayer, p)
	end
end

local TradeTokensController = {}

function TradeTokensController:PromptPurchase(p, currentProductInfoType)
	local currentProductId = tonumber(p)

	if not currentProductId or (self._currentProductId or self._currentProductInfoType or self._isLoading) then
		return
	end

	if v6:GetKey("TradingTokensEnabled") == true then
		self._isLoading = true
		local v11, v12 = v3:GetServerProductInfo(currentProductId, currentProductInfoType):timeout(1.25):await()
		local v13, v14 = v3:GetProductInfoAsync(currentProductId, currentProductInfoType):timeout(1.25):await()
		self._isLoading = nil
		local v15

		if v9 and v11 and v13 and v12 and v14 then
			v15 = (v9:Get("Tokens") or 0) >= v12.UserBasePriceInRobux
		else
			v15 = false
		end

		if v15 and v5.canBePurchasedWithTokens(v12) then
			self._currentProductId = currentProductId
			self._currentProductInfoType = currentProductInfoType
			popUpTokensBuy.Frame.Buttons.BuyRobux.Label.Text = `Buy With {v8.ValueConvertor:AddCommas(v14.PriceInRobux)} Robux`
			popUpTokensBuy.Frame.Buttons.BuyToken.Tokens.Amount.Text = `{v8.ValueConvertor:AddCommas(v12.UserBasePriceInRobux)} Tokens`
			popUpTokensBuy.Enabled = true
		else
			self._currentProductId = nil
			self._currentProductInfoType = nil
			promptPurchase(currentProductId, currentProductInfoType) -- equivalent call inferred; original call site unknown
		end
	else
		promptPurchase(currentProductId, currentProductInfoType) -- equivalent call inferred; original call site unknown
	end
end

function TradeTokensController:PromptConfirmation(data, callback)
	if v6:GetKey("TradingTokensEnabled") ~= true or v6:GetKey("TradingEnabled") ~= true then
		task.spawn(callback, false, "Tokens disabled!")
		return
	end

	if self._currentConfirmationPrompt then
		task.spawn(callback, false, "Processing other purchase!")
		return
	end

	self._currentProductId = -1
	local formatted = `<stroke color="#081749">Buy "<font color="#78ff62">{data.Name}</font>" for</stroke>`
	local clone = confirmationPrompt:Clone()
	clone.Visible = true
	clone.Label.Text = formatted

	if data.ProductId then
		clone.List.Amount.Text = "???"
		local v10 = v3:GetProductInfoAsync(data.ProductId, Enum.InfoType.Product):andThen(function(p)
			clone.List.Amount.Text = v8.ValueConvertor:AddCommas(p.UserBasePriceInRobux)
		end)
		clone.Destroying:Once(function()
			v10:cancel()
		end)
	else
		clone.List.Amount.Text = (data.Price == 0 or not data.Price) and "???" or v8.ValueConvertor:AddCommas(data.Price)
	end

	clone.ItemInfo.ItemName.Text = data.Name
	clone.ItemInfo.Vector.Image = data.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"

	if data.ItemKey and data.Type then
		v7:Add(clone.ItemInfo, data.Type, nil, data.ItemKey)
	end

	self._currentConfirmationPrompt = clone

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onClick(p)
		task.spawn(callback, p)

		if self._currentConfirmationPrompt then
			self._currentConfirmationPrompt:Destroy()
			self._currentConfirmationPrompt = nil
		end

		if self._currentProductId == -1 then
			self._currentProductId = nil
		end

		tokensPromptConfirmation.Enabled = false
	end

	clone.Buttons.Cancel.Activated:Connect(function()
		onClick(false) -- equivalent call inferred; original call site unknown
	end)
	clone.Buttons.Sell.Activated:Connect(function()
		onClick(true) -- equivalent call inferred; original call site unknown
	end)
	clone.Close.Activated:Connect(function()
		onClick(false) -- equivalent call inferred; original call site unknown
	end)
	clone.Parent = tokensPromptConfirmation
	tokensPromptConfirmation.Enabled = true
end

function TradeTokensController:Start()
	v9 = v.Client:WaitReplion("Inventory")

	if not v9 then
		return
	end

	popUpTokensBuy.Frame.Buttons.BuyRobux.Activated:Connect(function()
		local _currentProductId = self._currentProductId
		local _currentProductInfoType = self._currentProductInfoType

		if not _currentProductId or _currentProductId < 0 or not _currentProductInfoType then
			return
		end

		self._currentProductId = nil
		self._currentProductInfoType = nil
		popUpTokensBuy.Enabled = false
		promptPurchase(_currentProductId, _currentProductInfoType) -- equivalent call inferred; original call site unknown
	end)
	popUpTokensBuy.Frame.Buttons.BuyToken.Activated:Connect(function()
		local _currentProductId = self._currentProductId
		local _currentProductInfoType = self._currentProductInfoType

		if not _currentProductId or _currentProductId < 0 or not _currentProductInfoType then
			return
		end

		popUpTokensBuy.Enabled = false
		local v10, v11 = v4.Remotes.PurchaseProductWithTokens:InvokeServer({
			productId = _currentProductId,
			type = _currentProductInfoType == Enum.InfoType.Product and "Product" or _currentProductInfoType == Enum.InfoType.GamePass and "GamePass" or nil
		})

		if v10 then
			ReplicatedStorage2.Misc.reward:Play()
		else
			ReplicatedStorage2.Misc.error:Play()

			if _G.SendNotification and v11 then
				_G.SendNotification(v11, nil, true)
			end
		end

		self._currentProductId = nil
		self._currentProductInfoType = nil
	end)
	popUpTokensBuy.Frame.Cancel.Activated:Connect(function()
		self._currentProductId = nil
		self._currentProductInfoType = nil
		popUpTokensBuy.Enabled = false
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTokens()
		popUpTokensBuy.Frame.Tokens.Amount.Text = v8.ValueConvertor:AddCommas(v9:Get("Tokens") or 0)
	end

	v9:OnChange("Tokens", updateTokens)
	updateTokens() -- equivalent call inferred; original call site unknown
	v2:Connect("PromptTokenPurchase", function(...)
		self:PromptPurchase(...)
	end)
end

return TradeTokensController