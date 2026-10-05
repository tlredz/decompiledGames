local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local v = Component.new({
	Tag = "CharacterBodyList"
})
local v2 = false
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local CharacterBodyController = require(ReplicatedStorage.Modules.Client.AvatarEditor.CharacterBodyController)
local name = nil
local flag = false

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self.selectDebounce = false
	local CharacterBodyConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.CharacterBody.CharacterBodyConfig)
	v2 = CharacterBodyConfig
end

function v:Build(items)
	self._clickJanitor:Cleanup()

	for _, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = item.Name
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		local feminine = item.Feminine
		local child = clone:FindFirstChild(feminine and "FeminineSymbol" or "MaleSymbol")
		local child2 = clone:FindFirstChild(feminine and "MaleSymbol" or "FeminineSymbol")

		if child then
			child.Visible = true
		end

		if child2 then
			Debris:AddItem(child2, 0)
		end

		if name == clone.Name then
			UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, true)
		end

		local v4 = item

		local function onActivated()
			if self.selectDebounce then
				return
			end

			self.selectDebounce = true
			task.delay(0.5, function()
				self.selectDebounce = false
			end)

			if flag then
				return
			end

			flag = true
			name = clone.Name

			for i, button in self.Instance:GetChildren() do
				if button:IsA("ImageButton") then
					UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, button.Name == name)
				end
			end

			NotificationController.NotifyEditor("Please Wait...", 2)
			CharacterBodyController.ChangeCharacterBody(v4.CollectionIds)
			flag = false
		end

		clone.Parent = self.Instance
		self._clickJanitor:Add(clone.Activated:Connect(onActivated))
	end

	local absoluteContentSize = self.Instance:FindFirstChild("UIGridLayout").AbsoluteContentSize
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
end

function v:Destroy()
	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:Build(config)
		else
			self:Destroy()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v