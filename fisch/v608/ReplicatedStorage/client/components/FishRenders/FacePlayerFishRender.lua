local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local assets = require(ReplicatedStorage.shared.utils.assets)
local cframe = CFrame.Angles(0, 0, 0)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "FacePlayerFishRender"
})

function v:Construct()
	self.rootTrove = Trove.new()
	self.animationTrove = self.rootTrove:Extend()
	self.bobHeight = 0.02
	self.bobSpeed = 0.25
	self.timeElapsed = 0
	self.baseCFrame = CFrame.identity
	self.currentCFrame = CFrame.identity
	self.loaded = false
	self.lastInRange = 0
end

function v:Load()
	self.loaded = true
	local fishName = self.Instance:GetAttribute("FishName")

	if not fishName then
		return
	end

	local useRenderAsset = self.Instance:GetAttribute("UseRenderAsset")
	local child

	if useRenderAsset then
		child = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild(fishName)
	else
		child = assets.getAsync("fish", fishName)
	end

	if not child then
		return
	end

	local clone = child:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
	end

	clone.Parent = workspace
	clone:ScaleTo(self.Instance:GetAttribute("ScaleIncrement") or 0.5)
	self.model = clone
	self.rootTrove:Add(clone)
	local splash = self.model:FindFirstChild("Splash", true)
	local smokeBreath = self.model:FindFirstChild("SmokeBreath", true)
	self.splashVFX = splash

	if splash then
		self.rootTrove:Add(splash)
	end

	if smokeBreath then
		self.rootTrove:Add(smokeBreath)
	end

	self.range = self.Instance:GetAttribute("Range") or 600
	self.originalPosition = self.Instance:GetPivot().Position
	local posOffset = self.Instance:GetAttribute("PosOffset")

	if posOffset then
		self.originalPosition += posOffset
	end

	self.trackInstance = self.Instance:GetAttribute("TrackInstance") == true
	local bobHeight = self.Instance:GetAttribute("BobHeight")
	local bobSpeed = self.Instance:GetAttribute("BobSpeed")

	if bobHeight then
		self.bobHeight = bobHeight
	end

	if bobSpeed then
		self.bobSpeed = bobSpeed
	end

	self.baseCFrame = CFrame.new(self.originalPosition)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character

	if character then
		local position = character:GetPivot().Position

		if (position - self.originalPosition).Magnitude < 600 then
			local vector = Vector3.new(position.X, self.originalPosition.Y, position.Z)
			self.currentCFrame = CFrame.new(self.originalPosition, vector)
		else
			self.currentCFrame = self.baseCFrame
		end
	else
		self.currentCFrame = self.baseCFrame
	end

	clone:PivotTo(self.currentCFrame)
	local idleAnimationID = self.Instance:GetAttribute("IdleAnimationID")
	local enterAnimationID = self.Instance:GetAttribute("EnterAnimationID")
	local exitAnimationID = self.Instance:GetAttribute("ExitAnimationID")

	if idleAnimationID or enterAnimationID or exitAnimationID then
		if not useRenderAsset then
			clone = clone:FindFirstChild("Fish")
		end

		local animationController = clone:FindFirstChildOfClass("AnimationController") or self.rootTrove:Add(Instance.new(
			"AnimationController",
			clone
		))
		self.animator = animationController:FindFirstChildOfClass("Animator") or self.rootTrove:Add(Instance.new(
			"Animator",
			animationController
		))
	end

	if idleAnimationID then
		self.idleAnimationInstance = self.rootTrove:Add(Instance.new("Animation", self.model))
		self.idleAnimationInstance.AnimationId = `rbxassetid://{idleAnimationID}`
		self.idleTrack = self.animator:LoadAnimation(self.idleAnimationInstance)
	end

	if enterAnimationID then
		self.enterAnimationInstance = self.rootTrove:Add(Instance.new("Animation", self.model))
		self.enterAnimationInstance.AnimationId = `rbxassetid://{enterAnimationID}`
		self.enterTrack = self.animator:LoadAnimation(self.enterAnimationInstance)
	end

	if exitAnimationID then
		self.exitAnimationInstance = self.rootTrove:Add(Instance.new("Animation", self.model))
		self.exitAnimationInstance.AnimationId = `rbxassetid://{exitAnimationID}`
		self.exitTrack = self.animator:LoadAnimation(self.exitAnimationInstance)
	end

	local primaryPart = self.model.PrimaryPart

	if not primaryPart then
		return
	end

	self.fishPrimaryPart = primaryPart
	self.model.PrimaryPart.Anchored = true
	self.tilt = self.Instance:GetAttribute("Tilt") or cframe

	if self.enterAnimationInstance then
		self.enterTrack.Looped = false
		self.animationTrove:Add(self.enterTrack, "Stop")
		self.enterTrack:Play()

		if splash then
			splash.Enabled = true
		end

		self.animationTrove:Add(self.enterTrack.Stopped:Once(function()
			if not self.idleTrack then
				return
			end

			self.idleTrack:Play()
			self.animationTrove:Add(self.idleTrack, "Stop")

			if self.Instance:GetAttribute("IdleAnimationSpeed") then
				self.idleTrack:AdjustSpeed(self.Instance:GetAttribute("IdleAnimationSpeed"))
			end

			if splash then
				splash.Enabled = false
			end
		end))
	elseif self.idleTrack then
		if not self.idleTrack then
			return
		end

		self.idleTrack:Play()
		self.animationTrove:Add(self.idleTrack, "Stop")

		if self.Instance:GetAttribute("IdleAnimationSpeed") then
			self.idleTrack:AdjustSpeed(self.Instance:GetAttribute("IdleAnimationSpeed"))
		end

		if splash then
			splash.Enabled = false
		end
	end

	if smokeBreath then
		smokeBreath.Enabled = true
	end

	self.animationTrove:Add(RunService.PreRender:Connect(function(dt: number)
		self:_IdleStep(dt)
	end))
