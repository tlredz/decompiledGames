local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local assets = require(ReplicatedStorage.shared.utils.assets)
local remoteEvent = Net:RemoteEvent("EvilFishTouched", -1)
local v = Component.new({
	Tag = "FishRender"
})
local v2 = {
	Frostwyrm = CFrame.new(
		21720.4688,
		50.3250008,
		4120.72363,
		0.997564554,
		0,
		0.0697564781,
		0,
		1,
		0,
		-0.0697564781,
		0,
		0.997564554
	),
	Rotbloom = CFrame.new(-2477.4, -318.051, -2388.312) * CFrame.Angles(0, -1.8657569703819383, 0),
	Witherbloom = CFrame.new(-2477.4, -318.051, -2388.312) * CFrame.Angles(0, -1.8657569703819383, 0),
	["Goliath Siphonophore"] = CFrame.new(870.3, -2611.376, 1609.037) * CFrame.Angles(0, 1.5707963267948966, 0)
}

function v:Construct()
	self.trove = Trove.new()
	self.angle = 0
	self.currentSpringVel = CFrame.identity
	self.speed = self.Instance:GetAttribute("Speed") or 0.5
	self.radius = self.Instance:GetAttribute("Radius") or 5
	self.animTrove = self.trove:Extend()
	self.loaded = false
	self.lastInRange = 0
end

function v:Load()
	self.loaded = true
	local fishName = self.Instance:GetAttribute("FishName")

	if not fishName then
		return
	end

	self.Invert = self.Instance:GetAttribute("Invert") or false
	local useRenderAsset = self.Instance:GetAttribute("UseRenderAsset")
	local child

	if useRenderAsset then
		child = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild(fishName)
	else
		child = assets.getAsync("fish", fishName)
	end

	if not child then
		error((`[FishRender] Could not find fish model "{fishName}"`))
	end

	local clone = child:Clone()
	clone.Parent = workspace
	clone:ScaleTo(clone:GetScale() + (self.Instance:GetAttribute("ScaleIncrement") or 0))
	local child2 = self.Instance:GetAttribute("TrailingModelName") and ReplicatedStorage.resources.replicated.instances.general:FindFirstChild(self.Instance:GetAttribute("TrailingModelName"))

	if child2 then
		local clone2 = child2:Clone()
		clone2:PivotTo(clone.PrimaryPart.CFrame * self.Instance:GetAttribute("TrailingOffset"))
		clone2.Parent = clone
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = self.Instance:GetAttribute("KillOnTouch")

		if self.Instance:GetAttribute("KillOnTouch") then
			self.trove:Add(part.Touched:Connect(function(otherPart)
				if otherPart.Parent and otherPart.Parent == Players.LocalPlayer.Character then
					remoteEvent:FireServer(self.Instance)
				end
			end))
		end
	end

	self.trove:Add(clone)
	local cframe

	if self.Instance:GetAttribute("UseCustomCFrame") == true and v2[fishName] then
		cframe = v2[fishName]
	else
		cframe = CFrame.new(
			self.Instance.Position.X,
			self.Instance.Position.Y + (self.Instance:GetAttribute("FishYOffset") or 0),
			self.Instance.Position.Z
		)
		local renderOffset = self.Instance:GetAttribute("RenderOffset")

		if typeof(renderOffset) == "CFrame" then
			cframe *= renderOffset
		end
	end

	clone:PivotTo(cframe)
	self.spawnCFrame = cframe
	self.model = clone
	local animationID = self.Instance:GetAttribute("AnimationID")

	if animationID then
		local fish = clone:FindFirstChild("Fish")
		local animationController = fish and fish:FindFirstChildOfClass("AnimationController") or clone:FindFirstChildOfClass("AnimationController") or self.trove:Add(Instance.new(
			"AnimationController",
			self.model
		))
		local animator = animationController:FindFirstChildOfClass("Animator") or self.trove:Add(Instance.new(
			"Animator",
			animationController
		))
		local v3 = self.trove:Add(Instance.new("Animation", self.model))
		v3.AnimationId = `rbxassetid://{animationID}`
		animator:LoadAnimation(v3):Play()
	end

	local idleAnimationID = self.Instance:GetAttribute("IdleAnimationID")
	local enterAnimationID = self.Instance:GetAttribute("EnterAnimationID")
	local exitAnimationID = self.Instance:GetAttribute("ExitAnimationID")

	if idleAnimationID or enterAnimationID or exitAnimationID then
		local fish

		if useRenderAsset then
			fish = clone
		else
			fish = clone:FindFirstChild("Fish")
		end

		local animationController = fish and fish:FindFirstChildOfClass("AnimationController") or clone:FindFirstChildOfClass("AnimationController") or self.trove:Add(Instance.new(
			"AnimationController",
			clone
		))
		local animator = animationController:FindFirstChildOfClass("Animator") or self.trove:Add(Instance.new(
			"Animator",
			animationController
		))

		if idleAnimationID then
			local v3 = self.trove:Add(Instance.new("Animation", clone))
			v3.AnimationId = `rbxassetid://{idleAnimationID}`
			self.idleTrack = animator:LoadAnimation(v3)
		end

		if enterAnimationID then
			local v3 = self.trove:Add(Instance.new("Animation", clone))
			v3.AnimationId = `rbxassetid://{enterAnimationID}`
			self.enterTrack = animator:LoadAnimation(v3)
		end

		if exitAnimationID then
			local v3 = self.trove:Add(Instance.new("Animation", clone))
			v3.AnimationId = `rbxassetid://{exitAnimationID}`
			self.exitTrack = animator:LoadAnimation(v3)
		end

		if self.enterTrack then
			self.enterTrack.Looped = false
			self.animTrove:Add(self.enterTrack, "Stop")
			self.enterTrack:Play()
			self.animTrove:Add(self.enterTrack.Stopped:Once(function()
				if self.idleTrack then
					self.idleTrack:Play()
					self.animTrove:Add(self.idleTrack, "Stop")
				end
			end))
		elseif self.idleTrack then
			self.idleTrack:Play()
			self.animTrove:Add(self.idleTrack, "Stop")
		end
	end

	local instance = self.Instance
	self.centerX = instance.Position.X
	self.centerZ = instance.Position.Z
	self.y = instance.Position.Y + (self.Instance:GetAttribute("FishYOffset") or 0)
	assert(self.model.PrimaryPart)
	self.model.PrimaryPart.Anchored = true

	if instance:GetAttribute("CancelMovement") then
		self.model:PivotTo(self.spawnCFrame)
	elseif instance:GetAttribute("TrackInstance") then
		self.trove:Add(RunService.RenderStepped:Connect(function(dt: number)
			self:UpdateTracking(dt)
		end))
	else
		self.trove:Add(RunService.RenderStepped:Connect(function(dt: number)
			self:UpdateMovement(dt)
		end))
	end
