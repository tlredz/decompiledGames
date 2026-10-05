local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CharacterBodyController = require(ReplicatedStorage.Modules.Client.AvatarEditor.CharacterBodyController)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local v = Component.new({
	Tag = "SkinToneList"
})
local v2 = false
local name = nil

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._lastScrollPosition = Vector2.new(0, 0)
	self._isFirstLoad = true
	local SkinTonesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.SkinTones.SkinTonesConfig)
	v2 = SkinTonesConfig
end

function v:Build(items)
	if not self._isFirstLoad then
		self.Instance.CanvasPosition = self._lastScrollPosition
		return
	end

	for _, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = item.ColorName
		clone.Icon.Image = "rbxasset://textures/whiteCircle.png"

		if item.Premium then
			clone.PremiumMesh.Visible = true
		end

		local match, v3, v4 = item.Color:match("Color3%.fromRGB%((%d+),%s*(%d+),%s*(%d+)%)")
		clone.Icon.ImageColor3 = Color3.fromRGB(match, v3, v4)

		if name == clone.Name then
			UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, true)
		end

		local v6 = item

		local function onActivated()
			name = clone.Name

			for i, button in self.Instance:GetChildren() do
				if button:IsA("ImageButton") then
					UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, button.Name == name)
				end
			end

			CharacterBodyController.ChangeBodyColor(v6.ColorName)
		end

		clone.LayoutOrder = tonumber(item.LayoutOrder)
		clone.Parent = self.Instance
		self._clickJanitor:Add(clone.Activated:Connect(onActivated))
	end

	local uIGridLayout = self.Instance.UIGridLayout
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local absoluteContentSize = uIGridLayout.AbsoluteContentSize
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
	self.Instance.CanvasPosition = self._lastScrollPosition
	self._isFirstLoad = false
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:Build(config)
		else
			self._lastScrollPosition = self.Instance.CanvasPosition
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v