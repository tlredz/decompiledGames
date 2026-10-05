local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local AvatarEditorReworkABTest = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorReworkABTest)
local CharacterBodyController = require(ReplicatedStorage.Modules.Client.AvatarEditor.CharacterBodyController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "CatalogListSearchUI"
})
local uDim = UDim2.fromScale(0.35, 0.35)
local uDim2 = UDim2.fromScale(0.5, 0.5)
local uDim3 = UDim2.fromScale(0.103, 0.217)
local uDim4 = UDim2.fromScale(0.935, 0.89)
local v2 = {
	Idle = Enum.AssetType.IdleAnimation,
	Walk = Enum.AssetType.WalkAnimation,
	Run = Enum.AssetType.RunAnimation,
	Jump = Enum.AssetType.JumpAnimation,
	Fall = Enum.AssetType.FallAnimation,
	Climb = Enum.AssetType.ClimbAnimation,
	Swim = Enum.AssetType.SwimAnimation
}
local v3 = {}
local v4 = {
	"Idle",
	"Walk",
	"Run",
	"Jump",
	"Fall",
	"Climb",
	"Swim"
}
local v5 = false
local v6 = false
local v7 = false
local v8 = {
	Jump = true,
	Fall = true
}
local mergedCategory = { "Shirt", "Pants" }

for k, v10 in v2 do
	v3[v10.Value] = k
end

local v10 = {
	control = {
		SortType = "Relevance",
		SortAggregation = "AllTime"
	},
	None = {
		SortType = "Relevance",
		SortAggregation = "AllTime"
	},
	["best-selling-past-month"] = {
		SortType = "Bestselling",
		SortAggregation = "PastMonth"
	},
	["best-selling-past-week"] = {
		SortType = "Bestselling",
		SortAggregation = "PastWeek"
	},
	["most-favorited-past-week"] = {
		SortType = "MostFavorited",
		SortAggregation = "PastWeek"
	},
	["most-favorited-past-month"] = {
		SortType = "MostFavorited",
		SortAggregation = "PastMonth"
	}
}

local function getAnimationDisplayName(name: string)
	if #name <= 15 then
		return name
	end

	local v11 = string.upper(name)

	if string.sub(v11, -6) == "BUNDLE" then
		return (string.gsub(string.sub(name, 1, -7), "%s+$", ""))
	end

	if string.sub(v11, -4) == "PACK" then
		return (string.gsub(string.sub(name, 1, -5), "%s+$", ""))
	end

	return name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBodyItemGenderSymbol(clone, feminine: boolean)
	local child = clone:FindFirstChild(feminine and "FeminineSymbol" or "MaleSymbol")
	local child2 = clone:FindFirstChild(feminine and "MaleSymbol" or "FeminineSymbol")

	if child then
		child.Visible = true
	end

	if child2 then
		Debris:AddItem(child2, 0)
	end
end

local function isIgnoredBodyPartsBundledAsset(data)
	if data.Type ~= nil and data.Type ~= "Asset" or data.Name ~= nil and data.Name:lower():match("mood") then
		return true
	end

	local assetType = data.AssetType

	if typeof(assetType) ~= "string" then
		return false
	end

	if assetType == "Gear" or assetType == "EyebrowAccessory" or assetType == "EyelashAccessory" or assetType == "EmoteAnimation" or assetType == "MoodAnimation" then
		return true
	end

	return string.find(assetType, "Animation", 1, true) ~= nil
end

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v:IsBodyPartsBundleFullyWorn(options)
	local v11 = false

	for _, v12 in options or {} do
		if isIgnoredBodyPartsBundledAsset(v12) then
			continue
		end

		local id = tonumber(v12.Id)

		if id == nil then
			continue
		end

		if self:IsWearing(id) ~= true then
			return false
		end

		v11 = true
	end

	return v11
end

function v:AreAllBundledAssetIdsWorn(value: string?)
	local v11 = false

	for _, v12 in string.split(value or "", ",") do
		if v12 == "" then
			continue
		end

		local v13 = tonumber(v12)

		if v13 == nil then
			continue
		end

		if self:IsWearing(v13) ~= true then
			return false
		end

		v11 = true
	end

	return v11
end

function v:EnsureAnimationApplyConfirmationPanel()
	if self._animationApplyConfirmationPanel ~= nil then
		return true
	end

	local panel = PanelController.GetPanel("NoResetGUIHandler", "AvatarEditorConfirmationPanel")

	if panel == nil then
		return false
	end

	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		panel.Instance,
		"ConfirmationPanel",
		ConfirmationPanel
	)

	if waitForAncestorComponent == nil then
		return false
	end

	self._animationApplyConfirmationPanelObj = panel
	self._animationApplyConfirmationPanel = waitForAncestorComponent
	return true
end

function v:GetEquippedAnimationBundleIds()
	local assets = WearingController.GetWearingAssets()

	if assets == nil or #assets == 0 then
		local characterAppearanceInfo = WearingController.GetCharacterAppearanceInfoFromServer()

		if characterAppearanceInfo then
			assets = characterAppearanceInfo.assets
		else
			assets = nil
		end
	end

	if assets == nil then
		return {}
	end

	local v11 = {}
	local bundleIds = {}

	for _, asset in assets do
		local id

		if asset.assetType then
			id = asset.assetType.id
		end

		if not (typeof(id) == "number" and v3[id] ~= nil) then
			continue
		end

		local bundleId = tonumber(asset.bundleId)

		if not (bundleId ~= nil and v11[bundleId] ~= true) then
			continue
		end

		v11[bundleId] = true
		table.insert(bundleIds, bundleId)
	end

	return bundleIds
