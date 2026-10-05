local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local SwimmingBreathUI = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.SwimmingBreathUI)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local clientEffects = ReplicatedStorage.Communication.CnC.ClientEffects
local localPlayer = Players.LocalPlayer
local get_core_anim = Character_info_provider.get_core_anim(localPlayer, "swimIdle")
local get_core_anim2 = Character_info_provider.get_core_anim(localPlayer, "swimPaddle")
local get_core_anim3 = Character_info_provider.get_core_anim(localPlayer, "swimDive Down")
local get_core_anim4 = Character_info_provider.get_core_anim(localPlayer, "swimDrowning")
local swim = ReplicatedStorage.Assets.Swim
local swimEffectIdle = swim.SwimEffectIdle
local surfaceSwim = swim.SurfaceSwim
local bodyPartTrail = swim.BodyPartTrail
local drowningEffect = swim.DrowningEffect
local bodyPartParticles = swim.BodyPartParticles
local sounds = ReplicatedStorage.Assets.Swim.Sounds
local random = Random.new()
Checker.Swimming = false
Checker.ShallowWater = false
local parent = script.Parent.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local head = parent:WaitForChild("Head")
local holder = parent:WaitForChild("OverHead"):WaitForChild("Holder")
local getvaluesfolder = Utility.getvaluesfolder(parent, true)

if getvaluesfolder ~= nil then
	for _, child in getvaluesfolder:GetChildren() do
		if child.Name == "WalkSpeed" and child:GetAttribute("SeabedWalk") then
			child:Destroy()
		end
	end
end

local v = {
	"Stun",
	"Strict_Stun",
	"CombatStun",
	"RagDoll",
	"Ragdoll",
	"ragdoll",
	"ragDoll"
}

local function isStunnedOrRagdolled()
	if getvaluesfolder == nil then
		return false
	end

	for _, childName in v do
		if getvaluesfolder:FindFirstChild(childName) ~= nil then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playOneShot(instance)
	local clone = instance:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 0.25)
end

local v2 = 0
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function setSwimState(swimState: number)
	if parent:GetAttribute("SwimState") ~= swimState then
		parent:SetAttribute("SwimState", swimState)
	end

	if swimState ~= v2 then
		v2 = swimState
		SignalEvent.ToServer("Swim", "State", swimState)
	end
end

local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setCameraInSwimPart(cameraInSwimPart: boolean)
	if cameraInSwimPart == v3 then
		return
	end

	v3 = cameraInSwimPart
	parent:SetAttribute("CameraInSwimPart", cameraInSwimPart)

	if cameraInSwimPart ~= v4 then
		v4 = cameraInSwimPart

		if cameraInSwimPart == true then
			playOneShot(sounds.PS2DP2waterDIVE) -- equivalent call inferred; original call site unknown
		else
			playOneShot(sounds.PS2DP2waterCOMEUP) -- equivalent call inferred; original call site unknown
		end
	end
end

if parent:GetAttribute("SwimState") ~= 0 then
	parent:SetAttribute("SwimState", 0)
end

if v2 ~= 0 then
	v2 = 0
	SignalEvent.ToServer("Swim", "State", 0)
end

if v3 ~= false then
	v3 = false
	parent:SetAttribute("CameraInSwimPart", false)

	if v4 ~= false then
		v4 = false
		playOneShot(sounds.PS2DP2waterCOMEUP) -- equivalent call inferred; original call site unknown
	end
end

local children = {}

for _, childName in {
	"LeftHand",
	"RightHand",
	"LeftFoot",
	"RightFoot"
} do
	local child = parent:FindFirstChild(childName)

	if child then
		table.insert(children, child)
	end
end

local v5 = {
	humanoid.Animator:LoadAnimation(get_core_anim),
	humanoid.Animator:LoadAnimation(get_core_anim2),
	humanoid.Animator:LoadAnimation(get_core_anim3),
	(humanoid.Animator:LoadAnimation(get_core_anim4))
}
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function maxBreath()
	local stat = PlayerStatResolver.GetStat(localPlayer, "Breath Duration Factor")
	return (math.max(17 * (1 + (typeof(stat) ~= "number" and 0 or stat)), 1))
end

local v6 = {
	Breath = 1,
	Drowning = false,
	DiveStart = nil
}
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil

local function updateBreathBar()
	if v6.Breath < 1 and not v6.Drowning then
		local breath = v6.Breath

		if v8 == nil then
			v8, v9, v10, v11, v12, v13 = SwimmingBreathUI(holder, {
				ratio = breath,
				bubbles = {
					breath > 0,
					breath > 0.2,
					breath > 0.4,
					breath > 0.6,
					breath > 0.8
				}
			})
		end

		if v9 ~= nil then
			v9:Set(breath)
		end

		if v10 ~= nil then
			v10:Set(1 - breath)
		end

		if v11 ~= nil then
			v11:Set(UDim2.fromScale(breath, 2))
		end

		if v12 ~= nil then
			v12:Set(v6.Breath < 0.25 and 1 or 0)
		end

		if v13 ~= nil then
			for i = 1, 5 do
				local v14 = v13[i]

				if v14 ~= nil then
					v14:Set((i - 1) / 5 < breath)
				end
			end
		end
	elseif v8 ~= nil then
		v8()
		v8 = nil
		v9 = nil
		v10 = nil
		v11 = nil
		v12 = nil
		v13 = nil
	end
end

local total = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function accumulateDrownDamage(p: number)
	total += p

	if total >= 0.5 then
		SignalEvent.ToServer("Swim", "DrownDamage", total)
		total = 0
	end
end

local function tickBreath(p: number, flag: boolean)
	local v14 = MinigameSettings.Get("NoDrowning") == true

	if v14 then
		flag = false
	end

	local drowning = v6.Drowning
	local v15 = not v14

	if v15 then
		if v7 == nil or not (v7.current > 0) or getvaluesfolder == nil then
			v15 = false
		else
			local flag2 = true

			for _, childName in v do
				if getvaluesfolder:FindFirstChild(childName) == nil then
					continue
				end

				v15 = true
				flag2 = false
				break
			end

			if flag2 then
				v15 = false
			end
		end
	end

	if v15 then
		if v6.DiveStart == nil then
			v6.DiveStart = os.clock()
		end

		local v16 = v6
		local breath = v6.Breath
		v16.Breath = math.max(0, breath - p / maxBreath())
		v6.Drowning = true

		if humanoid.Health > 0 then
			accumulateDrownDamage(p) -- equivalent call inferred; original call site unknown
		end
	elseif flag then
		if v6.DiveStart == nil then
			v6.DiveStart = os.clock()
		end

		if os.clock() - v6.DiveStart >= 1.5 then
			local v16 = v6
			local breath = v6.Breath
			v16.Breath = math.max(0, breath - p / maxBreath())

			if v6.Breath <= 0 then
				v6.Drowning = true

				if humanoid.Health > 0 then
					accumulateDrownDamage(p) -- equivalent call inferred; original call site unknown
				end
			end
		end

		if v6.Breath > 0 then
			v6.Drowning = false
		end
	else
		v6.DiveStart = nil
		v6.Drowning = false

		if v6.Breath < 1 then
			local v16 = v6
			local breath = v6.Breath
			local v17 = p * 2
			v16.Breath = math.min(1, breath + v17 / maxBreath())
		end
	end

	updateBreathBar()

	if not v6.Drowning then
		total = 0
	end

	if drowning ~= v6.Drowning then
		parent:SetAttribute("SwimDrowning", v6.Drowning)
		SignalEvent.ToServer("Swim", "Drowning", v6.Drowning)

		if v7 then
			v7.update()
			v7.updateCamera()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireSplash(p: string, cframe: CFrame)
	clientEffects:Fire(p, cframe)
	SignalEvent.ToServer("Swim", "Splash", p, cframe)
end

local function getPartTopY(instance)
	local cFrame = instance.CFrame
	local size = instance.Size
	return cFrame.Y + math.abs(cFrame.RightVector.Y) * size.X / 2 + math.abs(cFrame.UpVector.Y) * size.Y / 2 + math.abs(cFrame.LookVector.Y) * size.Z / 2 - 0.25
end

local v14 = nil
local renderSteppedConnection = nil
local v15 = nil

local function setEffectPosition(clone, worldPosition: Vector3)
	if clone:IsA("Attachment") then
		clone.WorldPosition = worldPosition
	elseif clone:IsA("Model") then
		clone:PivotTo(CFrame.new(worldPosition))
	elseif clone:IsA("BasePart") then
		clone.CFrame = CFrame.new(worldPosition)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWalkingIdle()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v14 then
		v14.Name = "--"
		vfxUtility.EnableAll(v14, false)
		DebrisModule:AddItem(v14, 1)
		v14 = nil
	end

	v15 = nil
end

local function startWalkingIdle(equipped)
	if v14 ~= nil and v15 == equipped then
		return
	end

	stopWalkingIdle() -- equivalent call inferred; original call site unknown
	v15 = equipped
	local texture = equipped.Parent and equipped.Parent:FindFirstChild("Texture")

	if texture == nil or not texture:IsA("BasePart") then
		texture = equipped
	end

	local v16 = getPartTopY(texture) + 0.15
	local clone = swimEffectIdle:Clone()
	clone.Name = "WalkingSwimEffectIdle"
	clone.Parent = texture
	v14 = clone
	local position = humanoidRootPart.Position
	setEffectPosition(clone, Vector3.new(position.X, v16, position.Z))
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if clone == nil or clone.Parent == nil or (humanoidRootPart == nil or humanoidRootPart.Parent == nil) then
			return
		end

		local position2 = humanoidRootPart.Position
		setEffectPosition(clone, Vector3.new(position2.X, v16, position2.Z))
	end)
