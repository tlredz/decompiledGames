local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local Shake = require(ReplicatedStorage.packages.Shake)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local identity = CFrame.identity
local v = {
	Swim = 81220533569725
}
local v2 = {
	Crevice = "Swim",
	Ascending = "Swim",
	City = "Swim",
	Descending = "Swim"
}
local v3 = {
	Swim = true
}

local function isJointedRig(folder)
	for _, motor6D in ipairs(folder:GetDescendants()) do
		if motor6D:IsA("Motor6D") then
			return true
		end
	end

	return false
end

local v4 = Component.new({
	Tag = "MonstrousCuskRender",
	Ancestors = { workspace }
})

function v4:Construct()
	self.trove = Trove.new()
	self.fish = nil
	self.tracks = {}
	self.currentTrack = nil
	self.lastHeadHits = 0
	self.lastBodyHits = 0
	self.loaded = false
	self.lastInRange = 0
end

function v4:getRoot()
	local root = self.Instance:FindFirstChild("Root")

	if root and root:IsA("BasePart") then
		return root
	end

	return nil
end

function v4:shakeCamera()
	if not SettingsController:GetSettingValue("cameraShake") then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local value = Enum.RenderPriority.Last.Value
	local v5 = Shake.new()
	v5.FadeInTime = 0.03
	v5.FadeOutTime = 0.18
	v5.Frequency = 0.1
	v5.Amplitude = 1.8
	v5.SustainTime = 0.39
	v5.Sustain = true
	v5.RotationInfluence = createVector(0.1, 0.1, 0.1)
	v5:Start()
	v5:BindToRenderStep(Shake.NextRenderName(), value, function(position, data)
		currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
	end)
	task.delay(0.6, function()
		v5:Stop()
		task.wait(1)
		v5:Destroy()
	end)
end

function v4:playImpact(childName: string)
	local root = self:getRoot()

	if not root then
		return
	end

	local sound = script:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = root.Position
		part.Parent = workspace
		local clone = sound:Clone()
		clone.Parent = part
		clone:Play()
		Debris:AddItem(part, 6)
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and (humanoidRootPart.Position - root.Position).Magnitude <= 200 then
		self:shakeCamera()
	end
end

function v4:playStateAnimation(p: string)
	local v5 = v2[p]

	if not v5 then
		return
	end

	local track = self.tracks[v5]

	if not track or track == self.currentTrack then
		return
	end

	if self.currentTrack then
		self.currentTrack:Stop(0.2)
	end

	self.currentTrack = track
	track:Play(0.2)
end

function v4:loadModel()
	local monstrousCusk = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild("Monstrous Cusk")

	if not monstrousCusk then
		warn("[MonstrousCuskRender] Model \"Monstrous Cusk\" not found in resources.replicated.instances.general")
		return
	end

	local clone = monstrousCusk:Clone()

	if not clone.PrimaryPart then
		local rootPart = clone:FindFirstChild("RootPart")

		if rootPart and rootPart:IsA("BasePart") then
			clone.PrimaryPart = rootPart
		end
	end

	local jointedRig = isJointedRig(clone)
	local primaryPart = clone.PrimaryPart

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false

		if jointedRig and primaryPart and part ~= primaryPart then
			part.Anchored = false
			part.Massless = true
		else
			part.Anchored = true
		end
	end

	local root = self:getRoot()

	if root then
		clone:PivotTo(root.CFrame * identity)
	end

	clone.Parent = workspace
	local animationController = clone:FindFirstChildOfClass("AnimationController") or self.trove:Add(Instance.new(
		"AnimationController",
		clone
	))
	local animator = animationController:FindFirstChildOfClass("Animator") or self.trove:Add(Instance.new(
		"Animator",
		animationController
	))

	for k, v5 in pairs(v) do
		if v5 == 0 then
			continue
		end

		local v6 = self.trove:Add(Instance.new("Animation", clone))
		v6.AnimationId = `rbxassetid://{v5}`
		local track = animator:LoadAnimation(v6)
		track.Looped = v3[k] == true
		self.tracks[k] = track
	end

	self.trove:Add(clone)
	self.fish = clone
end

function v4:Update()
	local root = self:getRoot()

	if not (root and self.fish) then
		return
	end

	self.fish:PivotTo(root.CFrame * identity)
end

function v4:onStateChanged()
	if not self.loaded then
		return
	end

	self:playStateAnimation(self.Instance:GetAttribute("CuskState") or "Crevice")
end

function v4:CheckDistance()
	local currentCamera = workspace.CurrentCamera
	local root = self:getRoot()

	if not (currentCamera and root) then
		return
	end

	if (self.Instance:GetAttribute("MaxRenderDistance") or 1024) > (currentCamera.CFrame.Position - root.Position).Magnitude then
		self.lastInRange = tick()

		if not self.loaded then
			self:Load()
		end
	elseif self.loaded and tick() - self.lastInRange >= 3 then
		self:Unload()
	end
end

function v4:Load()
	self.loaded = true
	self:loadModel()
	self:Update()
	self:onStateChanged()
	self.lastHeadHits = self.Instance:GetAttribute("CuskHeadHits") or 0
	self.lastBodyHits = self.Instance:GetAttribute("CuskBodyHits") or 0
	self.trove:Add(self.Instance:GetAttributeChangedSignal("CuskState"):Connect(function()
		self:onStateChanged()
	end))
	self.trove:Add(self.Instance:GetAttributeChangedSignal("CuskHeadHits"):Connect(function()
		local cuskHeadHits = self.Instance:GetAttribute("CuskHeadHits") or 0

		if self.lastHeadHits < cuskHeadHits then
			self.lastHeadHits = cuskHeadHits
			self:playImpact("headhit")
		end
	end))
	self.trove:Add(self.Instance:GetAttributeChangedSignal("CuskBodyHits"):Connect(function()
		local cuskBodyHits = self.Instance:GetAttribute("CuskBodyHits") or 0

		if self.lastBodyHits < cuskBodyHits then
			self.lastBodyHits = cuskBodyHits
			self:playImpact("bodyhit")
		end
	end))
	self.trove:Add(RunService.RenderStepped:Connect(function()
		self:Update()
	end))
end

function v4:Unload()
	self.loaded = false
	self.fish = nil
	self.currentTrack = nil
	table.clear(self.tracks)
	self.trove:Clean()
end

function v4:Start()
	self:CheckDistance()
end

function v4:Stop()
	self:Unload()
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v5 in v4:GetAll() do
		task.spawn(v4.CheckDistance, v5)
	end
end)
return v4