local createVector = vector.create
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = game.Players.LocalPlayer
local color = Color3.fromRGB(110, 195, 255)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local color2 = Color3.fromRGB(175, 220, 250)
local color3 = Color3.fromRGB(228, 250, 255)
local color4 = Color3.fromRGB(118, 214, 255)
local vector2 = Vector2.new(12, 52)
local vector3 = Vector2.new(16, 11)
local v = {
	"SHOP",
	"QUEST",
	"MISC.",
	"ROLL",
	"INVENTORY"
}

local function getAuraNames()
	local result = {}

	for _, v2 in v do
		result[v2] = true
	end

	local assets = game.ReplicatedStorage:FindFirstChild("Assets")
	local nPCAura

	if assets then
		nPCAura = assets:FindFirstChild("NPCAura")
	end

	if nPCAura then
		for _, child in nPCAura:GetChildren() do
			result[child.Name] = true
		end
	end

	return result
end

local function stripQuestAura(folder)
	local auraNames = getAuraNames()
	folder:SetAttribute("NoRing", true)
	folder:SetAttribute("NoAura", true)

	for _, descendant in folder:GetDescendants() do
		if auraNames[descendant.Name] or descendant.Name == "QuestBBG" then
			descendant:Destroy()
		end
	end
end

local object = setmetatable({}, {
	__mode = "k"
})

local function trainerHome(trainerModel)
	local v2 = object[trainerModel]

	if v2 then
		return v2
	end

	local floorPos = trainerModel:GetAttribute("FloorPos")
	local floorNormal = trainerModel:GetAttribute("FloorNormal")
	local v3 = {
		CF = trainerModel:GetPivot(),
		FloorPos = 0,
		FloorNormal = 0
	}

	if typeof(floorPos) ~= "Vector3" then
		floorPos = nil
	end

	v3.FloorPos = floorPos

	if typeof(floorNormal) ~= "Vector3" then
		floorNormal = nil
	end

	v3.FloorNormal = floorNormal
	object[trainerModel] = v3
	return v3
end

local function destroyStaleClones()
	for _, model in workspace:GetChildren() do
		if model.Name == "FrozenTrainer" and model:IsA("Model") then
			model:Destroy()
		end
	end
end

