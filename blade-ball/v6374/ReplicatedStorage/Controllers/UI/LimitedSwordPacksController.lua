local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Promise)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Packages.Signal)
local v6 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v7 = require3(ReplicatedStorage2.Packages.Replion)
local v8 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v9 = require3(ReplicatedStorage2.Shared.LimitedSwordPacksData)
local v10 = require3(ReplicatedStorage2.Shared.UiPresets)
local v11 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v12 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v13 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v14 = require3(ReplicatedStorage2.Controllers.VFXController)
local v15 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v16 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v17 = require3(ReplicatedStorage2.Common.Utils.Utilities.RewardInfo)
local v18 = require3(ReplicatedStorage2.Common.RewardInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v19 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v20 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v21 = require3(ReplicatedStorage2.Shared.GiftProductsId)
local v22 = require3(ReplicatedStorage2.Common.Utils)
local v23 = require3(ReplicatedStorage2.Packages.Observers)
local v24 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local remoteEvent = v2:RemoteEvent("SessionAnalyticsEvent")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local limitedSword_SwordPacks = playerGui:WaitForChild("LimitedSword_SwordPacks")
local v25 = nil
local LimitedSwordPacksController = {
	_bundleChanged = v5.new(),
	BundleChanged = v5.new(),
	CurrentlySelectedBundle = nil,
	CurrentlySelectedColor = "Black",
	CurrentlyColorTypeForcedShowRoom = nil
}
local activeBundles = nil
local v26 = {}
local count = 0
local v27 = nil
local productIntelligence = false
local v29 = {}

local function getStartDate(p)
	return p.FFlagStartTime and v12:GetKey(p.FFlagStartTime) or p.RootFFlagStartTime and v12:GetKey(p.RootFFlagStartTime) or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEndDate(p)
	return p.FFlagEndTime and v12:GetKey(p.FFlagEndTime) or p.RootFFlagEndTime and v12:GetKey(p.RootFFlagEndTime) or 0
end

local function getProductRank(p: number?)
	return p and v26[p] or nil
end

local function getBundleRank(reward)
	local v30 = nil

	for _, v31 in reward.Rewards or {} do
		local productId = v31.ProductId
		local v32 = productId and v26[productId] or nil

		if v32 and (not v30 or v32 < v30) then
			v30 = v32
		end
	end

	return v30
end

local function getRankedRewards(rewards)
	local clone = table.clone(rewards)
	local v30 = {}

	for k, item in rewards do
		v30[item] = k
	end

	table.sort(clone, function(a, b)
		local productId = a.ProductId
		local v31 = productId and v26[productId] or nil
		local productId2 = b.ProductId
		local v32 = productId2 and v26[productId2] or nil

		if v31 == v32 then
			return v30[a] < v30[b]
		end

		return not not v31 and (not v32 or v31 < v32)
	end)
	return clone
end

local function getTopRankedBundle(items)
	local v30 = nil
	local v31 = nil
	local v32 = 1e999
	local v33 = nil

	for k, item in items do
		for k2, reward in item.Rewards do
			local bundleRank = getBundleRank(reward)
			local v34 = (k - 1) * 100 + k2

			if not (not v30 or bundleRank and not v31 or bundleRank and v31 and bundleRank < v31 or bundleRank == v31 and v34 < v32) then
				continue
			end

			v33 = `{k}_{reward.Name}`
			v32 = v34
			v31 = bundleRank
			v30 = reward
		end
	end

	return v30, v33
end

function LimitedSwordPacksController.GetItemFromProductId(_, p: number)
	for _, v30 in pairs(v9) do
		for _, reward in pairs(v30.Rewards) do
			for _, reward2 in pairs(reward.Rewards) do
				local item = reward2.Item

				if reward2.ProductId == p then
					return item
				end

				local giftName = reward2.GiftName
				local v31 = giftName and v21[giftName]

				if v31 and v31.productId == p then
					return item
				end
			end
		end
	end

	return nil
end

function LimitedSwordPacksController:GetRewardFromProductId(p: number)
	for _, v30 in pairs(v9) do
		for _, reward in pairs(v30.Rewards) do
			for _, reward2 in pairs(reward.Rewards) do
				local _ = reward2.Item

				if reward2.ProductId == p then
					return reward2
				end

				local giftName = reward2.GiftName
				local v31 = giftName and v21[giftName]

				if v31 and v31.productId == p then
					return reward2
				end
			end
		end
	end

	return nil
end

function LimitedSwordPacksController:SetupSwordBuyButtons()
	local v30 = v7.Client:WaitReplion("Inventory")
	local swordBuyButtons = limitedSword_SwordPacks:WaitForChild("SwordBuyButtons")
	local singleGift = swordBuyButtons:WaitForChild("SingleGift")
	local singleBuy = swordBuyButtons:WaitForChild("SingleBuy")
	local dualBuy = swordBuyButtons:WaitForChild("DualBuy")
	local dualGift = swordBuyButtons:WaitForChild("DualGift")
	local packBuyButtons = limitedSword_SwordPacks:WaitForChild("PackBuyButtons")
	local singleBuy2 = packBuyButtons:WaitForChild("SingleBuy")
	local singleGift2 = packBuyButtons:WaitForChild("SingleGift")
	local dualBuy2 = packBuyButtons:WaitForChild("DualBuy")
	local dualGift2 = packBuyButtons:WaitForChild("DualGift")
	local selectColorBuyButtons = limitedSword_SwordPacks:WaitForChild("SelectColorBuyButtons")
	local v31 = nil
	local v32 = nil
	local v33 = nil
	local v34 = nil

	local function updateTokens()
		if v31 then
			v31:cancel()
			v31 = nil
		end

		if v32 then
			v32:cancel()
			v32 = nil
		end

		local productId = singleBuy2:GetAttribute("ProductId")
		local productId2 = dualBuy2:GetAttribute("ProductId")
		local tokens = v30:Get("Tokens") or 0
		local price = nil
		local userBasePriceInRobux = nil
		local price2 = nil
		local userBasePriceInRobux2 = nil

		if v33 and v33.Id == productId then
			price = v33.Price
		elseif productId then
			singleBuy2.BuyToken.Visible = false
			v31 = v:GetProductInfoAsync(productId, Enum.InfoType.Product):timeout(5):andThen(function(p)
				price = p.PriceInRobux or 0
				userBasePriceInRobux = p.UserBasePriceInRobux or 0
			end)
		end

		if v34 and v34.Id == productId then
			price2 = v34.Price
		elseif productId2 then
			dualBuy2.BuyToken.Visible = false
			v32 = v:GetProductInfoAsync(productId2, Enum.InfoType.Product):timeout(5):andThen(function(p)
				price2 = p.PriceInRobux or 0
				userBasePriceInRobux2 = p.UserBasePriceInRobux or 0
			end)
		end

		local v35 = {}

		if not price then
			table.insert(v35, v31)
		end

		if not price2 then
			table.insert(v35, v32)
		end

		if not v3.all(v35):await() then
			return
		end

		v33 = {
			Id = productId,
			Price = price
		}
		v34 = {
			Id = productId2,
			Price = price2
		}
		local key = v12:GetKey("TradingTokensBuyProductsDisabledList") or {}
		local v36

		if v12:GetKey("TradingTokensBuyProductsEnabled") == true then
			v36 = v12:GetKey("TradingTokensEnabled") == true
		else
			v36 = false
		end

		local buyToken = singleBuy2.BuyToken
		local visible = userBasePriceInRobux

		if visible then
			if userBasePriceInRobux <= tokens then
				visible = v36 and not table.find(key, productId)
			else
				visible = false
			end
		end

		buyToken.Visible = visible
		singleBuy2.BuyToken.Coins.Amount.Text = v22.ValueConvertor:AddCommas(userBasePriceInRobux or 0)
		local buyToken2 = dualBuy2.BuyToken
		local visible2 = userBasePriceInRobux2

		if visible2 then
			if userBasePriceInRobux2 <= tokens then
				visible2 = v36 and not table.find(key, productId2)
			else
				visible2 = false
			end
		end

		buyToken2.Visible = visible2
		dualBuy2.BuyToken.Coins.Amount.Text = v22.ValueConvertor:AddCommas(userBasePriceInRobux2 or 0)
	end

	v30:OnChange("Tokens", updateTokens)
	singleBuy2:GetAttributeChangedSignal("ProductId"):Connect(updateTokens)
	dualBuy2:GetAttributeChangedSignal("ProductId"):Connect(updateTokens)
	task.spawn(updateTokens)

	local function promptTokenPurchase(productId: number)
		local rewardFromProductId = self:GetRewardFromProductId(productId)

		if not rewardFromProductId then
			return
		end

		v19:PromptConfirmation({
			Icon = rewardFromProductId.Item.Icon or "",
			ProductId = productId,
			Name = rewardFromProductId.GiftName or rewardFromProductId.Item.DisplayName
		}, function(p, p2)
			if p then
				local v35, v36 = v20.Remotes.PurchaseProductWithTokens:InvokeServer({
					productId = productId,
					type = "Product"
				})

				if v35 then
					ReplicatedStorage2.Misc.reward:Play()
				else
					ReplicatedStorage2.Misc.error:Play()

					if _G.SendNotification and v36 then
						_G.SendNotification(v36, nil, true)
					end
				end
			elseif p2 and _G.SendNotification then
				_G.SendNotification(p2, nil, true)
			end
		end)
	end

	singleBuy.Activated:Connect(function()
		v19:PromptPurchase(singleBuy:GetAttribute("ProductId"), Enum.InfoType.Product)
	end)
	dualBuy.Activated:Connect(function()
		v19:PromptPurchase(dualBuy:GetAttribute("ProductId"), Enum.InfoType.Product)
	end)
	singleBuy2.Activated:Connect(function()
		v:PromptProductPurchase(localPlayer, (singleBuy2:GetAttribute("ProductId")))
	end)
	singleBuy2.BuyToken.Activated:Connect(function()
		local productId = singleBuy2:GetAttribute("ProductId")

		if not productId then
			return
		end

		promptTokenPurchase(productId)
	end)

	local function updatePosition()
		local visible = singleBuy2.BuyToken.Visible
		local v35 = dualBuy2
		local position

		if visible then
			position = UDim2.fromScale(-0.013, 1.35)
		else
			position = UDim2.fromScale(-0.013, 0.87)
		end

		v35.Position = position
		local v37 = dualGift2
		local position2

		if visible then
			position2 = UDim2.fromScale(1.118, 1.54)
		else
			position2 = UDim2.fromScale(1.118, 1.05)
		end

		v37.Position = position2
	end

	singleBuy2.BuyToken:GetPropertyChangedSignal("Visible"):Connect(updatePosition)
	task.spawn(updatePosition)
	dualBuy2.Activated:Connect(function()
		v:PromptProductPurchase(localPlayer, (dualBuy2:GetAttribute("ProductId")))
	end)
	dualBuy2.BuyToken.Activated:Connect(function()
		local productId = dualBuy2:GetAttribute("ProductId")

		if not productId then
			return
		end

		promptTokenPurchase(productId)
	end)
	selectColorBuyButtons.Buttons.Buy.Activated:Connect(function()
		v19:PromptPurchase(selectColorBuyButtons.Buttons.Buy:GetAttribute("ProductId"), Enum.InfoType.Product)
	end)
	singleGift2.Activated:Connect(function()
		v13:SetGift(singleGift2:GetAttribute("GiftName"))
	end)
	dualGift2.Activated:Connect(function()
		v13:SetGift(dualGift2:GetAttribute("GiftName"))
	end)
	dualGift.Activated:Connect(function()
		v13:SetGift(dualGift:GetAttribute("GiftName"))
	end)
	singleGift.Activated:Connect(function()
		v13:SetGift(singleGift:GetAttribute("GiftName"))
	end)
	selectColorBuyButtons.Buttons.Gift.Activated:Connect(function()
		v13:SetGift(selectColorBuyButtons.Buttons.Gift:GetAttribute("GiftName"))
	end)
	local swordPacks = v24:Get("SwordPacks")
	local infoLabel = selectColorBuyButtons.Buttons.InfoLabel

	for _, v35 in {
		singleBuy2,
		dualBuy2,
		selectColorBuyButtons.Buttons.Buy,
		infoLabel
	} do
		for _, child in v35.Rewards:GetChildren() do
			local name = tonumber(child.Name)

			if not name then
				continue
			end

			local v36 = 0
			local v37 = v35
			local v38 = name

			local function try()
				local bundleRewardData = self.BundleRewardData

				if not bundleRewardData then
					return
				end

				local v39 = nil

				if v37 == selectColorBuyButtons.Buttons.Buy then
					for k, reward in bundleRewardData.Rewards do
						if reward.Color == self.CurrentlySelectedColor then
							v39 = reward
						end
					end
				elseif v37 == infoLabel then
					if self.CurrentlySelectedColor == "Chroma" then
						v39 = {
							Item = v18.createListReward({
								v18.createSwordReward("Chroma Oni Katana"),
								v18.createExplosionReward("Chroma Oni Katana Explosion"),
								v18.createEmoteReward("Emote966")
							})
						}
					else
						self.CurrentlySelectedColor = "Chroma"
						self.CurrentlyColorTypeForcedShowRoom = nil
						self._bundleChanged:Fire(bundleRewardData)
						self:ShowBuyButtons(bundleRewardData, self.RewardType)
						return
					end
				else
					v39 = bundleRewardData.Rewards[v37 == singleBuy2 and 1 or 2]
				end

				if not v39 or v39.Item.Type ~= "List" then
					return
				end

				local v40 = v39.Item.Value[v38]

				if not v40 then
					return
				end

				local selected = swordPacks.Info.Selected

				if not selected then
					return
				end

				local child2 = swordPacks.Instance.InnerShowRooms:FindFirstChild(selected)

				if not child2 then
					return
				end

				local _1 = child2.NPCS:FindFirstChild("1")

				if not _1 then
					return
				end

				local now = os.clock()

				if now - v36 < 1 then
					return
				end

				if v40.Type == "Explosion" then
					v14:PlayExplosion(
						v40.Value,
						(_1.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)).Position,
						nil,
						_1,
						nil
					)
					v36 = now
				elseif v40.Type == "Sword" or v40.Type == "SwordAccessory" then
					_1:SetAttribute("IsShown", false)

					if v40.Value == "Polar Bear" or v40.Value == "Winter Wolf" then
						_1:SetAttribute("IgnoreAccessory", v37 == singleBuy2)
					else
						_1:SetAttribute("IgnoreAccessory", nil)
					end

					_1:SetAttribute("Sword", v40.Value)
					_1:SetAttribute("Emote", nil)

					if v40.Type == "SwordAccessory" then
						_1:SetAttribute("Slash", nil)
						_1:SetAttribute("NoEmote", true)
					else
						_1:SetAttribute("Slash", true)
					end

					_1:SetAttribute("IsShown", true)
				elseif v40.Type == "Emote" then
					_1:SetAttribute("IsShown", false)
					local instance = v16:GetInstance(v40.Value)

					if instance and instance:GetAttribute("HideSword") then
						_1:SetAttribute("Sword", nil)
					else
						local instance2 = v15:GetInstance(v40.Value)

						if instance2 and instance2:GetAttribute("Sword") then
							_1:SetAttribute("Sword", instance2:GetAttribute("Sword"))
						end
					end

					if v40.Value == "Emote711" then
						_1:SetAttribute("IgnoreAccessory", false)
					else
						_1:SetAttribute("IgnoreAccessory", nil)
					end

					_1:SetAttribute("NoEmote", nil)
					_1:SetAttribute("Emote", v40.Value)
					_1:SetAttribute("Slash", nil)
					_1:SetAttribute("IsShown", true)
				end
			end

			child.Try.Activated:Connect(try)
			child.TryTop.Activated:Connect(try)
		end
	end

	for _, button in selectColorBuyButtons.SelectColor.ColorsList:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v35 = button
		button.Activated:Connect(function()
			local bundleRewardData = self.BundleRewardData
			local rewardType = self.RewardType

			if not (bundleRewardData and rewardType and self.CurrentlySelectedColor ~= v35.Name) then
				return
			end

			local v36 = nil

			for k, reward in bundleRewardData.Rewards do
				if reward.Color ~= v35.Name then
					continue
				end

				v36 = reward
				break
			end

			if not v36 then
				return
			end

			self.CurrentlySelectedColor = v35.Name
			self.CurrentlyColorTypeForcedShowRoom = nil
			self._bundleChanged:Fire(bundleRewardData)
			self:ShowBuyButtons(bundleRewardData, rewardType)
		end)
	end