end

local v16 = {}
local v17 = {
	Equipped = nil
}
local tweens = {}
local tweenInfo = TweenInfo.new(1)

local function tweenTransparency(instance, transparency: number)
	local v18 = tweens[instance]

	if v18 then
		v18:Cancel()
	end

	local tween = TweenService:Create(instance, tweenInfo, {
		Transparency = transparency
	})
	tweens[instance] = tween
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTexture(p)
	local parent2 = p.Parent

	if parent2 == nil then
		return nil
	end

	return parent2:FindFirstChild("Texture")
end

local function forEachFadeTarget(p, fn)
	local texture = getTexture(p) -- equivalent call inferred; original call site unknown

	if texture == nil then
		return
	end

	fn(texture)

	for _, child in texture:GetChildren() do
		if child:IsA("Texture") or child:IsA("Decal") then
			fn(child)
		end
	end
end

local v18 = false
local v19 = nil
local v20 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshFade(p)
	if p == nil then
		return
	end

	local v21 = v20 == p and 0.7 or v18 and v19 == p and 0.3 or 0
	forEachFadeTarget(p, function(instance)
		local originalTransparency = instance:GetAttribute("OriginalTransparency")

		if typeof(originalTransparency) ~= "number" then
			originalTransparency = instance.Transparency
			instance:SetAttribute("OriginalTransparency", originalTransparency)
		end

		tweenTransparency(instance, originalTransparency + (1 - originalTransparency) * v21)
	end)
end

local v21 = 0
local attachment = Instance.new("Attachment")
attachment.Name = "SwimAttachment"
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.MaxForce = 20000
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VectorVelocity = createVector(0, 0, 0)
linearVelocity.Attachment0 = attachment
linearVelocity.Parent = attachment
linearVelocity.Enabled = false
local alignPosition = Instance.new("AlignPosition")
alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
alignPosition.Attachment0 = attachment
alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
alignPosition.MaxAxesForce = createVector(0, 20000, 0)
alignPosition.Responsiveness = 20
alignPosition.Enabled = false
alignPosition.Parent = attachment
local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.Attachment0 = attachment
alignOrientation.Responsiveness = 20
alignOrientation.MaxTorque = 40000
alignOrientation.Parent = attachment

-- equivalent calls inferred from this helper; original call sites unknown
local function hasFloorBelow()
	return workspace:Raycast(humanoidRootPart.Position, createVector(0, -3.5, 0), RaycastHelper.Crater) ~= nil
end

local function isCameraInsidePart(instance)
	if not (instance and instance.Parent) then
		return false
	end

	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(currentCamera.CFrame.Position)
	local halfSize = instance.Size / 2
	return math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
end

local v22 = false
local colorCorrectionEffect = nil
local blurEffect = nil
local depthOfFieldEffect = nil
local tweenInfo2 = TweenInfo.new(0.3)
local color = Color3.new(0.4, 0.635294, 0.854902)
local color2 = Color3.new(1, 0.2, 0.2)
local v23 = nil
local tweenInfo3 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local drowning = false

local function applyCCEState()
	if not colorCorrectionEffect then
		return
	end

	if v6.Drowning then
		if v23 then
			v23:Cancel()
		end

		colorCorrectionEffect.TintColor = color
		v23 = TweenService:Create(colorCorrectionEffect, tweenInfo3, {
			TintColor = color2
		})
		v23:Play()
	else
		if v23 then
			v23:Cancel()
			v23 = nil
		end

		TweenService:Create(colorCorrectionEffect, tweenInfo2, {
			TintColor = color
		}):Play()
	end
end

local swimcorrection = currentCamera:FindFirstChild("swimcorrection")

if swimcorrection then
	swimcorrection:Destroy()
end

local swimblur = currentCamera:FindFirstChild("swimblur")

if swimblur then
	swimblur:Destroy()
end

local swimdepth = currentCamera:FindFirstChild("swimdepth")

if swimdepth then
	swimdepth:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addBodyPartTrails()
	for _, parent2 in children do
		local clone = bodyPartTrail:Clone()
		clone.Parent = parent2
		clone.Name = "BodyPartTrialForSwimming"
	end
end

local function removeBodyPartTrails()
	for _, v24 in children do
		for _, child in ipairs(v24:GetChildren()) do
			if child.Name ~= "BodyPartTrialForSwimming" then
				continue
			end

			child.Name = "--"
			child.Trail.Enabled = false
			task.delay(1, child.Destroy, child)
		end
	end