end

function v:ShouldIgnoreAllAnimationBundleApply(p: number, p2)
	local v11 = p2 or self:GetEquippedAnimationBundleIds()
	return #v11 == 1 and v11[1] == p
end

function v:ApplyAllAnimationBundle(p: number, p2)
	if self:ShouldIgnoreAllAnimationBundleApply(p, p2) then
		return
	end

	if self._isApplyingAnimation then
		NotificationController.NotifyClickDebounce(1)
		return
	end

	self._isApplyingAnimation = true
	local instantiableComponent = ComponentUtil.CloneInstantiableComponent("LoadingSpinnerAE")

	if instantiableComponent then
		Debris:AddItem(instantiableComponent, 15)
		instantiableComponent.Parent = self.Instance.Parent
		instantiableComponent.ZIndex = 10
		instantiableComponent.Spinner.Size = uDim
		instantiableComponent.Spinner.Position = uDim2
	end

	local v11 = false
	local success, result = pcall(function()
		v11 = WearingController.WearBundle(p) ~= false
	end)

	if instantiableComponent then
		instantiableComponent:Destroy()
	end

	self._isApplyingAnimation = false

	if not success then
		warn("Failed to apply animation pack: ", result)
	elseif v11 and self:IsPreviewContextActive() then
		self:StartPreview(v4, false)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._loadingBatch = false
	self._currentIndex = 1
	self._itemsToLoad = {}
	self._loadedItems = {}
	self._loadedIds = {}
	self._currentCategory = nil
	self._debounceEnabled = false
	self._abCatalogDefaultSort = nil
	self._abCatalogDefaultsApplied = false
	self._previewGeneration = 0
	self._previewTrack = nil
	self._isApplyingAnimation = false
	self._showBodyTypesForBodyParts = false
	self._animationBundleNameCache = {}
	self._Janitor:Add(WearingController.OnWearingUpdated:Connect(function(_)
		if not self.Instance.Visible then
			return
		end

		for _, button in self.Instance:GetChildren() do
			if not button:IsA("ImageButton") or (button:GetAttribute("ShowcasedItemCategory") or button:GetAttribute("CharacterBodyItem")) then
				continue
			end

			local id = button:GetAttribute("Id")
			local applyAssetId = button:GetAttribute("ApplyAssetId")
			local v11

			if typeof(applyAssetId) == "number" then
				v11 = self:IsWearing(applyAssetId)
			elseif button:GetAttribute("IsBundle") then
				if self.Instance:GetAttribute("Subcategory") == "Bundle: BodyParts" then
					v11 = self:AreAllBundledAssetIdsWorn(button:GetAttribute("BundledItems"))
				else
					v11 = self:IsWearing(id) == true

					if not v11 then
						for _, v13 in string.split(button:GetAttribute("BundledItems") or "", ",") do
							if not self:IsWearing((tonumber(v13))) then
								continue
							end

							v11 = true
							break
						end
					end
				end
			else
				v11 = self:IsWearing(id)
			end

			UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, v11)
		end
	end))
	local AccessoriesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Accessories.AccessoriesConfig)
	v5 = AccessoriesConfig
	local ShowcasedItemCategoriesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.ShowcasedItemCategories.ShowcasedItemCategoriesConfig)
	v6 = ShowcasedItemCategoriesConfig
	local CharacterBodyConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.CharacterBody.CharacterBodyConfig)
	v7 = CharacterBodyConfig
end

function v:IsAnimationSubcategory(p: string?)
	if p == "All" then
		return true
	elseif p == nil then
		return false
	else
		return v2[p] ~= nil
	end
end

function v:StopPreview()
	self._previewGeneration += 1

	if self._previewTrack ~= nil then
		self._previewTrack:Stop()
		self._previewTrack:Destroy()
		self._previewTrack = nil
	end
end

function v:PlayPreviewAnimation(value: string)
	if self._previewTrack ~= nil then
		self._previewTrack:Stop()
		self._previewTrack:Destroy()
		self._previewTrack = nil
	end

	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	if animator == nil then
		return false
	end

	local animate = character:FindFirstChild("Animate")

	if animate == nil then
		return false
	end

	local animation1 = nil

	for _, child in animate:GetChildren() do
		if child.Name:lower() ~= value:lower() then
			continue
		end

		animation1 = child:FindFirstChild("Animation1") or child:FindFirstChildOfClass("Animation")
		break
	end

	if animation1 == nil then
		return false
	end

	local track = animator:LoadAnimation(animation1)
	self._previewTrack = track
	track.Looped = v8[value] ~= true
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()
	return true
end

function v:IsPreviewContextActive()
	if not self.Instance.Visible or (self.avatarEditorMenu == nil or self.avatarEditorMenu.Instance == nil) then
		return false
	end

	return self.avatarEditorMenu.Instance.Visible == true
end

