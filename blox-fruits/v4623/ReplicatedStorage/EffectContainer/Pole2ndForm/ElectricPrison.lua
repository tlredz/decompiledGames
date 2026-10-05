local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local poleElectricPrison = FX:WaitForChild("Pole2ndForm").PoleElectricPrison
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local lightningBolt3 = Util.LightningBolt3

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
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
	destroyAfter(instance, value or 60)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
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

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
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

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	return part
end

local function CreateLightning(data)
	local attachment0 = data.Attachment0
	local attachment1 = data.Attachment1
	local destroyAttachments = data.DestroyAttachments
	local lightning = data.Lightning
	assert(attachment0, "No attachment0")
	assert(attachment1, "No attachment1")
	assert(lightning, "No Lightning Data found, lightning can't be created without it")
	local result

	if lightning then
		local amount = lightning.Amount or 9
		local thicknessDuration = lightning.ThicknessDuration
		local easing = lightning.Easing or "Linear"
		local props = lightning.Props or {}
		result = lightningBolt3.new(attachment0, attachment1, amount)

		for k, v in props do
			result[k] = v
		end

		local tweenInfo

		if easing == "Quad" then
			tweenInfo = TweenInfo.new(thicknessDuration, Enum.EasingStyle.Quad)
		elseif easing == "Linear" then
			tweenInfo = TweenInfo.new(thicknessDuration)
		else
			tweenInfo = error("Bad Easing provided!")
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Value = result.Thickness
		TweenService:Create(numberValue, tweenInfo, {
			Value = 0
		}):Play()
		local v = false
		local changedConnection = nil
		changedConnection = numberValue.Changed:Connect(function()
			result.Thickness = numberValue.Value

			if numberValue.Value < 0.1 then
				if destroyAttachments then
					attachment0:Destroy()
					attachment1:Destroy()
				end

				changedConnection:Disconnect()
				result:Destroy()
				numberValue:Destroy()
				v = true
			end
		end)
		task.delay(7, function()
			if v == false then
				if destroyAttachments then
					attachment0:Destroy()
					attachment1:Destroy()
				end

				changedConnection:Disconnect()
				result:Destroy()
				numberValue:Destroy()
			end
		end)
	else
		result = nil
	end

	return result
end

local function InRange(position, p: number)
	local position2 = Workspace.CurrentCamera.CFrame.Position

	if typeof(position) == "CFrame" then
		position = position.Position
	end

	return (position2 - position).Magnitude < p
end

local function ScreenFlash(p)
	local bloom = p.Bloom
	local colorCorrection = p.ColorCorrection

	if bloom then
		local clone = poleElectricPrison.BloomEffect:Clone()
		clone.Parent = Lighting
		local data = bloom.Data
		local tweenTime = bloom.TweenTime
		TweenService:Create(
			clone,
			TweenInfo.new(tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true),
			data
		):Play()
		task.delay(tweenTime, function()
			clone:Destroy()
		end)
	end

	if colorCorrection then
		local clone = poleElectricPrison.ColorCorrectionEffect:Clone()
		clone.Parent = Lighting
		local data = colorCorrection.Data
		local tweenTime = colorCorrection.TweenTime
		TweenService:Create(
			clone,
			TweenInfo.new(tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true),
			data
		):Play()
		task.delay(tweenTime, function()
			clone:Destroy()
		end)
	end
end

