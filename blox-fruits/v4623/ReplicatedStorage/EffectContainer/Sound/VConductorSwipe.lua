local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local rescheduleDestruction

rescheduleDestruction = function(instance, duration: number, flag: boolean?)
	if (flag == nil or flag) == true or instance:GetAttribute("PrevTimeDestructInitiated") == nil then
		instance:SetAttribute("PrevTimeDestructInitiated", time())
	end

	local destructionDepth = instance:GetAttribute("DestructionDepth") or 0
	instance:SetAttribute("DestructionDepth", destructionDepth + 1)

	if destructionDepth >= 100 then
		instance:Destroy()
		warn("rescheduleDestruction: Maximum re-entrancy depth of 100 exceeded")
	else
		task.delay(duration, function()
			local prevTimeDestructInitiated = instance:GetAttribute("PrevTimeDestructInitiated")

			if duration - (time() - prevTimeDestructInitiated) < 0.2 and instance ~= nil and instance.Parent ~= nil then
				instance:Destroy()
				return
			end

			if instance == nil or instance.Parent == nil then
				return
			end

			rescheduleDestruction(instance, duration, false)
		end)
	end
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	rescheduleDestruction(instance, value or 60)
	return instance
end

local function getValueOfValueObject(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function createDefaultProjectile(p: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(4, 4, 4)
	part.Transparency = 1
	part.Name = "Projectile"
	part.Parent = _WorldOrigin
	destroyAfter(part, p + 7)
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
end

local function fireClientProjectile(p: number, callback, p2, part, callback2)
	local v = callback2 or function(_)
		return CFrame.new()
	end
	local v2 = p2 or Instance.new("Folder")

	if not part then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(4, 4, 4)
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * v(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v4 = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p3)
		local v5 = v2
		local v6

		if v5:GetAttribute("ProjectileActive") == true or v5:GetAttribute("ImpactPos") == nil then
			v6 = false
		else
			v6 = v5:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v6 then
			part.CFrame = CFrame.lookAt(callback(p3), callback(p3 + 0.01)) * v(p3)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, v2:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(v2:GetAttribute("ImpactPos"), "Impact")
		v4 = true
	end, function()
		if v4 == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function haltUntilCondition(callback, value: number?)
	local v = value or 10
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(callback)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

local function alignCFrameWithPlane(rotation: CFrame, vector2: Vector3)
	local v = { rotation.RightVector, rotation.UpVector, rotation.LookVector }
	local v2 = -1e999
	local vector3 = nil

	for _, vector4 in ipairs(v) do
		local dot = vector4:Dot(vector2)

		if not (v2 < math.abs(dot)) then
			continue
		end

		v2 = math.abs(dot)
		vector3 = math.sign(dot) * vector4
	end

	local cross = vector3:Cross(vector2)
	local v3 = math.acos((math.clamp(v2, -1, 1)))

	if cross.Magnitude < 0.0001 then
		return rotation.Rotation
	end

	return CFrame.fromAxisAngle(cross, v3) * rotation.Rotation
end

local function snapPointToPlane(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local unit = vector3.Unit
	local X = unit.X
	local Y = unit.Y
	local Z = unit.Z
	local X2 = vector2.X
	local Z2 = vector2.Z
	local dot = vector4:Dot(unit)
	local v

	if math.abs(Y) < 0.1 then
		v = vector2.Y
	else
		v = (dot - X2 * X - Z2 * Z) / Y
	end

	return (Vector3.new(X2, v, Z2))
end

local function alignWithGround(folder, raycastResult: RaycastResult)
	local v = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal

	if typeof(folder) == "CFrame" then
		local position = folder.Position
		local rotation = folder.Rotation
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = position
		end

		local unit = v.Unit
		local X = unit.X
		local Y = unit.Y
		local Z = unit.Z
		local X2 = position.X
		local Z2 = position.Z
		local dot = position2:Dot(unit)
		local v2

		if math.abs(Y) < 0.1 then
			v2 = position.Y
		else
			v2 = (dot - X2 * X - Z2 * Z) / Y
		end

		local vector2 = Vector3.new(X2, v2, Z2)
		local v3 = vector2 + v * (position.Y - vector2.Y)
		return alignCFrameWithPlane(rotation, v) + v3
	else
		if typeof(folder) == "Instance" and folder:IsA("BasePart") then
			local position = folder.CFrame.Position
			local rotation = folder.CFrame.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v2, Z2)
			local v3 = vector2 + v * (position.Y - vector2.Y)
			folder.CFrame = alignCFrameWithPlane(rotation, v) + v3
		else
			if typeof(folder) ~= "Instance" or not folder:IsA("Model") then
				warn("alignWithGround: Failed to align with ground for object of type " .. typeof(folder))
				return
			end

			local pivot = folder:GetPivot()
			local position = pivot.Position
			local rotation = pivot.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v2, Z2)
			local v3 = vector2 + v * (position.Y - vector2.Y)
			folder:PivotTo(alignCFrameWithPlane(rotation, v) + v3)
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end
	end
end

local function mockRootPart(p, cFrame: CFrame)
	local clone = (p or Instance.new("Part")):Clone()
	clone.Name = "Mock" .. clone.Name
	clone:ClearAllChildren()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Transparency = 1
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	return clone
end

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

local function emitWithDelay(emitter)
	local emitDelay = emitter:GetAttribute("EmitDelay")

	if emitDelay then
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end)
	else
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end