end

function LimitedSwordPacksController:ShowBuyButtons(bundleRewardData, rewardType: string)
	local selectColorBuyButtons = limitedSword_SwordPacks:WaitForChild("SelectColorBuyButtons")
	local swordBuyButtons = limitedSword_SwordPacks:WaitForChild("SwordBuyButtons")
	local packBuyButtons = limitedSword_SwordPacks:WaitForChild("PackBuyButtons")
	local topbar = limitedSword_SwordPacks:WaitForChild("Top bar")
	local timer = topbar:WaitForChild("fade"):WaitForChild("Timer")
	local textLabel = topbar:WaitForChild("fade"):WaitForChild("Stock"):WaitForChild("ImageLabel"):WaitForChild("TextLabel")
	selectColorBuyButtons.Visible = rewardType == "SelectColors"
	swordBuyButtons.Visible = rewardType == "Sword"
	packBuyButtons.Visible = rewardType == "Bundle"

	for _, guiObject in limitedSword_SwordPacks:WaitForChild("Bottom Bar").ScrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject:FindFirstChild("SelGlow") then
			guiObject.SelGlow.Visible = guiObject == self.CurrentlySelectedBundle
		end
	end

	self.BundleRewardData = bundleRewardData
	self.RewardType = rewardType

	if rewardType == "SelectColors" then
		for _, button in selectColorBuyButtons.SelectColor.ColorsList:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local selected = button:FindFirstChild("Selected")
			selected.Visible = button.Name == self.CurrentlySelectedColor
		end

		local v30 = nil

		for _, reward in bundleRewardData.Rewards do
			if reward.Color ~= self.CurrentlySelectedColor then
				continue
			end

			v30 = reward
			break
		end

		for k, reward in bundleRewardData.Rewards do
			if not (reward.Color and reward.Stock) then
				continue
			end

			local child = selectColorBuyButtons.SelectColor.ColorsList:FindFirstChild(reward.Color)

			if child then
				child.LayoutOrder = k + (math.ceil(v25:Get({ "Stock", reward.Stock }) or 0) <= 0 and 999 or 0)
			end
		end

		if not v30 then
			return
		end

		local label = selectColorBuyButtons.Buttons.Buy.QuantityLeft.Label
		local flag = false

		if v30.Stock then
			timer.Visible = false
			textLabel.Parent.Parent.Visible = true
			label.Parent.Visible = true
			local v32 = v25:Get({ "Stock", v30.Stock }) or 0
			local v33 = v25:Get({ "InitialStock", v30.Stock }) or 0

			if v32 <= 0 then
				v32 = 0
				flag = true
			end

			textLabel.Text = `{math.ceil(v32)}/{math.ceil(v33)}`
			label.Text = `{v8:AddCommas((math.ceil(v32)))} LEFT`
		else
			timer.Visible = true
			textLabel.Parent.Parent.Visible = false
			label.Parent.Visible = false
		end

		local buy = selectColorBuyButtons.Buttons.Buy
		local gift = selectColorBuyButtons.Buttons.Gift

		for _, guiObject in buy:WaitForChild("Rewards"):GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local v32 = v30.Item.Value[tonumber(guiObject.Name)]

			if v32 then
				guiObject.Visible = true
				local visible = v32.Type == "Emote" or v32.Type == "Sword" or v32.Type == "SwordAccessory" or v32.Type == "Explosion"
				guiObject.Try.Visible = visible
				guiObject.TryTop.Visible = visible
				guiObject.ImageLabel.Image = v32.Icon or v11:GetIcon("DEFAULT_MISSING")
			else
				guiObject.Visible = false
			end
		end

		if flag then
			buy.ItemPrice.Text = textLabel.Text
			buy.TextLabel.Visible = false
			buy.Worth.Visible = false
			buy.Label.Visible = false
			buy.Obtain.Visible = false
			buy.Visible = true
			gift.Visible = false
			buy.Active = false
			buy.RobuxIcon.Visible = false
			gift:SetAttribute("GiftName", nil)
			buy:SetAttribute("ProductId", nil)
		else
			gift.Visible = true
			buy.Visible = true
			buy.ItemPrice.Text = "Loading"
			buy.Worth.Text = "Loading"
			buy.Worth.Visible = false
			buy.Label.Visible = false

			if v30.DiscountedFrom then
				buy.Worth.Text = v30.DiscountedFrom or "???"
				buy.TextLabel.Visible = true
			end

			buy.RobuxIcon.Visible = true
			buy.TextLabel.Visible = true
			buy.Active = true
			buy:SetAttribute("ProductId", v30.ProductId)
			gift:SetAttribute("GiftName", v30.GiftName)
			buy.Obtain.Visible = not v30.ProductId

			if v30.ProductId then
				if v17.playerOwnsItem(localPlayer, v30.Item) and client:GetInventoryVersion() == "Old" then
					buy.ItemPrice.Text = "PURCHASED"
					buy.TextLabel.Visible = false
					buy.RobuxIcon.Visible = false
					buy.Active = false
					buy:SetAttribute("ProductId", nil)
				else
					v:GetProductInfoAsync(v30.ProductId, Enum.InfoType.Product):andThen(function(p)
						buy.ItemPrice.Text = not p.PriceInRobux and "Failed to load" or v8:AddCommas(p.PriceInRobux)

						if v30.DiscountedFrom and p.PriceInRobux and v30.DiscountedFrom > p.PriceInRobux then
							buy.Worth.Visible = true
							buy.Label.Visible = true
							buy.Worth.Text = v30.DiscountedFrom
						end
					end):catch(function()
						buy.ItemPrice.Text = "Failed to load"
						buy.Worth.Text = "Failed to load"
					end)
				end
			else
				buy.ItemPrice.Text = ""
				buy.TextLabel.Visible = false
				buy.RobuxIcon.Visible = false
				gift.Visible = false
				buy.Active = false
				buy:SetAttribute("ProductId", nil)
			end
		end
	else
		if rewardType == "Sword" then
			packBuyButtons = swordBuyButtons
		end

		local singleBuy = packBuyButtons:WaitForChild("SingleBuy")
		local dualBuy = packBuyButtons:WaitForChild("DualBuy")
		local singleGift = packBuyButtons:WaitForChild("SingleGift")
		local dualGift = packBuyButtons:WaitForChild("DualGift")
		singleBuy.Visible = false
		dualBuy.Visible = false
		singleGift.Visible = false
		dualGift.Visible = false
		local v30 = false

		if bundleRewardData.Stock then
			timer.Visible = false
			textLabel.Parent.Parent.Visible = true
			local v31 = v25:Get({ "Stock", bundleRewardData.Stock }) or 0
			local v32 = v25:Get({ "InitialStock", bundleRewardData.Stock }) or 0

			if bundleRewardData.Stock == "Polar Bear" then
				local v33 = v25:Get({ "Stock", "Polar Bear" }) or 0
				local v34 = v25:Get({ "InitialStock", "Polar Bear" }) or 0
				v31 = v33 + (v25:Get({ "Stock", "Polar Bear Mount" }) or 0)
				v32 = v34 + (v25:Get({ "InitialStock", "Polar Bear Mount" }) or 0)
			elseif bundleRewardData.Stock == "Winter Wolf" then
				local v33 = v25:Get({ "Stock", "Winter Wolf" }) or 0
				local v34 = v25:Get({ "InitialStock", "Winter Wolf" }) or 0
				v31 = v33 + (v25:Get({ "Stock", "Winter Wolf Mount" }) or 0)
				v32 = v34 + (v25:Get({ "InitialStock", "Winter Wolf Mount" }) or 0)
			end

			if v31 <= 0 then
				v31 = 0
				v30 = true
			end

			textLabel.Text = `{math.ceil(v31)}/{math.ceil(v32)}`
		else
			timer.Visible = true
			textLabel.Parent.Parent.Visible = false
		end

		for k, v31 in getRankedRewards(bundleRewardData.Rewards) do
			local v32

			if k == 1 then
				v32 = singleBuy
			else
				v32 = dualBuy
			end

			local v33

			if k == 1 then
				v33 = singleGift
			else
				v33 = dualGift
			end

			if bundleRewardData.Stock == "Polar Bear" then
				if k == 1 then
					v30 = (v25:Get({ "Stock", "Polar Bear" }) or 0) <= 0
				else
					v30 = (v25:Get({ "Stock", "Polar Bear Mount" }) or 0) <= 0
				end
			elseif bundleRewardData.Stock == "Winter Wolf" then
				if k == 1 then
					v30 = (v25:Get({ "Stock", "Winter Wolf" }) or 0) <= 0
				else
					v30 = (v25:Get({ "Stock", "Winter Wolf Mount" }) or 0) <= 0
				end
			end

			if v31.Item.Type == "Sword" then
				if v30 then
					v32.ItemPrice.Text = "SOLD OUT"
					v32.TextLabel.Visible = false
					v32.ItemIcon.Image = v31.Item.Icon or v11:GetIcon("DEFAULT_MISSING")
					v32.ItemName.Text = v31.Item.DisplayName or "MISSING_DISPLAY_NAME"
					v32.Active = false
					v32.RobuxIcon.Visible = false
					v33:SetAttribute("GiftName", nil)
					v32:SetAttribute("ProductId", nil)
				else
					v32.Active = true
					v32.ItemPrice.Text = "Buy"
					v32.TextLabel.Visible = true
					v32.RobuxIcon.Visible = true
					v32.ItemIcon.Image = v31.Item.Icon or v11:GetIcon("DEFAULT_MISSING")
					v32.ItemPrice.Text = "Loading"
					v32.ItemName.Text = v31.Item.DisplayName or "MISSING_DISPLAY_NAME"
					v32.Visible = true
					v33.Visible = true
					v32:SetAttribute("CurrentDayRewardIndex", k)
					v32:SetAttribute("ProductId", v31.ProductId)
					v33:SetAttribute("GiftName", v31.Item.Value)

					if v17.playerOwnsItem(localPlayer, v31.Item) and client:GetInventoryVersion() == "Old" then
						v32.Active = false
						v32.ItemPrice.Text = "PURCHASED"
						v32.TextLabel.Visible = false
						v32.RobuxIcon.Visible = false
						v32:SetAttribute("ProductId", nil)
					else
						local v34 = v32
						local v35 = v32
						v:GetProductInfoAsync(v31.ProductId, Enum.InfoType.Product):andThen(function(p)
							v34.ItemPrice.Text = not p.PriceInRobux and "Failed to load" or v8:AddCommas(p.PriceInRobux)
						end):catch(function()
							v35.ItemPrice.Text = "Failed to load"
						end)
					end
				end
			elseif v31.Item.Type == "List" then
				for _, guiObject in v32:WaitForChild("Rewards"):GetChildren() do
					if not guiObject:IsA("GuiObject") then
						continue
					end

					local v34 = v31.Item.Value[tonumber(guiObject.Name)]

					if v34 then
						guiObject.Visible = true
						local visible = v34.Type == "Emote" or v34.Type == "Sword" or v34.Type == "SwordAccessory" or v34.Type == "Explosion"
						guiObject.Try.Visible = visible
						guiObject.TryTop.Visible = visible
						guiObject.LayoutOrder = k
						guiObject.ImageLabel.Image = v34.Icon or v11:GetIcon("DEFAULT_MISSING")
					else
						guiObject.Visible = false
					end
				end

				if v30 then
					v32.Stock.Visible = false

					if v31.Stock == "Polar Bear" or v31.Stock == "Polar Bear Mount" then
						local v34 = v25:Get({ "InitialStock", v31.Stock }) or 0
						v32.ItemPrice.Text = `0/{v8:AddCommas((math.ceil(v34)))}`
					elseif v31.Stock == "Winter Wolf" or v31.Stock == "Winter Wolf Mount" then
						local v34 = v25:Get({ "InitialStock", v31.Stock }) or 0
						v32.ItemPrice.Text = `0/{v8:AddCommas((math.ceil(v34)))}`
					else
						v32.ItemPrice.Text = textLabel.Text
					end

					v32.TextLabel.Visible = false
					v32.Worth.Visible = false
					v32.Label.Visible = false
					v32.Visible = true
					v33.Visible = false
					v32.Active = false
					v32.RobuxIcon.Visible = false
					v33:SetAttribute("GiftName", nil)
					v32:SetAttribute("ProductId", nil)
				else
					v33.Visible = true
					v32.Visible = true
					v32.ItemPrice.Text = "Loading"
					v32.Worth.Text = "Loading"
					v32.Worth.Visible = false
					v32.Label.Visible = false

					if v31.DiscountedFrom then
						v32.Worth.Text = v31.DiscountedFrom or "???"
						v32.TextLabel.Visible = true
					end

					v32.RobuxIcon.Visible = true
					v32.Active = true
					v32:SetAttribute("ProductId", v31.ProductId)
					v33:SetAttribute("GiftName", v31.GiftName)

					if v31.Stock == "Polar Bear" or v31.Stock == "Polar Bear Mount" or v31.Stock == "Winter Wolf" or v31.Stock == "Winter Wolf Mount" then
						local v34 = v25:Get({ "Stock", v31.Stock }) or 0
						local v35 = v25:Get({ "InitialStock", v31.Stock }) or 0
						v32.Stock.Text = `{v8:AddCommas((math.ceil(v34)))}/{v8:AddCommas((math.ceil(v35)))}`
						v32.Stock.Visible = true
						v32.Worth.Visible = false
						v32.Label.Visible = false
					else
						v32.Stock.Visible = false
					end

					if v17.playerOwnsItem(localPlayer, v31.Item) and client:GetInventoryVersion() == "Old" then
						v32.ItemPrice.Text = "PURCHASED"
						v32.TextLabel.Visible = false
						v32.RobuxIcon.Visible = false
						v32.Active = false
						v32:SetAttribute("ProductId", nil)
					else
						local v34 = v32
						local v35 = v31
						local v36 = v32
						v:GetProductInfoAsync(v31.ProductId, Enum.InfoType.Product):andThen(function(p)
							v34.ItemPrice.Text = not p.PriceInRobux and "Failed to load" or v8:AddCommas(p.PriceInRobux)

							if v35.DiscountedFrom and p.PriceInRobux and v35.DiscountedFrom > p.PriceInRobux then
								v34.Worth.Visible = true
								v34.Label.Visible = true
								v34.Worth.Text = v35.DiscountedFrom
							end
						end):catch(function()
							v36.ItemPrice.Text = "Failed to load"
							v36.Worth.Text = "Failed to load"
						end)
					end
				end
			end
		end
	end