local function Emit(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount")) then
			continue
		end

		if emitter:GetAttribute("Delay") then
			local v = emitter
			task.delay(emitter:GetAttribute("Delay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local color = Color3.fromRGB(146, 221, 253)
local color2 = Color3.fromRGB(160, 225, 253)
local color3 = Color3.fromRGB(81, 187, 253)

local function lerp(p: number, p2: number, p3: number)
	return p * (1 - p3) + p2 * p3
end

local function CubicOut(p: number)
	return 1 - math.pow(1 - p, 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutQuint(p: number)
	return 1 - math.pow(1 - p, 5)
end

local function ClampRandom(p: number, p2: number, p3: number)
	local random2 = Random.new()
	local number = random2:NextNumber(p, -p3)
	local number2 = random2:NextNumber(p3, p2)

	if random2:NextInteger(0, 1) == 1 then
		return number2
	end

	return number
end

local function storeParticle(emitter)
	local v = {
		Keypoints = {}
	}

	for k, keypoint in emitter.Size.Keypoints do
		v.Keypoints[k] = keypoint
	end

	v.Speed = emitter.Speed
	v.Acceleration = emitter.Acceleration
	return v
end

local function scaleParticle(k, sequence, p: number)
	local numberSequenceKeypoints = {}

	for k2, keypoint in sequence.Keypoints do
		numberSequenceKeypoints[k2] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	k.Size = NumberSequence.new(numberSequenceKeypoints)
	k.Speed = NumberRange.new(sequence.Speed.Min * p, sequence.Speed.Max * p)
	k.Acceleration = sequence.Acceleration * p
end

local function ApplyBolt(clone)
	local children = poleElectricPrison.BoltVFX:GetChildren()

	for _, v in children do
		local clone2 = v:Clone()
		clone2:SetAttribute("BoltVFX", true)
		clone2.Parent = clone
		destroyAfter(clone2, 7)
		clone2:Emit(v:GetAttribute("EmitCount"))
	end
end

local function RemoveBolt(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("BoltVFX") then
			emitter:Destroy()
		end
	end

	folder:Destroy()
end

local function BoltVFX(p)
	if p.Parts == nil then
		return
	end

	for k, part in p.Parts do
		if k % 2 ~= 0 then
			continue
		end

		local clone = part:Clone()
		clone.Transparency = 1
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		ApplyBolt(clone)
		task.delay(0.35, RemoveBolt, clone)
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir
	local v = random
	local poleElectricPrison2 = poleElectricPrison
	local parent = _WorldOrigin
	local targetPos = data.targetPos
	local cframe = CFrame.lookAt(origin, targetPos)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cframe
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	local clone = poleElectricPrison2.Shoot1:Clone()
	clone.CFrame = part.CFrame
	clone.Parent = _WorldOrigin

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.delay(1.6, function()
		clone:Destroy()
	end)
	local v4 = data.electricPrisonLastsFor * 1.1 / 1.6
	local v5 = data.electricPrisonLastsFor * 0.5 / 1.6
	local v6 = v4 + v5

	local function TweenBall(_, p: string, callback)
		local lastTime = os.clock()
		local v7 = 0
		local connection = nil
		connection = heartbeatLoopFor2(7, function(_)
			if v7 == 1 then
				connection:Disconnect()
			elseif p == "Start" then
				v7 = math.min((os.clock() - lastTime) / v4, 1)
				local v9 = easeOutQuint(v7) -- equivalent call inferred; original call site unknown
				callback(v9)
			elseif p == "End" then
				v7 = math.min((os.clock() - lastTime) / v5, 1)
				v7 = 1 - v7
				callback(v7)
			end
		end)
	end

	local raycastResult = Workspace:Raycast(part.Position, createVector(-0, -7, -0), raycastParams)

	if raycastResult then
		local clone2 = poleElectricPrison2.Shoot2:Clone()
		clone2.Position = raycastResult.Position
		clone2.Orientation = part.Orientation
		clone2.Parent = _WorldOrigin

		for _, emitter in clone2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.delay(1, function()
			clone2:Destroy()
		end)
	end

	local raycastResult2 = Workspace:Raycast(
		targetPos + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		raycastParams
	)
	local cframe2 = CFrame.new(targetPos, targetPos + createVector(0, 1, 0))

	if raycastResult2 then
		cframe2 = CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal)
	end

	local clone2 = poleElectricPrison2.Ball:Clone()
	clone2.Position = targetPos
	clone2.Size = createVector(0, 0, 0)
	clone2.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Parent = clone2
	destroyAfter(attachment, 7)
	attachment.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = clone2
	destroyAfter(attachment2, 7)
	CreateLightning({
		Attachment0 = attachment,
		Attachment1 = attachment2,
		DestroyAttachments = true,
		Lightning = {
			Amount = 8,
			ThicknessDuration = 0.35,
			Easing = "Quad",
			Props = {
				MaxRadius = 10,
				Color = color,
				PulseLength = 25,
				PulseSpeed = 5,
				AnimationSpeed = 0.05,
				Thickness = 5,
				Frequency = 3,
				FadeLength = 1,
				MinTransparency = 0,
				MaxTransparency = 0,
				MinThicknessMultiplier = 0.6
			}
		},
		Sparks = {
			Props = {
				MaxSparkCount = 8,
				MinSpeed = 5,
				MaxSpeed = 6,
				MinDistance = 2,
				MaxDistance = 3,
				MinPartsPerSpark = 3,
				MaxPartsPerSpark = 6
			}
		}
	})
	task.defer(function()
		for _ = 1, 3 do
			local v7 = { color, color3 }
			local number = v:NextNumber(0.15, 0.24)
			local attachment3 = Instance.new("Attachment")
			attachment3.Parent = clone2
			destroyAfter(attachment3, 7)
			attachment3.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(v:NextNumber(-2, 2), v:NextNumber(-2, 2), v:NextNumber(-2, 2))
			attachment4.Parent = clone2
			destroyAfter(attachment4, 7)
			local v8, _ = CreateLightning({
				Attachment0 = attachment3,
				Attachment1 = attachment4,
				DestroyAttachments = true,
				Lightning = {
					Amount = 8,
					ThicknessDuration = number,
					Easing = "Quad",
					Props = {
						MaxRadius = 14,
						Color = v7[math.random(#v7)],
						PulseLength = 25,
						PulseSpeed = 0.1,
						AnimationSpeed = 0.06,
						Thickness = Random.new():NextNumber(1, 2.25),
						Frequency = 2.5,
						FadeLength = 1,
						MinTransparency = 0,
						MaxTransparency = 0,
						MinThicknessMultiplier = 0.6
					}
				}
			})
			task.delay(0.06, function()
				BoltVFX(v8)
			end)
			task.wait(number / 7)
		end
	end)
	task.defer(function()
		for _ = 1, 4 do
			local v7 = { color, color3 }
			local number = Random.new():NextNumber(0.2, 0.26)
			local attachment3 = Instance.new("Attachment")
			attachment3.Parent = clone2
			destroyAfter(attachment3, 7)
			attachment3.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(v:NextNumber(-2, 2), v:NextNumber(-2, 2), v:NextNumber(-2, 2))
			attachment4.Parent = clone2
			destroyAfter(attachment4, 7)
			local v8, _ = CreateLightning({
				Attachment0 = attachment3,
				Attachment1 = attachment4,
				DestroyAttachments = true,
				Lightning = {
					Amount = 8,
					ThicknessDuration = number,
					Easing = "Quad",
					Props = {
						MaxRadius = 9,
						Color = v7[math.random(#v7)],
						PulseLength = 25,
						PulseSpeed = 0.1,
						AnimationSpeed = 0.06,
						Thickness = Random.new():NextNumber(0.5, 2.25),
						Frequency = 2.4,
						FadeLength = 0.7,
						MinTransparency = 0,
						MaxTransparency = 0,
						MinThicknessMultiplier = 0.6
					}
				}
			})
			task.delay(0.06, function()
				BoltVFX(v8)
			end)
			task.wait(number / 7)
		end
	end)
	local v7 = {}

	for _, emitter in clone2:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v7[emitter] = storeParticle(emitter)
		emitter.Enabled = true
	end

	table.freeze(v7)

	local function fn(p)
		for k, v8 in v7 do
			scaleParticle(k, v8, p)
		end
	end

	local lastTime = os.clock()
	local v8 = 0
	local connection = nil
	local v9 = "Start"
	connection = heartbeatLoopFor2(7, function(_)
		if v8 == 1 then
			connection:Disconnect()
		elseif v9 == "Start" then
			v8 = math.min((os.clock() - lastTime) / v4, 1)
			local v11 = easeOutQuint(v8) -- equivalent call inferred; original call site unknown
			fn(v11)
		elseif v9 == "End" then
			v8 = math.min((os.clock() - lastTime) / v5, 1)
			v8 = 1 - v8
			fn(v8)
		end
	end)
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Size = createVector(15, 15, 15)
	}):Play()
	TweenService:Create(clone2.Attachment.PointLight, TweenInfo.new(v4, Enum.EasingStyle.Quint), {
		Brightness = 4
	}):Play()
	local v10 = os.clock() + v6 - 0.4 * data.electricPrisonLastsFor / 1.6
	local spr = Util.spr
	task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local clone3 = poleElectricPrison2.Electric:Clone()
		clone3.Position = targetPos
		clone3.Parent = _WorldOrigin
		task.wait(WAIT_INTERVAL)
		local v11 = time()

		for _ = 1, 600 do
			spr.target(clone3, 0.1, 12, {
				Size = createVector(20, 20, 20)
			})
			TweenService:Create(clone3, TweenInfo.new(0.1), {
				Orientation = v:NextUnitVector() * 360
			}):Play()
			task.wait(WAIT_INTERVAL)
			spr.target(clone3, 0.3, 13, {
				Size = Vector3.new(v:NextNumber(37, 43), v:NextNumber(37, 43), v:NextNumber(37, 43))
			})
			task.wait(WAIT_INTERVAL)

			if v10 <= os.clock() or time() - v11 > 10 then
				break
			end
		end

		TweenService:Create(clone3, TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 0)
		}):Play()
		task.wait(0.22)
		clone3:Destroy()
	end)
	task.spawn(function()
		local v11 = time()
		local now = 0

		for _ = 1, 600 do
			task.wait(0.025)

			if os.clock() - now > 0.04 then
				now = os.clock()
				local attachment3 = Instance.new("Attachment")
				attachment3.Parent = clone2
				destroyAfter(attachment3, 7)
				local attachment4 = Instance.new("Attachment")
				local random2 = Random.new()
				local number = random2:NextNumber(-28, -14)
				local number2 = random2:NextNumber(14, 28)

				if random2:NextInteger(0, 1) == 1 then
					number = number2
				end

				local random3 = Random.new()
				local number3 = random3:NextNumber(9, -3)
				local number4 = random3:NextNumber(3, 18)

				if random3:NextInteger(0, 1) == 1 then
					number3 = number4
				end

				local random4 = Random.new()
				local number5 = random4:NextNumber(-28, -14)
				local number6 = random4:NextNumber(14, 28)

				if random4:NextInteger(0, 1) == 1 then
					number5 = number6
				end

				attachment4.Position = Vector3.new(number, number3, number5)
				attachment4.Parent = clone2
				destroyAfter(attachment4, 7)
				local raycastResult3 = Workspace:Raycast(
					attachment4.WorldPosition,
					createVector(0, -25, 0),
					raycastParams
				)

				if raycastResult3 then
					local cframe3 = CFrame.new(raycastResult3.Position, raycastResult3.Position + raycastResult3.Normal)
					local attachment5 = Instance.new("Attachment")
					attachment5.Parent = clone2
					destroyAfter(attachment5, 7)
					attachment5.WorldPosition = raycastResult3.Position + Vector3.new(
						v:NextNumber(-3, 3),
						0,
						v:NextNumber(-3, 3)
					)
					CreateLightning({
						Attachment0 = attachment3,
						Attachment1 = attachment4,
						Lightning = {
							Amount = 4,
							ThicknessDuration = v:NextNumber(0.33, 0.36),
							Easing = "Quad",
							Props = {
								Color = color,
								PulseLength = 25,
								PulseSpeed = 3,
								AnimationSpeed = 2,
								Thickness = Random.new():NextNumber(2.5, 3.5),
								Frequency = 3,
								FadeLength = 0.7,
								MinTransparency = 0,
								MaxTransparency = 0,
								MinThicknessMultiplier = 0.6
							}
						}
					})
					task.wait(0.05)
					CreateLightning({
						Attachment0 = attachment4,
						Attachment1 = attachment5,
						Lightning = {
							Amount = 5,
							ThicknessDuration = v:NextNumber(0.33, 0.36),
							Easing = "Quad",
							Props = {
								Color = color,
								PulseLength = 25,
								PulseSpeed = 3,
								AnimationSpeed = 2,
								Thickness = Random.new():NextNumber(2.5, 3.5),
								Frequency = 3,
								FadeLength = 0.7,
								MinTransparency = 0,
								MaxTransparency = 0,
								MinThicknessMultiplier = 0.6
							}
						}
					})
					local clone3 = poleElectricPrison2.MiniImpact:Clone()
					clone3.Position = attachment5.WorldPosition
					clone3.Parent = _WorldOrigin

					for _, emitter in clone3:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local attachment6 = attachment3
					local attachment7 = attachment4
					task.delay(1.8, function()
						clone3:Destroy()
						attachment6:Destroy()
						attachment7:Destroy()
						attachment5:Destroy()
					end)
					local clone4 = poleElectricPrison2.MiniCrack:Clone()
					local size = clone4.Size
					clone4.Size = Vector3.new()
					clone4.CFrame = cframe3 * CFrame.new(0, 0, -0.25)
					clone4.Parent = parent
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = size
					}):Play()
					task.spawn(function()
						task.wait(0.4)
						TweenService:Create(clone4.CrackLight, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						task.wait(0.7)
						TweenService:Create(clone4.Scorch, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						TweenService:Create(clone4.Scorch1, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						TweenService:Create(clone4.CrackDark, TweenInfo.new(0.85, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						task.wait(0.85)
						clone4:Destroy()
					end)
				else
					attachment3:Destroy()
					attachment4:Destroy()
				end
			end

			if v10 <= os.clock() or time() - v11 > 10 then
				break
			end
		end
	end)
	task.spawn(function()
		local v11 = time()

		for _ = 1, 600 do
			task.wait(0.06666666666666667)
			local attachment3 = Instance.new("Attachment")
			local random2 = Random.new()
			local number = random2:NextNumber(-22, -5)
			local number2 = random2:NextNumber(5, 22)

			if random2:NextInteger(0, 1) == 1 then
				number = number2
			end

			local random3 = Random.new()
			local number3 = random3:NextNumber(-22, -5)
			local number4 = random3:NextNumber(5, 22)

			if random3:NextInteger(0, 1) == 1 then
				number3 = number4
			end

			local random4 = Random.new()
			local number5 = random4:NextNumber(-22, -5)
			local number6 = random4:NextNumber(5, 22)

			if random4:NextInteger(0, 1) == 1 then
				number5 = number6
			end

			attachment3.Position = Vector3.new(number, number3, number5)
			attachment3.Parent = clone2
			destroyAfter(attachment3, 7)
			local attachment4 = Instance.new("Attachment")
			local random5 = Random.new()
			local number7 = random5:NextNumber(-22, -5)
			local number8 = random5:NextNumber(5, 22)

			if random5:NextInteger(0, 1) == 1 then
				number7 = number8
			end

			local random6 = Random.new()
			local number9 = random6:NextNumber(-22, -5)
			local number10 = random6:NextNumber(5, 22)

			if random6:NextInteger(0, 1) == 1 then
				number9 = number10
			end

			local random7 = Random.new()
			local number11 = random7:NextNumber(-22, -5)
			local number12 = random7:NextNumber(5, 22)

			if random7:NextInteger(0, 1) == 1 then
				number11 = number12
			end

			attachment4.Position = Vector3.new(number7, number9, number11)
			attachment4.Parent = clone2
			destroyAfter(attachment4, 7)
			local v12 = { color2, color3 }
			CreateLightning({
				Attachment0 = attachment3,
				Attachment1 = attachment4,
				DestroyAttachments = true,
				Lightning = {
					Amount = 5,
					ThicknessDuration = Random.new():NextNumber(0.23, 0.3),
					Props = {
						MaxRadius = 11,
						Color = v12[math.random(#v12)],
						PulseLength = 25,
						PulseSpeed = 3,
						AnimationSpeed = 0.06,
						Thickness = Random.new():NextNumber(1.5, 2.5),
						Frequency = 3,
						FadeLength = 0.7,
						MinTransparency = 0,
						MaxTransparency = 0,
						MinThicknessMultiplier = 0.6
					}
				}
			})

			if v10 <= os.clock() or time() - v11 > 10 then
				break
			end
		end
	end)
	task.spawn(function()
		task.wait(0.45)

		for _ = 1, 3 do
			spr.target(clone2, 0.4, 9, {
				Size = createVector(6, 6, 6)
			})
			task.wait(0.1)
			spr.target(clone2, 0.2, 9, {
				Size = createVector(18, 18, 18)
			})
		end
	end)
	local v11 = sound:Play("ElectricExplosionLong3", clone2.Position, nil, 0.9333)
	task.delay(v4 - 0.111, function()
		sound:Play("ElectricImpactShort", clone2.Position)
		sound:Play("ShortExplosion3", clone2.Position)
	end)
	task.wait(v4)
	sound:FadeOut(v11, 0.5)
	spr.stop(clone2)
	TweenService:Create(clone2, TweenInfo.new(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Size = createVector(0, 0, 0)
	}):Play()
	TweenService:Create(
		clone2.Attachment.PointLight,
		TweenInfo.new(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{
			Brightness = 0
		}
	):Play()

	for _, emitter in clone2:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.delay(v5, function()
		clone2:Destroy()
	end)

	local function Burst()
		local position = targetPos
		local position2 = Workspace.CurrentCamera.CFrame.Position

		if typeof(position) == "CFrame" then
			position = position.Position
		end

		if (position2 - position).Magnitude < 80 then
			ScreenFlash({
				Bloom = {
					Data = {
						Size = 100,
						Threshold = 0.3
					},
					TweenTime = 0.13
				},
				ColorCorrection = {
					Data = {
						Saturation = 1.5,
						Brightness = 0.2,
						TintColor = Color3.fromRGB(176, 242, 252)
					},
					TweenTime = 0.13
				}
			})
			local position3 = cframe2.Position
			local v12 = 8
			local v13 = 14
			local v14 = 0.2
			local v15 = 0.7

			if (80 or 300) > (Workspace.CurrentCamera.CFrame.Position - position3).Magnitude then
				Util.CameraShaker:ShakeOnce(v12, v13, v14, v15)
			end
		end

		local clone3 = poleElectricPrison2.Burst:Clone()
		clone3.Position = targetPos
		clone3.Parent = _WorldOrigin

		for _, emitter in clone3.Attachment:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if raycastResult2 then
			for _, emitter in clone3.Floor:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		TweenService:Create(clone3.Attachment.PointLight, TweenInfo.new(0.12, Enum.EasingStyle.Cubic), {
			Brightness = 25
		}):Play()
		task.delay(0.13, function()
			TweenService:Create(clone3.Attachment.PointLight, TweenInfo.new(0.2), {
				Brightness = 0
			}):Play()
		end)
		task.delay(2, function()
			clone3:Destroy()
		end)
		task.defer(function()
			for _ = 1, 3 do
				local random2 = Random.new()
				local v12 = { color, color3 }
				local number = random2:NextNumber(0.15, 0.27)
				local number2 = random2:NextNumber(29, 34)
				local attachment3 = Instance.new("Attachment")
				attachment3.Position = Vector3.new(
					(random2:NextInteger(0, 1) == 0 and -1 or 1) * number2,
					number2,
					(random2:NextInteger(0, 1) == 0 and -1 or 1) * number2
				)
				attachment3.Parent = clone3
				destroyAfter(attachment3, 7)
				local attachment4 = Instance.new("Attachment")
				attachment4.Parent = clone3
				destroyAfter(attachment4, 7)
				CreateLightning({
					Attachment0 = attachment4,
					Attachment1 = attachment3,
					DestroyAttachments = true,
					Lightning = {
						Amount = 11,
						ThicknessDuration = number,
						Easing = "Quad",
						Props = {
							Color = v12[math.random(#v12)],
							PulseLength = 25,
							PulseSpeed = 3,
							AnimationSpeed = 2,
							Thickness = Random.new():NextNumber(1.4, 2.25),
							Frequency = 3,
							FadeLength = 0.7,
							MinTransparency = 0,
							MaxTransparency = 0,
							MinThicknessMultiplier = 0.6
						}
					}
				})
				task.wait(number / 9)
			end
		end)
		task.defer(function()
			task.wait(0.03)

			for _ = 1, 2 do
				local v12 = { color, color3 }
				local number = Random.new():NextNumber(0.2, 0.31)
				local attachment3 = Instance.new("Attachment")
				attachment3.Position = createVector(0, 0, 0)
				attachment3.Parent = clone3
				destroyAfter(attachment3, 7)
				local attachment4 = Instance.new("Attachment")
				attachment4.Position = Vector3.new(math.random(-35, 35), math.random(0, 30), math.random(-35, 35))
				attachment4.Parent = clone3
				destroyAfter(attachment4, 7)
				CreateLightning({
					Attachment0 = attachment3,
					Attachment1 = attachment4,
					DestroyAttachments = true,
					Lightning = {
						Amount = 11,
						ThicknessDuration = number,
						Easing = "Quad",
						Props = {
							Color = v12[math.random(#v12)],
							PulseLength = 25,
							PulseSpeed = 3,
							AnimationSpeed = 2,
							Thickness = Random.new():NextNumber(0.3, 1.8),
							Frequency = 3,
							FadeLength = 0.7,
							MinTransparency = 0,
							MaxTransparency = 0,
							MinThicknessMultiplier = 0.6
						}
					}
				})
				task.wait(number / 8)
			end
		end)

		if raycastResult2 then
			local clone4 = poleElectricPrison2.Crack:Clone()
			local size = clone4.Size
			clone4.Size = Vector3.new()
			clone4.CFrame = cframe2 * CFrame.new(0, 0, -0.25)
			clone4.Parent = parent
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
			task.spawn(function()
				task.wait(1)
				TweenService:Create(clone4.CrackLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				task.wait(1)
				TweenService:Create(clone4.Scorch, TweenInfo.new(0.85, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone4.Scorch1, TweenInfo.new(1, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone4.CrackDark, TweenInfo.new(1.25, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				task.wait(1.25)
				clone4:Destroy()
			end)
		end
	end

	Burst()
end