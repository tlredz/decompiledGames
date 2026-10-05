local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local GhostCharacter = require(ReplicatedStorage.Modules.Client.Components.CharacterEffects.GhostCharacter)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local LinearAnimationSequence = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.LinearAnimationSequence)
local v = Component.new({
	Tag = "DSLRCameraTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._scopeJanitor = Janitor.new()
	self.linearAnimationSequence = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"LinearAnimationSequence",
		LinearAnimationSequence
	)
end

local function map(p: number, p2: number, p3: number, p4: number, p5: number)
	return p4 + (p - p2) * (p5 - p4) / (p3 - p2)
end

function v:FirstPerson()
	self.zoomedInTargetFOV = 55

	if self.zoomedIn then
		return
	end

	local localPlayer = Players.LocalPlayer
	local currentCamera = workspace.CurrentCamera

	if not (localPlayer.Character and localPlayer.PlayerGui:FindFirstChild("ToolGui")) then
		return
	end

	local scope = self.Instance:FindFirstChild("Scope")

	if not scope then
		return
	end

	local zoomClient = self.Instance.Handle:FindFirstChild("ZoomClient")
	task.spawn(function()
		for _, v2 in GhostCharacter:GetAll() do
			if not (v2.Instance and v2.Instance ~= localPlayer.Character) then
				continue
			end

			v2:SetTransparency(0.5, true)
			v2:SetGhostEffectsState(true)
		end
	end)
	self.zoomedIn = true
	local clone = scope:Clone()
	self._scopeJanitor:Add(clone)
	clone.Parent = localPlayer.PlayerGui
	self.blur = Instance.new("BlurEffect")
	self._scopeJanitor:Add(self.blur)
	self.blur.Size = 0
	self.blur.Parent = workspace.CurrentCamera
	task.spawn(function()
		while self.zoomedIn do
			if self.blur.Size <= 0 then
				self.blur:GetPropertyChangedSignal("Size"):Wait()
			end

			while self.zoomedIn and self.blur.Size > 0 do
				local v2 = RunService.RenderStepped:Wait()
				self.blur.Size = math.clamp(self.blur.Size - 20 * v2, 0, 25)

				if zoomClient and zoomClient.Playing then
					zoomClient.PlaybackSpeed = (55 / self.zoomedInTargetFOV / 2 - 0.25) * 1 / 2.5 + 0.75
				end
			end
		end
	end)
	localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		FieldOfView = self.zoomedInTargetFOV
	}):Play()

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			if descendant.Transparency ~= 0 then
				descendant:SetAttribute("Transparency", descendant.Transparency)
			end

			descendant.Transparency = 1
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Transparency = NumberSequence.new(1)
		end
	end

	local _scopeJanitor = self._scopeJanitor
	local UserInputService = game:GetService("UserInputService")
	_scopeJanitor:Add(UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local zoomedInTargetFOV = math.clamp(self.zoomedInTargetFOV - input.Position.Z * 3, 10, 110)
			local v3 = math.abs(zoomedInTargetFOV - self.zoomedInTargetFOV)
			self.zoomedInTargetFOV = zoomedInTargetFOV
			TweenService:Create(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				FieldOfView = self.zoomedInTargetFOV
			}):Play()
			self.blur.Size += v3 * 0.6

			if zoomClient and v3 > 1 then
				zoomClient:Play()
			end
		end
	end))
	local _scopeJanitor2 = self._scopeJanitor
	local UserInputService2 = game:GetService("UserInputService")
	_scopeJanitor2:Add(UserInputService2.TouchPinch:Connect(function(_, p)
		self.zoomedInTargetFOV = math.clamp(self.zoomedInTargetFOV + (1 - p), 10, 110)
		currentCamera.FieldOfView = self.zoomedInTargetFOV
	end))
	self._scopeJanitor:Add(function()
		localPlayer.CameraMode = Enum.CameraMode.Classic
		TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			FieldOfView = 70
		}):Play()
		localPlayer.CameraMinZoomDistance = 10
		localPlayer.CameraMaxZoomDistance = 10
		localPlayer.CameraMinZoomDistance = 0.5
		localPlayer.CameraMaxZoomDistance = 128

		if self.Instance then
			for _, descendant in self.Instance:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Transparency = descendant:GetAttribute("Transparency") or 0
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Transparency = NumberSequence.new(0)
				end
			end
		end

		self.zoomedIn = false
	end)
end

function v:StopFirstPerson()
	self._scopeJanitor:Cleanup()
	task.spawn(function()
		for _, v2 in GhostCharacter:GetAll() do
			if not (v2.Instance and v2.Instance ~= Players.LocalPlayer.Character) then
				continue
			end

			v2:SetTransparency(1, true)
			v2:SetGhostEffectsState(false)
		end
	end)
end

