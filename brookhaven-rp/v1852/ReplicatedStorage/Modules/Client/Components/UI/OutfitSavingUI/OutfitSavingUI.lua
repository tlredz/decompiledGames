local AvatarEditorService = game:GetService("AvatarEditorService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PromptPurchasePromptTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.PromptPurchasePromptTelemetryController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NumberUtil = require(ReplicatedStorage.Modules.Shared.Utils.NumberUtil)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "OutfitSavingUI"
})
local _ = {
	MY_OUTFIT = "MyOutfit",
	NEW_OUTFIT = "NewOutfit"
}
local v2 = {
	"LeftLeg",
	"RightLeg",
	"Torso",
	"LeftArm",
	"RightArm",
	"Head"
}
local v3 = {}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentDescription()
	local character = Players.LocalPlayer.Character

	if character then
		return character:FindFirstChild("Humanoid"):GetAppliedDescription()
	end

	warn("No character found")
	return nil
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._displayJanitor = self._Janitor.new(Janitor.new())
	self._selectionUI = self.Instance:WaitForChild("OutfitSelection")
	self._applyUI = self.Instance:WaitForChild("OutfitApply")
	self._unownedItemsPrompt = self.Instance:WaitForChild("UnownedItemsPrompt")
	self._blur = self._Janitor:Add(Instance.new("BlurEffect"))
	self._currentApplyType = nil
	self._ownedCache = {}
	self._unownedCache = {}
end

function v:Start()
	self._Janitor:Add(self._selectionUI.Selectors.MyOutfit.Activated:Connect(function()
		self:ApplyOutfit("MyOutfit")
	end))
	self._Janitor:Add(self._selectionUI.Selectors.NewOutfit.Activated:Connect(function()
		self:ApplyOutfit("NewOutfit")
	end))
	self._Janitor:Add(self._unownedItemsPrompt.InteractButtons.Yes.Activated:Connect(function()
		self:_saveToRoblox()
	end))
	self._Janitor:Add(self._unownedItemsPrompt.InteractButtons.No.Activated:Connect(function()
		self._unownedItemsPrompt.Visible = false
	end))
	self._Janitor:Add(self._applyUI.BottomArea.Buttons.BuyAllItems.Activated:Connect(function()
		TelemetryController.SendClientInteraction("avatarSaveItems", {
			button = "BuyAllItems"
		})
		self:_buyAllItems()
	end))
	self._Janitor:Add(self._applyUI.BottomArea.Buttons.SaveToRoblox.Activated:Connect(function()
		TelemetryController.SendClientInteraction("avatarSaveItems", {
			button = "SaveToRoblox"
		})
		self:_checkSaveToRoblox()
	end))
	self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(p, _)
		if p == "Outfits" then
			self:Open()
		end
	end))
	self._Janitor:Add(PanelController.OnPanelClosed:Connect(function(p, _)
		if p == "Outfits" then
			self:Close()
		end
	end))
	self._Janitor:Add(self._applyUI.Close.Activated:Connect(function()
		TelemetryController.SendClientInteraction("avatarSaveUI", {
			button = "Close"
		})
	end))
	self._Janitor:Add(self._selectionUI.Close.Activated:Connect(function()
		TelemetryController.SendClientInteraction("avatarSaveItems", {
			button = "Close"
		})
	end))
	self._Janitor:Add(MarketplaceService.PromptPurchaseFinished:Connect(function(_, p, p2)
		if not p2 then
			return
		end

		v3[tonumber(p)] = Enum.MarketplaceProductType.AvatarAsset
	end))
	self._Janitor:Add(MarketplaceService.PromptBulkPurchaseFinished:Connect(function(_, p, p2)
		if p ~= Enum.MarketplaceBulkPurchasePromptStatus.Completed then
			return
		end

		for _, item in p2.Items do
			if item.status == Enum.MarketplaceItemPurchaseStatus.Success then
				v3[tonumber(item.id)] = item.type
			end
		end
	end))
	local v5, hasAccessToOutfitSaving = ABTest.GetExperimentVariable("upload-avatar-to-roblox", "show-price"):timeout(7):await()

	if not v5 then
		warn("Failed to get experiment variable: show-price")
		return
	end

	self._hasAccessToOutfitSaving = hasAccessToOutfitSaving
	self:Close()
end