end

function LimitedSwordPacksController:CreateBundleOfType(p, p2: string, p3: string?)
	local v30

	if (p3 or p2) == "Sword" then
		v30 = limitedSword_SwordPacks["Bottom Bar"].TemplateSword
	else
		v30 = limitedSword_SwordPacks["Bottom Bar"].TemplateExplosion
	end

	local clone = v30:Clone()
	clone.SwordIcon.SwordName.Text = p.Name
	clone.ItemIcon.Image = p.Image ~= "" and p.Image or v11:GetIcon("DEFAULT_MISSING")
	clone.Visible = false
	clone.Parent = limitedSword_SwordPacks["Bottom Bar"].ScrollingFrame
	v10.animateButtonHover(clone)
	clone.Activated:Connect(function()
		if clone.LockedFrame.Visible then
			return
		end

		self._bundleChanged:Fire(p)

		if self.CurrentlySelectedBundle then
			self.CurrentlySelectedBundle.SelGlow.Visible = false
		end

		self.CurrentlySelectedBundle = clone
		self.CurrentlySelectedBundle.SelGlow.Visible = true
		self:ShowBuyButtons(p, p2)
	end)

	local function updateBlackFridayFrames()
		local key = v12:GetKey("LimitedSwordsBlackFridayDiscountActive")
		local v31

		if type(key) == "table" then
			v31 = key[`{p2}_{p.Name}`]
		else
			v31 = false
		end

		clone.Discount.TextLabel.Text = not v31 and "???% OFF" or `{math.floor(v31 * 100) / 100}% OFF` or "???% OFF"
		clone.Discount.Visible = v31 ~= nil
	end

	local dataUpdatedEventConnection = v12.DataUpdatedEvent:Connect(updateBlackFridayFrames)
	task.spawn(updateBlackFridayFrames)
	clone.Destroying:Connect(function()
		dataUpdatedEventConnection:Disconnect()
	end)
	return clone
