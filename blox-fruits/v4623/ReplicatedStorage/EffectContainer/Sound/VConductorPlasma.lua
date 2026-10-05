local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
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

-- equivalent calls inferred from this helper; original call sites unknown
local function createFrameSkipper()
	local v = 1
	return function(p)
		local v2 = 60 / p
		v += 1

		if v2 <= v then
			v -= v2
			return false
		else
			return true
		end
	end
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

	local v = {}
	local finalePos = data.finalePos
	local damageFor = data.damageFor
	Util.Sound:Play(
		data.maxTempoActive and "SoundFruit.Basw.SoundFruitVFinalExplosionTEMPO" or "SoundFruit.Basw.SoundFruitVFinalExplosion",
		finalePos
	)

	if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 140 or (finalePos - Workspace.CurrentCamera.CFrame.Position).Magnitude < 140 then
		Util.CameraShaker:ShakeOnce(12, 12, 0, 0.2)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "SoundVColorInvert"
		colorCorrectionEffect.Contrast = -7
		colorCorrectionEffect.Parent = Lighting
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "SoundVBloom"
		bloomEffect.Intensity = 2
		bloomEffect.Threshold = 0.6
		bloomEffect.Size = 48
		bloomEffect.Parent = Lighting
		task.delay(0.1, function()
			colorCorrectionEffect.Contrast = 0
			task.wait(0.1)
			Util.CameraShaker:ShakeOnce(12, 12, 0, 0.3)
			colorCorrectionEffect.Contrast = -7
			task.wait(0.1)
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect:Destroy()
			heartbeatLoopFor2(0.5, function(_, _, p)
				bloomEffect.Intensity = 2 - p
				bloomEffect.Threshold = 0.6 + 1.4 * p
				bloomEffect.Size = 48 - 24 * p
			end, function()
				bloomEffect:Destroy()
			end)
		end)
	end

	local raycastResult = Workspace:Raycast(finalePos + createVector(0, 5, 0), createVector(-0, -10, -0), raycastParams)
	local clone = FX:WaitForChild("SoundEffects").MusicalPlasma:Clone()
	clone:PivotTo(CFrame.new(finalePos))
	DestroyAfter(clone, 6) -- equivalent call inferred; original call site unknown

	if raycastResult then
		alignWithGround(clone.Floor, raycastResult)
	else
		for _, effect in ipairs(clone.Floor:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end
	end

	local v2 = {}
	local v3 = {
		"http://www.roblox.com/asset/?id=15040223498",
		"http://www.roblox.com/asset/?id=15040223840",
		"http://www.roblox.com/asset/?id=15040224172",
		"http://www.roblox.com/asset/?id=15040224480",
		"http://www.roblox.com/asset/?id=15040224807",
		"http://www.roblox.com/asset/?id=15040225127",
		"http://www.roblox.com/asset/?id=15040225500",
		"http://www.roblox.com/asset/?id=15040225812",
		"http://www.roblox.com/asset/?id=15040226242",
		"http://www.roblox.com/asset/?id=15040226630",
		"http://www.roblox.com/asset/?id=15040226958",
		"http://www.roblox.com/asset/?id=15040227423",
		"http://www.roblox.com/asset/?id=15040227681",
		"http://www.roblox.com/asset/?id=15040228027",
		"http://www.roblox.com/asset/?id=15040228366",
		"http://www.roblox.com/asset/?id=15040228707"
	}
	local v4 = 1

	for i = 1, 2 do
		local model = Instance.new("Model")
		model.Name = "SplashModel"
		model.Parent = clone
		local clone2 = clone.SplashMesh:Clone()
		clone2.Decal.ZIndex += (i - 1) * 2
		clone2.Parent = model

		if i == 2 then
			model:ScaleTo(v4 * 1)
		end

		local v5 = { clone2 }
		local v6 = model:GetPivot().Position - clone:GetPivot().Position

		for i2 = 1, #v5 do
			local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
			local v7 = v5[i2]
			local decal2 = v7.Decal
			table.insert(v2, decal2)
			local v8 = math.floor((i - 1) * #v3 / 4 + 0.5) + 1
			local v9 = i == 2 and i2 == 2 and 1 or v8
			local v13 = i2
			local parent = model
			local v15 = v6
			v["splashMeshIndex" .. i .. "-" .. i2] = heartbeatLoopFor2(damageFor * 2, function(p)
				if frameSkipper(45) then
					return
				end

				decal2.Texture = v3[v9]
				v7.CFrame = CFrame.Angles((v13 - 1) * 3.141592653589793, 0, 0) * CFrame.Angles(
					0,
					((v13 - 1) * 2 - 1) * p * 2.5,
					0
				) + v7.Position
				local v16 = v9 * 0.7 / #v3
				parent:ScaleTo((v16 + 1) * v4)
				parent:PivotTo(parent:GetPivot().Rotation + clone:GetPivot().Position + v15 * (v16 * 2 + 1) * v4)
				v9 = v9 % #v3 + 1
			end)
		end
	end

	clone.SplashMesh:Destroy()
	local size = clone.PrimaryPart.Size
	v.resizingLogic = clone.PrimaryPart:GetPropertyChangedSignal("Size"):Connect(function()
		local X = (clone.PrimaryPart.Size / size).X
		v4 *= X
		clone.Floor:ScaleTo(clone.Floor:GetScale() * X)
		size = clone.PrimaryPart.Size
	end)
	v.sizeTweening = clone.Size:GetPropertyChangedSignal("Value"):Connect(function()
		clone.Main:ScaleTo(clone.Size.Value)
	end)
	clone.Size.Value = 0.01
	clone.Parent = _WorldOrigin
	TweenService:Create(clone.Size, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
		Value = 0.5
	}):Play()
	heartbeatLoopFor2(damageFor, function(_, _, p)
		clone.Main.Main.Attachment.Position = Vector3.new(0, 0, (math.sin(p * 100)))
		clone.Main.Main.AttachmentClone.Position = clone.Main.Main.Attachment.Position
	end)
	local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(-1, 0, 0)):Inverse()
	local inverse2 = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()

	local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
		local v5 = math.max(1, color.R, color.G, color.B)
		local v6 = math.floor(color.R / v5 * 255) % 256
		local v7 = math.floor(color.G / v5 * 255) % 256
		local v8 = math.floor(color.B / v5 * 255) % 256
		local HSV, v9, v10 = Color3.fromRGB(v6, v7, v8):ToHSV()
		local v11 = (HSV + p) % 1
		local v12 = math.clamp(v9 + (p2 - v9) * 0.5, 0, 1)
		local v13 = math.clamp(v10 * p3, 0, 1)
		return Color3.fromHSV(v11, v12, v13 * v5)
	end

	local function noteTrailEnd(clone2, p)
		if clone2.Transparency == 1 then
			return
		end

		clone2.Transparency = 1
		clone2.Attachment.ParticleEmitter.Enabled = false
		local cframe

		if p then
			cframe = CFrame.lookAt(createVector(0, 0, 0), p.Normal) * inverse2 + p.Position + p.Normal * 0.5
		else
			cframe = CFrame.new(clone2.Position)
		end

		local clone3 = clone.ExplosionDebris:Clone()
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

	local frameSkipper = createFrameSkipper() -- equivalent call inferred; original call site unknown
	heartbeatLoopFor2(damageFor * 0.8, function()
		if frameSkipper(30) then
			return
		end

		local clone2 = clone.MusicNoteTrail:Clone()
		clone2.CFrame = clone.PrimaryPart.CFrame + random:NextUnitVector() * random:NextNumber(200, 240)
		clone2.Transparency = 0
		clone2.Attachment0.Trail.Enabled = true
		clone2.Attachment0.Trail2.Enabled = true
		clone2.Attachment0.Trail3.Enabled = true

		if data.maxTempoActive ~= true then
			local function fn(_, _, p)
				return applyColorShiftHSV(p, random:NextNumber(), 1, 1)
			end

			Util.AdjustObjectDescendantsColors(clone2, fn, true)
		end

		clone2.Parent = _WorldOrigin
		DestroyAfter(clone2, 4) -- equivalent call inferred; original call site unknown
		local position = clone2.Position
		local v5 = clone.PrimaryPart.Position + (position - clone.PrimaryPart.Position).Unit * 70
		clone2.Attachment.ParticleEmitter.Enabled = true
		heartbeatLoopFor2(random:NextNumber(0.2, 0.35), function(_, _, p)
			local position2 = position
			local v8 = p ^ 0.6 - 0.01
			local v9 = position2 + (v5 - position2) * v8
			local position3 = position
			local v12 = p ^ 0.6
			local v13 = position3 + (v5 - position3) * v12
			clone2.CFrame = CFrame.lookAt(createVector(0, 0, 0), v13 - v9) * inverse + v13
			clone2.Transparency = p ^ 2
		end, function()
			noteTrailEnd(clone2)
		end)
	end)

	if data.maxTempoActive ~= true then
		local function fn(instance, _, p)
			instance:SetAttribute("RandColorNumber", random:NextNumber())
			return applyColorShiftHSV(p, 0, 1, 1)
		end

		Util.AdjustObjectDescendantsColors(clone, fn, true)
		heartbeatLoopFor2(damageFor * 1.5, function(_, _, p)
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

	task.wait(damageFor)
	local tween = TweenService:Create(clone.Size, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Value = 0.01
	})
	tween:Play()
	tween.Completed:Wait()

	for _, connection in pairs(v) do
		connection:Disconnect()
	end

	if clone ~= nil and clone.Parent ~= nil then
		clone:Destroy()
	end
end