local function getTrainerModel(position: Vector3)
	local nPCs = workspace:FindFirstChild("NPCs")

	if not nPCs then
		return nil
	end

	local v2 = 1e999
	local v3 = nil

	for _, model in nPCs:GetChildren() do
		if not (model.Name == "Ability Teacher" and model:IsA("Model")) then
			continue
		end

		local magnitude = (model:GetPivot().Position - position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = model
		v2 = magnitude
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFloorPos(instance)
	instance:SetAttribute("FloorPos", instance:GetPivot().Position - createVector(0, 2.385, 0))
end

local function makeFrozenClone(trainerModel)
	local clone = trainerModel:Clone()
	clone.Name = "FrozenTrainer"
	stripQuestAura(clone)

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("BillboardGui") or descendant:IsA("ProximityPrompt") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			descendant:Destroy()
		end
	end

	local humanoid = clone:FindFirstChildWhichIsA("Humanoid", true)

	if humanoid then
		humanoid.Parent = clone
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true

local function refreshWalkExclusions(instance)
	local children = { instance }

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
end

local function getCloneAnimator(parent)
	local parent2 = parent:FindFirstChildWhichIsA("Humanoid", true)

	if parent2 then
		parent2.Parent = parent
		parent2.EvaluateStateMachine = false
	else
		parent2 = parent:FindFirstChildWhichIsA("AnimationController", true)

		if not parent2 then
			parent2 = Instance.new("AnimationController")
		end

		parent2.Parent = parent
	end

	local animator = parent2:FindFirstChildOfClass("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = parent2
	return animator2
end

local function playTrack(animator, animationId: string, priority, flag: boolean?)
	local v2 = nil
	pcall(function()
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		local track = animator:LoadAnimation(animation)
		track.Priority = priority
		track.Looped = flag == nil or flag
		track:Play()
		v2 = track
	end)
	return v2
end

local function prepareRigForAnimation(folder)
	local primaryPart = folder.PrimaryPart or folder:FindFirstChild("HumanoidRootPart") or folder:FindFirstChild("Torso")

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		return nil
	end

	folder.PrimaryPart = primaryPart

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == primaryPart
		part.CanCollide = false
	end

	return primaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundBelow(position: Vector3)
	local raycastResult = workspace:Raycast(position + createVector(0, 8, 0), createVector(-0, -258, -0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y + 2.385
	end

	return nil
end

local function dropCloneToGround(instance, fn)
	refreshWalkExclusions(instance)
	local pivot = instance:GetPivot()
	local v2 = groundBelow(pivot.Position) -- equivalent call inferred; original call site unknown

	if not v2 or pivot.Position.Y - v2 <= 0.1 then
		fn(pivot)
		return
	end

	local total = 0
	local total2 = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total2 += dt
		total += 260 * dt
		local pivot2 = instance:GetPivot()
		local v3 = pivot2.Position.Y - total * dt
		local v4 = v3 <= v2 or total2 >= 1.5 or instance.Parent == nil

		if v4 then
			v3 = v2
		end

		local v5 = CFrame.new(pivot2.Position.X, v3, pivot2.Position.Z) * pivot2.Rotation

		if instance.Parent then
			instance:PivotTo(v5)
		end

		if v4 then
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			fn(v5)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFrozenIdle(p)
	local frozenIdleTrack = p.MiscData.FrozenIdleTrack

	if frozenIdleTrack then
		frozenIdleTrack:Stop()
		p.MiscData.FrozenIdleTrack = nil
	end
end

local function startFrozenIdle(p, parent)
	if not prepareRigForAnimation(parent) then
		return
	end

	local cloneAnimator = getCloneAnimator(parent)

	if not (cloneAnimator and parent.Parent) then
		return
	end

	stopFrozenIdle(p) -- equivalent call inferred; original call site unknown
	local miscData = p.MiscData
	local idle = Enum.AnimationPriority.Idle
	local frozenIdleTrack = nil
	local animationId = "rbxassetid://123524799247897"
	local v4 = true
	pcall(function()
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		local track = cloneAnimator:LoadAnimation(animation)
		track.Priority = idle
		track.Looped = v4 == nil or v4
		track:Play()
		frozenIdleTrack = track
	end)
	miscData.FrozenIdleTrack = frozenIdleTrack
end

local function playBreakFree(data, parent, fn)
	local flag = false

	local function finish()
		if flag then
			return
		end

		flag = true
		stopFrozenIdle(data) -- equivalent call inferred; original call site unknown
		fn()
	end

	if prepareRigForAnimation(parent) then
		local cloneAnimator = getCloneAnimator(parent)
		local v2

		if cloneAnimator then
			local action = Enum.AnimationPriority.Action
			local v3 = nil
			local animationId = "rbxassetid://124304962980545"
			local v5 = false
			pcall(function()
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				local track = cloneAnimator:LoadAnimation(animation)
				track.Priority = action
				track.Looped = v5 == nil or v5
				track:Play()
				v3 = track
			end)
			v2 = v3
		end

		if v2 then
			v2.Stopped:Connect(finish)
			task.delay(6, finish)
		elseif not flag then
			flag = true
			stopFrozenIdle(data) -- equivalent call inferred; original call site unknown
			fn()
		end
	elseif not flag then
		flag = true
		stopFrozenIdle(data) -- equivalent call inferred; original call site unknown
		fn()
	end
end

local function walkCloneHome(instance, cframe: CFrame, fn)
	if prepareRigForAnimation(instance) then
		local cloneAnimator = getCloneAnimator(instance)
		local v2

		if cloneAnimator then
			local idle = instance:FindFirstChild("idle")
			local animationId = not (idle and idle:IsA("Animation")) and "rbxassetid://18884840386" or idle.AnimationId
			local idle2 = Enum.AnimationPriority.Idle
			local v4 = nil
			local v5 = nil
			pcall(function()
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				local track = cloneAnimator:LoadAnimation(animation)
				track.Priority = idle2
				track.Looped = v5 == nil or v5
				track:Play()
				v4 = track
			end)
			local movement = Enum.AnimationPriority.Movement
			local v6 = nil
			local animationId2 = "rbxassetid://9802959564"
			local v8 = nil
			pcall(function()
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId2
				local track = cloneAnimator:LoadAnimation(animation)
				track.Priority = movement
				track.Looped = v8 == nil or v8
				track:Play()
				v6 = track
			end)
			v2 = v6
		else
			v2 = nil
		end

		refreshWalkExclusions(instance)
		local flag = false
		local total = 0
		local renderSteppedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finish()
			if flag then
				return
			end

			flag = true

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			if v2 then
				v2:Stop()
			end

			if instance.Parent then
				instance:PivotTo(cframe)
			end

			fn()
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt

			if instance.Parent and not (total >= 20) then
				local position = instance:GetPivot().Position
				local v3 = (cframe.Position - position) * createVector(1, 0, 1)
				local magnitude = v3.Magnitude

				if not (magnitude <= 2.5) then
					local unit = v3.Unit
					local v4 = position + unit * math.min(12 * dt, magnitude)
					local raycastResult = workspace:Raycast(
						v4 + createVector(0, 8, 0),
						createVector(-0, -68, -0),
						raycastParams
					)
					local v5

					if raycastResult then
						v5 = raycastResult.Position.Y + 2.385
					else
						v5 = v4.Y
					end

					local v6 = v4.Y + (v5 - v4.Y) * math.min(1, dt * 8)
					local vector4 = Vector3.new(v4.X, v6, v4.Z)
					instance:PivotTo(CFrame.lookAt(vector4, vector4 + unit))
					return
				end
			end

			finish() -- equivalent call inferred; original call site unknown
		end)
	else
		warn("[Breaking the Ice] frozen trainer has no root part, skipping the thaw walk")
		fn()
	end
end

local function tryStartDialogue(p: string, items)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local v2 = DialogueController.new()
	v2:setTitle(p)
	v2:addPage("Main", function(object2)
		for _, item in items do
			object2:addText(item)
		end
	end)
	v2:build()
	return DialogueController.start(v2)
end

local function emitIceBurst(position: Vector3, p: number)
	local part = Instance.new("Part")
	part.Name = "IcebergBurst"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Position = position
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Enabled = false
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(0.4, 1)
	particleEmitter.Speed = NumberRange.new(12, 28)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Size = NumberSequence.new(0.8, 0)
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 235, 255))
	particleEmitter.Acceleration = createVector(0, -35, 0)
	particleEmitter.Parent = part
	part.Parent = workspace
	particleEmitter:Emit(p)
	Debris:AddItem(part, 3)
end

local function spawnIceShards(template, center: Vector3, p: number)
	local extentsSize = template:GetExtentsSize()
	local v2 = math.max(extentsSize.X, extentsSize.Z) * 0.5

	for _ = 1, p do
		local part = Instance.new("Part")
		part.Name = "IceShard"
		part.Material = Enum.Material.Ice
		part.Color = color2
		part.Transparency = 0.1
		part.Size = Vector3.new(0.4 + math.random() * 0.7, 0.4 + math.random() * 0.7, 0.4 + math.random() * 0.7)
		part.CanQuery = false
		part.CanTouch = false
		local v3 = math.random() * 2 * 3.141592653589793
		local vector4 = Vector3.new(math.cos(v3), 0, (math.sin(v3)))
		local v4 = (math.random() - 0.3) * extentsSize.Y * 0.5
		part.CFrame = CFrame.new(center + vector4 * v2 + createVector(0, 1, 0) * v4) * CFrame.Angles(
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793
		)
		part.Parent = workspace
		part.AssemblyLinearVelocity = vector4 * (12 + math.random() * 12) + createVector(0, 1, 0) * (10 + math.random() * 10)
		part.AssemblyAngularVelocity = Vector3.new(
			(math.random() - 0.5) * 12,
			(math.random() - 0.5) * 12,
			(math.random() - 0.5) * 12
		)
		TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.7), {
			Transparency = 1
		}):Play()
		Debris:AddItem(part, 1.4)
	end