function v:StartPreview(list, flag: boolean?)
	self:StopPreview()

	if list == nil or #list == 0 then
		return
	end

	local _previewGeneration = self._previewGeneration
	local v11 = flag == true
	task.spawn(function()
		task.wait(0.35)

		if _previewGeneration ~= self._previewGeneration or not self:IsPreviewContextActive() then
			return
		end

		if v11 then
			self:PlayPreviewAnimation(list[1])
			return
		end

		for _, v12 in list do
			if _previewGeneration ~= self._previewGeneration or not self:IsPreviewContextActive() then
				return
			end

			self:PlayPreviewAnimation(v12)
			task.wait(2)

			if _previewGeneration ~= self._previewGeneration or not self:IsPreviewContextActive() then
				return
			end
		end

		if _previewGeneration == self._previewGeneration and self:IsPreviewContextActive() then
			self:PlayPreviewAnimation("Idle")
		end
	end)
end

function v:ApplyAnimationItemVisualLayout(parent)
	local icon = parent:FindFirstChild("Icon")

	if icon and icon:IsA("GuiObject") then
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.36, 0)
		icon.Size = UDim2.new(0.92, 0, 0.78, 0)

		if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
			icon.ScaleType = Enum.ScaleType.Fit
		end
	end

	local parent2 = parent:FindFirstChild("Name")

	if parent2 == nil or not parent2:IsA("TextLabel") then
		parent2 = Instance.new("TextLabel")
		parent2.Name = "Name"
		parent2.BackgroundTransparency = 1
		parent2.TextColor3 = Color3.new(1, 1, 1)
		parent2.Parent = parent
	end

	parent2.Size = UDim2.new(1, -8, 0.26, 0)
	parent2.Position = UDim2.new(0, 4, 0.74, 0)
	parent2.Font = Enum.Font.GothamBlack
	parent2.TextScaled = true
	parent2.TextWrapped = true
	parent2.TextXAlignment = Enum.TextXAlignment.Center
	parent2.TextYAlignment = Enum.TextYAlignment.Center
	parent2.ZIndex = 3
	local v12 = parent2:FindFirstChildOfClass("UITextSizeConstraint")

	if v12 == nil then
		v12 = Instance.new("UITextSizeConstraint")
		v12.Parent = parent2
	end

	v12.MaxTextSize = 14
	v12.MinTextSize = 8
	local v13 = parent2:FindFirstChildOfClass("UIStroke")

	if v13 == nil then
		v13 = Instance.new("UIStroke")
		v13.Parent = parent2
	end

	v13.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	v13.Color = Color3.new(0, 0, 0)
	v13.Thickness = 1.5
	v13.Transparency = 0.35
	return parent2
end

function v:FindAnimationIdForSubcategory(items, value: string)
	local v11 = v2[value]

	if items == nil or v11 == nil then
		return nil
	end

	local name = v11.Name
	local lower = value:lower()

	for _, item in items do
		if not ((item.Type == nil or item.Type == "Asset") and (item.Name == nil or not item.Name:lower():match("mood"))) then
			continue
		end

		if item.AssetType == name then
			return item.Id
		end

		local v12 = item.Name == nil and "" or item.Name:lower()

		if v12 == lower or v12:match("^" .. lower) or v12:match(lower .. " ?anim") then
			return item.Id
		end
	end

	return nil
end

function v:ResolveAnimationIdFromBundle(p: number, p2: string, p3)
	local animationIdForSubcategory = self:FindAnimationIdForSubcategory(p3, p2)

	if animationIdForSubcategory ~= nil then
		return animationIdForSubcategory
	end

	local success, result = pcall(function()
		return AvatarEditorService:GetItemDetails(p, Enum.AvatarItemType.Bundle)
	end)

	if success and result ~= nil then
		return self:FindAnimationIdForSubcategory(result.BundledItems or result.Items, p2)
	end

	return nil
end

function v:GetAnimationBundleNames(list)
	local result = {}

	if #list == 0 then
		return result
	end

	local v11 = {}

	for _, v12 in list do
		local v13 = self._animationBundleNameCache[v12]

		if v13 == nil then
			table.insert(v11, v12)
		else
			result[v12] = v13
		end
	end

	if #v11 == 0 then
		return result
	end

	local success, result2 = pcall(function()
		return AvatarEditorService:GetBatchItemDetails(v11, Enum.AvatarItemType.Bundle)
	end)

	if not success or typeof(result2) ~= "table" then
		return result
	end

	for _, v12 in result2 do
		local id = tonumber(v12.Id)

		if not (id ~= nil and typeof(v12.Name) == "string" and v12.Name ~= "") then
			continue
		end

		result[id] = v12.Name
		self._animationBundleNameCache[id] = v12.Name
	end

	return result
end

