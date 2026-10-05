local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Modules.Tool)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local CupidBow = {}
local arrow = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("CupidBow"):WaitForChild("Arrow")

function CupidBow:UpdateAllBeams(callback)
	for _, beam in self.BeamStart:GetChildren() do
		if beam:IsA("Beam") then
			callback(beam)
		end
	end
end

function CupidBow:SetArrowVisibility(enabled: boolean)
	for _, child in self.Tool.Arrow:GetChildren() do
		child.Transparency = enabled and 0 or 1
	end

	for _, emitter in self.Tool.Arrow:QueryDescendants("ParticleEmitter,Beam") do
		emitter.Enabled = enabled

		if emitter:IsA("ParticleEmitter") then
			emitter:Clear()
		end
	end

	self:FireEvent("Replicator", "ArrowVisbility", enabled)
end

function CupidBow:Update(_: number)
	local character = self.Character
	local humanoidRootPart = self.HumanoidRootPart

	if self.Tool.Parent ~= character or not (character.Parent and humanoidRootPart) then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local worldPosition = self.BeamStart.WorldPosition
	local value = self.Charge.Value
	local v = 40 + 160 * value
	local position

	if UI:GetDeviceType() == "VR" then
		local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
		local v2 = currentCamera.CFrame * userCFrame
		position = v2.Position + v2.LookVector * v
	elseif mouse and mouse.Hit then
		position = mouse.Hit.Position
	else
		position = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * v
	end

	if humanoidRootPart and currentCamera and not self.Humanoid.Sit and UI:GetDeviceType() ~= "VR" then
		local cframe = CFrame.lookAt(humanoidRootPart.Position, position)
		local vector = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)

		if vector.Magnitude > 0 then
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + vector)
		end
	end

	local v2 = position + Vector3.new(0, -((1 - value) * 50), 0) - worldPosition
	local v3 = math.max(0.1, v2.Magnitude)
	local unit = v2.Magnitude > 0 and v2.Unit or workspace.CurrentCamera.CFrame.LookVector
	local v4 = math.min(v3, v)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { character, workspace.Terrain }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastResult = workspace:Raycast(worldPosition, unit * v4, raycastParams)
	local position2 = raycastResult and raycastResult.Position or worldPosition + unit * v4
	self.BeamEnd.WorldPosition = position2
end

function CupidBow:HandleAnimations()
	local animationTracks = self.AnimationTracks
	local humanoidRootPart = self.HumanoidRootPart

	if not humanoidRootPart then
		return
	end

	local magnitude = humanoidRootPart.AssemblyLinearVelocity.Magnitude

	if self.Tool.Parent == self.Character and self.Humanoid:GetState() == Enum.HumanoidStateType.Running then
		if not animationTracks.Idle.IsPlaying then
			animationTracks.Idle:Play()
		end

		if magnitude <= 0.15 then
			if animationTracks.Walk.IsPlaying then
				animationTracks.Walk:AdjustSpeed(1)
				animationTracks.Walk:Stop()
			end
		else
			if not animationTracks.Walk.IsPlaying then
				animationTracks.Walk:Play()
			end

			animationTracks.Walk:AdjustSpeed(magnitude / self.Humanoid.WalkSpeed)
		end
	else
		animationTracks.Idle:Stop()
		animationTracks.Walk:Stop()
	end
end

function CupidBow:StartCharging()
	local animationTracks = self.AnimationTracks
	self:FireEvent("Replicator", "PlaySound", "Pull")
	self.Handle.Pull:Play()
	animationTracks.Charge:Play()
	animationTracks.Charging:Play()
	self.Charging = true
	self.ChargeTween:Cancel()
	self.Charge.Value = 0
	self.ChargeTween:Play()
	self.RenderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		self:Update(dt)
	end)
	self:UpdateAllBeams(function(p)
		p.Enabled = true
	end)
end

function CupidBow:StopCharging()
	local animationTracks = self.AnimationTracks
	animationTracks.Charge:Stop()
	animationTracks.Charging:Stop()
	self.Charging = false
	self.ChargeTween:Cancel()
	self.Charge.Value = 0

	if self.RenderSteppedConnection then
		self.RenderSteppedConnection:Disconnect()
		self.RenderSteppedConnection = nil
	end

	self:UpdateAllBeams(function(p)
		p.Enabled = false
	end)
	task.wait(2)
	self.ActivationCooldown = false
end

function CupidBow:DeactivateAndShoot()
	local distanceFromCharacter = localPlayer:DistanceFromCharacter(self.BeamEnd.WorldPosition)
	local worldPosition = self.BeamEnd.WorldPosition
	local cframe = CFrame.new(self.Handle.Position, worldPosition)
	local projectileAngle = (cframe - cframe.Position) * CFrame.Angles(0, 3.141592653589793, 0)
	local mouseLocation = worldPosition + Vector3.new(0, distanceFromCharacter / 25, 0)
	local v3 = {
		Projectile = arrow,
		Tool = self.Tool,
		Handle = self.Handle,
		Caster = localPlayer,
		MouseLocation = mouseLocation,
		ProjectileVelocity = self.Charge.Value * 225,
		DebrisTimer = 5,
		FadeDelay = 4,
		ProjectileAngle = projectileAngle
	}
	local folder = Instance.new("Folder")
	folder.Name = self.Tool.Name
	folder.Parent = ReplicatedStorage.Cooldowns[localPlayer.Name]
	game.Debris:AddItem(folder, 2)
	self.ActivationCooldown = true
	_G.DisplayCooldown(CupidBow, 2, folder)
	_G.ProjectileCast(v3)
	self:FireEvent("Replicator", "ReplicateProjectile", v3.MouseLocation, v3.ProjectileVelocity, v3.ProjectileAngle)
	self:FireEvent("Replicator", "PlaySound", "Release")
	self.Handle.Release:Play()
	self.AnimationTracks.Shoot:Play()
	task.delay(0.05, function()
		self:SetArrowVisibility(false)
		task.wait(0.5)
		self.AnimationTracks.Reload:Play()
		task.wait(0.7)
		self:SetArrowVisibility(true)
	end)
	self:StopCharging()