end

function LimitedSwordPacksController:GetActiveBundles()
	local serverTimeNow = workspace:GetServerTimeNow()
	local result = {}

	for _, v30 in v9 do
		local key = v30.FFlagStartTime and v12:GetKey(v30.FFlagStartTime) or not v30.RootFFlagStartTime and 0 or v12:GetKey(v30.RootFFlagStartTime) or 0
		local key2 = v30.FFlagEndTime and v12:GetKey(v30.FFlagEndTime) or not v30.RootFFlagEndTime and 0 or v12:GetKey(v30.RootFFlagEndTime) or 0

		if not (serverTimeNow < key or key2 <= serverTimeNow) then
			table.insert(result, v30)
		end
	end

	return result
end

function LimitedSwordPacksController:GetTopRankedBundle(p)
	return getTopRankedBundle(p or self:GetActiveBundles())
end

function LimitedSwordPacksController:UpdateProductRanks()
	if not productIntelligence then
		return
	end

	local v30 = {}
	local productIds = {}

	for _, v31 in activeBundles or {} do
		for _, reward in v31.Rewards do
			for _, v32 in reward.Rewards or {} do
				local productId = v32.ProductId

				if not productId or v30[productId] then
					continue
				end

				v30[productId] = true
				table.insert(productIds, productId)
			end
		end
	end

	table.sort(productIds)
	local joined = table.concat(productIds, ",")

	if joined == v27 then
		return
	end

	v27 = joined
	count += 1
	local v31 = count

	if #productIds == 0 then
		table.clear(v26)
		return
	end

	local v32 = {}

	for _, id in productIds do
		table.insert(v32, {
			Id = id,
			InfoType = Enum.InfoType.Product
		})
	end

	local success, result = pcall(function()
		return v:RankProductsAsync(v32)
	end)

	if success and typeof(result) == "table" then
		if v31 ~= count then
			return
		end

		local v33 = {}

		for k, v34 in result do
			v33[v34.ProductIdentifier.Id] = k
		end

		v26 = v33
		self:UpdateBundleBar()

		if self.BundleRewardData and self.RewardType then
			self:ShowBuyButtons(self.BundleRewardData, self.RewardType)
		end
	else
		if v31 == count then
			v27 = nil
		end

		warn((`MarketplaceService:RankProductsAsync() failed for limited sword shop: {result}`))
	end
