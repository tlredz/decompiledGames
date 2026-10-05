local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "ShowcasedContentList"
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
	local ShowcasedContentConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Showcased.ShowcasedContentConfig)
	v2 = ShowcasedContentConfig
end

function v:ClearList()
	self._itemsToLoad = {}
	self._currentIndex = 1
	self._loadingBatch = false
	self._loadedItems = {}

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

	self._loadingBatch = true
	local v3 = math.min(self._currentIndex + 60 - 1, #self._itemsToLoad)

	for i = self._currentIndex, v3 do
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
		local thumbnailImage = "rbxthumb://type=Asset&id=" .. v4.Id .. "&w=150&h=150"

		if v4.ThumbnailImage then
			thumbnailImage = v4.ThumbnailImage
		end

		clone.Icon.Image = thumbnailImage
		clone.LayoutOrder = i
		local frame = Instance.new("Frame")
		frame.Name = "ShowcasedItemCatBorder"
		frame.Parent = clone
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.new(1, -12, 1, -12)
		frame.BackgroundTransparency = 1
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Parent = frame
		uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		uIStroke.LineJoinMode = Enum.LineJoinMode.Miter
		uIStroke.Thickness = 0.025
		uIStroke.Color = Color3.fromRGB(255, 255, 0)

		if v4.CornerIconData then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "CornerIcon"
			imageLabel.Image = v4.CornerIconData.Image
			local size

			if v4.CornerIconData.Size then
				size = UDim2.new(
					v4.CornerIconData.Size.X.Scale,
					v4.CornerIconData.Size.X.Offset,
					v4.CornerIconData.Size.Y.Scale,
					v4.CornerIconData.Size.Y.Offset
				)
			else
				size = UDim2.new(0.25, 0, 0.25, 0)
			end

			imageLabel.Size = size
			imageLabel.BackgroundTransparency = 1
			local position

			if v4.CornerIconData.Position then
				position = UDim2.new(
					v4.CornerIconData.Position.X.Scale,
					v4.CornerIconData.Position.X.Offset,
					v4.CornerIconData.Position.Y.Scale,
					v4.CornerIconData.Position.Y.Offset
				)
			else
				position = UDim2.new(0, 0, 1 - imageLabel.Size.Y.Scale, 0)
			end

			imageLabel.Position = position
			imageLabel.Parent = clone
		end

		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(v4.Id))
		clone.Parent = self.Instance
		local v5 = v4
		self._clickJanitor:Add(clone.Activated:Connect(function()
			WearingController.WearAsset(v5.Id, true)
		end))
		task.wait(0.01)
	end

	self._currentIndex = v3 + 1
end

function v:Build(itemsToLoad)
	self:ClearList()
	self._itemsToLoad = itemsToLoad
	self._currentIndex = 1
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
		if self.Instance.Visible then
			self:Build(config, "ShowcasedContent")
		else
			self:ClearList()
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