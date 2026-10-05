local createVector = vector.create
local Bobber = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	Gui = nil,
	Bar = nil,
	CastStrength = 0,
	state = nil
}
Bobber.__index = Bobber
local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace
local Config = require(script.Parent.Parent.Config)
Config = Config.WATER_BODY_TAG
Bobber.BobberStateEnum = {
	Bobbing = 1,
	Snagged = 2
}
local Config2 = require(script.Parent.Parent.Config)
local rod = Config2.Rod
local RunService = game:GetService("RunService")
local FishingPosition = require(script.Parent.Parent.Parent.FishingPosition)
local Anims = require(game.ReplicatedStorage.Util.Anims)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function blocksBobberMovement(instance, ancestor)
	return instance ~= nil and not (ancestor and instance:IsDescendantOf(ancestor) or instance:HasTag("WaterBody")) and instance.Name ~= "WaterBase-Plane"
end

function Bobber:GetSounds()
	return (self.__components:Get("Sounds"))
end

function Bobber:isBoatFishing()
	return self.BobberPosition ~= nil and FishingPosition.hasBoat(self.BobberPosition)
end

function Bobber:getBobberWorldPosition()
	return FishingPosition.getWorldPosition(self.BobberPosition)
end

function Bobber:getMovementAxis()
	if not self.MovementAxis then
		return nil
	end

	local boat = FishingPosition.getBoat(self.BobberPosition)

	if boat and self.MovementAxisLocal then
		return boat:GetPivot():ToWorldSpace(self.MovementAxisLocal)
	end

	return self.MovementAxis
end

function Bobber:getCurrentTargetPosition()
	if not self.CurrentTargetPos then
		return nil
	end

	local boat = FishingPosition.getBoat(self.BobberPosition)

	if boat and self.CurrentTargetLocalPosition then
		local pointToWorldSpace = boat:GetPivot():PointToWorldSpace(self.CurrentTargetLocalPosition)
		return (Vector3.new(pointToWorldSpace.X, self.TargetPos.Y, pointToWorldSpace.Z))
	else
		return self.CurrentTargetPos
	end
end

function Bobber:setOwnerAnchored(anchored: boolean)
	if self.observer or self:isBoatFishing() then
		return
	end

	local character = self.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		humanoidRootPart.Anchored = anchored
	end
end

function Bobber.PlayChestBobberVFX(p)
	local Effect = require(game.ReplicatedStorage.Effect)
	Effect.new("Chests.Despawn"):play({
		CFrame = p.instance.PrimaryPart.CFrame
	})
end

function Bobber:getRopeLength(data, flag: boolean)
	local v

	if self.playing then
		v = false
	else
		v = self.SlackTime and self.SlackTime < tick() and true or flag
	end

	local v2 = math.clamp(
		math.ceil((data.Attachment0.WorldPosition - data.Attachment1.WorldPosition).Magnitude * 1000) / 1000 + 0.5,
		0.1,
		rod.MaxLaunchDistance + 20 + 0.25
	)
	local currentDistance = data.CurrentDistance
	local v3 = math.clamp(tick() - (self.SlackTime or 1e999), 0, 1)
	local selected = currentDistance + (v2 - currentDistance) * v3

	if not v then
		selected = math.min(data.CurrentDistance, selected, data.Length)
	end

	self.Rod:SetAttribute("Tension", data.CurrentDistance / selected)
	self:updateRopeAttachPos(v)
	return selected
end

function Bobber:tweenBobberArc(part, p2, p3, p4)
	assert(part and part:IsA("BasePart"), "Bad bobber")
	assert(p3 > 0, "Duration must be positive")
	local v = FishingPosition.new(part.Position, FishingPosition.getBoat(p2))
	local total = 0

	while self.state and self.state.isThrowing or self.observer do
		total += task.wait()
		local v2 = math.clamp(total / p3, 0, 1)
		local lerped = FishingPosition.getReferenceWorldPosition(v):Lerp(
			FishingPosition.getWorldPosition(p2) + createVector(0, 0.1, 0),
			v2
		)
		local v3 = math.sin(3.141592653589793 * v2) * p4
		part.CFrame = CFrame.new((Vector3.new(lerped.X, lerped.Y + v3, lerped.Z)))

		if v2 >= 1 then
			break
		end
	end
end