end

function LimitedSwordPacksController:UpdateBundleBar()
	debug.profilebegin("LimitedSwordEventPacks:UpdateBundleBar")
	local scrollingFrame = limitedSword_SwordPacks["Bottom Bar"].ScrollingFrame
	local currentlySelectedBundle = self.CurrentlySelectedBundle
	self.CurrentlySelectedBundle = nil
	local serverTimeNow = workspace:GetServerTimeNow()
	local innerShowRooms = ReplicatedStorage2.Misc.ShowRooms.SwordPacks.InnerShowRooms
	local v30 = {}

	for k, v31 in activeBundles do
		local key = v31.FFlagStartTime and v12:GetKey(v31.FFlagStartTime) or not v31.RootFFlagStartTime and 0 or v12:GetKey(v31.RootFFlagStartTime) or 0
		local key2 = v31.FFlagEndTime and v12:GetKey(v31.FFlagEndTime) or not v31.RootFFlagEndTime and 0 or v12:GetKey(v31.RootFFlagEndTime) or 0

		if key2 <= serverTimeNow then
			for _, reward in v31.Rewards do
				local child = scrollingFrame:FindFirstChild((`{k}_{reward.Name}`))

				if child then
					child:Destroy()
				end
			end
		else
			local visible

			if key <= serverTimeNow then
				visible = serverTimeNow <= key2
			else
				visible = false
			end

			for k2, reward in v31.Rewards do
				if not innerShowRooms:FindFirstChild(reward.ShowRoom) then
					continue
				end

				local formatted = `{k}_{reward.Name}`
				local child = scrollingFrame:FindFirstChild(formatted)

				if not child then
					child = self:CreateBundleOfType(reward, reward.Type or "Sword", reward.TemplateType)
					child.Name = formatted
				end

				v30[formatted] = true
				child.LockedFrame.Visible = not visible
				child.LockedFrame.TextLabel.Text = string.format(
					"Available In %s",
					v8:FormatTimeWithDays(key - serverTimeNow)
				)
				child.LayoutOrder = getBundleRank(reward) or (k - 1) * 100 + k2
				child.TextBgQuantity.Visible = false
				child.Quantity.Visible = false
				child.TextBg.Visible = visible
				child.TextBg.TextLabel.Text = v8:FormatTimeWithDays(key2 - serverTimeNow)
				local v33 = { reward.Stock }

				if reward.Type == "SelectColors" then
					table.clear(v33)

					for _, reward2 in reward.Rewards do
						if reward2.Stock then
							table.insert(v33, reward2.Stock)
						end
					end
				end

				if reward.Stock == "Polar Bear" then
					table.insert(v33, "Polar Bear Mount")
				elseif reward.Stock == "Winter Wolf" then
					table.insert(v33, "Winter Wolf Mount")
				end

				if #v33 > 0 then
					local total = 0
					local total2 = 0

					for _, v34 in v33 do
						total += v25:Get({ "Stock", v34 }) or 0
						total2 += v25:Get({ "InitialStock", v34 }) or 0
					end

					child.TextBg.Position = UDim2.fromScale(0.025, 0.063)
					child.TextBgQuantity.Visible = true
					child.Quantity.Visible = true

					if total <= 0 then
						child.Quantity.Text = "SOLD OUT"
						child.LayoutOrder += 1000000000
					else
						child.Quantity.Text = `{v8:AddCommas((math.ceil(total)))}/{v8:AddCommas((math.ceil(total2)))}`
					end
				else
					child.TextBg.Position = UDim2.fromScale(0.621, 0.04)
				end

				child.Visible = true
			end
		end
	end

	for _, guiObject in scrollingFrame:GetChildren() do
		if not guiObject:IsA("GuiObject") or v30[guiObject.Name] then
			continue
		end

		guiObject:Destroy()
	end

	local currentlySelectedBundle2

	if currentlySelectedBundle then
		currentlySelectedBundle2 = scrollingFrame:FindFirstChild(currentlySelectedBundle.Name)
	end

	self.CurrentlySelectedBundle = currentlySelectedBundle2
	debug.profileend()