local function emitWithDelayDescendants(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitWithDelay(emitter)
		end
	end
end

local function round(p, p2)
	return math.floor((p + p2 / 2) / p2) * p2
end

local getPropertiesFor = Util.GetPropertiesFor

local function getDefaultColor(instance, p, p2)
	local v = "DefaultColor_" .. p
	local attribute = instance:GetAttribute(v)

	if not attribute then
		instance:SetAttribute(v, p2)
		attribute = p2
	end

	return attribute
end

local function applyColorTransformation(instance, p, sequence, callback)
	if typeof(sequence) == "Color3" then
		local v = "DefaultColor_" .. p
		local attribute = instance:GetAttribute(v)

		if not attribute then
			instance:SetAttribute(v, sequence)
			attribute = sequence
		end

		instance[p] = callback(instance, sequence, attribute, p)
	elseif typeof(sequence) == "ColorSequence" then
		local keypoints = sequence.Keypoints
		local colorSequenceKeypoints = {}

		for _, keypoint in pairs(keypoints) do
			local v = p .. "_" .. tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub("%.", "_")
			local value = keypoint.Value
			local v2 = "DefaultColor_" .. v
			local attribute = instance:GetAttribute(v2)

			if attribute then
				value = attribute
			else
				instance:SetAttribute(v2, value)
			end

			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(keypoint.Time, callback(instance, keypoint.Value, value, p, keypoint.Time))
			)
		end

		instance[p] = ColorSequence.new(colorSequenceKeypoints)
	end
end

local function getObjectColorProperties(p)
	local result = {}
	local propertiesFor = getPropertiesFor(p)

	if propertiesFor then
		for _, v in pairs(propertiesFor) do
			if v == "LevelOfDetail" then
				continue
			end

			local v2 = p[v]

			if not (typeof(v2) == "Color3" or typeof(v2) == "ColorSequence") then
				continue
			end

			table.insert(result, v)
		end
	end

	if #result == 0 then
		return nil
	end

	return result
end