function v:LoadEquippedAnimationItems()
	local subcategory = self.Instance:GetAttribute("Subcategory")

	if not self:IsAnimationSubcategory(subcategory) then
		return
	end

	local assets = WearingController.GetWearingAssets()

	if assets == nil or #assets == 0 then
		local characterAppearanceInfo = WearingController.GetCharacterAppearanceInfoFromServer()

		if characterAppearanceInfo then
			assets = characterAppearanceInfo.assets
		else
			assets = nil
		end
	end

	if assets == nil or #assets == 0 then
		return
	end

	local v11 = subcategory == "All"
	local v12 = {}
	local v13 = {}
	local bundleIds = {}

	for _, asset in assets do
		local id

		if asset.assetType then
			id = asset.assetType.id
		end

		local v14

		if typeof(id) == "number" then
			v14 = v3[id]
		end

		if v14 == nil then
			continue
		end

		local bundleId = tonumber(asset.bundleId)

		if bundleId == nil then
			continue
		end

		local id2 = tonumber(asset.id)
		local bundleName

		if typeof(asset.bundleName) == "string" and asset.bundleName ~= "" then
			bundleName = asset.bundleName
		end

		if v11 then
			if v12[bundleId] ~= true then
				v12[bundleId] = true
				table.insert(v13, {
					bundleId = bundleId,
					assetId = id2,
					displayName = bundleName
				})

				if bundleName == nil then
					table.insert(bundleIds, bundleId)
				end
			end
		elseif v14 == subcategory then
			table.insert(v13, {
				bundleId = bundleId,
				assetId = id2,
				displayName = bundleName
			})

			if bundleName ~= nil then
				break
			end

			table.insert(bundleIds, bundleId)
			break
		end
	end

	local animationBundleNames = self:GetAnimationBundleNames(bundleIds)

	for _, v14 in v13 do
		local displayName = v14.displayName or animationBundleNames[v14.bundleId]

		if displayName == nil then
			continue
		end

		self.currentItemLayoutOrder += 1
		local v15 = {
			Id = v14.bundleId,
			Name = displayName,
			ItemType = "Bundle",
			BundledItems = {}
		}
		local currentItemLayoutOrder = self.currentItemLayoutOrder
		local v16

		if not v11 then
			v16 = v14.assetId
		end

		self:CreateItem(currentItemLayoutOrder, v15, v16)
	end
end

function v:ClearList()
	self:StopPreview()
	self._isApplyingAnimation = false
	self._currentIndex = 1
	self._loadingBatch = false
	self._loadedItems = {}
	self._loadedIds = {}

	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self._clickJanitor:Cleanup()
	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function v:ShouldLoadMoreItems()
	local instance = self.Instance
	local Y = instance.CanvasPosition.Y
	return instance.CanvasSize.Y.Offset - (Y + instance.AbsoluteSize.Y) < 200
end

function v:LoadCharacterBodyItems()
	local config = v7.getConfig()

	if not (config and self.templateButton) then
		return
	end

	local templateBodyButton = self.Instance:FindFirstChild("TemplateBodyButton")

	if not (templateBodyButton and templateBodyButton:IsA("ImageButton") and templateBodyButton) then
		templateBodyButton = self.templateButton
	end

	for _, v11 in config do
		self.currentItemLayoutOrder += 1
		local clone = templateBodyButton:Clone()
		clone.Name = v11.Name
		clone:SetAttribute("CharacterBodyItem", true)
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. v11.Id .. "&w=150&h=150"
		clone.LayoutOrder = self.currentItemLayoutOrder
		applyBodyItemGenderSymbol(clone, v11.Feminine) -- equivalent call inferred; original call site unknown
		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, false)
		local v13 = v11
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if self._characterBodyChangeDebounce then
				return
			end

			self._characterBodyChangeDebounce = true
			self._selectedCharacterBodyName = clone.Name

			for i, button in self.Instance:GetChildren() do
				if button:IsA("ImageButton") and button:GetAttribute("CharacterBodyItem") then
					UIAnimationEffects.SetVisibilityWithPopInOutFX(
						button.SelectedIcon,
						button.Name == self._selectedCharacterBodyName
					)
				end
			end

			NotificationController.NotifyEditor("Please Wait...", 2)
			CharacterBodyController.ChangeCharacterBody(v13.CollectionIds)
			task.wait(1)
			self._characterBodyChangeDebounce = false
		end))
		clone.Parent = self.Instance
	end
end

function v:LoadShowcasedCategoryItems()
	local v11 = v6.getConfig()[self.Instance:GetAttribute("Subcategory")]

	if not v11 then
		return
	end

	local isSearchingForBundlesOnCatalog = self:IsSearchingForBundlesOnCatalog()

	for _, v12 in v11 do
		self.currentItemLayoutOrder += 1
		local clone = self.templateButton:Clone()
		clone:SetAttribute("ShowcasedItemCategory", true)
		clone.Name = string.format("%08d_ShowcasedCategory", self.currentItemLayoutOrder)
		clone.Icon.Image = v12.CategoryIcon
		clone.Parent = self.Instance
		local v13 = v12

		local function ApplyShowcasedItemCatBorder(clone2)
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Parent = clone2
			uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			uIStroke.LineJoinMode = Enum.LineJoinMode.Round
			uIStroke.Thickness = 0.02
			uIStroke.Transparency = 0.5
			uIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner

			if v13.BorderColor then
				uIStroke.Color = Color3.fromRGB(v13.BorderColor[1], v13.BorderColor[2], v13.BorderColor[3])
			end
		end

		ApplyShowcasedItemCatBorder(clone)
		local currentItemLayoutOrder = self.currentItemLayoutOrder
		clone.LayoutOrder = currentItemLayoutOrder
		local v14 = nil
		local v16 = v12
		local ApplyShowcasedItemCatBorder2 = ApplyShowcasedItemCatBorder
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if v14 then
				UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, false)
				v14:Destroy()
				v14 = nil
			else
				UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, true)
				v14 = Janitor.new()

				for k, content in v16.Contents do
					local clone2 = table.clone(content)
					clone2.ItemType = (v16.BundledItems or isSearchingForBundlesOnCatalog) and "Bundle" or "Asset"
					clone2.AssetType = v16.AssetType

					if clone2.BundledItems then
						for k2, bundledItem in clone2.BundledItems do
							if not (bundledItem.Id and bundledItem.Name) then
								warn(bundledItem)
								error("Bundled item inside of an RC-based Showcased Item Category must have an Id and Name field! Item data is above.")
							end

							local clone3 = table.clone(bundledItem)
							clone3.Type = "Asset"
							clone2.BundledItems[k2] = clone3
						end
					end

					local item = self:CreateItem(currentItemLayoutOrder + k, clone2)

					if not item then
						continue
					end

					ApplyShowcasedItemCatBorder2(item)
					v14:Add(item)
				end
			end
		end))
		self.currentItemLayoutOrder += #v12.Contents
	end