end

local function newAwakeningBeam(vector4: Vector3, p: number, color5: Color3, transparency: number)
	local part = Instance.new("Part")
	part.Name = "AwakeningBeam"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color5
	part.Transparency = transparency
	part.Size = Vector3.new(p * 0.12, 700, p * 0.12)
	part.CFrame = CFrame.new(vector4 + createVector(0, 350, 0))
	local cylinderMesh = Instance.new("CylinderMesh")
	cylinderMesh.Parent = part
	part.Parent = workspace
	local tween = TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(p, 700, p)
	})
	tween.Completed:Connect(function()
		TweenService:Create(part, TweenInfo.new(2.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = Vector3.new(p * 0.05, 700, p * 0.05),
			Transparency = 1
		}):Play()
	end)
	tween:Play()
	Debris:AddItem(part, 2.7)
end

local function igniteAwakeningGlow(instance)
	local highlight = Instance.new("Highlight")
	highlight.Name = "AwakeningGlow"
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color3
	highlight.OutlineColor = color4
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = instance
	local tween = TweenService:Create(highlight, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FillTransparency = 0.1,
		OutlineTransparency = 0
	})
	tween.Completed:Connect(function()
		TweenService:Create(
			highlight,
			TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 1.2),
			{
				FillTransparency = 1,
				OutlineTransparency = 1
			}
		):Play()
	end)
	tween:Play()
	Debris:AddItem(highlight, 4.02)