function Bobber:SetupRod(rod2)
	local Spring = require(game.ReplicatedStorage.Packages.Spring)
	self.BobberSpring = Spring.new(0.25, 1, 0)
	local Spring2 = require(game.ReplicatedStorage.Packages.Spring)
	self.BobberRotationXSpring = Spring2.new(0.25, 1, 0)
	local Spring3 = require(game.ReplicatedStorage.Packages.Spring)
	self.BobberRotationYSpring = Spring3.new(0.25, 1, 0)
	self.Rod = rod2
	self.BobberOffset = createVector(0, 0, 0)
end

function Bobber:updateRopeAttachPos(p2)
	if p2 then
		return
	end

	self.attach.Position = createVector(0, 0, 0)
end

function Bobber:onDestroy() end

function Bobber.makeBobber(_) end

local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)

function Bobber:launch(parent, p, flag: boolean, flag2: boolean, flag3: boolean)
	self.BobberPosition = FishingPosition.fromValue(p)
	local bobberWorldPosition = self:getBobberWorldPosition()
	self.__maid:GiveTask(parent.AncestryChanged:Connect(function(_, _)
		self.__maid:Destroy()
	end))

	if self.observer then
		self.__maid:GiveTask(parent:GetAttributeChangedSignal("BobberId"):Connect(function()
			if not self.reelingIn then
				self.__maid:Destroy()
			end
		end))
	end

	self.__components:Get("RodController"):SetState("Launching")

	if not flag then
		self.__components:Get("RodController"):SetState("LaunchingFail")
	end

	if flag2 then
		self:GetSounds():PlayRandom("PerfectCast")
	else
		self:GetSounds():PlayRandom("Cast")
	end

	local instance = self.instance

	if not instance then
		self:SetupRod(parent)
		instance = script.Parent.Parent.Parent.Bobbers:FindFirstChild(parent:GetAttribute("BobberAsset") or "Bobber"):Clone()
		self.__maid:GiveTask(instance)
		self.__maid:GiveTask(function()
			self:onDestroy()
		end)
		instance.PrimaryPart.CFrame = parent:FindFirstChild("Attachment", true).WorldCFrame
		local bobAttach = instance:FindFirstChild("BobAttach", true)
		self.LaunchTime = tick()
		self.attach = bobAttach
		self:updateRopeAttachPos()
		local ropeConstraint = Instance.new("RopeConstraint", instance)
		self.RopeConstraint = ropeConstraint
		ropeConstraint.Name = "RopeConstraint"
		ropeConstraint.Attachment0 = parent:FindFirstChild("Attachment", true)
		self.rodAttach = ropeConstraint.Attachment0
		ropeConstraint.Attachment1 = bobAttach
		ropeConstraint.WinchEnabled = true
		ropeConstraint.Color = self.Rod:GetAttribute("FishingLineColor") or BrickColor.Black()
		ropeConstraint.Length = self:getRopeLength(ropeConstraint) + 1
		ropeConstraint.Visible = true
		ropeConstraint.Thickness = 0.05
		instance.Parent = parent
		self.instance = instance
	end

	local ropeConstraint = instance.RopeConstraint
	instance.PrimaryPart.CFrame = parent:FindFirstChild("Attachment", true).WorldCFrame
	local magnitude = (bobberWorldPosition - instance.PrimaryPart.Position).Magnitude
	self.MovementAxis = CFrame.new(
		parent.PrimaryPart.Position * createVector(1, 0, 1),
		bobberWorldPosition * createVector(1, 0, 1)
	)
	local boat = FishingPosition.getBoat(self.BobberPosition)
	local movementAxisLocal

	if boat then
		movementAxisLocal = boat:GetPivot():ToObjectSpace(self.MovementAxis)
	end

	self.MovementAxisLocal = movementAxisLocal
	local boats = { workspace.Characters, workspace.Enemies }

	if boat then
		table.insert(boats, boat)
	end

	self.Distance = magnitude
	self.TargetPos = bobberWorldPosition + createVector(0, 0.1, 0)
	self.playing = false
	self.__maid:GiveTask(instance)
	local thread = task.spawn(function()
		while instance:IsDescendantOf(workspace) do
			ropeConstraint.Length = self:getRopeLength(ropeConstraint)
			RunService.RenderStepped:Wait()
		end
	end)
	self.__maid:GiveTask(task.defer(function()
		local fishRigs = self.Owner:WaitForChild("FishRigs", 999)

		repeat
			task.wait(0.1)
		until #fishRigs:GetChildren() > 0

		self.FishRig = fishRigs:GetChildren()[1]
		self.FishRig.Parent = workspace
		task.defer(function()
			local fishRig = self.FishRig
			local animationId = fishRig:FindFirstChild("AnimationId")
			local holdingAnimationId = fishRig:FindFirstChild("HoldingAnimationId")
			local animationController = fishRig:FindFirstChild("AnimationController")

			if animationController and animationId then
				if not animationController:FindFirstChild("Animator") then
					Instance.new("Animator", animationController)
				end

				animationController.Animator:LoadAnimation(Anims:GetRaw(animationId.Value))

				if holdingAnimationId then
					animationController.Animator:LoadAnimation(Anims:GetRaw(holdingAnimationId.Value))
				end
			end
		end)

		while self.FishRig.Parent == workspace do
			self.FishRig:MoveTo(createVector(100000, 100000, 100000))
			task.wait()
		end
	end))

	if flag3 then
		self.SlackTime = tick()
	else
		self.SlackTime = tick() + (0.3 + magnitude / 70) / 1.3
		self:tweenBobberArc(instance.PrimaryPart, self.BobberPosition, 0.3 + magnitude / 70, 2 + magnitude / 4)
	end

	task.cancel(thread)
	self.__maid.BobberCFrameTask = task.spawn(function()
		while instance:IsDescendantOf(workspace) do
			local bobberWorldPosition2 = self:getBobberWorldPosition()
			self.TargetPos = bobberWorldPosition2 + createVector(0, 0.1, 0)
			local foam, vector2 = workspace:FindPartOnRayWithIgnoreList(
				Ray.new(bobberWorldPosition2 + createVector(0, 50, 0), createVector(0, -100, 0)),
				boats
			)
			local v2, v3 = GetWaterHeightAtLocation(vector2)

			if foam then
				if foam.Name == "WaterBase-Plane" or foam.Name == "Sand" then
					foam = workspace:FindFirstChild("Foam;") or foam

					if foam then
						vector2 = Vector3.new(vector2.X, foam.Position.Y, vector2.Z)
					end

					vector2 = Vector3.new(vector2.X, math.max(vector2.Y, v3 and v2 + 0.1 or -3.9), vector2.Z)
				end

				if foam then
					self.TargetPos = vector2 + createVector(0, 0.1, 0)
				end
			end

			ropeConstraint.Length = self:getRopeLength(ropeConstraint, true)
			instance.PrimaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			instance.PrimaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local currentTargetPosition = self:getCurrentTargetPosition()

			if currentTargetPosition then
				instance.PrimaryPart.CFrame = CFrame.new(
					currentTargetPosition + createVector(0, 1, 0) * self.BobberSpring:Get(),
					self.rodAttach.WorldPosition
				) * CFrame.Angles(-1.5707963267948966, 0, 0)
			else
				instance.PrimaryPart.CFrame = CFrame.new(self.TargetPos or bobberWorldPosition2) + createVector(0, 1, 0) * self.BobberSpring:Get()
			end

			self.BobberSpring:Step(RunService.RenderStepped:Wait())
		end
	end)
	task.defer(function()
		if instance.Parent and flag then
			self:HitWater()
		end
	end)

	if not flag then
		instance:Destroy()
		self.__components:Get("RodController"):ReeledInRod()
	end

	return instance
