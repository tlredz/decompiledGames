local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "AccessoriesListStandard"
})
local v2 = false

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
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
				local id = v3:GetAttribute("Id")
				UIAnimationEffects.SetVisibilityWithPopInOutFX(v3.SelectedIcon, self:IsWearing(id))
			end
		end
	end)
	local AccessoriesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Accessories.AccessoriesConfig)
	v2 = AccessoriesConfig
end

function v:ClearList()
	for k, _cachedButton in pairs(self._cachedButtons) do
		for k2, v3 in pairs(_cachedButton) do
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
	self.uiGridLayout.Parent = nil

	for k, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = string.format("%08d_%s", k, item.Name)
		clone:SetAttribute("Id", item.Id)
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		clone.LayoutOrder = k

		if item.Premium then
			clone.PremiumMesh.Visible = true
		end

		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(item.Id))
		local v3 = item
		self._clickJanitor:Add(clone.Activated:Connect(function()
			WearingController.WearAsset(v3.Id, true)
		end))
		clone.Parent = self.Instance
		self._cachedButtons[currentCategory][k] = clone
	end

	self.uiGridLayout.Parent = self.Instance
	self.Instance.CanvasPosition = self._scrollPositions[currentCategory] or Vector2.new(0, 0)
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.uiGridLayout.AbsoluteContentSize.Y)
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	self.Instance:RemoveTag("AutoSizeY")
	local config = v2.getConfig()
	self.uiGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self.uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
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