end

local function attachAwakeningAura(instance)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "AwakeningAura"
	attachment.Parent = primaryPart
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color3
	pointLight.Brightness = 0
	pointLight.Range = 46
	pointLight.Shadows = false
	pointLight.Parent = attachment
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "AwakeningMotes"
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Rate = 120
	particleEmitter.Lifetime = NumberRange.new(0.5, 1.3)
	particleEmitter.Speed = NumberRange.new(8, 22)
	particleEmitter.SpreadAngle = Vector2.new(28, 28)
	particleEmitter.Acceleration = createVector(0, 34, 0)
	particleEmitter.Drag = 1.5
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Color = ColorSequence.new(color3, color4)
	particleEmitter.Parent = attachment
	particleEmitter:Emit(45)
	TweenService:Create(pointLight, TweenInfo.new(0.12), {
		Brightness = 5
	}):Play()
	task.delay(1.3199999999999998, function()
		if attachment.Parent then
			TweenService:Create(pointLight, TweenInfo.new(2.2), {
				Brightness = 0
			}):Play()
			particleEmitter.Rate = 26
		end
	end)
	task.delay(4.5, function()
		particleEmitter.Enabled = false
		Debris:AddItem(attachment, 2)
	end)
end

local function playAwakening(instance)
	refreshWalkExclusions(instance)
	local position = instance:GetPivot().Position
	local v2 = groundBelow(position) -- equivalent call inferred; original call site unknown
	local vector4

	if v2 then
		vector4 = Vector3.new(position.X, v2 - 2.385, position.Z)
	else
		vector4 = position
	end

	newAwakeningBeam(vector4, 8, color3, 0)
	newAwakeningBeam(vector4, 22.4, color4, 0.72)
	igniteAwakeningGlow(instance)
	attachAwakeningAura(instance)
	Effect.new("ShineExplosion"):play({
		Position = position,
		Size = 34,
		Lifetime = { 0.35, 0.7 }
	})
	Effect.new("Column"):play({
		CFrame = CFrame.new(vector4),
		Size = vector2,
		Color = color4,
		InnerColor = color3,
		ShockwaveColor = color3,
		Duration = 0.85
	})
	Effect.new("ShakeCam"):play({
		Magnitude = 11,
		Roughness = 4,
		FadeIn = 0.05,
		FadeOut = 2.4,
		PosInfluence = createVector(0.35, 0.35, 0.35),
		RotInfluence = createVector(1, 1, 1)
	})
	Sound:Play("LightBoom", position, nil, 0.85, 1)
	Sound:Play("IceSummon", position, nil, 0.9, 0.7)