end

function LimitedSwordPacksController:UpdateCountdown()
	local textLabel = limitedSword_SwordPacks:WaitForChild("Top bar"):WaitForChild("fade"):WaitForChild("Timer"):WaitForChild("ImageLabel"):WaitForChild("TextLabel")
	debug.profilebegin("LimitedSwordEventPacks:UpdateCountdown")
	local serverTimeNow = workspace:GetServerTimeNow()
	local activeBundles2 = self:GetActiveBundles()
	local v30 = 0

	for _, activeBundle in activeBundles2 do
		v30 = math.max(v30, getEndDate(activeBundle))
	end

	if #activeBundles2 < 0 and v4:IsOpen(limitedSword_SwordPacks.Name) then
		v4:Close(limitedSword_SwordPacks.Name)
	end

	textLabel.Text = v8:FormatTimeWithDays(v30 - serverTimeNow)
	debug.profileend()
end

function LimitedSwordPacksController:Hook()
	v25 = v7.Client:WaitReplion("LimitedStockItems")
	self._bundleChanged:Connect(function(p, p2)
		task.defer(function()
			self.BundleChanged:Fire(p, p2)
		end)

		if not v25:Get("Loaded") then
			return
		end

		if p.Type == "SelectColors" then
			if v29[p] then
				return
			end

			v29[p] = true
			local color = nil

			for _, reward in p.Rewards do
				if not reward.Stock or not reward.Color or (v25:Get({ "Stock", reward.Stock }) or 0) <= 0 then
					continue
				end

				color = reward.Color
				break
			end

			if not color then
				return
			end

			self.CurrentlySelectedColor = color
		end
	end)
	local close = limitedSword_SwordPacks:WaitForChild("Close")
	v4:OnGuiOpen(limitedSword_SwordPacks.Name, function()
		remoteEvent:FireServer("LimitedSwordShopOpened", {
			inMatch = workspace:GetAttribute("GameActive") == true,
			productIntelligence = productIntelligence
		})
	end)

	local function setProductRankSorting(flag: boolean)
		if productIntelligence == flag then
			return
		end

		productIntelligence = flag
		count += 1
		v27 = nil
		table.clear(v26)

		if flag then
			task.spawn(function()
				self:UpdateProductRanks()
			end)
		elseif activeBundles then
			self:UpdateBundleBar()

			if self.BundleRewardData and self.RewardType then
				self:ShowBuyButtons(self.BundleRewardData, self.RewardType)
			end
		end
	end

	local function runExperiments(object2)
		local v30 = object2:Get({ "Configs", "LimitedSwordProductRankSorting" }) == true
		local v31 = object2:Get({ "Configs", "CombinedShopProductRankSorting" }) == true
		setProductRankSorting(v30 or v31)
	end

	local v30 = {}

	local function observeConfigReplion(object2)
		if v30[object2] then
			return
		end

		v30[object2] = true
		runExperiments(object2)
		object2:OnChange({ "Configs", "LimitedSwordProductRankSorting" }, function()
			runExperiments(object2)
		end)
		object2:OnChange({ "Configs", "CombinedShopProductRankSorting" }, function()
			runExperiments(object2)
		end)
	end

	task.spawn(function()
		local v31 = v7.Client:WaitReplion(`{localPlayer.Name}_Configs`, 60)

		if v31 then
			observeConfigReplion(v31)
		end
	end)
	v7.Client:OnReplionAddedWithTag("PlayerConfigs", observeConfigReplion)

	local function refreshActiveSwordPacks()
		activeBundles = self:GetActiveBundles()
		task.spawn(function()
			self:UpdateProductRanks()
		end)
	end

	v12.DataUpdatedEvent:Connect(refreshActiveSwordPacks)
	task.spawn(refreshActiveSwordPacks)
	local bottomBar = limitedSword_SwordPacks:WaitForChild("Bottom Bar")
	close.Activated:Connect(function()
		v24:Close()
	end)
	v6.Every(1, function()
		if not v4:IsOpen(limitedSword_SwordPacks.Name) then
			return
		end

		self:UpdateCountdown()
		self:UpdateBundleBar()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateButtons()
		if self.BundleRewardData and self.RewardType then
			self:ShowBuyButtons(self.BundleRewardData, self.RewardType)
		end
	end

	local function update()
		self:UpdateBundleBar()
		updateButtons() -- equivalent call inferred; original call site unknown
	end

	v6.Every(60, updateButtons)
	v25:OnChange("Stock", update)
	client:OnChange("Sword", update)
	client:OnChange("Explosion", update)
	client:OnChange("Emote", update)
	task.spawn(update)
	self:SetupSwordBuyButtons()
	v24.ShowRoomOpened:Connect(function(p: string)
		if p == "SwordPacks" then
			self:UpdateCountdown()
			self:UpdateBundleBar()
			local topRankedBundle, v31 = self:GetTopRankedBundle()

			if not (topRankedBundle and v31) then
				return
			end

			local child = bottomBar.ScrollingFrame:FindFirstChild(v31)

			if child then
				self.CurrentlySelectedBundle = child
				self._bundleChanged:Fire(topRankedBundle)
			end

			self:ShowBuyButtons(topRankedBundle, topRankedBundle.Type or "Sword")
		end
	end)

	local function updateBlackFridayFrames()
		local key = v12:GetKey("LimitedSwordsBlackFridayDiscountActive")
		local blackFridayBanner = limitedSword_SwordPacks["Top bar"].BlackFridayBanner
		blackFridayBanner.Visible = type(key) == "table" and next(key) ~= nil
	end

	v12.DataUpdatedEvent:Connect(updateBlackFridayFrames)
	task.spawn(updateBlackFridayFrames)
	local selectColorBuyButtons = limitedSword_SwordPacks:WaitForChild("SelectColorBuyButtons")
	selectColorBuyButtons.Buttons.InfoLabel.Info.Activated:Connect(function()
		selectColorBuyButtons.Buttons.InfoLabel.InfoLabel.Visible = not selectColorBuyButtons.Buttons.InfoLabel.InfoLabel.Visible
	end)
	selectColorBuyButtons.Buttons.InfoLabel.InfoLabel.Close.Activated:Connect(function()
		selectColorBuyButtons.Buttons.InfoLabel.InfoLabel.Visible = false
	end)

	local function updateInfoLabel()
		selectColorBuyButtons.Buttons.InfoLabel.Visible = v12:GetKey("ShowSelectColorInfoLabel")
	end

	v12.DataUpdatedEvent:Connect(updateInfoLabel)
	task.spawn(updateInfoLabel)
	playerGui.LimitedSword_ShowRoom.Frame.Close.Activated:Connect(function()
		v24:Close()
	end)
end

function LimitedSwordPacksController:Start()
	v12:WaitForData()
	v7.Client:WaitReplion("Data")
	self:Hook()
	v23.observeTagNoAncestry("GoatedLimitedSwordsEndTime", function(p)
		local connection = v22.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local key = v12:GetKey("LimitedQuantityDropTimestamp")
			p.Parent.Parent.Enabled = key and true or false

			if not key then
				return
			end

			local v30 = math.max(key - serverTimeNow, 0)
			p.Text = v22.ValueConvertor:FormatTimeWithDaysFull(v30)
		end)
		return function()
			connection:Disconnect()
		end
	end)
end

return LimitedSwordPacksController