end

function v:CheckDistance()
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

function v:Unload()
	self.loaded = false
	self.animationTrove:Clean()
	self.rootTrove:Clean()
	self.rootTrove:Add(self.animationTrove)
end

function v:Start()
	self:CheckDistance()
end

function v:Stop()
	self.animationTrove:Destroy()

	if self.splashVFX then
		self.splashVFX.Enabled = true
	end

	if self.exitAnimationInstance then
		self.exitTrack.Looped = false
		self.exitTrack:Play()
		self.rootTrove:Add(self.idleTrack, "Stop")
		self.exitTrack.Stopped:Wait()

		if self.splashVFX then
			self.splashVFX.Enabled = false
		end
	end

	self:Unload()
end

function v:_IdleStep(value: number)
	self.timeElapsed += value

	if self.trackInstance then
		local v2 = self.Instance:GetPivot().Position + Vector3.new(0, self.Instance:GetAttribute("FishYOffset") or 0, 0)

		if self.Instance:GetAttribute("PosOffset") then
			v2 += self.Instance:GetAttribute("PosOffset")
		end

		self.baseCFrame = CFrame.new(v2)
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local position = self.baseCFrame.Position
	local cframe2 = nil

	if character then
		local position2 = character:GetPivot().Position

		if (position2 - position).Magnitude < self.range then
			local vector = Vector3.new(position2.X, position.Y, position2.Z)
			cframe2 = CFrame.new(position, vector)
		end
	end

	if not cframe2 then
		local v2 = math.sin(self.timeElapsed * 1.5) * 0.017453292519943295
		cframe2 = self.baseCFrame * CFrame.Angles(0, v2, 0)
	end

	local v2 = math.clamp(value, 0, 0.5)
	self.currentCFrame = self.currentCFrame:Lerp(cframe2, v2)
	self.model:PivotTo(self.currentCFrame * CFrame.new(
		0,
		math.sin(self.timeElapsed * self.bobSpeed) * self.bobHeight,
		0
	))
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v2 in v:GetAll() do
		task.spawn(v.CheckDistance, v2)
	end

	now = tick()
end)
return v