function v:TakePhoto()
	if self.animationNum == 1 or not self.animationNum then
		return
	end

	local playerGui = Players.LocalPlayer.PlayerGui

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(1)
		elseif descendant:IsA("Sound") and descendant.Name ~= "Clone" and descendant.Name ~= "ZoomClient" then
			descendant.PlaybackSpeed = math.random(75, 125) / 100
			descendant:Play()
		end
	end

	local scope = playerGui:FindFirstChild("Scope")

	if not scope then
		return
	end

	local flash2D = scope.Frame:FindFirstChild("Flash2D")

	if not flash2D then
		return
	end

	local HUD = scope.Frame:FindFirstChild("HUD")

	if not HUD then
		return
	end

	local flashShutterEffect = scope.Frame:FindFirstChild("FlashShutterEffect")
	local clone = flash2D:Clone()
	clone.Name = "Flashing"
	clone.Visible = true
	clone.Parent = flash2D.Parent
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 1,
		Size = UDim2.new(0.25, 0, 0.25, 0),
		Rotation = math.random(-45, 45)
	}):Play()
	Debris:AddItem(clone, 0.5)
	TweenService:Create(HUD, TweenInfo.new(0.025, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageColor3 = Color3.fromRGB(200, 200, 200),
		Size = UDim2.new(0.9, 0, 0.9, 0)
	}):Play()
	task.delay(0.025, function()
		TweenService:Create(HUD, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	end)

	if self.camTween then
		self.camTween:Cancel()
	end

	if self.blur then
		self.blur.Size = math.max(self.blur.Size, 15)
	end

	if self.isEquipped then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.02, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				FieldOfView = self.zoomedInTargetFOV * 0.86
			}
		):Play()
	end

	RunService.RenderStepped:Wait()
	local shootSoundClient = self.Instance:FindFirstChild("ShootSoundClient", true)

	if shootSoundClient then
		task.delay(0.3 / shootSoundClient.PlaybackSpeed, function()
			if not self.isEquipped then
				return
			end

			self.camTween = TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.3 * shootSoundClient.PlaybackSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					FieldOfView = self.zoomedInTargetFOV
				}
			)
			self.camTween:Play()
		end)
	elseif self.isEquipped then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				FieldOfView = self.zoomedInTargetFOV
			}
		):Play()
	end

	if flashShutterEffect then
		local clone2 = flashShutterEffect:Clone()
		Debris:AddItem(clone2, 0.15)
		clone2.Parent = flashShutterEffect.Parent
		clone2.Visible = true
		TweenService:Create(clone2.Bottom, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 0)
		}):Play()
		TweenService:Create(clone2.Top, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 0)
		}):Play()
	end

	Lighting.ExposureCompensation = 1.25
	self.exposureTween = TweenService:Create(
		Lighting,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			ExposureCompensation = 0
		}
	)
	self.exposureTween:Play()
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local mouse = Players.LocalPlayer:GetMouse()
	local now = 0
	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		if self.Instance:GetAttribute("DisableCameraSnapshot") or tick() - now < 0.1 then
			return
		end

		now = tick()
		self:TakePhoto()
		Remotes.fireServerComponent(self.Instance, "TakePhoto", mouse.Hit.Position)
	end))
	self._equipJanitor:Add(self.Instance:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not self.Instance.Enabled then
			self.Instance.Enabled = true
		end
	end))
	self._equipJanitor:Add(self.linearAnimationSequence.OnAnimationNumberUpdated:Connect(function(animationNum: number)
		self.animationNum = animationNum
		Remotes.fireServerComponent(self.Instance, "CycledNextAnimation", animationNum)

		if animationNum == 3 then
			self:FirstPerson()
		else
			self:StopFirstPerson()
		end
	end))
end

function v.DescendantAdded(instance)
	if instance.Name:match("Client") then
		return
	end

	if instance:IsA("ParticleEmitter") or instance:IsA("Sound") then
		Debris:AddItem(instance, 0)
	end
end

function v:Start()
	local instance = self.Instance
	local localPlayer = Players.LocalPlayer

	if not (instance:IsDescendantOf(localPlayer.Backpack) or instance:IsDescendantOf(localPlayer.Character)) then
		return
	end

	for _, descendant in self.Instance:GetDescendants() do
		v.DescendantAdded(descendant)
	end

	self._Janitor:Add(self.Instance.DescendantAdded:Connect(v.DescendantAdded))
	local instance2 = self.Instance
	self._Janitor:Add(instance2.Equipped:Connect(function()
		self.isEquipped = true
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance2.Unequipped:Connect(function()
		self.isEquipped = false

		if self.camTween then
			self.camTween:Cancel()
		end

		workspace.CurrentCamera.FieldOfView = 70
		self._equipJanitor:Cleanup()
		self:StopFirstPerson()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
	self._scopeJanitor:Destroy()
end

return v