end

function v:CreateItem(layoutOrder: number, data, applyAssetId: number?)
	if not (data and data.Name) or self._loadedIds[data.Id] then
		return
	end

	self._loadedIds[data.Id] = true
	local clone = self.templateButton:Clone()
	clone.Name = string.format("%08d_%s", layoutOrder, data.Name)
	clone:SetAttribute("Id", data.Id)
	local subcategory = self.Instance:GetAttribute("Subcategory")
	local isAnimationSubcategory = self:IsAnimationSubcategory(subcategory)
	local itemType = data.ItemType
	local v11 = subcategory == "Bundle: BodyParts"

	if data.ItemType == "Bundle" or isAnimationSubcategory then
		clone:SetAttribute("IsBundle", true)
		local v12 = ""
		itemType = "BundleThumbnail"

		for _, v13 in data.BundledItems or {} do
			if v11 then
				if not isIgnoredBodyPartsBundledAsset(v13) then
					v12 ..= v13.Id .. ","
				end
			elseif (v13.Type == nil or v13.Type == "Asset") and v13.Name and not v13.Name:lower():match("mood") then
				v12 ..= v13.Id .. ","
			end
		end

		clone:SetAttribute("BundledItems", v12)
	end

	local thumbnailImage = `rbxthumb://type={itemType}&id={data.Id}&w=150&h=150`

	if data.ThumbnailImage then
		thumbnailImage = data.ThumbnailImage
	end

	clone.Icon.Image = thumbnailImage
	clone.LayoutOrder = layoutOrder

	if applyAssetId == nil and isAnimationSubcategory and subcategory ~= "All" then
		applyAssetId = self:FindAnimationIdForSubcategory(data.BundledItems, subcategory)
	end

	if applyAssetId ~= nil then
		clone:SetAttribute("ApplyAssetId", applyAssetId)
	end

	local v12

	if typeof(applyAssetId) == "number" then
		v12 = self:IsWearing(applyAssetId)
	elseif v11 and (data.ItemType == "Bundle" or clone:GetAttribute("IsBundle")) then
		v12 = self:IsBodyPartsBundleFullyWorn(data.BundledItems)
	elseif data.ItemType == "Bundle" or clone:GetAttribute("IsBundle") then
		v12 = self:IsWearing(data.Id) == true

		if not v12 then
			for _, v14 in data.BundledItems or {} do
				if v14.Type ~= "Asset" or not v14.Name or v14.Name:lower():match("mood") then
					continue
				end

				if not self:IsWearing((tonumber(v14.Id))) then
					continue
				end

				v12 = true
				break
			end
		end
	else
		v12 = self:IsWearing(data.Id)
	end

	local emptyMesh = data.CornerIconData and data.CornerIconData.Image and clone:FindFirstChild("EmptyMesh")

	if emptyMesh then
		emptyMesh.Visible = true
		emptyMesh.Image = data.CornerIconData.Image

		if data.CornerIconData.Position then
			emptyMesh.Position = UDim2.new(
				data.CornerIconData.Position.X.Scale,
				data.CornerIconData.Position.X.Offset,
				data.CornerIconData.Position.Y.Scale,
				data.CornerIconData.Position.Y.Offset
			)
		end

		if data.CornerIconData.Size then
			emptyMesh.Size = UDim2.new(
				data.CornerIconData.Size.X.Scale,
				data.CornerIconData.Size.X.Offset,
				data.CornerIconData.Size.Y.Scale,
				data.CornerIconData.Size.Y.Offset
			)
		end
	end

	if isAnimationSubcategory then
		local v13 = self:ApplyAnimationItemVisualLayout(clone)
		v13.Text = getAnimationDisplayName(data.Name)
		v13.Visible = true
		local feminineSymbol = clone:FindFirstChild("FeminineSymbol")

		if feminineSymbol and feminineSymbol:IsA("GuiObject") then
			feminineSymbol.Visible = false
		end

		local maleSymbol = clone:FindFirstChild("MaleSymbol")

		if maleSymbol and maleSymbol:IsA("GuiObject") then
			maleSymbol.Visible = false
		end
	end

	UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, v12)
	clone.Parent = self.Instance
	local id = data.Id
	local assetType = data.AssetType
	local bundledItems = data.BundledItems
	self._clickJanitor:Add(clone.Activated:Connect(function()
		if isAnimationSubcategory then
			if self._isApplyingAnimation then
				NotificationController.NotifyClickDebounce(1)
			elseif subcategory == "All" then
				local equippedAnimationBundleIds = self:GetEquippedAnimationBundleIds()

				if self:ShouldIgnoreAllAnimationBundleApply(id, equippedAnimationBundleIds) then
					return
				end

				if not self:EnsureAnimationApplyConfirmationPanel() then
					self:ApplyAllAnimationBundle(id, equippedAnimationBundleIds)
				elseif self._animationApplyConfirmationPanelObj == nil or not self._animationApplyConfirmationPanelObj:IsOpen() then
					self._animationApplyConfirmationPanel:Init(
						"Apply pack to all animations? (Will overwrite currently selected)",
						function(flag: boolean)
							if flag == true then
								self:ApplyAllAnimationBundle(id)
							end
						end
					)
				else
					self._animationApplyConfirmationPanelObj:Close()
				end
			else
				self._isApplyingAnimation = true
				local instantiableComponent = ComponentUtil.CloneInstantiableComponent("LoadingSpinnerAE")

				if instantiableComponent then
					Debris:AddItem(instantiableComponent, 15)
					instantiableComponent.Parent = self.Instance.Parent
					instantiableComponent.ZIndex = 10
					instantiableComponent.Spinner.Size = uDim
					instantiableComponent.Spinner.Position = uDim2
				end

				local v13 = nil
				local v14 = false
				local v15 = false
				local success, result = pcall(function()
					local applyAssetId2 = clone:GetAttribute("ApplyAssetId")

					if typeof(applyAssetId2) ~= "number" then
						applyAssetId2 = self:ResolveAnimationIdFromBundle(id, subcategory, bundledItems)

						if typeof(applyAssetId2) == "number" then
							clone:SetAttribute("ApplyAssetId", applyAssetId2)
						end
					end

					if typeof(applyAssetId2) ~= "number" then
						NotificationController.NotifyEditor("Animation not found in bundle")
						return
					end

					v15 = WearingController.WearAsset(applyAssetId2, nil, id) ~= false

					if v15 then
						v13 = { subcategory }
						v14 = subcategory == "Idle"
					end
				end)

				if instantiableComponent then
					instantiableComponent:Destroy()
				end

				self._isApplyingAnimation = false

				if not success then
					warn("Failed to apply animation pack: ", result)
				elseif v15 and v13 ~= nil and self:IsPreviewContextActive() then
					self:StartPreview(v13, v14)
				end
			end
		else
			if self._debounceEnabled and self._debounce then
				NotificationController.NotifyClickDebounce(1)
				return
			end

			if self._debounceEnabled then
				self._debounce = true
			end

			task.delay(0.5, function()
				self._debounce = false
			end)

			if clone:GetAttribute("IsBundle") then
				WearingController.WearBundle(id)
			elseif assetType == "Shirt" then
				WearingController.WearShirt(id)
			elseif assetType == "Pants" then
				WearingController.WearPants(id)
			else
				WearingController.WearAsset(id, true)
			end
		end
	end))
	return clone