function v:ApplyOutfit(currentApplyType)
	if currentApplyType == "MyOutfit" then
		TelemetryController.SendClientInteraction("avatarSaveUI", {
			button = "UpdateCurrentAvatar"
		})
	elseif currentApplyType == "NewOutfit" then
		TelemetryController.SendClientInteraction("avatarSaveUI", {
			button = "CreateOutfit"
		})
	end

	self._currentApplyType = currentApplyType
	self:_updateOwnedAndUnownedItems()
	self._applyUI.BottomArea.Buttons.SaveToRoblox.TextLabel.Text = currentApplyType == "MyOutfit" and "Update Current Avatar" or "Create Outfit"
	PanelController.Close("Outfits", "OutfitSelection")
	PanelController.OpenPanelByContext("Outfits", "OutfitApply")
end

function v:Open()
	self._blur.Parent = Lighting
	TweenService:Create(self._blur, TweenInfo.new(0.2), {
		Size = 24
	}):Play()
	TweenService:Create(self._applyUI, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, 0.525)
	}):Play()
	TweenService:Create(self._selectionUI, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, 0.525)
	}):Play()
	TweenService:Create(self._unownedItemsPrompt, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, 0.5)
	}):Play()
end

function v:Close()
	local tween = TweenService:Create(self._blur, TweenInfo.new(0.2), {
		Size = 0
	})
	tween.Completed:Connect(function(p)
		if p == Enum.PlaybackState.Completed then
			self._blur.Parent = nil
		end
	end)
	tween:Play()
	self._unownedItemsPrompt.Visible = false
	TweenService:Create(self._applyUI, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, -0.6)
	}):Play()
	TweenService:Create(self._selectionUI, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, -0.6)
	}):Play()
	TweenService:Create(self._unownedItemsPrompt, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, -0.6)
	}):Play()
end

function v:_addItemToUI(p, data, parent, flag: boolean)
	local v5 = p == Enum.MarketplaceProductType.AvatarAsset and "Asset" or "BundleThumbnail"
	local v6 = self._displayJanitor:Add(parent:WaitForChild("Template"):Clone())
	v6.ItemName.Text = data.Name
	v6.Preview.Icon.Image = `rbxthumb://type={v5}&id={data.Id}&w=420&h=420`
	v6.Parent = parent
	v6.Visible = true

	if flag and self._hasAccessToOutfitSaving then
		if data.Price == 0 then
			v6.NotOwned.Text = "Free"
		else
			v6.NotOwned.Text = NumberUtil.Commas(data.Price, "")
		end

		v6.NotOwned.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	if flag and data.SaleLocationType ~= "ShopAndAllExperiences" then
		print(data.SaleLocationType)
		v6.NotOwned.Text = "Unavailable"
		v6.NotOwned.TextColor3 = Color3.fromRGB(100, 100, 100)
	elseif flag then
		self._displayJanitor:Add(v6.Activated:Connect(function()
			self:_buyItem({
				Id = data.Id,
				Type = p
			})
		end))
	end
end

function v:_buyItem(p)
	PromptPurchasePromptTelemetryController.SetAssetPurchaseContext("outfitSaving")
	local success, result = pcall(function()
		if p.Type == Enum.MarketplaceProductType.AvatarBundle then
			return MarketplaceService:PromptBundlePurchase(Players.LocalPlayer, p.Id)
		end

		return MarketplaceService:PromptPurchase(Players.LocalPlayer, p.Id)
	end)

	if not success then
		NotificationController.NotifyCenterAlwaysVisible("Failed to purchase item")
		warn("Failed to purchase item: " .. result)
	end

	if p.Type == Enum.MarketplaceProductType.AvatarAsset then
		self._Janitor:Add(MarketplaceService.PromptPurchaseFinished:Once(function(_: number, p2: number, flag: boolean)
			if not flag or p2 ~= p.Id then
				return
			end

			self:_onItemPurchased(p)
		end))
	else
		self._Janitor:Add(MarketplaceService.PromptBundlePurchaseFinished:Once(function(_: number, p2: number, flag: boolean)
			if not flag or p2 ~= p.Id then
				return
			end

			self:_onItemPurchased(p)
		end))
	end
end

function v:_onItemPurchased(p)
	NotificationController.NotifyCenterAlwaysVisible("Purchase successful!")
	v3[tonumber(p.Id)] = p.Type
	self:_updateOwnedAndUnownedItems()