end

function Bobber:VerticalBob(p2)
	local v = p2 / 2.5
	self.BobberSpring.Goal -= v

	if self.Splashes then
		for _, emitter in pairs(self.Splashes:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		task.delay(math.random(200, 500) / 1000, function()
			self.BobberSpring.Goal += v
		end)
	end
end

function Bobber:OnBite()
	task.spawn(function()
		local rodController = self.__components:Get("RodController")
		rodController:SetState("Biting")
		local lastTime = tick()

		while self.instance.Parent do
			self:VerticalBob(math.random(300, 1200) / 1000)
			task.wait(math.random(600, 1200) / 1000)

			if self.observer then
				if tick() - lastTime > 1.5 then
					break
				end
			elseif not self.__state.isBiting then
				break
			end
		end

		if rodController:GetState() == "Biting" then
			rodController:SetState("Waiting")
		end
	end)
end

function Bobber:AnimateReelHandle(p2)
	self.Rod:SetAttribute("ReelingSpeed", p2 * 100)
end

function Bobber.GetTension(p)
	return p.RopeConstraint.CurrentDistance / (p.RopeConstraint.Attachment0.WorldPosition - p.RopeConstraint.Attachment1.WorldPosition).Magnitude
end

function Bobber.ReelExcessSlack(p)
	local length = p.RopeConstraint.Length
	local currentDistance = p.RopeConstraint.CurrentDistance
	print(
		currentDistance,
		length,
		length / currentDistance,
		p.RopeConstraint.CurrentDistance / (p.RopeConstraint.Attachment0.WorldPosition - p.RopeConstraint.Attachment1.WorldPosition).Magnitude
	)

	if length / currentDistance >= 1.002 then
		return true
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
task.spawn(function()
	raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:WaitForChild("Boats") }
end)