end

function v:IsSearchingForBundlesOnCatalog()
	local subcategory = self.Instance:GetAttribute("Subcategory")

	if self:IsAnimationSubcategory(subcategory) then
		return true
	end

	local v11 = string.split(subcategory or "", ",")

	for _, v12 in v11 do
		if string.sub(v12:lower(), 1, 8) == "bundle: " then
			return true
		end
	end

	return false
end

function v:GetSearchParamAssetAndBundleTypes(p: string?)
	local v11 = p or self.Instance:GetAttribute("Subcategory")

	if self:IsAnimationSubcategory(v11) then
		return {}, { Enum.BundleType.Animations }
	end

	local v12 = string.split(v11 or "", ",")
	local result = {}
	local result2 = {}

	for _, v13 in v12 do
		if string.sub(v13:lower(), 1, 8) == "bundle: " then
			table.insert(result2, Enum.BundleType[string.sub(v13, 9)])
		else
			table.insert(result, Enum.AvatarAssetType[v13])
		end
	end

	return result, result2
end

function v:GetTableRepresentationOfSearchParams(data)
	if data then
		return {
			SearchKeyword = data.SearchKeyword,
			CreatorName = data.CreatorName,
			CreatorType = data.CreatorType,
			MinPrice = data.MinPrice,
			MaxPrice = data.MaxPrice,
			IncludeOffSale = data.IncludeOffSale,
			Limit = data.Limit,
			AssetTypes = data.AssetTypes,
			BundleTypes = data.BundleTypes,
			CategoryFilter = data.CategoryFilter,
			SortType = data.SortType,
			SortAggregation = data.SortAggregation
		}
	end

	return nil
end