end

function v:_processAssetOwnership(p)
	local result = {}
	local v5 = {}
	local result2 = {}

	for _, asset in p.assets do
		if table.find(v2, asset.assetType.name) then
			continue
		end

		if v3[asset.id] then
			result[asset.id] = v3[asset.id]
		elseif asset.bundleId then
			if not v5[asset.bundleId] then
				v5[asset.bundleId] = true
				local v6 = asset
				local success, result3 = pcall(function()
					if v3[v6.bundleId] then
						return v3[v6.bundleId]
					end

					if v4[v6.bundleId] == nil then
						return MarketplaceService:PlayerOwnsBundle(Players.LocalPlayer, v6.bundleId)
					end

					return v4[v6.bundleId]
				end)

				if success then
					local v7 = success and result3
					v4[asset.bundleId] = v7

					if v7 then
						result[asset.bundleId] = Enum.MarketplaceProductType.AvatarBundle
					else
						result2[asset.bundleId] = Enum.MarketplaceProductType.AvatarBundle
					end
				else
					NotificationController.NotifyCenterAlwaysVisible("There was an error checking if you own this item.")
					warn("Failed to check if player owns bundle: " .. result3)
				end
			end
		elseif asset.price then
			local v6 = asset
			local success, result3 = pcall(function()
				if v3[v6.id] then
					return v3[v6.id]
				end

				if v4[v6.id] == nil then
					return MarketplaceService:PlayerOwnsAssetAsync(Players.LocalPlayer, v6.id)
				end

				return v4[v6.id]
			end)

			if success then
				v4[asset.id] = result3

				if result3 then
					result[asset.id] = Enum.MarketplaceProductType.AvatarAsset
				else
					result2[asset.id] = Enum.MarketplaceProductType.AvatarAsset
				end
			else
				NotificationController.NotifyCenterAlwaysVisible("There was an error checking if you own this item.")
				warn("Failed to check if player owns item: " .. result3)
				result2[asset.id] = Enum.MarketplaceProductType.AvatarAsset
			end
		else
			result[asset.id] = Enum.MarketplaceProductType.AvatarAsset
		end
	end

	return result, result2
end

function v:_separateItemsByType(items, items2)
	local result = {}
	local result2 = {}

	for k, item in items do
		if item == Enum.MarketplaceProductType.AvatarAsset then
			table.insert(result, k)
		elseif item == Enum.MarketplaceProductType.AvatarBundle then
			table.insert(result2, k)
		end
	end

	for k, item in items2 do
		if item == Enum.MarketplaceProductType.AvatarAsset then
			table.insert(result, k)
		elseif item == Enum.MarketplaceProductType.AvatarBundle then
			table.insert(result2, k)
		end
	end

	return result, result2
end

function v:_renderItems(items, items2, p)
	local total = 0

	for _, item in items do
		if p[item.Id] then
			self:_addItemToUI(Enum.MarketplaceProductType.AvatarAsset, item, self._applyUI.Items.OwnedItems, false)
		else
			self:_addItemToUI(Enum.MarketplaceProductType.AvatarAsset, item, self._applyUI.Items.UnownedItems, true)
			total += item.Price or 0
		end
	end

	for _, item in items2 do
		if p[item.Id] then
			self:_addItemToUI(Enum.MarketplaceProductType.AvatarBundle, item, self._applyUI.Items.OwnedItems, false)
		else
			self:_addItemToUI(Enum.MarketplaceProductType.AvatarBundle, item, self._applyUI.Items.UnownedItems, true)
			total += item.Price or 0
		end
	end

	return total
end

function v:_updateUICanvasSizes()
	self._applyUI.Items.OwnedItems.CanvasSize = UDim2.fromOffset(
		0,
		self._applyUI.Items.OwnedItems.UIListLayout.AbsoluteContentSize.Y
	)
	self._applyUI.Items.UnownedItems.CanvasSize = UDim2.fromOffset(
		0,
		self._applyUI.Items.UnownedItems.UIListLayout.AbsoluteContentSize.Y
	)
end