function Bobber:Update(p: number, p2: number, playerRot: number?)
	local bobberDistance = p + 0.5

	if bobberDistance > 0 then
		bobberDistance *= 2
	end

	if self.bobberDistance then
		local v2 = bobberDistance - self.bobberDistance
		self:AnimateReelHandle(v2)

		if not self.observer then
			local v3 = math.sign(v2)
			local sounds = self.__components:Get("Sounds")

			if v3 == 1 then
				sounds:FadeOut("ReelingHoveringFishOut", 0.1)
				sounds:FadeIn("ReelingHoveringFishIn", 0.1)
			else
				sounds:FadeOut("ReelingHoveringFishIn", 0.1)
				sounds:FadeIn("ReelingHoveringFishOut", 0.1)
			end
		end
	end

	self.bobberDistance = bobberDistance

	if not self.observer then
		self.playerRot = playerRot

		if self.__state.RemoteEvent then
			self.__state.RemoteEvent:FireServer("UpdateBobberPos", p, p2, playerRot)
		end
	end

	local movementAxis = self:getMovementAxis()

	if not movementAxis then
		return
	end

	local bobberWorldPosition = self:getBobberWorldPosition()
	local vector2 = Vector3.new(bobberWorldPosition.X, self.TargetPos.Y, bobberWorldPosition.Z)
	local distance = self.Distance
	local v2 = vector2 + movementAxis.RightVector * (p2 * 1.5 + bobberDistance / 2) * (distance / 2)
	local lookVector = movementAxis.LookVector
	local v3 = -distance / 2
	local halfDistance = distance / 2
	local v5 = bobberDistance + 0.5
	local currentTargetPos = v2 + lookVector * (v3 + (halfDistance - v3) * v5)
	local boat = FishingPosition.getBoat(self.BobberPosition)
	local raycastResult = workspace:Raycast(
		currentTargetPos + createVector(0, 20, 0),
		createVector(-0, -50, -0),
		raycastParams
	)
	local instance = raycastResult and raycastResult.Instance
	local v7

	if instance == nil then
		v7 = false
	else
		v7 = not (boat and instance:IsDescendantOf(boat)) and not instance:HasTag("WaterBody") and instance.Name ~= "WaterBase-Plane"
	end

	if v7 then
		return
	end

	local raycastResult2 = workspace:Raycast(vector2, currentTargetPos - vector2, raycastParams)
	local instance2 = raycastResult2 and raycastResult2.Instance
	local v8

	if instance2 == nil then
		v8 = false
	else
		v8 = not (boat and instance2:IsDescendantOf(boat)) and not instance2:HasTag("WaterBody") and instance2.Name ~= "WaterBase-Plane"
	end

	if v8 then
		return
	end

	self.CurrentTargetPos = currentTargetPos
	local currentTargetLocalPosition

	if boat then
		currentTargetLocalPosition = boat:GetPivot():PointToObjectSpace(currentTargetPos)
	end

	self.CurrentTargetLocalPosition = currentTargetLocalPosition
end

function Bobber:FishCatchingReel(p, p2)
	local _ = self.instance.PrimaryPart
	self.__maid.FishCatchingReel = nil
	local fishCatchingReel = {
		tasks = {},
		Destroy = function(self)
			for _, task2 in self.tasks do
				task.cancel(task2)
			end
		end
	}
	self.__maid.FishCatchingReel = fishCatchingReel
	self:ReelInFishAndFlex(p, p2)
	return fishCatchingReel
end

function Bobber:ReelInFishAndIdle(p, p2)
	self:StickFishToBobber(p, p2)

	while p.Parent do
		task.wait()
	end
end

