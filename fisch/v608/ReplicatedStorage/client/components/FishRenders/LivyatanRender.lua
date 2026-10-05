local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local Shake = require(ReplicatedStorage.packages.Shake)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local v = {
	Patrol = 136489609015596,
	DiveDown = 131569101654786,
	Slam = 113777068332041,
	DiveReturn = 80946535161221
}
local v2 = {
	Patrol = true,
	DiveReturn = true
}
local v3 = Component.new({
	Tag = "LivyatanRender",
	Ancestors = { workspace }
})

function v3:Construct()
	self.trove = Trove.new()
	self.fish = nil
	self.currentRotation = nil
	self.tracks = {}
	self.currentTrack = nil
	self.lastStrikeCount = 0
	self.loaded = false
	self.lastInRange = 0
end

function v3:shakeCamera()
	if not SettingsController:GetSettingValue("cameraShake") then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local value = Enum.RenderPriority.Last.Value
	local v4 = Shake.new()
	v4.FadeInTime = 0.05
	v4.FadeOutTime = 0.25
	v4.Frequency = 0.1
	v4.Amplitude = 2.5
	v4.SustainTime = 0.7
	v4.Sustain = true
	v4.RotationInfluence = createVector(0.1, 0.1, 0.1)
	v4:Start()
	v4:BindToRenderStep(Shake.NextRenderName(), value, function(position, data)
		currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
	end)
	task.delay(1, function()
		v4:Stop()
		task.wait(1)
		v4:Destroy()
	end)
end

function v3:playImpact()
	if not (self.fish and self.fish.PrimaryPart) then
		return
	end

	local position = self.fish.PrimaryPart.Position
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Parent = workspace
	local clone = script.crash:Clone()
	clone.Parent = part
	clone:Play()
	Debris:AddItem(part, 6)
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 250 then
		self:shakeCamera()
	end
end

function v3:playStateAnimation(p: string)
	local track = self.tracks[p]

	if not track or track == self.currentTrack then
		return
	end

	local v4 = p == "Slam" and 0 or 0.2

	if self.currentTrack then
		self.currentTrack:Stop(v4)
	end

	self.currentTrack = track
	track:Play(v4)
end

function v3:loadFish()
	local livyatan = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild("Livyatan")

	if not livyatan then
		return
	end

	local clone = livyatan:Clone()

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
	end

	clone.Parent = workspace
	local animationController = clone:FindFirstChildOfClass("AnimationController")
	local animator = animationController:FindFirstChildOfClass("Animator") or Instance.new(
		"Animator",
		animationController
	)

	for k, v4 in pairs(v) do
		local v5 = self.trove:Add(Instance.new("Animation", clone))
		v5.AnimationId = `rbxassetid://{v4}`
		local track = animator:LoadAnimation(v5)
		track.Looped = v2[k] == true
		self.tracks[k] = track
	end

	self.trove:Add(clone)
	self.fish = clone
end

function v3:updateFish(cframe2: CFrame, p: number, p2: number)
	if not (self.fish and self.fish.PrimaryPart) then
		return
	end

	local v4 = cframe2.Position + Vector3.new(0, p, 0)
	local v5 = v4 + cframe2.LookVector
	local currentRotation = CFrame.lookAt(v4, v5) - v4

	if self.currentRotation then
		self.currentRotation = self.currentRotation:Lerp(currentRotation, (math.clamp(p2 * 2, 0, 1)))
	else
		self.currentRotation = currentRotation
	end

	self.fish:SetPrimaryPartCFrame(CFrame.new(v4) * self.currentRotation * cframe)
end

function v3:Update(p: number)
	local instance = self.Instance

	if instance and instance.Parent then
		local fishYOffset = instance:GetAttribute("FishYOffset") or 0
		self:updateFish(instance.CFrame, fishYOffset, p)
	end
end

function v3:CheckDistance()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if (self.Instance:GetAttribute("MaxRenderDistance") or 1024) > (currentCamera.CFrame.Position - self.Instance.Position).Magnitude then
		self.lastInRange = tick()

		if not self.loaded then
			self:Load()
		end
	elseif self.loaded and tick() - self.lastInRange >= 3 then
		self:Unload()
	end
end

function v3:Load()
	self.loaded = true
	self:loadFish()
	self:playStateAnimation(self.Instance:GetAttribute("LivyatanState") or "Patrol")
	self.trove:Add(self.Instance:GetAttributeChangedSignal("LivyatanState"):Connect(function()
		self:playStateAnimation(self.Instance:GetAttribute("LivyatanState") or "Patrol")
	end))
	self.lastStrikeCount = self.Instance:GetAttribute("LivyatanStrikeCount") or 0
	self.trove:Add(self.Instance:GetAttributeChangedSignal("LivyatanStrikeCount"):Connect(function()
		local livyatanStrikeCount = self.Instance:GetAttribute("LivyatanStrikeCount") or 0

		if self.lastStrikeCount < livyatanStrikeCount then
			self.lastStrikeCount = livyatanStrikeCount
			self:playImpact()
		end
	end))
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		self:Update(dt)
	end))
end

function v3:Unload()
	self.loaded = false
	self.trove:Clean()
end

function v3:Start()
	self:CheckDistance()
end

function v3:Stop()
	self:Unload()
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v4 in v3:GetAll() do
		task.spawn(v3.CheckDistance, v4)
	end

	now = tick()
end)
return v3