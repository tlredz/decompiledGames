local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
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

local function putValueAsValueObject(parent, name: string, clone, value: number)
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
		instance = Instance.new(v2[typeof(clone)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = clone
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

local function RandomVectorOffsetBetween(vector2: Vector3, p: number, p2: number)
	return (CFrame.lookAt(Vector3.new(), vector2) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	if vector3.y >= vector2.y + p then
		p = vector3.y + 0.1 - vector2.y
	end

	local v = vector2.y + p
	local v2 = math.sqrt(p * 2) + math.sqrt((v - vector3.y) * 2)
	return vector2 + ((vector3 - vector2) / v2 + createVector(0, 1, 0) * v2 / 2) * v2 * p2 - createVector(0, 0.5, 0) * (v2 * p2) ^ 2
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

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local v = parent:FindFirstChild("ItemsTableFolder")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "ItemsTableFolder"
		v.Parent = parent
	end

	local projectileType = data.projectileType
	local v2 = 6.283185307179586 * math.random()

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

	local function spawnOrbitingProjectile(p, p2)
		local v3 = 6.283185307179586 * p / p2
		local clone = FX:WaitForChild("SoundEffects")["NoteProjectile" .. projectileType]:Clone()
		local cframe = CFrame.fromEulerAnglesYXZ(
			random:NextNumber(-1, 1) * 0.3490658503988659,
			random:NextNumber(-1, 1) * 0.3490658503988659,
			0
		)
		clone:PivotTo(cframe * CFrame.Angles(0, v2 + v3, 0) * CFrame.new(0, 0, -15) + hrp.Position)

		if data.maxTempoActive ~= true then
			local function fn(_, _, p3)
				return applyColorShiftHSV(p3, random:NextNumber(), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone, fn, true)
		end

		clone.Parent = _WorldOrigin
		destroyAfter(clone, 30)
		emitWithDelayDescendants(clone.PrimaryPart.Emit)
		putValueAsValueObject(v, "NoteProjectile" .. projectileType .. tostring(p), clone, 30)
		local connection = nil
		connection = heartbeatLoopFor2(25, function(p3)
			if clone ~= nil and clone.Parent ~= nil and clone:GetAttribute("Launched") ~= true then
				clone:PivotTo(cframe * CFrame.Angles(0, v2 + v3 + p3 * 6.283185307179586, 0) * CFrame.new(0, 0, -15) + hrp.Position)
				return
			end

			connection:Disconnect()
			connection = nil
		end)
	end

	if projectileType ~= "Mini" then
		spawnOrbitingProjectile(1, 1)
		return
	end

	spawnOrbitingProjectile(1, 5)
	spawnOrbitingProjectile(2, 5)
	spawnOrbitingProjectile(3, 5)
	spawnOrbitingProjectile(4, 5)
	spawnOrbitingProjectile(5, 5)
end