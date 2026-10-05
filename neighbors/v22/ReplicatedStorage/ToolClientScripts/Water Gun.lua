local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Tool)
local waterGun = ReplicatedStorage.Assets.Tools.WaterGun
local parents = {}
local _ = {
	DrainDuration = 6
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isMobile()
	return UserInputService:GetLastInputType() == Enum.UserInputType.Touch
end

local WaterGun = {}

function WaterGun:UpdateVisuals()
	self.Tool.WaterGun["Cylinder.008"].Transparency = 1 - 0.3 * (self.Tank / 100)
	self.Gui.WaterLeft.Bar.UIGradient.Offset = Vector2.new(-(0.5 - self.Tank / 100), 0)

	for _, v in self.Tool.WaterGun["Cylinder.007"]:QueryDescendants("ParticleEmitter,Beam") do
		if not self.OriginalTransparencyCache[v] then
			self.OriginalTransparencyCache[v] = v.Transparency
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in self.OriginalTransparencyCache[v].Keypoints do
			local value = keypoint.Value
			local v2 = math.clamp(value + (1 - value) * (1 - self.Tank / 100), 0, 1)
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v2))
		end

		v.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end
end

function WaterGun:HandleAnimations()
	local humanoidRootPart = self.HumanoidRootPart
	local character = self.Character

	if not (humanoidRootPart and character) then
		return
	end

	local humanoid = self.Humanoid
	local magnitude = humanoidRootPart.AssemblyLinearVelocity.Magnitude

	if self.Tool.Parent == character and humanoid:GetState() == Enum.HumanoidStateType.Running then
		if not self.AnimationTracks.Idle.IsPlaying then
			self.AnimationTracks.Idle:Play()
		end

		if magnitude <= 0.15 then
			if self.AnimationTracks.Walk.IsPlaying then
				self.AnimationTracks.Walk:AdjustSpeed(1)
				self.AnimationTracks.Walk:Stop()
			end
		else
			if not self.AnimationTracks.Walk.IsPlaying then
				self.AnimationTracks.Walk:Play()
			end

			self.AnimationTracks.Walk:AdjustSpeed(magnitude / humanoid.WalkSpeed)
		end
	else
		self.AnimationTracks.Idle:Stop()
		self.AnimationTracks.Walk:Stop()
	end
end

function WaterGun:Hitbox()
	local humanoidRootPart = self.HumanoidRootPart
	local character = self.Character

	if not (humanoidRootPart and character) then
		return
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = { character }
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -7.5)
	local partBoundsInBox = workspace:GetPartBoundsInBox(v, createVector(4.5, 7.5, 7.5), overlapParams)

	for _, v2 in partBoundsInBox do
		if not (v2.Name == "HumanoidRootPart" or v2.Name == "Root") then
			continue
		end

		local parent = v2.Parent
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if not (v2.Name ~= "HumanoidRootPart" or playerFromCharacter and not table.find(parents, parent)) then
			continue
		end

		table.insert(parents, parent)
		local parent2 = parent
		task.delay(0.1, function()
			table.remove(parents, table.find(parents, parent2))
		end)

		if v2.Name == "HumanoidRootPart" then
			self:FireEvent("Hit", parent)
		else
			self:FireEvent("Hit", "Grill")
		end
	end
end

function WaterGun:EnableStream()
	if self.Firing or self.Tank <= 0 or os.clock() - self.Debounce <= 0.5 then
		return
	end

	for _, v in self.Tool.WaterGun["Cylinder.009"]:QueryDescendants("ParticleEmitter") do
		v.Enabled = true
	end

	self:FireEvent("Stream", true)
	self.Debounce = os.clock()
	self.AnimationTracks.Shoot:Play()
	self.Firing = true
	task.spawn(function()
		while self.Firing do
			local v = RunService.Heartbeat:Wait()
			self:UpdateVisuals()

			if os.clock() - self.Debounce >= 0.25 then
				self.Tank = math.max(self.Tank - 16.666666666666668 * v, 0)
				self:Hitbox()
			end

			if not (self.Tank <= 0) then
				continue
			end

			self:DisableStream()
			self:Reload()
			break
		end
	end)
end

function WaterGun:Reload()
	local number = Random.new():NextNumber(2, 4)
	TweenService:Create(self.Gui.WaterLeft.Bar.UIGradient, TweenInfo.new(number, Enum.EasingStyle.Linear), {
		Offset = Vector2.new(0.5, 0)
	}):Play()
	task.delay(number, function()
		self.Tank = 100
		self:UpdateVisuals()
	end)
end

function WaterGun:DisableStream()
	if not self.Firing then
		return
	end

	for _, v in self.Tool.WaterGun["Cylinder.009"]:QueryDescendants("ParticleEmitter") do
		v.Enabled = false
	end

	self:FireEvent("Stream", false)
	self.AnimationTracks.Shoot:Stop(0.5)
	self.Firing = false
end

function WaterGun:ShowGui()
	self.Gui.Parent = Players.LocalPlayer.PlayerGui
end

function WaterGun:HideGui()
	self.Gui.Parent = script
end

function WaterGun:Activated()
	if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
		self:EnableStream()
	elseif self.Firing then
		self:DisableStream()
	else
		self:EnableStream()
	end
end

function WaterGun:Deactivated()
	if isMobile() then
		return
	end

	self:DisableStream()
end

function WaterGun:Equipped()
	self:ShowGui()
	self:DisableStream()
end

function WaterGun:Unequipped()
	self:HideGui()
	self:DisableStream()
end

function WaterGun:Initialize()
	local animator = self.Humanoid:WaitForChild("Animator")
	local track = animator:LoadAnimation(waterGun:WaitForChild("Shoot"))
	local track2 = animator:LoadAnimation(waterGun:WaitForChild("Idle"))
	local track3 = animator:LoadAnimation(waterGun:WaitForChild("Walk"))
	self.OriginalTransparencyCache = {}
	self.Firing = false
	self.Tank = 100
	self.AnimationTracks = {
		Shoot = track,
		Idle = track2,
		Walk = track3
	}
	self.Debounce = os.clock()
	self.Gui = script.WaterLeft:Clone()
	task.spawn(function()
		while self.Tool and self.Tool.Parent do
			self:HandleAnimations()
			task.wait(0.05)
		end
	end)
end

function WaterGun.Destroyed(p)
	p.Gui:Destroy()

	for _, animationTrack in p.AnimationTracks do
		animationTrack:Stop()
	end
end

return WaterGun