function Bobber:ReelInFishAndFlex(instance, p)
	if not (instance and instance.Parent) then
		return
	end

	local stickFishToBobber = self:StickFishToBobber(instance, p)
	task.wait(p.reelTime)
	stickFishToBobber()
	local thread = coroutine.create(function()
		local character = self.Owner.Character
		local humanoidRootPart = self.observer and character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.RootPriority += 10

			function self.__maid._downgradeRootPriorityHRP()
				humanoidRootPart.RootPriority -= 10
			end
		end

		local v = instance:FindFirstChild("Bone") and instance:FindFirstChild(
			instance:FindFirstChild("Bone").Value,
			true
		) or instance:FindFirstChild("Front1", true)
		local part = instance:FindFirstChild("Part")
		local motor6D = Instance.new("Motor6D", instance)
		motor6D.Part0 = part
		motor6D.Part1 = instance.PrimaryPart
		part.Motor6D.Part0 = self.Owner.Character:FindFirstChild("RightHand")
		local weldTarget = instance:FindFirstChild("GripOffset"):GetAttribute("WeldTarget")
		local part2

		if weldTarget then
			part2 = instance:FindFirstChild(weldTarget, true)
		else
			part2 = part
		end

		part.Motor6D.Part1 = part2
		part.Motor6D.C0 = instance:FindFirstChild("GripOffset"):GetAttribute("C0") or CFrame.Angles(
			0,
			0.17453292519943295,
			0
		)
		part.Motor6D.C1 = instance:FindFirstChild("GripOffset").Value
		task.spawn(function()
			while instance:IsDescendantOf(workspace) do
				motor6D.C0 = v.TransformedWorldCFrame:Inverse() * instance.PrimaryPart.CFrame
				local RunService2 = game:GetService("RunService")
				RunService2.Stepped:Wait()
			end

			self.__maid._downgradeRootPriorityHRP = nil
		end)
	end)
	local holdingAnimationId = instance:FindFirstChild("HoldingAnimationId")

	if not (instance.Parent and holdingAnimationId) then
		return
	end

	local raw = Anims:GetRaw(holdingAnimationId.Value)
	local hideRod = raw and raw:GetAttribute("HideRod")

	if hideRod then
		self.__components:Get("RodController"):HideRod()
	end

	self.__components:Get("Sounds"):PlayRandom("FishHoldShimmerLoop")

	if self.observer then
		coroutine.resume(thread)

		while instance.Parent do
			task.wait()
		end
	else
		local raw2 = Anims:GetRaw(holdingAnimationId.Value)
		local v = Anims:Get(game.Players.LocalPlayer.Character, holdingAnimationId.Value)
		v.Looped = raw2:GetAttribute("Looped") ~= false
		v.Priority = Enum.AnimationPriority.Action4
		v:Play()
		task.spawn(function()
			while v.Length == 0 do
				task.wait()
			end

			coroutine.resume(thread)

			if self._loadedBobberFishAnim then
				v.TimePosition = self._loadedBobberFishAnim.TimePosition
			end
		end)

		while instance.Parent do
			task.wait()
		end

		v:Stop()
	end

	self.__components:Get("Sounds"):StopSound("FishHoldShimmerLoop", 0.5)

	if hideRod then
		self.__components:Get("RodController"):ShowRod()
	end
end