end

local function addBodyPartParticles()
	for _, parent2 in children do
		for _, child in bodyPartParticles:GetChildren() do
			local clone = child:Clone()
			clone.Parent = parent2
			clone.Name = "BodyPartTrailParticlesForSwim"
		end
	end
end

local function removeBodyPartParticles()
	for _, v24 in children do
		for _, child in ipairs(v24:GetChildren()) do
			if child.Name ~= "BodyPartTrailParticlesForSwim" then
				continue
			end

			child.Enabled = false
			child.Name = "--"
			task.delay(1, child.Destroy, child)
		end
	end
end

local function hasTrails(p: number)
	return p == 2 or p == 3 or p == 4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function hasParticles(p: number)
	return p == 3 or p == 4
end

local tweenInfo4 = TweenInfo.new(0.45)

local function clearDrownEffects()
	for _, child in head:GetChildren() do
		if child.Name ~= "SwimDrownEffect" then
			continue
		end

		child.Name = "--"
		local dP2PS2waterDROWNloop = child:FindFirstChild("DP2PS2waterDROWNloop")

		if dP2PS2waterDROWNloop ~= nil and dP2PS2waterDROWNloop:IsA("Sound") then
			TweenService:Create(dP2PS2waterDROWNloop, tweenInfo4, {
				Volume = 0
			}):Play()
		end

		vfxUtility.EnableAll(child, false)
		DebrisModule:AddItem(child, 1)
	end
end

