game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local v = Component.new({
	Tag = "AnimationBundleList"
})
local v2 = false
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v.Refresh(p)
	p.Instance.Visible = false
	p.Instance.Visible = true
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self.selectDebounce = false
	self._Janitor:Add(WearingController.OnWearingUpdated:Connect(function(_)
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
	end))
	local AnimationsConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Animations.AnimationsConfig)
	v2 = AnimationsConfig
end

function v:PlayOneShot(value: string)
	if self.lastOneShotTrack ~= nil then
		self.lastOneShotTrack:Stop()
		self.lastOneShotTrack:Destroy()
		self.lastOneShotTrack = nil
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

	if not animator then
		return
	end

	local animate = character:FindFirstChild("Animate")

	if not animate then
		return
	end

	local animation1 = nil

	for _, child in animate:GetChildren() do
		if child.Name:lower() ~= value:lower() then
			continue
		end

		animation1 = child:FindFirstChild("Animation1") or child:FindFirstChildOfClass("Animation")
		break
	end

	if not animation1 then
		return
	end

	local track = animator:LoadAnimation(animation1)
	self.lastOneShotTrack = track
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()
	track.Stopped:Once(function()
		if self.lastOneShotTrack == track then
			self.lastOneShotTrack = nil
		end

		track:Destroy()
	end)
end

function v:ApplyControlItemVisualLayout(instance)
	local name = instance:FindFirstChild("Name")

	if name ~= nil then
		name:Destroy()
	end

	local icon = instance:FindFirstChild("Icon")

	if icon ~= nil and icon:IsA("GuiObject") then
		icon.AnchorPoint = Vector2.new(0, 0)
		icon.Position = UDim2.fromScale(0, 0)
		icon.Size = UDim2.fromScale(1, 1)

		if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
			icon.ScaleType = Enum.ScaleType.Fit
		end
	end
end

function v:Build(items, p: string)
	self._clickJanitor:Cleanup()

	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	for k, item in items do
		if not item[p] then
			continue
		end

		local clone = self.templateButton:Clone()
		clone.Name = k
		clone:SetAttribute("Id", item[p])
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. k .. "&w=150&h=150"
		self:ApplyControlItemVisualLayout(clone)
		UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(item[p]))
		local v3 = item

		local function onActivated()
			if self.selectDebounce then
				return
			end

			self.selectDebounce = true
			task.delay(0.5, function()
				self.selectDebounce = false
			end)
			WearingController.WearAsset(v3[p], nil, (tonumber(v3.bundleId)))
			self:PlayOneShot(p)
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
	self:ApplyControlItemVisualLayout(self.templateButton)
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			self:Destroy()
			return
		end

		self:Build(config, (self.Instance:GetAttribute("Subcategory")))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v