function Bobber:StickFishToBobber(folder, p)
	local primaryPart = self.instance.PrimaryPart
	local v

	if folder then
		v = folder:FindFirstChild("Front3", true) or folder:FindFirstChild("Front2", true) or folder:FindFirstChild(
			"Front1",
			true
		)

		if not v then
			v = Instance.new("Bone", folder.PrimaryPart)
			v.Name = "Front1"
		end
	else
		v = nil
	end

	p.reelTime = 0.3

	if folder and v then
		local magnitude = folder:GetExtentsSize().Magnitude
		local v2

		if folder:GetAttribute("SplashVFX") then
			v2 = self:AttachEmitter(folder:GetAttribute("SplashVFX"), nil)
		end

		local v3

		if magnitude > 20 then
			v3 = v2 or self:AttachEmitter("Large", nil)
			self.__components:Get("Sounds"):PlayRandom("ReelInLarge")
		elseif magnitude > 10 then
			v3 = v2 or self:AttachEmitter("Medium", nil)
			self.__components:Get("Sounds"):PlayRandom("ReelInMedium")
		else
			v3 = v2 or self:AttachEmitter("Small", nil)
			self.__components:Get("Sounds"):PlayRandom("ReelInSmall")
		end

		v3.Parent = workspace._WorldOrigin
		v3.CFrame = CFrame.new(primaryPart.Position + createVector(0, 0.5, 0))
		v3.Anchored = true
		self:Emit(v3)
		p.reelTime = 1
		p.reelTo = 0

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Massless = true

			if self.observer then
				part.RootPriority = -127
			end
		end

		if folder:FindFirstChild("AnimationController") then
			if not folder.AnimationController:FindFirstChild("Animator") then
				Instance.new("Animator", folder.AnimationController)
			end

			local raw = Anims:GetRaw(folder.AnimationId.Value)
			local track = folder.AnimationController.Animator:LoadAnimation(raw)
			self._loadedBobberFishAnim = track
			track.Looped = raw:GetAttribute("Looped") ~= false
			local v4 = tick() + 1

			while track.Length == 0 and tick() < v4 do
				task.wait()
			end

			if folder:FindFirstChild("WiggleWeight") then
			end

			track:Play(1)
			task.spawn(function()
				if raw.Name == "Fishing_BottleRigAnim" then
					local circle006Motor6D = folder:FindFirstChild("Circle.006Motor6D", true)
					local circle008Motor6D = folder:FindFirstChild("Circle.008Motor6D", true)
					local parent = circle008Motor6D.Parent
					local v5 = false
					local v6 = false

					while task.wait() do
						if v5 or not (track.TimePosition >= 2) then
							if not v6 and track.TimePosition >= 1 then
								circle008Motor6D:Destroy()
								parent.AssemblyLinearVelocity = parent.CFrame.UpVector * 20
								v6 = true
							end
						else
							circle006Motor6D.Part0 = self.Owner.Character.LeftHand
							circle006Motor6D.C0 = CFrame.new(0, -0.3, 0) * CFrame.Angles(0, 0.17453292519943295, 0)
							v5 = true
						end
					end
				end
			end)
			raw:GetAttribute("FreezeAtTime")
		end

		local RunService2 = game:GetService("RunService")
		local renderStepped = RunService2.RenderStepped
		self.__maid.StickFishToBobber = task.spawn(function()
			self.instance.base.Massless = false
			folder.Parent = workspace._WorldOrigin

			if self.Splashes then
				self.Splashes:Destroy()
			end

			local part = Instance.new("Part", folder)
			part.Size = createVector(0.01, 0.01, 0.01)
			local motor6D = Instance.new("Motor6D", part)
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = part
			motor6D.C0 = folder.PrimaryPart.CFrame:ToObjectSpace(v.TransformedWorldCFrame)
			part.CFrame = CFrame.lookAt(
				primaryPart.Position + (part.Position - primaryPart.Position).unit * 1.25,
				primaryPart.Position,
				createVector(1, 0, 0)
			) * CFrame.Angles(-1.5707963267948966, 0, 0)

			while folder.Parent do
				motor6D.C0 = folder.PrimaryPart.CFrame:ToObjectSpace(v.TransformedWorldCFrame)
				local cFrame = CFrame.lookAt(
					primaryPart.Position + (part.Position - primaryPart.Position).unit * 1.25,
					primaryPart.Position,
					createVector(1, 0, 0)
				) * CFrame.Angles(-1.5707963267948966, 0, 0)

				if (cFrame.Position - part.CFrame.Position).Magnitude > 20 then
					part.CFrame = cFrame
				else
					part.CFrame = part.CFrame:Lerp(cFrame, 0.8)
				end

				folder.PrimaryPart.AssemblyLinearVelocity = folder.PrimaryPart.AssemblyLinearVelocity * 0.25
				folder.PrimaryPart.AssemblyAngularVelocity = folder.PrimaryPart.AssemblyAngularVelocity * 0.25
				primaryPart.AssemblyLinearVelocity *= 0.9
				primaryPart.AssemblyAngularVelocity *= 0.9
				renderStepped:Wait()
			end
		end)
	end

	return function()
		self.__maid.StickFishToBobber = nil
		self.__maid.Droplets = nil
		primaryPart.AssemblyLinearVelocity *= 0.3
		primaryPart.AssemblyAngularVelocity *= 0.3
	end
end

