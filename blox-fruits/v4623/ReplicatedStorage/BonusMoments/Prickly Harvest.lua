local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.DialoguesList.Util)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
local NPCManager = require(game.ReplicatedStorage.NPCManager)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local v = {
	SearchRadius = 170,
	Back = 34,
	Height = 15,
	LookUp = 5,
	RevealDamping = 1,
	RevealFrequency = 1.1,
	ReturnTime = 0.8
}
local pricklyHarvest = script.PricklyHarvest
local flag = false
local v2 = false

local function reflectProgress(p)
	for _, child in pricklyHarvest.ProgressVisuals:GetChildren() do
		if p < tonumber(child.Name) then
			for _, child2 in child:GetChildren() do
				child2.Transparency = 1
			end
		else
			for _, child2 in child:GetChildren() do
				child2.Transparency = 0
			end
		end
	end
end

local _ = {
	Distance = 12,
	Height = 4.5,
	LookUp = 3,
	SideAngle = 0.3839724354387525,
	Damping = 1,
	Frequency = 0.95
}

-- equivalent calls inferred from this helper; original call sites unknown
local function merchantModel()
	local character = game.Players.LocalPlayer.Character
	local v3 = not character and createVector(0, 0, 0) or character:GetPivot().Position
	local closestNPC = NPCManager.getClosestNPC(v3, "Desert Merchant")
	return closestNPC and closestNPC:getModel()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function panOrigin()
	local v3 = merchantModel() -- equivalent call inferred; original call site unknown

	if v3 then
		return v3:GetPivot().Position
	end

	local character = game.Players.LocalPlayer.Character

	if character then
		return character:GetPivot().Position
	end

	return nil
end

local function merchantFocusCFrame()
	local v3 = merchantModel() -- equivalent call inferred; original call site unknown

	if not v3 then
		return nil
	end

	local pivot = v3:GetPivot()
	local character = game.Players.LocalPlayer.Character
	local v4

	if character then
		v4 = character:GetPivot().Position
	else
		v4 = pivot.Position + pivot.LookVector * 10
	end

	local v5 = (v4 - pivot.Position) * createVector(1, 0, 1)
	local unit

	if v5.Magnitude > 0.5 then
		unit = v5.Unit
	else
		unit = pivot.LookVector * createVector(1, 0, 1)
	end

	local v6 = unit.Magnitude < 0.01 and createVector(0, 0, 1) or unit
	local unit2 = (CFrame.fromAxisAngle(createVector(0, 1, 0), 0.3839724354387525) * v6.Unit).Unit
	local v7 = pivot.Position + unit2 * 12 + createVector(0, 4.5, 0)
	return CFrame.lookAt(v7, pivot.Position + createVector(0, 3, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cactiFolderOf()
	local desert = workspace.Map:FindFirstChild("Desert")

	if desert then
		return (desert:FindFirstChild("Cacti"))
	end

	return nil
end

local function demoCactusFor(vector2: Vector3)
	local v3 = cactiFolderOf() -- equivalent call inferred; original call site unknown

	if not v3 then
		return nil
	end

	local v4 = -1
	local v5 = 1e999
	local v6 = nil
	local v7 = nil

	for _, model in v3:GetChildren() do
		if not (model:IsA("Model") and model:GetAttribute("TreeType") == "Cactus") then
			continue
		end

		local magnitude = (model:GetPivot().Position - vector2).Magnitude

		if magnitude <= 170 and v4 < magnitude then
			v6 = model
			v4 = magnitude
		end

		if not (magnitude < v5) then
			continue
		end

		v7 = model
		v5 = magnitude
	end

	return v6 or v7
end

local _ = {
	RecoilTime = 0.45,
	RecoilAngle = 0.19198621771937624,
	RecoilDecay = 7,
	RecoilWobble = 21,
	PopTime = 0.18,
	PopHeight = 7,
	PopScale = 1.15,
	FlyTime = 0.5,
	FlyArc = 12,
	EndScale = 0.1,
	SpinSpeed = 17,
	ChestLift = 1.5
}
local v3 = {
	FreshWindow = 4,
	MaxDelay = 0.6,
	Duration = 0.7,
	StartScale = 0.08,
	BurstAt = 0.5,
	BurstCount = 10,
	BurstSpeed = 14,
	BurstSize = 0.55,
	BurstSpread = 75
}
local frozen = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Cactus_Hit_01",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Hit_02",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Hit_03"
})
local frozen2 = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Cactus_Collect_01",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Collect_02",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Collect_03",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Collect_04",
	"DesertBonusMoments.BF_DesertBonus_Cactus_Collect_05"
})
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v4 = {}
local v5 = {}
local v6 = {}
local nows = {}
local v7 = {}
local count = 0