function v:_updateOwnedAndUnownedItems()
	self._displayJanitor:Cleanup()
	self._applyUI.UnownedItems.Text = "Unowned Items (...)"
	self._applyUI.Items.UnownedItems.OwnAllItems.Visible = false
	self._applyUI.Items.OwnedItems.OwnNoItems.Visible = false
	local instantiableComponent = ComponentUtil.CloneInstantiableComponent("LoadingSpinner")

	if instantiableComponent then
		instantiableComponent.Parent = self._applyUI.Items
		instantiableComponent.ZIndex = 10
	end

	self:_updateUICanvasSizes()
	task.spawn(function()
		local _processAssetOwnership, unownedCache = self:_processAssetOwnership((Remotes.invokeServer(AvatarEditorRequests.GET_CHARACTER_APPEARANCE_INFO)))
		local _separateItemsByType, v7 = self:_separateItemsByType(_processAssetOwnership, unownedCache)
		self._ownedCache = _processAssetOwnership
		self._unownedCache = unownedCache
		local v8 = {}

		for _, v9 in _separateItemsByType do
			if v9 ~= "0" then
				table.insert(v8, v9)
			end
		end

		local success, result = pcall(function()
			return AvatarEditorService:GetBatchItemDetailsAsync(v8, Enum.AvatarItemType.Asset)
		end)
		local success2, result2 = pcall(function()
			return AvatarEditorService:GetBatchItemDetailsAsync(v7, Enum.AvatarItemType.Bundle)
		end)

		if not success then
			warn("Failed to get asset details: " .. result)
			return
		end

		if not success2 then
			warn("Failed to get bundle details: " .. result2)
			return
		end

		local _renderItems = self:_renderItems(result, result2, _processAssetOwnership)
		self:_updateUICanvasSizes()
		self._applyUI.UnownedItems.Text = `Unowned Items ({_renderItems})`
		local visible = next(unownedCache) == nil
		local visible2 = next(_processAssetOwnership) == nil
		self._applyUI.Items.UnownedItems.OwnAllItems.Visible = visible
		self._applyUI.Items.OwnedItems.OwnNoItems.Visible = visible2

		if instantiableComponent then
			instantiableComponent:Destroy()
		end
	end)
end

function v:_buyAllItems()
	PromptPurchasePromptTelemetryController.SetBulkPurchaseContext("outfitSaving")
	local v5, v6 = Remotes.invokeServer(AvatarEditorRequests.PROMPT_FULL_AVATAR_PURCHASE)

	if v5 then
		self._Janitor:Add(MarketplaceService.PromptBulkPurchaseFinished:Once(function(p, p2, _)
			if p ~= Players.LocalPlayer then
				return
			end

			if p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed then
				NotificationController.NotifyCenterAlwaysVisible("Purchase successful!")
				self:_updateOwnedAndUnownedItems()
			elseif p2 == Enum.MarketplaceBulkPurchasePromptStatus.Aborted then
				NotificationController.NotifyCenterAlwaysVisible("Cancelled")
			elseif p2 == Enum.MarketplaceBulkPurchasePromptStatus.Error then
				NotificationController.NotifyCenterAlwaysVisible("Error purchasing items")
			else
				warn("Unknown marketplace bulk purchase prompt status: " .. p2)
			end
		end))
	else
		NotificationController.NotifyCenterAlwaysVisible(v6)
	end
end

function v:_checkSaveToRoblox()
	local count = 0

	for _, button in self._applyUI.Items.UnownedItems:GetChildren() do
		if button:IsA("TextButton") and button.Visible then
			count += 1
		end
	end

	if not (count > 0) then
		self:_saveToRoblox()
		return
	end

	if count == 1 then
		self._unownedItemsPrompt.Description.Text = "You still have 1 unpurchased item. Would you like to save without this item?"
	else
		self._unownedItemsPrompt.Description.Text = `You still have {count} unpurchased items. Would you like to save without these items?`
	end

	self._unownedItemsPrompt.Visible = true
end