end

function v:Unload()
	self.loaded = false
	self.animTrove:Clean()
	self.trove:Clean()
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

function v:Start()
	self:CheckDistance()
end

function v:UpdateTracking(p: number)
	if not (self.model and self.model.PrimaryPart) then
		return
	end

	local instance = self.Instance
	local fishYOffset = instance:GetAttribute("FishYOffset") or 0
	local bobAmount = instance:GetAttribute("BobAmount") or 0
	local bobSpeed = instance:GetAttribute("BobSpeed") or 1
	local trackSmoothing = instance:GetAttribute("TrackSmoothing")
	local trackInstanceDirection = instance:GetAttribute("TrackInstanceDirection")
	self.angle += bobSpeed * p
	local v3 = math.sin(self.angle) * bobAmount
	local vector = Vector3.new(instance.Position.X, instance.Position.Y + fishYOffset + v3, instance.Position.Z)
	local cframe

	if trackInstanceDirection then
		cframe = CFrame.lookAlong(vector, instance.CFrame.LookVector)
	else
		cframe = CFrame.new(vector)
	end

	if not trackSmoothing then
		self.model:PivotTo(cframe)
		return
	end

	local smoothDamp, currentSpringVel = TweenService:SmoothDamp(
		self.model:GetPivot(),
		cframe,
		self.currentSpringVel,
		trackSmoothing,
		nil,
		p
	)
	self.currentSpringVel = currentSpringVel
	self.model:PivotTo(smoothDamp)
end

function v:UpdateMovement(p)
	if not (self.model and self.model.PrimaryPart) then
		return
	end

	self.angle += self.speed * p
	local v3 = self.centerX + self.radius * math.cos(self.angle)
	local v4 = self.centerZ + self.radius * math.sin(self.angle)
	local vector = Vector3.new(v3, self.y, v4)

	if vector ~= vector then
		return
	end

	local v5 = self.angle + self.speed * p
	local v6 = self.centerX + self.radius * math.cos(v5)
	local v7 = self.centerZ + self.radius * math.sin(v5)
	local vector2 = Vector3.new(v6, self.y, v7)

	if vector2 ~= vector2 then
		return
	end

	local model = self.model
	local cframe = CFrame.lookAt(vector, vector2)
	local v8

	if self.Invert then
		v8 = CFrame.Angles(0, 3.141592653589793, 0)
	else
		v8 = CFrame.Angles(0, 0, 0)
	end

	model:PivotTo(cframe * v8)
end

function v:Stop()
	self.animTrove:Destroy()

	if self.exitTrack then
		self.exitTrack.Looped = false
		self.exitTrack:Play()
		self.exitTrack.Stopped:Wait()
	end

	self:Unload()
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v3 in v:GetAll() do
		task.spawn(v.CheckDistance, v3)
	end

	now = tick()
end)
return v