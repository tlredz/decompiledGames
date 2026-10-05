local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
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

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	if vector3.y >= vector2.y + p then
		p = vector3.y + 0.1 - vector2.y
	end

	local v = vector2.y + p
	local v2 = math.sqrt(p * 2) + math.sqrt((v - vector3.y) * 2)
	return vector2 + ((vector3 - vector2) / v2 + createVector(0, 1, 0) * v2 / 2) * v2 * p2 - createVector(0, 0.5, 0) * (v2 * p2) ^ 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		if clone ~= nil then
			clone:Destroy()
		end
	end)
end

local random = Random.new()

local function RandomVectorOffsetBetween(vector2: Vector3, p: number, p2: number)
	return (CFrame.lookAt(Vector3.new(), vector2) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
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

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local origin = data.origin
	local raycastResult = Workspace:Raycast(origin + createVector(0, 5, 0), createVector(-0, -10, -0), raycastParams)
	local v = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal
	Util.Sound:Play(
		data.maxTempoActive and "SoundFruit.Basw.SoundFruitVLargeExplosionTEMPO" or "SoundFruit.Basw.SoundFruitVLargeExplosion",
		origin
	)
	local clone = FX:WaitForChild("SoundEffects").MusicalExplosionWindup:Clone()
	local v2 = origin + v * 10
	clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), currentCamera.CFrame.Position - v2) * inverse + v2
	clone.Parent = _WorldOrigin
	DestroyAfter(clone, 2) -- equivalent call inferred; original call site unknown

	local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
		local v3 = math.max(1, color.R, color.G, color.B)
		local v4 = math.floor(color.R / v3 * 255) % 256
		local v5 = math.floor(color.G / v3 * 255) % 256
		local v6 = math.floor(color.B / v3 * 255) % 256
		local HSV, v7, v8 = Color3.fromRGB(v4, v5, v6):ToHSV()
		local v9 = (HSV + p) % 1
		local v10 = math.clamp(v7 + (p2 - v7) * 0.5, 0, 1)
		local v11 = math.clamp(v8 * p3, 0, 1)
		return Color3.fromHSV(v9, v10, v11 * v3)
	end

	if data.maxTempoActive ~= true then
		local function fn(_, _, p)
			return applyColorShiftHSV(p, random:NextNumber(), 1, 1)
		end

		Util.AdjustObjectDescendantsColors(clone, fn, true)
	end

	emitWithDelayDescendants(clone)
	task.wait(data.windUpTime)
	local inverse2 = CFrame.lookAt(createVector(0, 0, 0), createVector(-1, 0, 0)):Inverse()
	local inverse3 = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
	local clone2 = FX:WaitForChild("SoundEffects").MusicalExplosion:Clone()
	clone2:PivotTo(CFrame.new(origin))
	clone2.Parent = _WorldOrigin
	DestroyAfter(clone2, 6) -- equivalent call inferred; original call site unknown

	if raycastResult then
		alignWithGround(clone2.AccretionDisks, raycastResult)
		alignWithGround(clone2.Floor, raycastResult)
		alignWithGround(clone2.BeamFlame, raycastResult)
	end

	local raycastResult2 = Workspace:Raycast(
		clone2:GetPivot().Position + clone2:GetPivot().UpVector * 5,
		clone2:GetPivot().UpVector * -10,
		raycastParams
	)

	if raycastResult2 == nil then
		for _, emitter in ipairs(clone2.Floor.CirclePart.Floor:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Orientation = Enum.ParticleOrientation.FacingCamera

			if emitter.Name == "Treble" or emitter.Name == "TrebleUp" then
				emitter.Texture = "rbxassetid://14906113427"
				emitter.Rotation = NumberRange.new(0)
			end

			if emitter.Name == "TrebleUp" then
				emitter.Speed = NumberRange.new(18)
			end
		end
	end

	emitWithDelayDescendants(clone2.Floor.CirclePart)

	local function noteTrailEnd(state, p)
		if state.Transparency == 1 then
			return
		end

		state.Transparency = 1
		state.Attachment.ParticleEmitter.Enabled = false
		local cframe

		if p then
			cframe = CFrame.lookAt(createVector(0, 0, 0), p.Normal) * inverse3 + p.Position + p.Normal * 0.5
		else
			cframe = CFrame.new(state.Position)
		end

		local clone3 = clone2.ExplosionDebris:Clone()
		clone3:PivotTo(cframe)

		if data.maxTempoActive ~= true then
			local function fn(_, _, p2)
				return applyColorShiftHSV(p2, random:NextNumber(), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone3, fn, true)
		end

		clone3.Parent = _WorldOrigin
		DestroyAfter(clone3, 2) -- equivalent call inferred; original call site unknown
		emitWithDelayDescendants(clone3.CirclePart)
	end

	for _ = 1, 8 do
		local clone3 = clone2.MusicNoteTrail:Clone()
		clone3.CFrame = clone2:GetPivot()
		clone3.Transparency = 0
		clone3.Attachment0.Trail.Enabled = true
		clone3.Attachment0.Trail2.Enabled = true
		clone3.Attachment0.Trail3.Enabled = true

		if data.maxTempoActive ~= true then
			local function fn(_, _, p)
				return applyColorShiftHSV(p, random:NextNumber(), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone3, fn, true)
		end

		clone3.Parent = _WorldOrigin
		DestroyAfter(clone3, 4) -- equivalent call inferred; original call site unknown
		local position = clone3.Position
		local number = random:NextNumber(30, 80)
		local v3

		if raycastResult2 == nil then
			v3 = position + RandomVectorOffsetBetween(createVector(0, 1, 0), 0.4363323129985824, 2.443460952792061) * random:NextNumber(
				160,
				240
			) * 1.2
		else
			v3 = position + RandomVectorOffsetBetween(createVector(0, 1, 0), 0.7853981633974483, 2.443460952792061) * random:NextNumber(
				100,
				240
			) - createVector(0, 1, 0) * number * 1
		end

		clone3.Attachment.ParticleEmitter.Enabled = true
		local connection = nil
		local v4 = position
		local v8 = clone3
		connection = heartbeatLoopFor2(random:NextNumber(0.4, 0.7), function(p, p2, p3)
			local v9 = ballisticTrajectory(position, v3, number, p3 ^ 0.6 - 0.01)
			local v10 = ballisticTrajectory(position, v3, number, p3 ^ 0.6)
			clone3.CFrame = CFrame.lookAt(createVector(0, 0, 0), v10 - v9) * inverse2 + v10
			clone3.Transparency = p3 ^ 2
			local raycastResult3 = Workspace:Raycast(v4, v10 - v4, raycastParams)

			if not raycastResult3 then
				v4 = v10
				return
			end

			if connection then
				connection:Disconnect()
				connection = nil
			end

			noteTrailEnd(clone3, raycastResult3)
		end, function()
			noteTrailEnd(v8)
		end)
	end

	local v3 = { clone2.BeamFlame.Part.Attachment0.Fire1, clone2.BeamFlame.Part.Attachment0.Fire2 }

	for _, v4 in ipairs(v3) do
		SetVFXObjectTransparency(v4, 1)
		v4.Enabled = true
	end

	heartbeatLoopFor2(0.8, function(_, _, p)
		for _, v4 in ipairs(v3) do
			SetVFXObjectTransparency(v4, (math.abs(p - 0.5) * 2) ^ 4)
		end
	end, function()
		for _, v4 in ipairs(v3) do
			SetVFXObjectTransparency(v4, 1)
			v4.Enabled = false
		end
	end)
	local accretionDisks = clone2.AccretionDisks
	local beams = {}

	for _, beam in ipairs(accretionDisks:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Transparency = NumberSequence.new(1)
		beam.Enabled = true
		table.insert(beams, beam)
	end

	accretionDisks:ScaleTo(0.1)
	local currentCamera2 = Workspace.CurrentCamera
	local inverse4 = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
	heartbeatLoopFor2(0.7, function(_, _, p)
		local position = accretionDisks.SwirlyBeams2FaceCamera:GetPivot().Position
		accretionDisks.SwirlyBeams2FaceCamera:PivotTo(CFrame.lookAt(
			createVector(0, 0, 0),
			currentCamera2.CFrame.Position - position
		) * inverse4 + position)

		for _, v4 in ipairs(beams) do
			v4.Transparency = NumberSequence.new((math.abs(p - 0.5) * 2) ^ 1)
		end

		accretionDisks:ScaleTo(0.1 + 1.4 * p ^ 0.5)
	end, function()
		for _, v4 in ipairs(beams) do
			v4.Transparency = NumberSequence.new(1)
			v4.Enabled = false
		end

		accretionDisks:ScaleTo(1.5)
	end)

	if data.maxTempoActive ~= true then
		local function fn(instance, _, p)
			instance:SetAttribute("RandColorNumber", random:NextNumber())
			return applyColorShiftHSV(p, 0, 1, 1)
		end

		Util.AdjustObjectDescendantsColors(clone2, fn, true)
		task.delay(0.3, function()
			heartbeatLoopFor2(0.5, function(_, _, p)
				local function fn2(instance, _, p2)
					return applyColorShiftHSV(p2, p * 2 * instance:GetAttribute("RandColorNumber"), 1, 1)
				end

				Util.AdjustObjectDescendantsColors(clone2, fn2, true)
			end, function()
				local function fn2(instance, _, p)
					return applyColorShiftHSV(p, 2 * instance:GetAttribute("RandColorNumber"), 1, 1)
				end

				Util.AdjustObjectDescendantsColors(clone2, fn2, true)
			end)
		end)
	end

	if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 140 or (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 140 then
		Util.CameraShaker:ShakeOnce(12, 12, 0, 0.3)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "MusicVBloom"
		bloomEffect.Intensity = 4
		bloomEffect.Threshold = 0.4
		bloomEffect.Size = 64
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.3, function(_, _, p)
			bloomEffect.Intensity = 4 - 4 * p
			bloomEffect.Threshold = 0.4 + 0.6 * p
			bloomEffect.Size = 64 - 64 * p
		end, function()
			bloomEffect:Destroy()
		end)
	end
end