local function restStateOf(folder)
	local v8 = v4[folder]

	if v8 then
		return v8
	end

	local pivot = folder:GetPivot()
	local boundingBox, v9 = folder:GetBoundingBox()
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, {
				part = part,
				size = part.Size,
				cframe = part.CFrame
			})
		end
	end

	local v11 = {
		pivot = pivot,
		bottomOffset = boundingBox.Position.Y - v9.Y * 0.5 - pivot.Position.Y,
		parts = parts
	}
	v4[folder] = v11
	return v11
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restPivotOf(p)
	return restStateOf(p).pivot
end

local function restoreRest(instance)
	local v8 = restStateOf(instance)
	instance:ScaleTo(1)
	instance:PivotTo(v8.pivot)

	for _, part in v8.parts do
		part.part.Size = part.size
		part.part.CFrame = part.cframe
	end
end

local function biggestPart(folder)
	local v8 = 0
	local v9 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local v10 = part.Size.X * part.Size.Y * part.Size.Z

		if not (v8 < v10) then
			continue
		end

		v9 = part
		v8 = v10
	end

	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cactusColor(p)
	local v8 = biggestPart(p)

	if v8 then
		return v8.Color
	end

	return (Color3.fromRGB(88, 138, 74))
end

local function burst(position: Vector3, color: Color3, p: number, p2: number, p3: number, p4: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Parent = _WorldOrigin
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, p3), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.65)
	particleEmitter.Speed = NumberRange.new(p2 * 0.5, p2)
	particleEmitter.SpreadAngle = Vector2.new(p4, p4)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-180, 180)
	particleEmitter.Acceleration = createVector(0, -55, 0)
	particleEmitter.LightEmission = 0.35
	particleEmitter.Enabled = false
	particleEmitter.Parent = part
	particleEmitter:Emit(p)
	Debris:AddItem(part, 1.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopRecoil(p)
	v5[p] = (v5[p] or 0) + 1

	if v4[p] and p.Parent then
		restoreRest(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishBloom(p)
	if not v7[p] then
		return
	end

	v7[p] = nil
	restoreRest(p)
end

local function isFreshBloom(instance)
	local bloomedAt = instance:GetAttribute("BloomedAt")
	return typeof(bloomedAt) == "number" and workspace:GetServerTimeNow() - bloomedAt <= 4
end

local function recentlyRestored(p)
	local v8 = nows[p]
	return v8 ~= nil and os.clock() - v8 < 1
end

local function bloomCactus(model, duration: number)
	finishBloom(model) -- equivalent call inferred; original call site unknown
	local v8 = restStateOf(model)
	local pivot = v8.pivot
	local bottomOffset = v8.bottomOffset
	local v9 = cactusColor(model) -- equivalent call inferred; original call site unknown
	local lerped = v9:Lerp(Color3.new(1, 1, 1), 0.3)
	count += 1
	local v10 = count
	v7[model] = v10

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyScale(p: number)
		model:ScaleTo(p)
		model:PivotTo(pivot + createVector(0, 1, 0) * (bottomOffset * (1 - p)))
	end

	task.spawn(function()
		model:ScaleTo(0.08)
		model:PivotTo(pivot + createVector(0, 1, 0) * (bottomOffset * 0.92))

		if duration > 0 then
			task.wait(duration)
		end

		local total = 0
		local v11 = false

		while total < 0.7 do
			if v7[model] ~= v10 then
				return
			end

			if not model.Parent then
				break
			end

			local v12 = total / 0.7
			applyScale(0.08 + 0.92 * TweenService:GetValue(v12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)) -- equivalent call inferred; original call site unknown

			if not v11 and v12 >= 0.5 then
				burst(pivot.Position, lerped, 10, 14, 0.55, 75)
				v11 = true
			end

			total += RunService.Heartbeat:Wait()
		end

		if v7[model] == v10 then
			v7[model] = nil
			restoreRest(model)
		end
	end)
end

local function recoilCactus(model, position: Vector3?)
	finishBloom(model) -- equivalent call inferred; original call site unknown
	local pivot = restPivotOf(model) -- equivalent call inferred; original call site unknown
	local _, v9 = model:GetBoundingBox()
	local v10 = pivot.Position - createVector(0, 1, 0) * (v9.Y * 0.5)
	local character = game.Players.LocalPlayer.Character

	if not position then
		if character then
			position = character:GetPivot().Position
		else
			position = pivot.Position - createVector(0, 0, 1)
		end
	end

	local v11 = (pivot.Position - position) * createVector(1, 0, 1)
	local v12

	if v11.Magnitude > 0.1 then
		v12 = v11.Unit
	else
		v12 = pivot.LookVector
	end

	local cross = (createVector(0, 1, 0)):Cross(v12)

	if cross.Magnitude < 0.01 then
		return
	end

	local unit = cross.Unit
	local position2 = pivot.Position
	local v14 = cactusColor(model) -- equivalent call inferred; original call site unknown
	burst(position2, v14, 12, 18, 0.7, 45)
	Sound:Play(frozen[math.random(1, #frozen)], pivot.Position)
	local v15 = (v5[model] or 0) + 1
	v5[model] = v15
	task.spawn(function()
		local total = 0

		while total < 0.45 do
			if v5[model] ~= v15 or not model.Parent then
				return
			end

			local v16 = 0.19198621771937624 * math.exp(-7 * total) * math.sin(21 * total)
			model:PivotTo(CFrame.new(v10) * CFrame.fromAxisAngle(unit, v16) * CFrame.new(-v10) * pivot)
			total += RunService.Heartbeat:Wait()
		end

		if v5[model] == v15 and model.Parent then
			restoreRest(model)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showCactus(p)
	local parent = v6[p]
	v6[p] = nil

	if parent and parent.Parent and p.Parent == nil then
		nows[p] = os.clock()
		restoreRest(p)
		p.Parent = parent
	end
end

local function restoreAllCacti()
	for k in v6 do
		showCactus(k) -- equivalent call inferred; original call site unknown
	end

	for k in v5 do
		stopRecoil(k) -- equivalent call inferred; original call site unknown
	end

	for k in v7 do
		finishBloom(k) -- equivalent call inferred; original call site unknown
	end
end

local function buildFlyingCactus(instance, cframe: CFrame)
	local clone = instance:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part:RemoveTag("M1HitRegistry")
	end

	local v8 = biggestPart(clone)

	if not v8 then
		clone:Destroy()
		return nil, nil
	end

	clone:PivotTo(cframe)
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 2.6799999999999997)
	return clone, v8
end

local function attachTrail(parent, color: Color3)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, parent.Size.Y * 0.4, 0)
	attachment.Parent = parent
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, -parent.Size.Y * 0.4, 0)
	attachment2.Parent = parent
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(color)
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
	trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	trail.Lifetime = 0.3
	trail.LightEmission = 0.4
	trail.FaceCamera = true
	trail.Parent = parent
end

local function chestPosition()
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position + createVector(0, 1.5, 0)
	end

	if character then
		return character:GetPivot().Position + createVector(0, 1.5, 0)
	end

	return nil
end

local function flyCactusTo(p, chestPosition2)
	local pivot = restPivotOf(p) -- equivalent call inferred; original call site unknown
	local v9 = cactusColor(p) -- equivalent call inferred; original call site unknown
	local parent = p.Parent
	finishBloom(p) -- equivalent call inferred; original call site unknown
	stopRecoil(p) -- equivalent call inferred; original call site unknown

	if parent then
		v6[p] = parent
		p.Parent = nil
	end

	local flyingCactus, parent2 = buildFlyingCactus(p, pivot)

	if not (flyingCactus and parent2) then
		return
	end

	Sound:Play(frozen[math.random(1, #frozen)], pivot.Position)
	burst(pivot.Position, v9, 26, 34, 1.1, 60)
	burst(pivot.Position - createVector(0, 2, 0), Color3.fromRGB(214, 184, 128), 18, 16, 1.6, 75)
	attachTrail(parent2, v9)
	local vector2 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
	local v11 = not (vector2.Magnitude > 0.01) and createVector(1, 0, 0) or vector2.Unit
	local v12 = pivot.Position + createVector(0, 7, 0)
	local total = 0
	local total2 = 0

	while flyingCactus.Parent do
		local v13 = math.min(total / 0.18, 1)
		local value = TweenService:GetValue(v13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		flyingCactus:ScaleTo(1 + 0.1499999999999999 * value)
		flyingCactus:PivotTo(CFrame.new(pivot.Position:Lerp(v12, value)) * CFrame.fromAxisAngle(v11, total2))

		if v13 >= 1 then
			local position = flyingCactus:GetPivot().Position
			local v14 = chestPosition2() or position
			local v15 = position:Lerp(v14, 0.5) + createVector(0, 12, 0)
			local total3 = 0

			while flyingCactus.Parent do
				v14 = chestPosition2() or v14
				local v16 = math.min(total3 / 0.5, 1)
				local value2 = TweenService:GetValue(v16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				local value3 = TweenService:GetValue(v16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local lerped = position:Lerp(v15, value2):Lerp(v15:Lerp(v14, value2), value2)
				flyingCactus:ScaleTo(1.15 + -1.0499999999999998 * value3)
				flyingCactus:PivotTo(CFrame.new(lerped) * CFrame.fromAxisAngle(v11, total2))

				if v16 >= 1 then
					local v17 = chestPosition2() or v14
					flyingCactus:Destroy()
					burst(v17, v9, 20, 13, 0.65, 180)
					Sound:Play(frozen2[math.random(1, #frozen2)], v17)
					return
				else
					local v17 = RunService.Heartbeat:Wait()
					total2 += v17 * 17
					total3 += v17
				end
			end

			break
		else
			local v14 = RunService.Heartbeat:Wait()
			total2 += v14 * 17 * 0.35
			total += v14
		end
	end
end

local function flyCactusToPlayer(p)
	flyCactusTo(p, chestPosition)
end

local v8 = {
	Standoff = 6.5,
	Spread = 4.4,
	GroundRayUp = 25,
	GroundRayDown = 80,
	SwingSpeed = 1.2,
	ImpactDelay = 0.34,
	Beats = { 0.75, 1.65, 2.55 },
	RegrowDelay = 3
}
local cframe = CFrame.new(0.050994873, -0.242996216, 0.052993774, 0, 1, 0, 1, 0, 0, 0, 0, -1)

local function cutlassAnimationIds()
	local animationIds = {}
	local success, result = pcall(function()
		local WeaponData = require(game.ReplicatedStorage.Modules.WeaponData)
		return WeaponData.cutlass.Moveset
	end)

	if not (success and result) then
		return animationIds, nil
	end

	for _, v9 in result.Basic or {} do
		if typeof(v9.AnimationId) == "string" then
			table.insert(animationIds, v9.AnimationId)
		end
	end

	local actions = result.Actions
	local animationId = actions and actions.Idle and actions.Idle.AnimationId

	if typeof(animationId) == "string" then
		return animationIds, animationId
	end

	return animationIds, nil
end

local function groundYAt(vector2: Vector3, filterDescendantsInstances, p: number)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = true
	local v9 = vector2 + createVector(0, 1, 0) * v8.GroundRayUp
	local raycastResult = workspace:Raycast(
		v9,
		createVector(0, 1, 0) * -(v8.GroundRayUp + v8.GroundRayDown),
		raycastParams
	)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return p
end

local function giveCutlass(clone)
	local cutlass = script:FindFirstChild("Cutlass")

	if not cutlass then
		warn("[Prickly Harvest] Cutlass.rbxm missing from the moment's Client module; bandits go bare-handed")
		return
	end

	local rightHand = clone:FindFirstChild("RightHand")
	local clone2 = cutlass:Clone()
	local right = clone2:FindFirstChild("Right")
	local handle = right and right:FindFirstChild("Handle")

	if rightHand and rightHand:IsA("BasePart") and right and handle and handle:IsA("BasePart") then
		local v9 = rightHand.CFrame * cframe * handle.CFrame:Inverse()

		for _, part in right:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.CFrame = v9 * part.CFrame

			if part.Name == "Hidden" or part.Parent.Name == "Hidden" then
				part.Transparency = 1
			end
		end

		for _, part in right:GetDescendants() do
			if not (part:IsA("BasePart") and part ~= handle) then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = handle
			weldConstraint.Part1 = part
			weldConstraint.Parent = handle
		end

		local motor6D = Instance.new("Motor6D")
		motor6D.Name = "DemoCutlassGrip"
		motor6D.Part0 = rightHand
		motor6D.Part1 = handle
		motor6D.C0 = cframe
		motor6D.Parent = rightHand
		right.Name = "DemoCutlass"
		right.Parent = clone
		clone2:Destroy()
	else
		warn("[Prickly Harvest] cutlass grip parts missing, skipping weapon")
		clone2:Destroy()
	end
end

local function spawnBandit(vector2: Vector3, position: Vector3, folder, characters, p: number)
	local bandit = script:FindFirstChild("Bandit")

	if not bandit then
		warn("[Prickly Harvest] Bandit.rbxm missing from the moment's Client module; re-sync/rebuild the place")
		return nil, nil
	end

	local clone = bandit:Clone()
	clone.Name = "PricklyHarvestDemoBandit"

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local primaryPart = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart")

	if primaryPart then
		clone.PrimaryPart = primaryPart
		local humanoid = clone:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end

		clone.Parent = folder
		clone:PivotTo(CFrame.lookAt(vector2, (Vector3.new(position.X, vector2.Y, position.Z))))
		local boundingBox, v9 = clone:GetBoundingBox()
		local v10 = groundYAt(vector2, characters, p) - (boundingBox.Position.Y - v9.Y * 0.5)
		clone:PivotTo(CFrame.new(0, v10, 0) * clone:GetPivot())
		local head = clone:FindFirstChild("Head")
		local accoutrement = clone:FindFirstChildWhichIsA("Accoutrement")
		local handle = accoutrement and accoutrement:FindFirstChild("Handle")

		if head and head:IsA("BasePart") and handle and handle:IsA("BasePart") then
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = head
			weldConstraint.Part1 = handle
			weldConstraint.Parent = handle
		end

		giveCutlass(clone)
		primaryPart.Anchored = true
		local parent = humanoid or clone:FindFirstChildWhichIsA("AnimationController") or Instance.new("AnimationController")

		if not parent.Parent then
			parent.Parent = clone
		end

		local animator = parent:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")

		if not animator.Parent then
			animator.Parent = parent
		end

		return clone, animator
	else
		warn("[Prickly Harvest] bandit rig has no HumanoidRootPart")
		clone:Destroy()
		return nil, nil
	end
end

local function loadTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()

	if success then
		return result
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chestOf(instance)
	if not instance.Parent then
		return nil
	end

	local upperTorso = instance:FindFirstChild("UpperTorso") or instance.PrimaryPart

	if upperTorso and upperTorso:IsA("BasePart") then
		return upperTorso.Position
	end

	return nil
end

local function playBanditDemo(instance, vector2: Vector3)
	local v9 = restPivotOf(instance) -- equivalent call inferred; original call site unknown
	local _, v10 = instance:GetBoundingBox()
	local v11 = v9.Position.Y - v10.Y * 0.5
	local cross = vector2:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.01 then
		return function() end
	end

	local unit = cross.Unit
	local folder = Instance.new("Folder")
	folder.Name = "PricklyHarvestDemo"
	folder.Parent = _WorldOrigin
	Debris:AddItem(folder, 60)
	local v12, animationId = cutlassAnimationIds()
	local v14 = {}
	local v15 = {}
	local characters = { folder, instance }
	local character = game.Players.LocalPlayer.Character

	if character then
		table.insert(characters, character)
	end

	for i = 1, 2 do
		local v16

		if i == 1 then
			v16 = v8.Spread
		else
			v16 = -v8.Spread
		end

		local v18, v19 = spawnBandit(
			v9.Position + vector2 * v8.Standoff + unit * v16,
			v9.Position,
			folder,
			characters,
			v11
		)

		if not (v18 and v19) then
			continue
		end

		table.insert(v14, v18)
		table.insert(v15, v19)

		if not animationId then
			continue
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		local animator = v19
		local success, result = pcall(function()
			return animator:LoadAnimation(animation)
		end)
		animation:Destroy()

		if not success then
			result = nil
		end

		if not result then
			continue
		end

		result.Looped = true
		result.Priority = Enum.AnimationPriority.Idle
		result:Play()
	end

	if #v14 == 0 then
		warn("[Prickly Harvest] no demo bandits spawned, skipping the showcase")
		folder:Destroy()
		return function() end
	else
		if #v12 == 0 then
			warn("[Prickly Harvest] no cutlass swing animations resolved from WeaponData")
		end

		local flag2 = false
		local threads = {}

		local function chop(p: number, p2: number, flag3: boolean)
			local v16 = v14[(p - 1) % #v14 + 1]
			local animator = v15[(p - 1) % #v15 + 1]

			if #v12 > 0 then
				local animationId2 = v12[(p2 - 1) % #v12 + 1]
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId2
				local success, result = pcall(function()
					return animator:LoadAnimation(animation)
				end)
				animation:Destroy()

				if not success then
					result = nil
				end

				if result then
					result.Priority = Enum.AnimationPriority.Action
					result:Play(0.1, 1, v8.SwingSpeed)
				end
			end

			table.insert(threads, task.delay(v8.ImpactDelay, function()
				if flag2 then
					return
				end

				if flag3 then
					task.spawn(flyCactusTo, instance, function()
						local v17 = v16

						if not v17.Parent then
							return nil
						end

						local upperTorso = v17:FindFirstChild("UpperTorso") or v17.PrimaryPart

						if upperTorso and upperTorso:IsA("BasePart") then
							return upperTorso.Position
						end

						return nil
					end)
					return
				end

				local v20 = chestOf(v16) -- equivalent call inferred; original call site unknown
				recoilCactus(instance, v20 or v9.Position)
			end))
		end

		for k, duration in v8.Beats do
			local v16 = k
			table.insert(threads, task.delay(duration, function()
				if flag2 then
					return
				end

				chop(v16, v16, v16 == #v8.Beats)
			end))
		end

		return function()
			if flag2 then
				return
			end

			flag2 = true

			for _, v16 in threads do
				pcall(task.cancel, v16)
			end

			folder:Destroy()
			stopRecoil(instance) -- equivalent call inferred; original call site unknown
			task.delay(v8.RegrowDelay, function()
				showCactus(instance) -- equivalent call inferred; original call site unknown
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCompass()
	if not flag then
		return
	end

	flag = false
	pcall(function()
		CompassTracker.removeTracker("PricklyHarvestMerchant")
	end)
end

local function startCompass()
	if flag then
		return
	end

	flag = true
	pcall(function()
		CompassTracker.createTracker("PricklyHarvestMerchant", {
			Target = function()
				local character = game.Players.LocalPlayer.Character
				local v9 = not character and createVector(0, 0, 0) or character:GetPivot().Position
				local closestNPC = NPCManager.getClosestNPC(v9, "Desert Merchant")
				local v10 = closestNPC and closestNPC:getModel()

				if v10 then
					return v10:GetPivot().Position + createVector(0, 10, 0)
				end

				return createVector(0, 0, 0)
			end,
			AlertIconSettings = {
				MaxDistance = 1000
			},
			IconSettings = {
				ShowIsland = false
			},
			ShowOffScreenAlert = true
		})
	end)
end

local PricklyHarvest = {}
PricklyHarvest.Repeatable = true

function PricklyHarvest.OnLoad(p)
	pricklyHarvest.Parent = workspace
	local flag2 = false
	p.Trove:Add(function()
		pricklyHarvest.Parent = script
		flag2 = true
		restoreAllCacti()
	end)
	local v9 = cactiFolderOf() -- equivalent call inferred; original call site unknown

	if v9 then
		p.Trove:Add(v9.ChildAdded:Connect(function(model)
			if model:IsA("Model") and model:GetAttribute("TreeType") == "Cactus" then
				local bloomedAt = v9:GetAttribute("BloomedAt")
				local v10

				if typeof(bloomedAt) == "number" then
					v10 = workspace:GetServerTimeNow() - bloomedAt <= v3.FreshWindow
				else
					v10 = false
				end

				if v10 then
					local v11 = nows[model]
					local v12

					if v11 == nil then
						v12 = false
					else
						v12 = os.clock() - v11 < 1
					end

					if not v12 then
						bloomCactus(model, math.random() * 0.6)
					end
				end
			end
		end))
	end

	task.defer(function()
		local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
		local v10 = os.clock() + 30
		local rescueHasan = nil

		while not (rescueHasan or flag2) do
			local loadedMoments = BonusMomentsController:GetLoadedMoments()

			if loadedMoments["Rescue Hasan"] then
				rescueHasan = loadedMoments["Rescue Hasan"]
			elseif v10 < os.clock() then
				return
			else
				task.wait(1)
			end
		end

		if flag2 or not rescueHasan then
			return
		end

		while not rescueHasan.Completed and rescueHasan.Progress ~= 2 and not flag2 do
			task.wait()
		end

		if flag2 then
			return
		end

		if not rescueHasan.Completed and rescueHasan.Progress == 2 and not flag then
			flag = true
			pcall(function()
				CompassTracker.createTracker("PricklyHarvestMerchant", {
					Target = function()
						local character = game.Players.LocalPlayer.Character
						local v11 = not character and createVector(0, 0, 0) or character:GetPivot().Position
						local closestNPC = NPCManager.getClosestNPC(v11, "Desert Merchant")
						local v12 = closestNPC and closestNPC:getModel()

						if v12 then
							return v12:GetPivot().Position + createVector(0, 10, 0)
						end

						return createVector(0, 0, 0)
					end,
					AlertIconSettings = {
						MaxDistance = 1000
					},
					IconSettings = {
						ShowIsland = false
					},
					ShowOffScreenAlert = true
				})
			end)
		end

		while not (v2 or flag2) do
			task.wait()
		end

		stopCompass() -- equivalent call inferred; original call site unknown
	end)
end

function PricklyHarvest.OnComplete(_, p, p2)
	restoreAllCacti()
	reflectProgress(0)

	if p and not p2 then
		Sound:Play("DesertBonusMoments.BF_DesertBonus_Collected_All_Cactuses_06")
	end
end

PricklyHarvest.RemoteEvents = {
	ResetCacti = function(_)
		restoreAllCacti()
		reflectProgress(0)
	end,
	UpdateProgress = function(_, p)
		reflectProgress(p)
	end,
	CactusHit = function(_, model)
		if typeof(model) == "Instance" and model:IsA("Model") and model.Parent then
			recoilCactus(model)
		end
	end,
	CactusHarvested = function(_, model)
		if typeof(model) == "Instance" and model:IsA("Model") and model.Parent then
			task.spawn(flyCactusToPlayer, model)
		end
	end
}

function PricklyHarvest.TalkedToMerchant(_)
	v2 = true
end

function PricklyHarvest.PlayCactusPan(_)
	local function noop() end

	local v9 = {
		stop = noop,
		focusMerchant = noop
	}
	local v10 = panOrigin() -- equivalent call inferred; original call site unknown

	if not v10 then
		warn("[Prickly Harvest] no Desert Merchant NPC or character to anchor the pan on")
		return v9
	end

	local v11 = demoCactusFor(v10)

	if not v11 then
		warn("[Prickly Harvest] the Desert Cacti folder is empty or missing, skipping the pan")
		return v9
	end

	finishBloom(v11) -- equivalent call inferred; original call site unknown
	local position = v11:GetPivot().Position
	local v12 = (v10 - position) * createVector(1, 0, 1)
	local v13 = not (v12.Magnitude > 1) and createVector(0, 0, 1) or v12.Unit
	local v14 = v13 * 34 + createVector(0, 15, 0)
	local v15 = CameraController.new()
	v15.Animations:AnimateTo(CFrame.lookAt(position + v14, position + createVector(0, 5, 0)), 1, 1.1)
	local v16 = playBanditDemo(v11, v13)
	local flag2 = false
	local v17 = false
	return {
		stop = function()
			if flag2 then
				return
			end

			flag2 = true
			v16()
			v15:FadeOut(0.8)
		end,
		focusMerchant = function()
			if flag2 or v17 then
				return
			end

			v17 = true
			v16()
			local v18 = merchantFocusCFrame()

			if v18 then
				v15.Animations:AnimateTo(v18, 1, 0.95)
				return
			end

			if flag2 then
				return
			end

			flag2 = true
			v16()
			v15:FadeOut(v.ReturnTime)
		end
	}
end

return PricklyHarvest