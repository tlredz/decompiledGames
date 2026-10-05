local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "ClothesListStandard"
})
local v2 = false
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v:IsWearingOutfit(p: number, p2: number)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local appliedDescription = humanoid and humanoid:GetAppliedDescription()

	if not appliedDescription then
		return false
	end

	return tonumber(appliedDescription.Pants) == tonumber(p2) and tonumber(appliedDescription.Shirt) == tonumber(p)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._currentCategory = nil
	self._cachedButtons = {}
	self._scrollPositions = {}
	WearingController.OnWearingUpdated:Connect(function(_)
		if not self.Instance.Visible then
			return
		end

		for _, _cachedButton in self._cachedButtons do
			for _, v3 in _cachedButton do
				v3:GetAttribute("Id")

				if self._currentCategory == "Outfits" then
					UIAnimationEffects.SetVisibilityWithPopInOutFX(
						v3.SelectedIcon,
						self:IsWearingOutfit(v3:GetAttribute("ShirtId"), v3:GetAttribute("PantsId"))
					)
				else
					local id = v3:GetAttribute("Id")
					UIAnimationEffects.SetVisibilityWithPopInOutFX(v3.SelectedIcon, self:IsWearing(id))
				end
			end
		end
	end)
	local ClothesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Clothes.ClothesConfig)
	v2 = ClothesConfig
end

function v:ClearList()
	for k, _cachedButton in self._cachedButtons do
		for k2, v3 in _cachedButton do
			v3:Destroy()
			self._cachedButtons[k][k2] = nil
		end

		self._cachedButtons[k] = {}
	end
end

function v:Build(items, currentCategory: string)
	if self._currentCategory then
		self._scrollPositions[self._currentCategory] = self.Instance.CanvasPosition
	end

	self:ClearList()
	self._currentCategory = currentCategory
	self._cachedButtons[currentCategory] = {}
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	uIGridLayout.Parent = nil

	if currentCategory == "Outfits" then
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIGridLayout.CellSize = UDim2.new(0.323, 0, 1, 0)
	else
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIGridLayout.CellSize = UDim2.new(0.24, 0, 1, 0)
	end

	uIGridLayout.CellPadding = UDim2.new(0.01, 0, 0, 0)

	for k, item in items do
		if not (item and item.Id and item.Id ~= "") then
			continue
		end

		local clone = self.templateButton:Clone()
		clone.Name = string.format("%08d_%s", k, item.Name)

		if currentCategory == "Outfits" then
			clone:SetAttribute("ShirtId", item.ShirtId)
			clone:SetAttribute("PantsId", item.PantsId)
			UIAnimationEffects.SetVisibilityWithPopInOutFX(
				clone.SelectedIcon,
				self:IsWearingOutfit(item.ShirtId, item.PantsId)
			)
		else
			clone:SetAttribute("Id", item.Id)
			UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(item.Id))
		end

		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		clone.LayoutOrder = k

		if item.RPButton then
			clone.RP.Visible = true
		end

		local v3 = item
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if currentCategory == "Outfits" then
				WearingController.WearOutfit(v3.ShirtId, v3.PantsId, v3.Accessories)
			elseif currentCategory:lower():match("pant") then
				WearingController.WearPants(v3.Id)
			elseif currentCategory:lower():match("shirt") then
				WearingController.WearShirt(v3.Id)
			else
				WearingController.WearAsset(v3.Id, true)
			end
		end))
		clone.Parent = self.Instance
		self._cachedButtons[currentCategory][k] = clone
	end

	uIGridLayout.Parent = self.Instance
	self.Instance.CanvasPosition = self._scrollPositions[currentCategory] or Vector2.new(0, 0)
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	self.Instance:RemoveTag("AutoSizeY")
	local config = v2.getConfig()
	self.uiGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			self:ClearList()
			return
		end

		local subcategory = self.Instance:GetAttribute("Subcategory")

		if config[subcategory] then
			self:Build(config[subcategory], subcategory)
		else
			warn("Subcategory " .. subcategory .. " not found in config")
		end
	end))
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	self._Janitor:Add(waitForAncestorComponent.OnVisibleChanged:Connect(function(p)
		if not p then
			self:ClearList()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v