local random = Random.new()

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function SetVFXObjectTransparency(instance, value)
	local v = math.clamp(value, 0, 1)
	local defaultTransparency = instance:GetAttribute("DefaultTransparency")

	if not defaultTransparency then
		instance:SetAttribute("DefaultTransparency", instance.Transparency)
		defaultTransparency = instance.Transparency
	end

	local keypoints = defaultTransparency.Keypoints
	local v2 = {}

	for i, keypoint in ipairs(keypoints) do
		local time2 = keypoint.Time
		local value2 = keypoint.Value
		v2[i] = NumberSequenceKeypoint.new(time2, value2 + (1 - value2) * v, 0)
	end

	instance.Transparency = NumberSequence.new(v2)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local fireDir = data.fireDir
	local position = hrp.Position
	local clone = FX:WaitForChild("SoundEffects").MusicalSwipe:Clone()
	local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(-1, 0, 0)):Inverse()
	clone:PivotTo(CFrame.lookAt(createVector(0, 0, 0), fireDir) * inverse + position)
	local windwaves = clone.Windwaves
	local decals = {}

	for _, decal in ipairs(windwaves:GetDescendants()) do
		if decal:IsA("Decal") then
			table.insert(decals, decal)
		end
	end

	local objectSpace = clone:GetPivot():ToObjectSpace(windwaves:GetPivot())
	local objectSpace2 = clone:GetPivot():ToObjectSpace(clone.Slash:GetPivot())
	local objectSpace3 = clone:GetPivot():ToObjectSpace(clone.GroundCrack.CFrame)
	local objectSpace4 = clone:GetPivot():ToObjectSpace(clone.WindwaveExtraFX:GetPivot())
	local Texture = require(clone.Slash.Slash.Texture)
	local Texture2 = require(clone.Windwaves.Slash.Texture)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 5)
	clone.Swipe.SwipePart.CFrame = clone.PrimaryPart.CFrame.Rotation + clone.Swipe.SwipePart.Position
	clone.Swipe.SwipePart.TrailAttach1.Trail.Enabled = true
	clone.Swipe.SwipePart.TrailAttach1.TrailGlow.Enabled = true
	heartbeatLoopFor2(0.2, function(_, _, p)
		clone.Swipe.SwipePart.CFrame = clone.PrimaryPart.CFrame.Rotation * CFrame.Angles(0, 2.443460952792061 * p, 0) + clone.Swipe.SwipePart.Position
		clone.Swipe.SwipePart.TrailAttach1.Specs:Emit(clone.Swipe.SwipePart.TrailAttach1.Specs:GetAttribute("EmitCount"))
		clone.Swipe.SwipePart.TrailAttach2.Specs:Emit(clone.Swipe.SwipePart.TrailAttach2.Specs:GetAttribute("EmitCount"))
	end, function()
		clone.Swipe.SwipePart.TrailAttach1.Trail.Enabled = false
		clone.Swipe.SwipePart.TrailAttach1.TrailGlow.Enabled = false
	end)
	emitWithDelayDescendants(clone.Swipe.TrebleClef.Emit)
	emitWithDelayDescendants(clone.Floor.Floor.Floor)

	for _, v in ipairs(decals) do
		v.Transparency = 1
	end

	task.wait(0.1)
	task.spawn(function()
		Texture()
		Texture2()
	end)

	for _, v in ipairs(decals) do
		v.Transparency = 0
		TweenService:Create(v, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			Transparency = 1
		}):Play()
	end

	local worldSpace = clone:GetPivot():ToWorldSpace(objectSpace)
	local worldSpace2 = clone:GetPivot():ToWorldSpace(objectSpace2)
	local worldSpace3 = clone:GetPivot():ToWorldSpace(objectSpace3)
	local worldSpace4 = clone:GetPivot():ToWorldSpace(objectSpace4)
	clone.GroundCrack.Velocity = worldSpace.LookVector * 30 / 0.4
	clone.GroundCrack.RockEmitter:Emit(clone.GroundCrack.RockEmitter:GetAttribute("EmitCount"))
	clone.GroundCrack.RockEmitter2:Emit(clone.GroundCrack.RockEmitter2:GetAttribute("EmitCount"))

	for _, effect in ipairs(clone.WindwaveExtraFX:GetDescendants()) do
		if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = true
	end

	local Y = clone.WindwaveExtraFX.Slash.CFrame.RightVector.Y

	if Y < -0.02 then
		clone.WindwaveExtraFX.Slash.Slash.Rotation = NumberRange.new(90)
	elseif Y > -0.02 and Y < 0.02 then
		clone.WindwaveExtraFX.Slash.Slash.Enabled = false
	end

	heartbeatLoopFor2(0.4, function(_, _, p)
		SetVFXObjectTransparency(clone.WindwaveExtraFX.WindwaveExtraFX.BeamTrail.Aura2, math.abs(p - 0.5) * 2)
	end, function()
		SetVFXObjectTransparency(clone.WindwaveExtraFX.WindwaveExtraFX.BeamTrail.Aura2, 1)
	end)
	heartbeatLoopFor2(0.4, function(_, _, p)
		if p < 0.5 then
			clone.GroundCrack.RockEmitter:Emit(clone.GroundCrack.RockEmitter:GetAttribute("EmitCount"))
			clone.GroundCrack.RockEmitter2:Emit(clone.GroundCrack.RockEmitter2:GetAttribute("EmitCount"))
		end

		windwaves:PivotTo(worldSpace * CFrame.new(0, 0, -30 * p ^ 0.2) * CFrame.Angles(
			0,
			3.141592653589793 * p ^ 0.5 * 0.25,
			0
		))
		clone.Slash:PivotTo(worldSpace2 * CFrame.Angles(0, -3.141592653589793 * p * 0.5, 0))
		windwaves:ScaleTo(1 + p ^ 0.2)
		clone.GroundCrack.CFrame = worldSpace3 * CFrame.new(-30 * p ^ 0.2, 0, 0)
		clone.WindwaveExtraFX:PivotTo(worldSpace4 * CFrame.new(0, 0, 30 * p ^ 0.2))
		clone.WindwaveExtraFX:ScaleTo(1 + p ^ 0.2)
	end, function()
		clone.WindwaveExtraFX.Slash.Slash.Enabled = false
		clone.WindwaveExtraFX.Slash.Slash.Rotation = NumberRange.new(-90)
		clone.WindwaveExtraFX.WindwaveExtraFX.TrebleSymbol.TrebleSymbol.Enabled = false
		heartbeatLoopFor2(0.1, function(_, _, p)
			for _, child in ipairs(clone.WindwaveExtraFX.WindwaveExtraFX.Center:GetChildren()) do
				SetVFXObjectTransparency(child, p)
			end
		end, function()
			for _, child in ipairs(clone.WindwaveExtraFX.WindwaveExtraFX.Center:GetChildren()) do
				child.Enabled = false
				SetVFXObjectTransparency(child, 0)
			end
		end)
	end)
	local raycastResult = Workspace:Raycast(position + createVector(0, 5, 0), createVector(-0, -10, -0), raycastParams)

	if raycastResult then
		alignWithGround(clone.SwirlyBeams, raycastResult)
		alignWithGround(clone.Floor, raycastResult)
	end

	local v = {
		clone.SwirlyBeams.CirclePart.Beam1,
		clone.SwirlyBeams.CirclePart.Beam2,
		clone.SwirlyBeams.CirclePart.Beam3
	}

	for _, v2 in ipairs(v) do
		v2.Enabled = true
	end

	heartbeatLoopFor2(0.4, function(_, _, p)
		clone.SwirlyBeams:ScaleTo(0.01 + 0.24 * p ^ 0.5)

		for _, v2 in ipairs(v) do
			v2.Transparency = NumberSequence.new(math.abs(p - 0.5) * 2)
		end
	end, function()
		clone.SwirlyBeams:ScaleTo(0.25)

		for _, v2 in ipairs(v) do
			v2.Transparency = NumberSequence.new(1)
		end
	end)

	local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
		local v2 = math.max(1, color.R, color.G, color.B)
		local v3 = math.floor(color.R / v2 * 255) % 256
		local v4 = math.floor(color.G / v2 * 255) % 256
		local v5 = math.floor(color.B / v2 * 255) % 256
		local HSV, v6, v7 = Color3.fromRGB(v3, v4, v5):ToHSV()
		local v8 = (HSV + p) % 1
		local v9 = math.clamp(v6 + (p2 - v6) * 0.5, 0, 1)
		local v10 = math.clamp(v7 * p3, 0, 1)
		return Color3.fromHSV(v8, v9, v10 * v2)
	end

	if data.maxTempoActive ~= true then
		local function fn(instance, _, p)
			instance:SetAttribute("RandColorNumber", random:NextNumber())
			return applyColorShiftHSV(p, 0, 1, 1)
		end

		Util.AdjustObjectDescendantsColors(clone, fn, true)
		heartbeatLoopFor2(0.8, function(_, _, p)
			local function fn2(instance, _, p2)
				return applyColorShiftHSV(p2, p * 3 * instance:GetAttribute("RandColorNumber"), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone, fn2, true)
		end, function()
			local function fn2(instance, _, p)
				return applyColorShiftHSV(p, 3 * instance:GetAttribute("RandColorNumber"), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone, fn2, true)
		end)
	end
end