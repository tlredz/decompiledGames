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
local poleHandOfGod = FX:WaitForChild("Pole2ndForm").PoleHandOfGod
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

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraShakeAt(position: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
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
		local clone = poleHandOfGod.BloomEffect:Clone()
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
		local clone = poleHandOfGod.ColorCorrectionEffect:Clone()
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
local color2 = Color3.fromRGB(81, 187, 253)
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir
	sound:Play("ShortExplosion3", origin)

	if player == game.Players.LocalPlayer then
		cameraShakeAt(cFrame.Position, 999, 7, 10, 0.1, 0.5) -- equivalent call inferred; original call site unknown
	end

	local v = random
	local poleHandOfGod2 = poleHandOfGod
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
	local raycastResult = Workspace:Raycast(targetPos + createVector(0, 5, 0), createVector(-0, -15, -0), raycastParams)
	local cframe2 = CFrame.new(targetPos, targetPos + createVector(0, 1, 0))

	if raycastResult then
		cframe2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
	end

	local clone = poleHandOfGod2.Impact:Clone()
	clone.Position = cframe2.Position
	clone.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Parent = clone
	destroyAfter(attachment, 7)
	attachment.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = clone
	destroyAfter(attachment2, 7)
	CreateLightning({
		Attachment0 = attachment,
		Attachment1 = attachment2,
		DestroyAttachments = true,
		Lightning = {
			Amount = 9,
			ThicknessDuration = 0.35,
			Easing = "Quad",
			Props = {
				MaxRadius = 10,
				Color = color,
				PulseLength = 30,
				PulseSpeed = 5,
				AnimationSpeed = 0.05,
				Thickness = 5,
				Frequency = 3,
				FadeLength = 1,
				MinTransparency = 0,
				MaxTransparency = 0,
				MinThicknessMultiplier = 0.6
			}
		}
	})
	task.defer(function()
		for _ = 1, 1 do
			local v4 = { color, color2 }
			local number = v:NextNumber(0.15, 0.24)
			local attachment3 = Instance.new("Attachment")
			attachment3.Parent = clone
			destroyAfter(attachment3, 7)
			attachment3.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(v:NextNumber(-2, 2), v:NextNumber(-2, 2), v:NextNumber(-2, 2))
			attachment4.Parent = clone
			destroyAfter(attachment4, 7)
			CreateLightning({
				Attachment0 = attachment3,
				Attachment1 = attachment4,
				DestroyAttachments = true,
				Lightning = {
					Amount = 9,
					ThicknessDuration = number,
					Easing = "Quad",
					Props = {
						MaxRadius = 14,
						Color = v4[math.random(#v4)],
						PulseLength = 30,
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
			task.wait(number / 7)
		end
	end)
	task.defer(function()
		for _ = 1, 1 do
			local v4 = { color, color2 }
			local number = v:NextNumber(0.2, 0.26)
			local attachment3 = Instance.new("Attachment")
			attachment3.Parent = clone
			destroyAfter(attachment3, 7)
			attachment3.WorldPosition = (part.CFrame * CFrame.new(0, 0, -2)).Position
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(v:NextNumber(-2, 2), v:NextNumber(-2, 2), v:NextNumber(-2, 2))
			attachment4.Parent = clone
			destroyAfter(attachment4, 7)
			CreateLightning({
				Attachment0 = attachment3,
				Attachment1 = attachment4,
				DestroyAttachments = true,
				Lightning = {
					Amount = 8,
					ThicknessDuration = number,
					Easing = "Quad",
					Props = {
						MaxRadius = 9,
						Color = v4[math.random(#v4)],
						PulseLength = 30,
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
			task.wait(number / 7)
		end
	end)
	task.wait(0.04)
	task.defer(function()
		for _ = 1, 3 do
			local random2 = Random.new()
			local v4 = { color, color2 }
			local number = random2:NextNumber(0.15, 0.27)
			local number2 = random2:NextNumber(13, 21)
			local attachment3 = Instance.new("Attachment")
			attachment3.Position = Vector3.new(
				(random2:NextInteger(0, 1) == 0 and -1 or 1) * number2,
				number2,
				(random2:NextInteger(0, 1) == 0 and -1 or 1) * number2
			)
			attachment3.Parent = clone
			destroyAfter(attachment3, 7)
			local attachment4 = Instance.new("Attachment")
			attachment4.Parent = clone
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
						Color = v4[math.random(#v4)],
						PulseLength = 30,
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
			local v4 = { color, color2 }
			local number = Random.new():NextNumber(0.2, 0.31)
			local attachment3 = Instance.new("Attachment")
			attachment3.Position = createVector(0, 0, 0)
			attachment3.Parent = clone
			destroyAfter(attachment3, 7)
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(math.random(-23, 23), math.random(0, 22), math.random(-23, 23))
			attachment4.Parent = clone
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
						Color = v4[math.random(#v4)],
						PulseLength = 30,
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
	Emit(clone)
	TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.12, Enum.EasingStyle.Cubic), {
		Brightness = 40
	}):Play()
	task.delay(0.15, function()
		TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.2), {
			Brightness = 0
		}):Play()
	end)

	if raycastResult then
		local clone2 = poleHandOfGod2.Crack:Clone()
		local size = clone2.Size
		clone2.Size = Vector3.new()
		clone2.CFrame = cframe2 * CFrame.new(0, 0, -0.25)
		clone2.Parent = parent
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
		task.spawn(function()
			task.wait(1)
			TweenService:Create(clone2.CrackLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			task.wait(1)
			TweenService:Create(clone2.Scorch, TweenInfo.new(0.85, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.Scorch1, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.CrackDark, TweenInfo.new(1.25, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			task.wait(1.25)
			clone2:Destroy()
		end)
	end

	task.delay(3, function()
		clone:Destroy()
	end)
end