function Bobber:ReelIn(p)
	self.__maid.ReelingVFX = nil

	if self.Splashes then
		self.Splashes:Destroy()
	end

	self.__maid.IdleVFX = nil
	self.__maid.Droplets = nil
	self.__maid.BobberCFrameTask = nil
	local primaryPart = self.instance.PrimaryPart

	if not primaryPart then
		return
	end

	if p then
		self:setOwnerAnchored(true)
		self.__components:Get("Sounds"):PlayRandom("CatchSuccess")
		self.reelingIn = true

		for _, part in self.instance:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Massless = true

			if self.observer then
				part.RootPriority = -100
			end
		end

		primaryPart.Anchored = false
		local fishRig = p and self.FishRig

		if p and not fishRig then
			local fishRigs = self.Owner:WaitForChild("FishRigs", 10)

			if fishRigs then
				local total = 0

				while #fishRigs:GetChildren() < 1 do
					total += task.wait()

					if not (total > 2) then
						continue
					end

					fishRigs:ClearAllChildren()
					break
				end

				fishRig = fishRigs:GetChildren()[1]
			end
		end

		local v = {
			reelTo = 0,
			reelTime = 0.3
		}
		local v2 = nil
		local thread = task.spawn(function()
			v2 = self:FishCatchingReel(fishRig, v)
		end)
		local currentDistance = self.RopeConstraint.CurrentDistance
		local unit = ((self.rodAttach.WorldPosition - primaryPart.Position) * -1).Unit
		self.RopeConstraint.WinchEnabled = false
		local lastTime = tick()

		while self.RopeConstraint.Length > v.reelTo + 0.1 do
			primaryPart.AssemblyLinearVelocity = createVector(0, 20, 0) + unit
			primaryPart.CFrame = CFrame.lookAt(
				self.rodAttach.WorldPosition + (primaryPart.Position - self.rodAttach.WorldPosition).Unit * self.RopeConstraint.Length,
				self.rodAttach.WorldPosition
			) * CFrame.Angles(-90, 0, 0)
			local ropeConstraint = self.RopeConstraint
			local reelTo = v.reelTo
			local v3 = (tick() - lastTime) / v.reelTime
			ropeConstraint.Length = math.clamp(currentDistance + (reelTo - currentDistance) * v3, 0, 100)
			task.wait()
		end

		self:setOwnerAnchored(false)

		if self.observer then
			pcall(function()
				self.instance.PrimaryPart.RootPriority = 2
			end)
		end

		while coroutine.status(thread) ~= "dead" do
			task.wait()
		end

		self.__components:Get("Sounds"):StopSound("CatchSuccess", 0.5)
		self.reelingIn = false

		if v2 then
			v2:Destroy()
		end
	else
		local v = self:AttachEmitter("Small", nil)
		v.Parent = workspace._WorldOrigin
		v.CFrame = CFrame.new(primaryPart.Position + createVector(0, 0.5, 0))
		v.Anchored = true
		self:setOwnerAnchored(true)
		self.__components:Get("Sounds"):PlayRandom("CatchFailure")

		for _, part in self.instance:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Massless = true

			if self.observer then
				part.RootPriority = -100
			end
		end

		primaryPart.Anchored = false
		local currentDistance = self.RopeConstraint.CurrentDistance
		local unit = ((self.rodAttach.WorldPosition - primaryPart.Position) * -1).Unit
		self.RopeConstraint.WinchEnabled = false
		local lastTime = tick()

		while self.RopeConstraint.Length > 0.1 do
			primaryPart.AssemblyLinearVelocity = createVector(0, 20, 0) + unit
			primaryPart.CFrame = CFrame.lookAt(
				self.rodAttach.WorldPosition + (primaryPart.Position - self.rodAttach.WorldPosition).Unit * self.RopeConstraint.Length,
				self.rodAttach.WorldPosition
			) * CFrame.Angles(-90, 0, 0)
			local ropeConstraint = self.RopeConstraint
			local v2 = (tick() - lastTime) / 0.5
			ropeConstraint.Length = math.clamp(currentDistance + (0.1 - currentDistance) * v2, 0, 100)
			task.wait()
		end

		self:setOwnerAnchored(false)
	end
end