local v24 = {
	{
		Add = function()
			local clone = swimEffectIdle:Clone()
			clone.Parent = humanoidRootPart
			clone.Name = "SwimEffectIdle"
		end,
		Remove = function()
			local swimEffectIdle2 = humanoidRootPart:FindFirstChild("SwimEffectIdle")

			if swimEffectIdle2 ~= nil then
				swimEffectIdle2.Name = "--"
				vfxUtility.EnableAll(swimEffectIdle2, false)
				DebrisModule:AddItem(swimEffectIdle2, 1)
			end
		end
	},
	{
		Add = function(p)
			local clone = surfaceSwim:Clone()
			clone.Parent = humanoidRootPart
			clone.Name = "SwimEffectSurfaceSwim"
			local clone2 = sounds.PS2swimloopTRUE:Clone()
			clone2.Parent = clone
			clone2:Play()
			local volume = clone2.Volume
			clone2.Volume = 0
			TweenService:Create(clone2, tweenInfo4, {
				Volume = volume
			}):Play()

			if p ~= 2 and p ~= 3 and p ~= 4 then
				addBodyPartTrails() -- equivalent call inferred; original call site unknown
			end
		end,
		Remove = function(p)
			local swimEffectSurfaceSwim = humanoidRootPart:FindFirstChild("SwimEffectSurfaceSwim")

			if swimEffectSurfaceSwim ~= nil then
				TweenService:Create(swimEffectSurfaceSwim.PS2swimloopTRUE, tweenInfo4, {
					Volume = 0
				}):Play()
				swimEffectSurfaceSwim.Name = "--"
				vfxUtility.EnableAll(swimEffectSurfaceSwim, false)
				DebrisModule:AddItem(swimEffectSurfaceSwim, 1)
			end

			if p ~= 2 and p ~= 3 and p ~= 4 then
				removeBodyPartTrails()
			end
		end
	},
	{
		Add = function(p)
			if p ~= 2 and p ~= 3 and p ~= 4 then
				addBodyPartTrails() -- equivalent call inferred; original call site unknown
			end

			if p ~= 3 and p ~= 4 then
				addBodyPartParticles()
			end
		end,
		Remove = function(p)
			if p ~= 2 and p ~= 3 and p ~= 4 then
				removeBodyPartTrails()
			end

			if p ~= 3 and p ~= 4 then
				removeBodyPartParticles()
			end
		end
	},
	{
		Add = function(p)
			if p ~= 2 and p ~= 3 and p ~= 4 then
				addBodyPartTrails() -- equivalent call inferred; original call site unknown
			end

			if p ~= 3 and p ~= 4 then
				addBodyPartParticles()
			end

			if head:FindFirstChild("SwimDrownEffect") ~= nil then
				return
			end

			local clone = drowningEffect:Clone()
			clone.Name = "SwimDrownEffect"
			clone.Parent = head
			playOneShot(sounds.PS2waterDROWNstart) -- equivalent call inferred; original call site unknown
			local clone2 = sounds.DP2PS2waterDROWNloop:Clone()
			clone2.Parent = clone
			clone2.Looped = true
			local volume = clone2.Volume
			clone2.Volume = 0
			clone2:Play()
			TweenService:Create(clone2, tweenInfo4, {
				Volume = volume
			}):Play()
		end,
		Remove = function(p)
			if p ~= 2 and p ~= 3 and p ~= 4 then
				removeBodyPartTrails()
			end

			if p ~= 3 and p ~= 4 then
				removeBodyPartParticles()
			end

			clearDrownEffects()
		end
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function onDiveStateChange(_: number, _: number)
	playOneShot(sounds.PS2DP2waterMOVE) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onDiveIdle(_: number)
	playOneShot(sounds.PS2DP2waterSTOPMOVING) -- equivalent call inferred; original call site unknown
end

v7 = {
	current = 0,
	prevCurrent = 0,
	jumping = false,
	animState = 0,
	effectState = 0,
	update = function()
		local current = 0
		local animState

		if v7.current > 0 then
			if v6.Drowning then
				current = 4
				animState = 4
			else
				animState = (v7.current == 1 or v7.current == 3) and 1 or v7.current == 2 and 2 or 3

				if v7.current == 3 or v7.current == 4 then
					current = 3
				elseif v7.current <= 2 then
					current = v7.current
				end
			end
		else
			animState = 0
		end

		if current ~= v7.effectState then
			local effectState = v7.effectState
			local v26 = v24[effectState]
			local v27 = v24[current]
			v7.effectState = current

			if v26 then
				v26.Remove(current)
			end

			if v27 then
				v27.Add(effectState)
			end
		end

		if animState ~= v7.animState then
			if v5[v7.animState] then
				v5[v7.animState]:Stop()
			end

			v7.animState = animState

			if v5[animState] then
				v5[animState]:Play()
			end
		end

		local prevCurrent = v7.prevCurrent
		local current2 = v7.current

		if prevCurrent ~= current2 then
			local particles = hasParticles(prevCurrent)
			local particles2 = hasParticles(current2)

			if not v6.Drowning then
				if prevCurrent == 4 and current2 == 3 then
					onDiveIdle() -- equivalent call inferred; original call site unknown
				elseif particles2 and not particles or prevCurrent == 3 and current2 == 4 then
					onDiveStateChange() -- equivalent call inferred; original call site unknown
				end
			end

			v7.prevCurrent = current2
		end
	end,
	updateCamera = function()
		local v25 = v20

		if not (v20 and isCameraInsidePart(v20)) then
			v20 = nil

			for k in pairs(v16) do
				if not isCameraInsidePart(k) then
					continue
				end

				v20 = k
				break
			end
		end

		if v25 ~= v20 then
			refreshFade(v25) -- equivalent call inferred; original call site unknown
			refreshFade(v20) -- equivalent call inferred; original call site unknown
		end

		setCameraInSwimPart(v20 ~= nil) -- equivalent call inferred; original call site unknown
		local v27 = v20 ~= nil or v6.Drowning

		if v27 and not v22 then
			v22 = true
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect", currentCamera)
			colorCorrectionEffect.Name = "swimcorrection"
			blurEffect = Instance.new("BlurEffect", currentCamera)
			blurEffect.Name = "swimblur"
			blurEffect.Size = 0
			depthOfFieldEffect = Instance.new("DepthOfFieldEffect", currentCamera)
			depthOfFieldEffect.Name = "swimdepth"
			depthOfFieldEffect.FarIntensity = 0
			depthOfFieldEffect.InFocusRadius = 10
			TweenService:Create(depthOfFieldEffect, tweenInfo2, {
				FarIntensity = 1,
				InFocusRadius = 9.05
			}):Play()
			TweenService:Create(blurEffect, tweenInfo2, {
				Size = 8
			}):Play()
			applyCCEState()
			drowning = v6.Drowning
		elseif v27 or not v22 then
			if v22 and v6.Drowning ~= drowning then
				applyCCEState()
				drowning = v6.Drowning
			end
		else
			v22 = false

			if v23 then
				v23:Cancel()
				v23 = nil
			end

			if blurEffect ~= nil then
				TweenService:Create(blurEffect, tweenInfo2, {
					Size = 0
				}):Play()
				task.delay(tweenInfo2.Time, blurEffect.Destroy, blurEffect)
				blurEffect = nil
			end

			if depthOfFieldEffect ~= nil then
				TweenService:Create(depthOfFieldEffect, tweenInfo2, {
					FarIntensity = 0,
					InFocusRadius = 10
				}):Play()
				task.delay(tweenInfo2.Time, depthOfFieldEffect.Destroy, depthOfFieldEffect)
				depthOfFieldEffect = nil
			end

			if colorCorrectionEffect ~= nil then
				TweenService:Create(colorCorrectionEffect, tweenInfo2, {
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				task.delay(tweenInfo2.Time, colorCorrectionEffect.Destroy, colorCorrectionEffect)
				colorCorrectionEffect = nil
			end
		end
	end
}
local v25 = 0
local flag = false
local now = 0
local v26 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setDiveJumpBlock(flag2: boolean)
	if flag2 == v26 then
		return
	end

	v26 = flag2
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not flag2)

	if flag2 then
		humanoid.Jump = false
	end
end

local function surfaceJumpImpulse()
	if v7.jumping then
		return
	end

	v7.jumping = true
	attachment.Parent = humanoidRootPart
	local equipped = v17.Equipped

	if typeof(equipped) == "Instance" then
		local position = humanoidRootPart.Position
		fireSplash("SplashLeave", CFrame.new(position.X, getPartTopY(equipped), position.Z)) -- equivalent call inferred; original call site unknown
	end

	local attachment2 = Instance.new("Attachment", humanoidRootPart)
	local linearVelocity2 = Instance.new("LinearVelocity")
	linearVelocity2.MaxForce = 20000
	linearVelocity2.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity2.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity2.VectorVelocity = createVector(0, 65, 0)
	linearVelocity2.Attachment0 = attachment2
	linearVelocity2.Parent = attachment2
	linearVelocity2.Enabled = true
	task.wait(0.125)
	attachment2:Destroy()
	task.wait(0.1)
	v7.jumping = false
end

humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	if not humanoid.Jump or v7.jumping or flag then
		return
	end

	local v27

	if humanoid.FloorMaterial == nil then
		v27 = false
	else
		v27 = humanoid.FloorMaterial ~= Enum.Material.Air
	end

	local v28 = v7.current == 1 or v7.current == 2
	local v29 = v7.current == 3 or v7.current == 4

	if v17.Equipped ~= nil and not v29 and (v27 or v28) then
		v25 = os.clock() + 0.45
	end

	if v7.current ~= 1 and v7.current ~= 2 then
		return
	end

	if v27 then
		alignPosition.Enabled = false
	else
		surfaceJumpImpulse()
	end
end)

local function getSwimDirection()
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	local lookVector = currentCamera.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude > 0 then
		vector2 = vector2.Unit
	end

	local dot = moveDirection:Dot(vector2)
	local v27 = moveDirection - vector2 * dot
	local v28 = lookVector * dot + v27
	return v28.Magnitude > 0 and v28.Unit or createVector(0, 0, 0)
end

local v27 = -11
local v28 = false

local function rootWithinPart(equipped)
	local pointToObjectSpace = equipped.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	local halfSize = equipped.Size / 2
	return math.abs(pointToObjectSpace.X) <= halfSize.X + 5 and math.abs(pointToObjectSpace.Y) <= halfSize.Y + 5 and math.abs(pointToObjectSpace.Z) <= halfSize.Z + 5
end

function updatePart()
	local DISTANCE_THRESHOLD = 0

	if v17.Equipped == nil then
		for k in pairs(v17) do
			if k == "Equipped" then
				continue
			end

			v17.Equipped = k
			break
		end
	end

	if v27 ~= v17.Equipped then
		local v29 = v27
		local equipped = v17.Equipped
		v27 = equipped
		local number = random:NextNumber()
		v21 = number
		linearVelocity.Enabled = false
		alignPosition.Enabled = false
		alignOrientation.Enabled = false
		linearVelocity.VectorVelocity = createVector(0, 0, 0)
		v7.jumping = false
		v25 = 0
		v7.current = 0
		flag = false

		if v26 ~= false then
			v26 = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end

		Checker.Swimming = false
		Checker.ShallowWater = false

		if parent:GetAttribute("SwimState") ~= 0 then
			parent:SetAttribute("SwimState", 0)
		end

		if v2 ~= 0 then
			v2 = 0
			SignalEvent.ToServer("Swim", "State", 0)
		end

		v7.update()
		attachment.Parent = script
		clearDrownEffects()
		stopWalkingIdle() -- equivalent call inferred; original call site unknown
		parent:SetAttribute("SwimUnderwater", false)

		if typeof(v29) == "Instance" then
			if v19 == v29 then
				v19 = nil
			end

			refreshFade(v29) -- equivalent call inferred; original call site unknown
		end

		if equipped == nil then
			while v21 == number do
				local v30 = task.wait(0.25)
				v7.updateCamera()
				tickBreath(v30, false)
			end
		else
			local partTopY = getPartTopY(equipped)
			local v30 = nil
			local v31 = v28
			v28 = false
			local flag2 = false

			while v21 == number and humanoid ~= nil and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil do
				if rootWithinPart(equipped) then
					local v32 = 0
					local v33 = humanoid.MoveDirection.magnitude >= 0.01
					local v34, flag3, v35, cFrame

					if v7.jumping then
						v34 = false
						flag3 = false
					else
						flag3 = true
						local position = humanoidRootPart.Position
						cFrame = currentCamera.CFrame
						local orientation = cFrame:ToOrientation()
						local v36 = position.Y - partTopY
						v35 = getSwimDirection()
						local vector2 = Vector3.new(cFrame.LookVector.X, 0, cFrame.LookVector.Z)

						if vector2.Magnitude > DISTANCE_THRESHOLD then
							vector2 = vector2.Unit
						end

						local v37 = humanoid.MoveDirection:Dot(vector2) > 0

						if not (orientation <= -0.9) then
							v37 = false
						end

						v34 = v36 <= -1.5

						if v31 then
							if v37 then
								v31 = false
							elseif v34 then
								flag2 = true
							elseif flag2 then
								v31 = false
							end
						end

						local v38

						if humanoid.FloorMaterial == nil then
							v38 = false
						else
							v38 = humanoid.FloorMaterial ~= Enum.Material.Air
						end

						if v38 and humanoid.Jump and not v34 then
							v25 = os.clock() + 0.45
						end

						if v36 > 0 and hasFloorBelow() then
							v32 = 2
						elseif v31 and v34 then
							v32 = 1
						elseif v34 or v37 then
							v32 = 3
						elseif v36 > -1.5 and v36 <= 0.75 then
							v32 = 1
						else
							v32 = v32
						end

						if (v32 == 1 or v32 == 3) and not v38 and v25 ~= 0 then
							if os.clock() < v25 or not v34 and humanoidRootPart.AssemblyLinearVelocity.Y > 1 then
								v32 = 0
							else
								v25 = 0
							end
						end

						if v32 == 1 and not v38 and not v34 and humanoidRootPart.AssemblyLinearVelocity.Y > 8 then
							v32 = 0
						end
					end

					if v32 > 0 then
						local flag4

						if getvaluesfolder == nil then
							flag4 = false
						else
							local flag5 = true

							for _, childName in v do
								if getvaluesfolder:FindFirstChild(childName) == nil then
									continue
								end

								flag4 = true
								flag5 = false
								break
							end

							if flag5 then
								flag4 = false
							end
						end

						if flag4 then
							v32 = 3
						end
					end

					parent:SetAttribute("SwimUnderwater", v34)

					if humanoid.Jump then
						now = os.clock()
					end

					local v36 = os.clock() - now <= 0.2

					if not v36 then
						flag = false
					end

					local v37

					if v32 == 3 then
						v37 = v34 and v36
					else
						v37 = false
					end

					if v37 then
						flag = true
					elseif flag and v36 and not v34 and flag3 then
						flag = false

						if v17.Equipped ~= nil and (humanoid.FloorMaterial == nil or humanoid.FloorMaterial == Enum.Material.Air) then
							v25 = os.clock() + 0.45
							task.spawn(surfaceJumpImpulse)
						end
					end

					local current

					if v32 == 1 then
						current = v33 and 2 or 1
					else
						current = v32 == 3 and ((v33 or v37) and 4 or 3) or 0
					end

					if Checker.Climbing and not v6.Drowning then
						Checker.Swimming = false
						Checker.ShallowWater = false

						if parent:GetAttribute("SwimState") ~= 0 then
							parent:SetAttribute("SwimState", 0)
						end

						if v2 ~= 0 then
							v2 = 0
							SignalEvent.ToServer("Swim", "State", 0)
						end

						if v26 ~= false then
							v26 = false
							humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
						end

						if v7.current ~= 0 then
							v7.current = 0
							v7.update()
						end

						linearVelocity.Enabled = false
						alignPosition.Enabled = false
						alignOrientation.Enabled = false
						v30 = nil
					else
						Checker.Swimming = v32 > 0 and v32 ~= 2
						Checker.ShallowWater = v32 == 2
						setSwimState(v32) -- equivalent call inferred; original call site unknown

						if flag3 then
							setDiveJumpBlock(v32 == 3 or flag) -- equivalent call inferred; original call site unknown
						end

						if current ~= v7.current then
							v7.current = current
							v7.update()
						end

						if v32 ~= v30 then
							if v32 > 0 then
								attachment.Parent = humanoidRootPart
							else
								attachment.Parent = script
							end

							if v32 == 1 then
								linearVelocity.Enabled = false
								alignPosition.Position = vector.create(0, partTopY, 0)
								alignPosition.Enabled = true
								alignOrientation.Enabled = false
							else
								if v32 == 3 then
									alignOrientation.Enabled = true
									alignOrientation.CFrame = cFrame
									linearVelocity.Enabled = true
								else
									alignOrientation.Enabled = false
									linearVelocity.Enabled = false
								end

								alignPosition.Enabled = false
							end

							if v32 == 2 then
								startWalkingIdle(equipped)
							else
								stopWalkingIdle() -- equivalent call inferred; original call site unknown
							end

							v18 = v32 == 3
							local v41

							if v18 then
								v41 = equipped
							end

							v19 = v41

							if equipped ~= nil then
								local v42 = v20 == equipped and 0.7 or v18 and v19 == equipped and 0.3 or 0
								forEachFadeTarget(equipped, function(instance)
									local originalTransparency = instance:GetAttribute("OriginalTransparency")

									if typeof(originalTransparency) ~= "number" then
										originalTransparency = instance.Transparency
										instance:SetAttribute("OriginalTransparency", originalTransparency)
									end

									tweenTransparency(instance, originalTransparency + (1 - originalTransparency) * v42)
								end)
							end

							v30 = v32
						end

						if v32 == 3 then
							local v41 = v6.Drowning and 4 or 16 * PlayerStatResolver.GetMovementMultiplier(localPlayer)

							if v37 then
								v33 = false
								v35 = createVector(0, 1, 0)
							end

							local enabled = v37 or v33 and v35.Magnitude > DISTANCE_THRESHOLD

							if v6.Drowning then
								alignOrientation.Enabled = false
							else
								alignOrientation.Enabled = enabled

								if enabled and v35.Magnitude > DISTANCE_THRESHOLD then
									local v43 = math.abs(v35.Y) > 0.99 and createVector(0, 0, 1) or createVector(
										0,
										1,
										0
									)
									alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), v35, v43)
								end
							end

							if enabled and v35.Magnitude > DISTANCE_THRESHOLD then
								local vector2 = v35 * v41

								if vector2.Y > 0 then
									vector2 = Vector3.new(vector2.X, vector2.Y * 0.4, vector2.Z)
								end

								linearVelocity.VectorVelocity = vector2
							elseif v6.Drowning then
								linearVelocity.VectorVelocity = humanoid.FloorMaterial ~= nil and humanoid.FloorMaterial ~= Enum.Material.Air and createVector(
									0,
									0,
									0
								) or createVector(0, -4, 0)
							else
								linearVelocity.VectorVelocity = createVector(0, 0, 0)
							end
						end
					end

					v7.updateCamera()
					tickBreath(task.wait(0.05), v34)
				else
					v17[equipped] = nil

					if v17.Equipped == equipped then
						v17.Equipped = nil
					end

					task.spawn(updatePart)
					return
				end
			end
		end
	end