function v:LoadMoreCatalogItems()
	if self._loadingBatch or not self.Instance.Visible then
		return
	end

	local noItemsFound = self.Instance:FindFirstChild("NoItemsFound")

	if noItemsFound then
		noItemsFound.Visible = false
	end

	self._loadingBatch = true
	local instantiableComponent = ComponentUtil.CloneInstantiableComponent("LoadingSpinnerAE")

	if instantiableComponent then
		Debris:AddItem(instantiableComponent, 10)
		instantiableComponent.Parent = self.Instance.Parent
		instantiableComponent.ZIndex = 10
		local spinner = instantiableComponent.Spinner
		local size

		if self.currentItemLayoutOrder == 0 then
			size = uDim
		else
			size = uDim3
		end

		spinner.Size = size
		local spinner2 = instantiableComponent.Spinner
		local position

		if self.currentItemLayoutOrder == 0 then
			position = uDim2
		else
			position = uDim4
		end

		spinner2.Position = position
	end

	local tableRepresentationOfSearchParams = self:GetTableRepresentationOfSearchParams(self.searchParams)

	if tableRepresentationOfSearchParams then
		local function doLoad()
			local clone = tableRepresentationOfSearchParams
			local currentPage

			if self._mergedBalancedMerge and self._mergedCategory and self._mergedPhase and self._mergedPhase <= #self._mergedCategory then
				local v12 = self._mergedCategory[self._mergedPhase]
				clone = table.clone(tableRepresentationOfSearchParams)
				local searchParamAssetAndBundleTypes, bundleTypes = self:GetSearchParamAssetAndBundleTypes(v12)
				clone.AssetTypes = searchParamAssetAndBundleTypes
				clone.BundleTypes = bundleTypes
				currentPage = (self._mergedPhasePages[self._mergedPhase] or 0) + 1
			else
				currentPage = not self.currentPage and 1 or self.currentPage + 1
				self.currentPage = currentPage
			end

			if self.avatarEditorMenu:IsPerformingSearch() then
				return
			end

			self.avatarEditorMenu:SetPerformingSearch(true)
			local v12 = Remotes.invokeServer("PerformCatalogSearch", clone, currentPage)
			self.avatarEditorMenu:SetPerformingSearch(false)

			if typeof(v12) == "string" and v12:match("Error") then
				warn("An error occured while attempting to load more catalog items: ", v12)
				return nil
			end

			if v12 and #v12 > 0 then
				for _, v13 in v12 do
					self.currentItemLayoutOrder += 1
					self:CreateItem(self.currentItemLayoutOrder, v13)
				end

				if self._mergedBalancedMerge then
					self._mergedPhasePages[self._mergedPhase] = currentPage
					self._mergedPhase = self._mergedPhase == 1 and 2 or 1
				end

				return "has_results"
			elseif self._mergedBalancedMerge then
				self._mergedPhaseExhausted[self._mergedPhase] = true
				self._mergedPhase = self._mergedPhase == 1 and 2 or 1

				if self._mergedPhaseExhausted[self._mergedPhase] then
					return "no_more"
				end

				return "next_phase"
			else
				self.currentPage -= 1

				if not self._mergedCategory then
					warn("An error occured while attempting to load more catalog items - no current page items found!")
				end

				return "no_more"
			end
		end

		while true do
			local v11 = doLoad()

			if v11 == nil then
				break
			end

			if v11 == "next_phase" then
				continue
			end

			if instantiableComponent then
				instantiableComponent:Destroy()
			end

			if noItemsFound then
				noItemsFound.Visible = #self.Instance:GetChildren() == 2
			end

			self._loadingBatch = false
			self.avatarEditorMenu:SetPerformingSearch(false)
			return
		end

		self._loadingBatch = false

		if instantiableComponent then
			instantiableComponent:Destroy()
		end
	else
		self._loadingBatch = false

		if instantiableComponent then
			instantiableComponent:Destroy()
		end
	end
end

function v:PreviewEquippedAnimationForCurrentSubcategory()
	local subcategory = self.Instance:GetAttribute("Subcategory")

	if not self:IsAnimationSubcategory(subcategory) or subcategory == "All" or not self:IsPreviewContextActive() then
		return
	end

	self:StartPreview({ subcategory }, true)
end

function v:Build()
	self:ClearList()
	self:LoadShowcasedCategoryItems()

	if self.Instance:GetAttribute("Subcategory") == "Bundle: BodyParts" and self._showBodyTypesForBodyParts then
		self:LoadCharacterBodyItems()
	end

	if self:IsAnimationSubcategory(self.Instance:GetAttribute("Subcategory")) then
		self:LoadEquippedAnimationItems()
	end

	if self:ShouldLoadMoreItems() then
		self:LoadMoreCatalogItems()
	end

	self:PreviewEquippedAnimationForCurrentSubcategory()
end

