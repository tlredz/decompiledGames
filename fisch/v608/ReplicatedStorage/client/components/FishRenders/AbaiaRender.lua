local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local identity = CFrame.identity
local v = {
	Normal = "Abaia",
	Ancestral = "Ancestral Abaia",
	Fruity = "Fruity Abaia"
}
local v2 = {
	Swimming = 82574287814445,
	Chomp = 89932330712931,
	Idle = 119843671885213
}
local v3 = {
	Awakening = "Idle",
	Exiting = "Swimming",
	Surfacing = "Swimming",
	Waiting = "Idle",
	Escaping = "Swimming",
	Returning = "Swimming",
	Guarding = "Swimming"
}
local v4 = {
	Swimming = true,
	Idle = true
}
local v5 = Component.new({
	Tag = "AbaiaRender",
	Ancestors = { workspace }
})

function v5:Construct()
	self.trove = Trove.new()
	self.fish = nil
	self.modelName = nil
	self.currentRotation = nil
	self.tracks = {}
	self.currentTrack = nil
	self.chompActive = false
	self.lastProtection = nil
	self.loaded = false
	self.lastInRange = 0
end

function v5:getModelName()
	local abaiaVariant = self.Instance:GetAttribute("AbaiaVariant")

	if typeof(abaiaVariant) == "string" and v[abaiaVariant] then
		return v[abaiaVariant]
	end

	return "Abaia"
end

function v5:loadFish()
	local modelName = self:getModelName()
	local child = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild(modelName)

	if not child then
		warn((`[AbaiaRender] Model "{modelName}" not found`))
		return
	end

	local clone = child:Clone()

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
	local animationController = clone:FindFirstChildOfClass("AnimationController") or self.trove:Add(Instance.new(
		"AnimationController",
		clone
	))
	local animator = animationController:FindFirstChildOfClass("Animator") or self.trove:Add(Instance.new(
		"Animator",
		animationController
	))

	for k, v6 in pairs(v2) do
		local v7 = self.trove:Add(Instance.new("Animation", clone))
		v7.AnimationId = `rbxassetid://{v6}`
		local track = animator:LoadAnimation(v7)
		track.Looped = v4[k] == true
		self.tracks[k] = track
	end

	self.trove:Add(clone)
	self.fish = clone
	self.modelName = modelName
end

function v5:playStateAnimation(p: string)
	if self.chompActive then
		return
	end

	local v6 = v3[p]

	if not v6 then
		return
	end

	local track = self.tracks[v6]

	if not track or track == self.currentTrack then
		return
	end

	if self.currentTrack then
		self.currentTrack:Stop(0.2)
	end

	self.currentTrack = track
	track:Play(0.2)
end

function v5:playChomp()
	local chomp = self.tracks.Chomp

	if not chomp then
		return
	end

	if self.currentTrack then
		self.currentTrack:Stop(0.1)
	end

	self.chompActive = true
	self.currentTrack = chomp
	chomp:Play(0.1)
	task.delay(chomp.Length, function()
		if not self.loaded then
			return
		end

		self.chompActive = false
		self.currentTrack = nil
		self:playStateAnimation(self.Instance:GetAttribute("AbaiaState") or "Waiting")
	end)
end

function v5:updateFish(cframe: CFrame, p: number, p2: number)
	if not (self.fish and self.fish.PrimaryPart) then
		return
	end

	local v6 = cframe.Position + Vector3.new(0, p + 5, 0)
	local v7 = v6 + cframe.LookVector
	local currentRotation = CFrame.lookAt(v6, v7) - v6

	if self.currentRotation then
		self.currentRotation = self.currentRotation:Lerp(currentRotation, (math.clamp(p2 * 2, 0, 1)))
	else
		self.currentRotation = currentRotation
	end

	self.fish:SetPrimaryPartCFrame(CFrame.new(v6) * self.currentRotation * identity)
end

function v5:Update(p: number)
	local instance = self.Instance

	if instance and instance.Parent then
		local fishYOffset = instance:GetAttribute("FishYOffset") or 0
		self:updateFish(instance.CFrame, fishYOffset, p)
	end
end

function v5:CheckDistance()
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

function v5:Load()
	self.loaded = true
	self:loadFish()
	self:playStateAnimation(self.Instance:GetAttribute("AbaiaState") or "Awakening")
	self.trove:Add(self.Instance:GetAttributeChangedSignal("AbaiaState"):Connect(function()
		self:playStateAnimation(self.Instance:GetAttribute("AbaiaState") or "Awakening")
	end))
	self.trove:Add(self.Instance:GetAttributeChangedSignal("AbaiaVariant"):Connect(function()
		if self:getModelName() == self.modelName then
			return
		end

		task.defer(function()
			if not self.loaded then
				return
			end

			self:Unload()
			self:Load()
		end)
	end))
	self.lastProtection = self.Instance:GetAttribute("AbaiaProtection")
	self.trove:Add(self.Instance:GetAttributeChangedSignal("AbaiaProtection"):Connect(function()
		local abaiaProtection = self.Instance:GetAttribute("AbaiaProtection")

		if typeof(abaiaProtection) ~= "number" or not (self.lastProtection and abaiaProtection < self.lastProtection) then
			self.lastProtection = abaiaProtection
			return
		end

		self.lastProtection = abaiaProtection
		self:playChomp()
	end))
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		self:Update(dt)
	end))
end

function v5:Unload()
	self.loaded = false
	self.fish = nil
	self.modelName = nil
	self.currentTrack = nil
	self.chompActive = false
	self.currentRotation = nil
	table.clear(self.tracks)
	self.trove:Clean()
end

function v5:Start()
	self:CheckDistance()
end

function v5:Stop()
	self:Unload()
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v6 in v5:GetAll() do
		task.spawn(v5.CheckDistance, v6)
	end
end)
return v5