function v:_getDescriptionOfOwnedItems()
	local currentDescription = getCurrentDescription() -- equivalent call inferred; original call site unknown

	if not currentDescription then
		return
	end

	local v5 = {}
	local result = {}

	for k, v6 in self._ownedCache do
		if v6 == Enum.MarketplaceProductType.AvatarBundle then
			table.insert(v5, k)
		end
	end

	local success, result2 = pcall(function()
		return AvatarEditorService:GetBatchItemDetails(v5, Enum.AvatarItemType.Bundle)
	end)

	if not success then
		print("Failed to get bundle details", result2)
		return
	end

	for _, v6 in result2 do
		for _, bundledItem in v6.BundledItems do
			result[bundledItem.Id] = true
		end
	end

	local result3 = {}

	for _, v6 in currentDescription:GetAccessories(true) do
		if self._ownedCache[v6.AssetId] or v3[v6.AssetId] or result[v6.AssetId] then
			table.insert(result3, v6)
		end
	end

	currentDescription:SetAccessories(result3, true)

	if not self._ownedCache[currentDescription.Shirt] then
		currentDescription.Shirt = 0
	end

	if not self._ownedCache[currentDescription.Pants] then
		currentDescription.Pants = 0
	end

	return currentDescription, result, result3
end

function v:_saveToRoblox()
	local _getDescriptionOfOwnedItems, v5, v6 = self:_getDescriptionOfOwnedItems()

	if not _getDescriptionOfOwnedItems then
		warn("No humanoid description found")
	elseif self._currentApplyType == "MyOutfit" then
		AvatarEditorService:PromptSaveAvatar(_getDescriptionOfOwnedItems, Enum.HumanoidRigType.R15)
		self._Janitor:Add(AvatarEditorService.PromptSaveAvatarCompleted:Once(function(p, _)
			local items = {}

			for _, v8 in v5 do
				table.insert(items, v8)
			end

			for _, v8 in v6 do
				table.insert(items, v8.AssetId)
			end

			if _getDescriptionOfOwnedItems.Shirt ~= 0 then
				table.insert(items, _getDescriptionOfOwnedItems.Shirt)
			end

			if _getDescriptionOfOwnedItems.Pants ~= 0 then
				table.insert(items, _getDescriptionOfOwnedItems.Pants)
			end

			local v8 = {
				items = items
			}

			if p == Enum.AvatarPromptResult.Success then
				PanelController.Close("Outfits", "OutfitApply")
				NotificationController.NotifyCenterAlwaysVisible("Outfit saved to Roblox")
				v8.savedToRoblox = true
			elseif p == Enum.AvatarPromptResult.Failed then
				NotificationController.NotifyCenterAlwaysVisible("Failed to save outfit")
				v8.savedToRoblox = false
			elseif p == Enum.AvatarPromptResult.PermissionDenied then
				NotificationController.NotifyCenterAlwaysVisible("Cancelled")
				v8.savedToRoblox = false
			else
				warn("Unknown avatar prompt result: " .. p)
			end

			TelemetryController.SendClientInteraction("saveAvatarCharacter", v8)
		end))
	else
		if self._currentApplyType ~= "NewOutfit" then
			warn("No current apply type found")
			return
		end

		AvatarEditorService:PromptCreateOutfit(_getDescriptionOfOwnedItems, Enum.HumanoidRigType.R15)
		self._Janitor:Add(AvatarEditorService.PromptCreateOutfitCompleted:Once(function(p, p2)
			local items = {}

			for _, v8 in v5 do
				table.insert(items, v8)
			end

			for _, v8 in v6 do
				table.insert(items, v8.AssetId)
			end

			if _getDescriptionOfOwnedItems.Shirt ~= 0 then
				table.insert(items, _getDescriptionOfOwnedItems.Shirt)
			end

			if _getDescriptionOfOwnedItems.Pants ~= 0 then
				table.insert(items, _getDescriptionOfOwnedItems.Pants)
			end

			local v8 = {
				items = items
			}

			if p == Enum.AvatarPromptResult.Success then
				PanelController.Close("Outfits", "OutfitApply")
				NotificationController.NotifyCenterAlwaysVisible("Outfit saved to Roblox")
				v8.savedToRoblox = true
			elseif p == Enum.AvatarPromptResult.Failed then
				NotificationController.NotifyCenterAlwaysVisible("Failed to save outfit")
				warn("Failed to save outfit:", p2)
				v8.savedToRoblox = false
			elseif p == Enum.AvatarPromptResult.PermissionDenied then
				NotificationController.NotifyCenterAlwaysVisible("Cancelled")
				warn("Permission denied to save outfit", p2)
				v8.savedToRoblox = false
			end

			TelemetryController.SendClientInteraction("saveAvatarOutfit", v8)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v