function v:RestartSearch()
	self:ClearList()
	self.currentPage = 0
	self.currentItemLayoutOrder = 0
	self._mergedCategory = nil
	self._mergedBalancedMerge = nil
	self._mergedPhasePages = nil
	self._mergedPhaseExhausted = nil
	local editorSearchComponent = self.avatarEditorMenu.editorSearchComponent
	local userSearchOptions = editorSearchComponent.userSearchOptions
	local v11 = (userSearchOptions.SearchTerm or "") ~= ""
	local hasManuallySetSortOptions = editorSearchComponent.hasManuallySetSortOptions == true

	if v11 then
		if not hasManuallySetSortOptions then
			if (userSearchOptions.SortType or "Relevance") ~= "Relevance" or (userSearchOptions.SortAggregation or "AllTime") ~= "AllTime" then
				editorSearchComponent:ApplyDefaultSortOptions("Relevance", "AllTime")
				userSearchOptions = editorSearchComponent.userSearchOptions
			end

			self._abCatalogDefaultsApplied = false
		end
	elseif self._abCatalogDefaultsApplied ~= true and not hasManuallySetSortOptions and (userSearchOptions.SortType or "Relevance") == "Relevance" and (userSearchOptions.SortAggregation or "AllTime") == "AllTime" then
		if self._abCatalogDefaultSort == nil then
			local v12, v13 = ABTest.GetExperimentVariable("ae-catalog-default-params", "queryParams"):timeout(5):await()
			local control

			if v12 == true and typeof(v13) == "string" then
				control = v10[v13]
			end

			if control == nil then
				if v12 == true then
					if typeof(v13) == "string" and v13 ~= "None" then
						warn("Unknown ae-catalog-default-params queryParams value:", v13)
					end
				else
					warn("Failed to get default queryParams from ABTest:", v13)
				end

				control = v10.control
			end

			self._abCatalogDefaultSort = control
		end

		editorSearchComponent:ApplyDefaultSortOptions(
			self._abCatalogDefaultSort.SortType,
			self._abCatalogDefaultSort.SortAggregation
		)
		self._abCatalogDefaultsApplied = true
		userSearchOptions = editorSearchComponent.userSearchOptions
	end

	local v12 = (userSearchOptions.SortType or "Relevance") ~= "Relevance"
	local subcategory = self.Instance:GetAttribute("Subcategory")

	if subcategory == "Merged: Shirt/Pants" then
		self._mergedCategory = mergedCategory
		self._mergedPhase = 1
		self._mergedBalancedMerge = true
		self._mergedPhasePages = { 0, 0 }
		self._mergedPhaseExhausted = {}
	end

	local showBodyTypesForBodyParts

	if subcategory == "Bundle: BodyParts" then
		showBodyTypesForBodyParts = not (v11 or v12)
	else
		showBodyTypesForBodyParts = false
	end

	self._showBodyTypesForBodyParts = showBodyTypesForBodyParts
	local catalogSearchParams = CatalogSearchParams.new()

	if userSearchOptions.SearchTerm ~= "" then
		if userSearchOptions.SearchType == "Keyword / ID" then
			catalogSearchParams.SearchKeyword = userSearchOptions.SearchTerm
			local searchTerm = tonumber(userSearchOptions.SearchTerm)

			if not searchTerm then
				if string.sub(userSearchOptions.SearchTerm, 1, 13) == "rbxassetid://" then
					searchTerm = tonumber((string.sub(userSearchOptions.SearchTerm, 14)))
				end

				searchTerm = searchTerm or tonumber(userSearchOptions.SearchTerm:match("catalog/(%d+)/"))
			end

			if searchTerm then
				local itemDetails = nil
				pcall(function()
					local v16

					if self:IsSearchingForBundlesOnCatalog() then
						v16 = Enum.AvatarItemType.Bundle
					else
						v16 = Enum.AvatarItemType.Asset
					end

					itemDetails = AvatarEditorService:GetItemDetails(searchTerm, v16)
				end)

				if itemDetails then
					self:ClearList()
					local noItemsFound = self.Instance:FindFirstChild("NoItemsFound")

					if noItemsFound then
						noItemsFound.Visible = false
					end

					self:CreateItem(1, itemDetails)
					return
				end
			end
		elseif userSearchOptions.SearchType == "Creator" then
			catalogSearchParams.CreatorName = userSearchOptions.SearchTerm
			catalogSearchParams.CreatorType = Enum.CreatorTypeFilter.User
		elseif userSearchOptions.SearchType == "Group" then
			catalogSearchParams.CreatorName = userSearchOptions.SearchTerm
			catalogSearchParams.CreatorType = Enum.CreatorTypeFilter.Group
		end
	end

	catalogSearchParams.MinPrice = userSearchOptions.PriceMin

	if userSearchOptions.PriceMax > 0 then
		catalogSearchParams.MaxPrice = userSearchOptions.PriceMax
	end

	catalogSearchParams.IncludeOffSale = false
	catalogSearchParams.Limit = 60
	catalogSearchParams.SortType = Enum.CatalogSortType[userSearchOptions.SortType]
	catalogSearchParams.SortAggregation = Enum.CatalogSortAggregation[userSearchOptions.SortAggregation]
	local v14

	if self._mergedCategory then
		v14 = self._mergedCategory[1]
	end

	local searchParamAssetAndBundleTypes, bundleTypes = self:GetSearchParamAssetAndBundleTypes(v14)
	catalogSearchParams.AssetTypes = searchParamAssetAndBundleTypes
	catalogSearchParams.BundleTypes = bundleTypes
	self.searchParams = catalogSearchParams
	self:Build()
end

function v:Start()
	self.avatarEditorMenu = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	task.spawn(function()
		local success, result = pcall(function()
			return ComponentUtil.FindAndWaitForAncestorComponent(
				self.Instance,
				"AvatarEditorReworkABTest",
				AvatarEditorReworkABTest
			)
		end)

		if success and result then
			self._debounceEnabled = result:IsAvatarEditorReworkABTestEnabled()
		end
	end)
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if self:ShouldLoadMoreItems() then
			self:LoadMoreCatalogItems()
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if self:ShouldLoadMoreItems() then
			self:LoadMoreCatalogItems()
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:RestartSearch()
			return
		end

		self:StopPreview()
		self:ClearList()
	end))
	self._Janitor:Add(self.avatarEditorMenu.editorSearchComponent.UserSearchOptionsChanged:Connect(function(...)
		if self.Instance.Visible then
			self:RestartSearch()
		end
	end))
	self._Janitor:Add(self.avatarEditorMenu.OnSubcategoryChanged:Connect(function()
		self:StopPreview()
	end))
	self._Janitor:Add(self.avatarEditorMenu.OnCategoryChanged:Connect(function()
		self:StopPreview()
	end))
	self._Janitor:Add(self.avatarEditorMenu.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.avatarEditorMenu.Instance.Visible then
			self:StopPreview()
			self:ClearList()
			self._abCatalogDefaultSort = nil
			self._abCatalogDefaultsApplied = false
			self.avatarEditorMenu.editorSearchComponent:ResetUserSearchOptions()
		end
	end))
end

function v:Stop()
	self:StopPreview()
	self._clickJanitor:Destroy()
	self._Janitor:Destroy()
end

return v