end

local function playAwakeningLanding(cframe: CFrame)
	local position = cframe.Position - createVector(0, 2.385, 0)
	Effect.new("Column"):play({
		CFrame = CFrame.new(position),
		Size = vector3,
		Color = color4,
		InnerColor = color3,
		ShockwaveColor = color3,
		Duration = 0.55,
		ShockwaveMultiplier = 2
	})
	Effect.new("ShakeCam"):play({
		Magnitude = 7,
		Roughness = 9,
		FadeIn = 0,
		FadeOut = 0.8,
		PosInfluence = createVector(0.4, 0.4, 0.4),
		RotInfluence = createVector(1, 1, 1)
	})
	emitIceBurst(position, 40)
	Sound:Play("ElectroDrop_Land", position, nil, 0.9, 0.9)
	Sound:Play("IceShoot", position, nil, 0.7, 0.5)
end

local function setIceTransparency(folder, p: number?)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local breakingIceTransparency = part:GetAttribute("BreakingIceTransparency")

		if typeof(breakingIceTransparency) ~= "number" then
			breakingIceTransparency = part.Transparency
			part:SetAttribute("BreakingIceTransparency", breakingIceTransparency)
		end

		part.Transparency = p or breakingIceTransparency
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopShake(p)
	local shakeConnection = p.MiscData.ShakeConnection

	if shakeConnection then
		shakeConnection:Disconnect()
		p.MiscData.ShakeConnection = nil
	end

	p.MiscData.ShakePriority = nil
	local template = p.MiscData.Template
	local restCF = p.MiscData.RestCF

	if template and restCF and template.Parent == workspace then
		template:PivotTo(restCF)
	end
end

local function startShake(p, shakeDuration: number, shakePosition: number, shakeRotation: number, shakePriority: number)
	local template = p.MiscData.Template
	local restCF = p.MiscData.RestCF

	if not (template and restCF) or p.MiscData.ShakeConnection and shakePriority < (p.MiscData.ShakePriority or 0) then
		return
	end

	p.MiscData.ShakeElapsed = 0
	p.MiscData.ShakeDuration = shakeDuration
	p.MiscData.ShakePosition = shakePosition
	p.MiscData.ShakeRotation = shakeRotation
	p.MiscData.ShakePriority = shakePriority

	if p.MiscData.ShakeConnection then
		return
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local shakeDuration2 = p.MiscData.ShakeDuration or 0.4
		local shakeElapsed = (p.MiscData.ShakeElapsed or 0) + dt
		p.MiscData.ShakeElapsed = shakeElapsed

		if shakeDuration2 <= shakeElapsed or template.Parent ~= workspace then
			stopShake(p) -- equivalent call inferred; original call site unknown
		else
			local shakePosition2 = p.MiscData.ShakePosition or 0.35
			local shakeRotation2 = p.MiscData.ShakeRotation or 0.026179938779914945
			local v3 = 1 - shakeElapsed / shakeDuration2
			local v4 = Vector3.new(
				math.noise(shakeElapsed * 14, 0, 0),
				math.noise(0, shakeElapsed * 14 * 1.15, 0) * 0.55,
				math.noise(0, 0, shakeElapsed * 14 * 0.9)
			) * shakePosition2 * v3
			local cframe = CFrame.Angles(
				math.noise(shakeElapsed * 14 * 1.2, 4, 0) * shakeRotation2 * v3,
				math.noise(0, shakeElapsed * 14, 8) * shakeRotation2 * 0.65 * v3,
				math.noise(12, 0, shakeElapsed * 14 * 1.1) * shakeRotation2 * v3
			)
			template:PivotTo(restCF * CFrame.new(v4) * cframe)
		end
	end)
	p.MiscData.ShakeConnection = renderSteppedConnection
end