end

function CupidBow:OnActivated()
	if not self.ActivationCooldown then
		self:StartCharging()
	end
end

function CupidBow:OnDeactivated()
	if self.Charging then
		self:DeactivateAndShoot()
	end
end

function CupidBow:OnEquipped()
	self:StopCharging()
end

function CupidBow:OnUnequipped()
	self:StopCharging()
end

function CupidBow:Activated()
	if UI:GetDeviceType() == "PC" or UI:GetDeviceType() == "VR" then
		self:OnActivated()
	elseif self.Charging then
		self:DeactivateAndShoot()
	else
		self:OnActivated()
	end
end

function CupidBow:Deactivated()
	if UI:GetDeviceType() == "PC" or UI:GetDeviceType() == "VR" then
		self:OnDeactivated()
	end
end

local function reloadBowAnimationTracks(player)
	if not player.AnimationTracks then
		return
	end

	for _, animationTrack in player.AnimationTracks do
		animationTrack:Stop()
		animationTrack:Destroy()
	end

	table.clear(player.AnimationTracks)
	local animator = player.Humanoid:WaitForChild("Animator")

	for _, animation in ReplicatedStorage.Assets.Tools.CupidBow.Animations:GetChildren() do
		player.AnimationTracks[animation.Name] = animator:LoadAnimation(animation)
	end
end

function CupidBow:Initialize()
	self.Model = self.Tool:WaitForChild("Model")
	self.Handle = self.Model:WaitForChild("Cylinder.089")
	self.AnimationTracks = {}
	self.Charging = false
	self.ActivationCooldown = false
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Adornee = self.Character
	highlight.Parent = self.Tool
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "Charge"
	numberValue.Value = 0
	numberValue.Parent = self.Tool
	local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FillTransparency = 1
	})
	local tween2 = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Value = 1
	})
	self.Charge = numberValue
	self.ChargeTween = tween2
	self.HighlightTween = tween
	self.BeamEnd = self.Tool:WaitForChild("BeamEnd")
	self.BeamStart = self.Handle:WaitForChild("BeamStart")
	local clone = ReplicatedStorage.Assets.Tools.CupidBow.Pull:Clone()
	clone.Parent = self.Handle
	local clone_2 = ReplicatedStorage.Assets.Tools.CupidBow.Release:Clone()
	clone_2.Parent = self.Handle
	local serverPull = self.Handle:WaitForChild("ServerPull")
	serverPull.Volume = 0
	local serverRelease = self.Handle:WaitForChild("ServerRelease")
	serverRelease.Volume = 0
	reloadBowAnimationTracks(self)
	tween:GetPropertyChangedSignal("PlaybackState"):Connect(function()
		highlight.Enabled = tween.PlaybackState == Enum.PlaybackState.Playing
	end)
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		if numberValue.Value == 1 then
			tween:Cancel()
			highlight.FillTransparency = 0
			tween:Play()
		end
	end)
	self.Tool.Equipped:Connect(function()
		self:OnEquipped()
	end)
	self.Tool.Unequipped:Connect(function()
		self:OnUnequipped()
	end)
	self.Handle.ServerRelease.Volume = 0
	self.Handle.ServerPull.Volume = 0
	self:UpdateAllBeams(function(p)
		p.Attachment0 = self.BeamStart
		p.Attachment1 = self.BeamEnd
		p.Enabled = false
	end)

	local function onCharacterChanged(instance)
		self.Character = instance
		self.Humanoid = instance:WaitForChild("Humanoid")
		self.HumanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		local highlight2 = self.Tool:FindFirstChildOfClass("Highlight")

		if highlight2 then
			highlight2.Adornee = instance
		end

		reloadBowAnimationTracks(self)
	end

	self.CharacterAddedConn = localPlayer.CharacterAdded:Connect(onCharacterChanged)
	self.AnimationHeartbeat = RunService.Heartbeat:Connect(function()
		if not (self.Tool and self.Tool.Parent) then
			return
		end

		if self.Character and self.Character.Parent then
			self:HandleAnimations()
		end
	end)
end

function CupidBow:Destroyed()
	if self.CharacterAddedConn then
		self.CharacterAddedConn:Disconnect()
		self.CharacterAddedConn = nil
	end

	if self.RenderSteppedConnection then
		self.RenderSteppedConnection:Disconnect()
	end

	if self.AnimationHeartbeat then
		self.AnimationHeartbeat:Disconnect()
		self.AnimationHeartbeat = nil
	end

	for _, animationTrack in self.AnimationTracks do
		animationTrack:Stop()
		animationTrack:Destroy()
	end
end

return CupidBow