local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FaceListStandard"
})
local v2 = false
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._lastScrollPosition = Vector2.new(0, 0)
	self._cachedButtons = {}
	WearingController.OnWearingUpdated:Connect(function(_)
		if not self.Instance.Visible then
			return
		end

		for _, _cachedButton in self._cachedButtons do
			local id = _cachedButton:GetAttribute("Id")
			UIAnimationEffects.SetVisibilityWithPopInOutFX(_cachedButton.SelectedIcon, self:IsWearing(id))
		end
	end)
	local FacesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Faces.FacesConfig)
	v2 = FacesConfig
end

function v:ClearList()
	for k, _cachedButton in self._cachedButtons do
		_cachedButton:Destroy()
		self._cachedButtons[k] = nil
	end

	self._cachedButtons = {}
end

function v:Build(items)
	self._lastScrollPosition = self.Instance.CanvasPosition
	self:ClearList()
	self.uiGridLayout.Parent = nil

	for k, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = string.format("%08d_%s", k, item.Id)
		clone:SetAttribute("Id", item.Id)
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		clone.LayoutOrder = k

		if item.FacePass then
			clone.FacePassMesh.Visible = true
		end

		local v3 = item
		self._clickJanitor:Add(clone.Activated:Connect(function()
			WearingController.WearAsset(v3.Id)
		end))
		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(item.Id))
		clone.Parent = self.Instance
		self._cachedButtons[k] = clone
	end

	self.uiGridLayout.Parent = self.Instance
	self.Instance.CanvasPosition = self._lastScrollPosition
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
		if self.Instance.Visible then
			self:Build(config)
			return
		end

		self._lastScrollPosition = self.Instance.CanvasPosition
		self:ClearList()
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