local function playIdleShake(p)
	local template = p.MiscData.Template

	if not template or template.Parent ~= workspace then
		return
	end

	startShake(p, 0.9, 0.12, 0.010471975511965976, 1)

	for _, emitter in template:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "CrackEmit" then
			emitter:Emit(3)
		end
	end

	local center = p.MiscData.Center

	if center then
		Sound:Play("IceShoot", center, nil, 0.55, 0.22)
	end
end

local v2 = {
	{
		id = "Thought1",
		text = "Hm... looks like someone's trapped inside that ice. How does someone even end up like this?",
		hold = 3.6
	},
	{
		id = "Thought2",
		text = "Doesn't look like they're getting out on their own anytime soon. I can't just leave them in there.",
		hold = 3.4
	},
	{
		id = "Thought3",
		text = "Maybe a few good hits will break this thing open..?",
		hold = 3
	}
}

local function thoughtLines()
	local texts = {}

	for _, v3 in v2 do
		table.insert(texts, v3.text)
	end

	return texts
end

local function playDiscoveryCutscene(p)
	local center = p.MiscData.Center
	local template = p.MiscData.Template

	if p.MiscData.Broken or not center or not template or template.Parent ~= workspace then
		local texts = {}

		for _, v5 in v2 do
			table.insert(texts, v5.text)
		end

		tryStartDialogue("", texts)
	else
		local DialogueController = require(game.ReplicatedStorage.DialogueController)

		if DialogueController.Active then
			local texts = {}

			for _, v5 in v2 do
				table.insert(texts, v5.text)
			end

			tryStartDialogue("", texts)
		else
			local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
			local character = localPlayer.Character
			local v3 = not character and createVector(0, 0, 0) or (center - character:GetPivot().Position) * createVector(
				1,
				0,
				1
			)
			local v4 = not (v3.Magnitude > 0.05) and createVector(0, 0, 1) or v3.Unit
			local v5 = DialogueController.new()
			v5:setTitle("")
			local v6 = {
				controller = nil,
				cancelled = false
			}

			for k, v7 in v2 do
				local v8 = k
				local v9 = v7
				v5:addPage(v7.id, function(object2)
					if v8 == 1 and not v6.controller then
						local controller = CameraController.new()
						v6.controller = controller
						p.MiscData.CutsceneActive = true
						v5:getMaid():GiveTask(function()
							v6.cancelled = true
							p.MiscData.CutsceneActive = false
							controller:FadeOut(0.6)
						end)
						local v11 = center - v4 * 26 + createVector(0, 7, 0)
						controller.Animations:AnimateTo(CFrame.lookAt(v11, center), 1, 1.5)
						task.delay(2.2, function()
							if v6.cancelled then
								return
							end

							local v12 = center - v4 * 13 + createVector(0, 3, 0)
							controller.Animations:AnimateTo(CFrame.lookAt(v12, center), 1, 1.1)
							controller.Animations:PivotAroundY(center, 26, 1, 0.55)
						end)
						task.delay(1.6, function()
							if not v6.cancelled then
								playIdleShake(p)
							end
						end)
					end

					object2:setTitle("")
					object2:noCancel()
					object2:addText(v9.text)
					local v10 = v2[v8 + 1]

					if v10 then
						object2:jumpToOnAdvance(v10.id)
					end

					object2:advanceAfterDelay(v9.hold)
				end)
			end

			v5:build()

			if DialogueController.start(v5) == nil then
				v6.cancelled = true
				p.MiscData.CutsceneActive = false
				local controller = v6.controller

				if controller then
					controller:FadeOut(0.6)
				end
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFeedback(p)
	local feedbackTween = p.MiscData.FeedbackTween

	if feedbackTween then
		feedbackTween:Cancel()
		p.MiscData.FeedbackTween = nil
	end

	local feedbackHighlight = p.MiscData.FeedbackHighlight

	if feedbackHighlight then
		feedbackHighlight:Destroy()
		p.MiscData.FeedbackHighlight = nil
	end
end

