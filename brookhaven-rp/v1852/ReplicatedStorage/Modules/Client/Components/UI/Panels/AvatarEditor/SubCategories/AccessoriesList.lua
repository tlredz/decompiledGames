local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "AccessoriesList"
})
local v2 = false

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._loadingBatch = false
	self._currentIndex = 1
	self._itemsToLoad = {}
	self._loadedItems = {}
	self._currentCategory = nil
	WearingController.OnWearingUpdated:Connect(function(_)
		if not self.Instance.Visible then
			return
		end

		for _, button in self.Instance:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local id = button:GetAttribute("Id")
			UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, self:IsWearing(id))
		end
	end)
	local AccessoriesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Accessories.AccessoriesConfig)
	v2 = AccessoriesConfig
end

function v:ClearList()
	self._itemsToLoad = {}
	self._currentIndex = 1
	self._loadingBatch = false
	self._loadedItems = {}
	self._currentCategory = nil

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

function v:LoadNextBatch()
	if self._loadingBatch or not self.Instance.Visible or self._currentIndex > #self._itemsToLoad then
		return
	end

	local _currentCategory = self._currentCategory
	self._loadingBatch = true
	local v3 = math.min(self._currentIndex + 60 - 1, #self._itemsToLoad)

	for i = self._currentIndex, v3 do
		if _currentCategory ~= self._currentCategory then
			self._loadingBatch = false
			return
		end

		if not self.Instance.Visible then
			self._loadingBatch = false
			return
		end

		local v4 = self._itemsToLoad[i]

		if not v4 or self._loadedItems[v4.Id] then
			continue
		end

		self._loadedItems[v4.Id] = true
		local clone = self.templateButton:Clone()
		clone.Name = string.format("%08d_%s", i, v4.Name)
		clone:SetAttribute("Id", v4.Id)
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. v4.Id .. "&w=150&h=150"
		clone.LayoutOrder = i

		if v4.Premium then
			clone.PremiumMesh.Visible = true
		end

		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(v4.Id))
		clone.Parent = self.Instance
		local v5 = v4
		self._clickJanitor:Add(clone.Activated:Connect(function()
			WearingController.WearAsset(v5.Id, true)
		end))
		task.wait(0.01)
	end

	if _currentCategory == self._currentCategory then
		self._currentIndex = v3 + 1
	end

	self._loadingBatch = false
end

function v:Build(itemsToLoad, currentCategory: string)
	self:ClearList()
	self._itemsToLoad = itemsToLoad
	self._currentIndex = 1
	self._currentCategory = currentCategory
	self:LoadNextBatch()
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if self:ShouldLoadMoreItems() then
			self:LoadNextBatch()
		end
	end))
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
		"AvatarEditorMenu_OLD",
		AvatarEditorMenu
	)

	if not waitForAncestorComponent then
		return
	end

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