end

function Added(p)
	Removed(p)
	forEachFadeTarget(p, function(instance)
		local originalTransparency = instance:GetAttribute("OriginalTransparency")

		if originalTransparency == nil then
			instance:SetAttribute("OriginalTransparency", instance.Transparency)
		else
			instance.Transparency = originalTransparency
		end
	end)
	v16[p] = {}
	local v29 = {}
	local v30 = nil
	table.insert(v16[p], p.Touched:Connect(function(otherPart)
		if otherPart.Parent == parent then
			v29[otherPart] = true
			v30 = nil

			if v17[p] == nil then
				local v31

				if humanoidRootPart == nil then
					v31 = false
				else
					v31 = -humanoidRootPart.AssemblyLinearVelocity.Y >= 30
				end

				if v31 then
					local position = humanoidRootPart.Position
					fireSplash("SplashEnter", CFrame.new(position.X, getPartTopY(p), position.Z)) -- equivalent call inferred; original call site unknown
				end

				v28 = v31
				v17[p] = true
				updatePart()
			end
		end
	end))
	table.insert(v16[p], p.TouchEnded:Connect(function(otherPart)
		if otherPart.Parent == parent then
			v29[otherPart] = nil

			if next(v29) == nil and v17[p] ~= nil then
				local now2 = os.clock()
				v30 = now2
				task.delay(0.08, function()
					if not (v30 == now2 and next(v29) == nil and v17[p] ~= nil) then
						return
					end

					v30 = nil
					v17[p] = nil

					if v17.Equipped == p then
						v17.Equipped = nil
						updatePart()
					end
				end)
			end
		end
	end))
end

function Removed(p)
	if v16[p] then
		if v17.Equipped == p then
			v17.Equipped = nil
			updatePart()
		end

		if v17[p] then
			v17[p] = nil
		end

		for _, connection in v16[p] do
			connection:Disconnect()
		end

		v16[p] = nil
	end
end

for _, v29 in CollectionService:GetTagged("SwimParts") do
	Added(v29)
end

CollectionService:GetInstanceRemovedSignal("SwimParts"):Connect(Removed)
CollectionService:GetInstanceAddedSignal("SwimParts"):Connect(Added)
updatePart()