local function flashFeedback(p)
	local template = p.MiscData.Template

	if not template then
		return
	end

	releaseFeedback(p) -- equivalent call inferred; original call site unknown
	local highlight = Instance.new("Highlight")
	highlight.Name = "IcebergHitFeedback"
	highlight.Adornee = template
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.2
	highlight.OutlineTransparency = 0
	highlight.Parent = template
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	p.MiscData.FeedbackHighlight = highlight
	p.MiscData.FeedbackTween = tween
	tween.Completed:Connect(function()
		if p.MiscData.FeedbackTween == tween then
			releaseFeedback(p) -- equivalent call inferred; original call site unknown
		end
	end)
	tween:Play()
end

return {
	DataName = script.Name,
	LoadWhenCompleted = true,
	OnLoad = function(object2)
		if object2.Completed then
			return
		end

		object2:FireServer("Init")
	end,
	RemoteEvents = {
		Setup = function(data)
			if data.Completed or data.MiscData.SetUp then
				return
			end

			data.MiscData.SetUp = true
			destroyStaleClones()
			local iceberg = script:WaitForChild("Iceberg", 10)

			if not (iceberg and iceberg:IsA("Model")) then
				return
			end

			local pivot = iceberg:GetPivot()
			local position = pivot.Position
			data.MiscData.Template = iceberg
			data.MiscData.RestCF = pivot
			data.MiscData.Center = position
			local v3 = nil
			local CF = nil
			local floorPos = nil
			local floorNormal = nil
			local v4 = nil

			local function ensureTrainerFrozen()
				if not v3 then
					local trainerModel = getTrainerModel(position)

					if not trainerModel then
						return
					end

					v3 = trainerModel
					local v5 = trainerHome(trainerModel)
					CF = v5.CF
					floorPos = v5.FloorPos
					floorNormal = v5.FloorNormal
					local frozenClone = makeFrozenClone(trainerModel)
					frozenClone:PivotTo(CF.Rotation + position)
					frozenClone.Parent = workspace
					v4 = frozenClone
					task.spawn(startFrozenIdle, data, frozenClone)
				end

				local v5 = v3
				local v6 = CF
				local v7 = v6.Position - createVector(0, 500, 0)

				if not v5:GetAttribute("Destroyed") and (v5:GetPivot().Position - v7).Magnitude > 50 then
					v5:PivotTo(v6 - createVector(0, 500, 0))
					setFloorPos(v5) -- equivalent call inferred; original call site unknown
				end
			end

			ensureTrainerFrozen()
			setIceTransparency(iceberg, 0.55)
			iceberg.Parent = workspace

			local function revealTrainer(flag: boolean?)
				local v5 = v3
				local v6 = v4

				if v5 and CF and not v5:GetAttribute("Destroyed") then
					v5:PivotTo(CF)

					if floorNormal then
						v5:SetAttribute("FloorNormal", floorNormal)
					end

					if floorPos then
						v5:SetAttribute("FloorPos", floorPos)
					else
						setFloorPos(v5) -- equivalent call inferred; original call site unknown
					end
				end

				if not v6 then
					return
				end

				if flag and v5 then
					task.spawn(function()
						local lastTime = os.clock()

						while os.clock() - lastTime < 1 and not v5.Parent do
							task.wait()
						end

						if v4 == v6 then
							v4 = nil
						end

						v6:Destroy()
					end)
					return
				end

				v4 = nil
				v6:Destroy()
			end

			local v5 = false
			local flag = false

			local function restore()
				if flag then
					return
				end

				flag = true
				stopShake(data) -- equivalent call inferred; original call site unknown
				releaseFeedback(data) -- equivalent call inferred; original call site unknown
				setIceTransparency(iceberg, nil)
				iceberg.Parent = script

				if not v5 then
					stopFrozenIdle(data) -- equivalent call inferred; original call site unknown
				end

				if v5 and data.MiscData.Completing then
					return
				end

				revealTrainer()
			end

			local function beginThaw()
				if flag or v5 then
					return
				end

				v5 = true
				data.MiscData.Completing = true
				stopShake(data) -- equivalent call inferred; original call site unknown
				releaseFeedback(data) -- equivalent call inferred; original call site unknown
				setIceTransparency(iceberg, nil)
				iceberg.Parent = script
				local v8 = v4
				local v9 = CF

				if not (v8 and v8.Parent and v9) then
					revealTrainer()
					return
				end

				local flag2 = false
				local v10 = false

				local function walkHome()
					if not (flag2 and v10) then
						return
					end

					if v8.Parent then
						walkCloneHome(v8, v9, function()
							revealTrainer(true)
						end)
					else
						revealTrainer(true)
					end
				end

				playAwakening(v8)
				playBreakFree(data, v8, function()
					v10 = true

					if flag2 then
						if not v10 then
							return
						end

						if v8.Parent then
							walkCloneHome(v8, v9, function()
								revealTrainer(true)
							end)
						else
							revealTrainer(true)
						end
					end
				end)
				dropCloneToGround(v8, function(p)
					flag2 = true

					if v8.Parent then
						playAwakeningLanding(p)
					end

					if flag2 then
						if not v10 then
							return
						end

						if v8.Parent then
							walkCloneHome(v8, v9, function()
								revealTrainer(true)
							end)
						else
							revealTrainer(true)
						end
					end
				end)
			end

			data.MiscData.Restore = restore
			data.MiscData.BeginThaw = beginThaw
			data.Trove:Add(restore)
			local flag2 = false
			local total = 0
			local total2 = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt

				if total < 0.5 then
					return
				end

				total = 0

				if data.MiscData.Broken then
					heartbeatConnection:Disconnect()
					return
				end

				ensureTrainerFrozen()
				local character = localPlayer.Character

				if not character then
					return
				end

				local magnitude = (character:GetPivot().Position - position).Magnitude
				total2 += 0.5

				if total2 >= 5 and magnitude <= 140 then
					total2 = 0

					if not data.MiscData.CutsceneActive then
						playIdleShake(data)
					end
				end

				if flag2 then
					return
				end

				if magnitude <= 48.75 then
					flag2 = true
					task.spawn(playDiscoveryCutscene, data)
				end
			end)
			data.Trove:Add(heartbeatConnection)
		end,
		IcebergHit = function(p, p2: number, p3: number)
			local center = p.MiscData.Center

			if not center or p.MiscData.Broken then
				return
			end

			Sound:Play("IceShoot", center, nil, p2 / p3 * 0.4 + 0.9, 0.5)
			local template = p.MiscData.Template

			if template and template.Parent == workspace then
				for _, emitter in template:GetDescendants() do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "CrackEmit" then
						emitter:Emit(p2 * 2 + 6)
					end
				end

				spawnIceShards(template, center, 5)
				startShake(p, 0.4, 0.35, 0.026179938779914945, 2)
				flashFeedback(p)
			end
		end,
		IcebergBroken = function(p)
			if p.MiscData.Broken then
				return
			end

			p.MiscData.Broken = true
			local center = p.MiscData.Center
			local template = p.MiscData.Template

			if center then
				Sound:Play("IcebergExplosion", center, nil, 1, 0.8)
				emitIceBurst(center, 60)

				if template and template.Parent == workspace then
					spawnIceShards(template, center, 14)
				end
			end

			local beginThaw = p.MiscData.BeginThaw

			if beginThaw then
				beginThaw()
			end

			task.spawn(function()
				task.wait(0.4)
				local v3 = {
					"*GASP!* Finally... I'm free! I thought I was going to become an ice sculpture.",
					"You're stronger than you look. Not many people could've broken through that thick ball of ice. I could've gotten through it... with some more time... *ahem*",
					"Thanks for helping me out. You know... with a little training, I could teach you how to put that strength to much better use. Come find me when you're ready!"
				}
				local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("FrozenAbilityTeacher")
				local v4

				if interactQuestGiver then
					v4 = interactQuestGiver.OpeningDialogue
				end

				for _, v5 in v4 or {} do
					table.insert(v3, v5)
				end

				tryStartDialogue("Ability Teacher", v3)
			end)
		end
	}
}