function Bobber:Engaged()
	self.__components:Get("RodController"):SetState("Playing")
	local primaryPart = self.instance.PrimaryPart

	if not primaryPart then
		return
	end

	self.__maid.ReelingVFX = self:AttachEmitter("Reeling", primaryPart)
	self.__maid.IdleVFX = nil
	self.WaterHitTime = tick()
	self.playing = true
	self.Rod:SetAttribute("IsReeling", true)

	function self.__maid.reeling()
		self.__maid.ReelingVFX = nil
		self.Rod:SetAttribute("IsReeling", false)
	end

	local clone = script.Droplets:Clone()
	clone.CFrame = CFrame.new(primaryPart.Position)
	clone.Parent = _WorldOrigin
	self.__maid.Droplets = clone
	task.spawn(function()
		while self.instance:IsDescendantOf(workspace) do
			clone.CFrame = CFrame.new(primaryPart.Position)
			task.wait()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(2)
		clone:Destroy()
	end)

	if not self.observer then
		self.__maid:GiveTask(task.spawn(function()
			local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart

			while self.instance.PrimaryPart:IsDescendantOf(workspace) do
				local v = humanoidRootPart.Position + ((self.TargetPos - humanoidRootPart.Position) * createVector(
					1,
					0,
					1
				)).Unit * 25 - humanoidRootPart.Position
				local unit = Vector3.new(v.X, 0, v.Z).Unit
				local _, _, _ = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit):ToEulerAnglesYXZ()
				self.Rod:SetAttribute("ReelingAngle", ((self.playerRot or 0.5) - 0.5) * -250)
				task.wait()
			end
		end))
	end
end

function Bobber:HitWater()
	self.__components:Get("RodController"):SetState("Waiting")
	self.WaterHitTime = tick()
	self.Splashes = self:AttachEmitter("BobberSplash", nil)
	self.__maid.IdleVFX = self.Splashes
	self.Splashes.CFrame = CFrame.new(self.instance.PrimaryPart.Position + createVector(0, 0.1, 0))
	self.Splashes.Parent = _WorldOrigin

	for _, emitter in pairs(self.Splashes:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	task.spawn(function()
		while self.instance:IsDescendantOf(workspace) do
			self.Splashes.CFrame = CFrame.new(self.instance.PrimaryPart.Position + createVector(0, 0.1, 0))
			task.wait()
		end

		for _, emitter in pairs(self.Splashes:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(2)
		self.Splashes:Destroy()
	end)
end

function Bobber:AttachEmitter(p, parent)
	local moduleScript = script.VFX[p]

	if moduleScript:IsA("ModuleScript") then
		return {
			callback = require(moduleScript)
		}
	else
		local clone = script.VFX[p]:Clone()

		if not parent then
			return clone
		end

		clone.Parent = parent
		clone.Anchored = true
		task.spawn(function()
			while clone.Parent do
				task.wait()
				clone.CFrame = CFrame.new(parent.Position)
			end
		end)
		self:Emit(clone)
		return clone
	end
end

function Bobber:Emit(folder)
	if typeof(folder) == "table" then
		if folder.CFrame then
			task.spawn(folder.callback, folder.CFrame.Position)
		end
	else
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			coroutine.wrap(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)()
		end
	end
end

function Bobber.SetupPlayingField(_) end

function Bobber.Construct(p)
	return (setmetatable(p, Bobber))
end

local v = {}

function Bobber.Setup()
	function Bobber.__state.clientEvents.ReplicateBobber(player, p, p2, ...)
		if player == game.Players.LocalPlayer then
			return
		end

		if p2 == "Spawn" then
			if v[p] then
				return
			end

			local character = player.Character

			if not character then
				return
			end

			local tool = character:FindFirstChildOfClass("Tool")

			if not (tool and tool:HasTag("FishingRod")) then
				return
			end

			local parentModule = require(script.Parent)
			local bobber = parentModule.Bucket(player):Get("Bobber")
			v[p] = bobber
			bobber:launch(tool, ...)
			bobber.__maid:GiveTask(tool.AncestryChanged:Connect(function()
				bobber.__maid:Destroy()
				task.delay(2, function()
					v[p] = nil
				end)
			end))
		elseif p2 == "Destroy" then
			if v[p] then
				v[p]:ReelIn(...)
				v[p].__maid:Destroy()
				task.delay(2, function()
					v[p] = nil
				end)
			end

			local parentModule = require(script.Parent)
			parentModule.Bucket(player):Get("RodController"):SetState("ReeledIn")
		elseif p2 == "Bit" then
			if v[p] then
				v[p]:OnBite()
			end
		elseif p2 == "Engaged" then
			if v[p] then
				v[p]:Engaged()
			end
		elseif p2 == "Update" and v[p] then
			local v2, v3, v4 = ...
			v[p]:Update(v2, v3, v4)
		end
	end
end

return Bobber