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
local poleLightningRain = FX:WaitForChild("Pole1stForm").PoleLightningRain
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
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

local function getXZRadialPosition(p, p2)
	return math.cos(p) * p2, math.sin(p) * p2
end

local function GetCraterData(data)
	local anchorPoint = data.AnchorPoint or error("An anchor point is required!")
	local radius = data.Radius or 7
	local _ = data.XAngle or 15
	local _ = data.YAngle or 0
	local partAmount = data.PartAmount or 9
	local _ = data.Type or "Radial"
	local v = {
		MinXAngle = data.isRandom.MinXAngle or 0,
		MaxXAngle = data.isRandom.MaxXAngle or 0,
		MinYAngle = data.isRandom.MinYAngle or 0,
		MaxYAngle = data.isRandom.MaxYAngle or 0
	}
	local isNear = data.isNear or 1
	local result = {}

	for i = 1, partAmount do
		local v2 = math.random(v.MinXAngle, v.MaxXAngle)
		local v3 = math.random(v.MinYAngle, v.MaxYAngle)
		local v4 = math.rad(v2)
		local v5 = math.rad(v3)
		local v6 = i * (6.283185307179586 / partAmount)
		local v7 = math.cos(v6) * radius
		local v8 = math.sin(v6) * radius
		local v9 = v7 / isNear
		local v10 = v8 / isNear
		local v11 = anchorPoint * CFrame.new(v9, v10, 0)
		local raycastResult = Workspace:Raycast(
			(v11 * CFrame.new(0, 0, -15)).Position,
			-v11.LookVector * 25,
			raycastParams
		)

		if not (raycastResult and raycastResult.Instance) then
			continue
		end

		result[i] = {}
		result[i].RayResult = raycastResult
		result[i].CFrame = CFrame.lookAt(raycastResult.Position, anchorPoint.Position) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(v4, v5, 0)
	end

	return result
end

local function CraterEffect(p)
	local _ = p.AnchorPoint
	local craterData = GetCraterData(p)

	for k, v2 in craterData do
		local rayResult = v2.RayResult
		local part = Instance.new("Part")
		part.Size = Vector3.new(math.random(50, 70) / 10, math.random(50, 70) / 100, math.random(360, 440) / 100)
		part.CFrame = v2.CFrame + Vector3.new(math.random(-15, 15) / 10, 0, math.random(-15, 15) / 10)
		part.Material = rayResult.Material
		part.Color = rayResult.Instance.Color
		part.Anchored = true
		part.Massless = true
		part.CanQuery = false
		part.CanCollide = false
		part.Parent = _WorldOrigin
		task.delay(2 + 0.04 * k, function()
			TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				CFrame = part.CFrame * CFrame.new(0, -3, 0)
			}):Play()
			task.wait(1)
			part:Destroy()
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

local function InRange(position, p: number)
	local position2 = Workspace.CurrentCamera.CFrame.Position

	if typeof(position) == "CFrame" then
		position = position.Position
	end

	return (position2 - position).Magnitude < p
end

local function ScreenFlash(p, vector2: Vector3)
	local bloom = p.Bloom
	local colorCorrection = p.ColorCorrection

	if bloom then
		local clone = poleLightningRain.BloomEffect:Clone()

		if (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude < 200 then
			clone.Parent = Lighting
		end

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
		local clone = poleLightningRain.ColorCorrectionEffect:Clone()

		if (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude < 200 then
			clone.Parent = Lighting
		end

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

local spr = Util.spr
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local _ = data.fireDir
	local random2 = Random.new()
	local clone = poleLightningRain.Cloud:Clone()
	clone.Name = parent.Name .. "_Polev1Cloud"
	clone.Size = createVector(0, 0, 0)
	clone.Position = data.cloudPos
	clone.Parent = _WorldOrigin
	spr.target(clone, 0.5, 4, {
		Size = createVector(30, 10, 30)
	})

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	task.wait(0.21)
	spr.target(clone, 0.1, 8, {
		Size = createVector(33, 11, 33)
	})

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.delay(0.11, function()
		spr.target(clone, 0.3, 5, {
			Size = createVector(30, 10, 30)
		})
		task.wait(0.05)

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.2)
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 0)
		}):Play()
		task.wait(1)
		clone:Destroy()
	end)
	local raycastResult = Workspace:Raycast(
		data.impactPos + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		raycastParams
	)
	local cframe = CFrame.new(data.impactPos, data.impactPos + createVector(0, 1, 0))

	if raycastResult then
		cframe = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
	end

	Util.Sound:Play("Explosion2", cframe.Position)
	local clone2 = poleLightningRain.Impact:Clone()
	clone2.Position = cframe.Position
	clone2.Parent = _WorldOrigin
	local position = cframe.Position
	local position2 = Workspace.CurrentCamera.CFrame.Position

	if typeof(position) == "CFrame" then
		position = position.Position
	end

	if (position2 - position).Magnitude < 70 then
		local position3 = cframe.Position
		local v = 8
		local v2 = 14
		local v3 = 0.2
		local v4 = 0.7

		if (70 or 300) > (Workspace.CurrentCamera.CFrame.Position - position3).Magnitude then
			Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
		end
	end

	if raycastResult then
		local clone3 = poleLightningRain.Crack:Clone()
		local size = clone3.Size
		clone3.Size = Vector3.new()
		clone3.CFrame = cframe * CFrame.new(0, 0, -0.25)
		clone3.Parent = _WorldOrigin
		TweenService:Create(clone3, TweenInfo.new(0.23, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
		task.spawn(function()
			task.wait(0.7)
			TweenService:Create(clone3.CrackLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			task.wait(1)
			TweenService:Create(clone3.Scorch, TweenInfo.new(0.85, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.Scorch1, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3.CrackDark, TweenInfo.new(1.25, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			task.wait(1.25)
			clone3:Destroy()
		end)
	end

	local v = data.cloudPos.Y - data.impactPos.Y
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, v, 0)
	attachment.Parent = clone2
	destroyAfter(attachment, 7)
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = clone2
	destroyAfter(attachment2, 7)
	local v2 = lightningBolt3.new(attachment, attachment2, 13)
	v2.Color = Color3.fromRGB(146, 221, 253)
	v2.PulseLength = 10
	v2.PulseSpeed = 5
	v2.AnimationSpeed = 1
	v2.Thickness = 5
	v2.Frequency = 2
	v2.FadeLength = 0.5
	v2.MinTransparency = 0
	v2.MaxTransparency = 0
	v2.MinThicknessMultiplier = 0.6
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = v2.Thickness
	TweenService:Create(numberValue, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Value = 0
	}):Play()
	local changedConnection = nil
	changedConnection = numberValue.Changed:Connect(function()
		v2.Thickness = numberValue.Value

		if numberValue.Value <= 0 then
			changedConnection:Disconnect()
			changedConnection = nil
			v2:Destroy()
		end
	end)
	task.delay(7, function()
		if changedConnection then
			v2:Destroy()
			changedConnection:Disconnect()
			changedConnection = nil

			if numberValue then
				numberValue:Destroy()
			end
		end
	end)
	task.spawn(function()
		for _ = 1, 1 do
			local v3 = { Color3.fromRGB(146, 221, 253), Color3.fromRGB(81, 187, 253) }
			local number = random2:NextNumber(0.15, 0.25)
			local attachment3 = Instance.new("Attachment")
			attachment3.Position = Vector3.new(math.random(-1, 1), v, math.random(-1, 1))
			attachment3.Parent = clone2
			destroyAfter(attachment3, 7)
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
			attachment4.Parent = clone2
			destroyAfter(attachment4, 7)
			local v4 = lightningBolt3.new(attachment3, attachment4, 11)
			v4.Color = v3[math.random(#v3)]
			v4.PulseLength = 10
			v4.PulseSpeed = 4
			v4.AnimationSpeed = 2
			v4.Thickness = random:NextNumber(1.4, 2.75) * 1.5
			v4.Frequency = 2
			v4.FadeLength = 0.2
			v4.MinTransparency = 0
			v4.MaxTransparency = 0
			v4.MinThicknessMultiplier = 0.6
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = v4.Thickness
			TweenService:Create(numberValue2, TweenInfo.new(number, Enum.EasingStyle.Quad), {
				Value = 0
			}):Play()
			local changedConnection2 = nil
			changedConnection2 = numberValue2.Changed:Connect(function()
				v4.Thickness = numberValue2.Value

				if numberValue2.Value <= 0 then
					changedConnection2:Disconnect()
					changedConnection2 = nil
					v4:Destroy()
				end
			end)
			local v7 = v4
			local v8 = numberValue2
			task.delay(7, function()
				if changedConnection2 then
					v7:Destroy()
					changedConnection2:Disconnect()
					changedConnection2 = nil

					if v8 then
						v8:Destroy()
					end
				end
			end)
			task.wait(number / 9)
		end
	end)
	task.spawn(function()
		task.wait(0.04)

		for _ = 1, 2 do
			local v3 = { Color3.fromRGB(146, 221, 253), Color3.fromRGB(81, 187, 253) }
			local number = random:NextNumber(0.2, 0.28)
			local attachment3 = Instance.new("Attachment")
			attachment3.Position = Vector3.new(math.random(-9, 9), v, math.random(-9, 9))
			attachment3.Parent = clone2
			destroyAfter(attachment3, 7)
			local attachment4 = Instance.new("Attachment")
			attachment4.Position = Vector3.new(math.random(-12, 12), 0, math.random(-12, 12))
			attachment4.Parent = clone2
			destroyAfter(attachment4, 7)
			local v4 = lightningBolt3.new(attachment3, attachment4, 8)
			v4.Color = v3[math.random(#v3)]
			v4.PulseLength = 10
			v4.PulseSpeed = 5
			v4.AnimationSpeed = 3
			v4.Thickness = random:NextNumber(0.2, 1.25)
			v4.Frequency = 2
			v4.FadeLength = 0.2
			v4.MinTransparency = 0
			v4.MaxTransparency = 0
			v4.MinThicknessMultiplier = 0.6
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = v4.Thickness
			TweenService:Create(numberValue2, TweenInfo.new(number, Enum.EasingStyle.Quad), {
				Value = 0
			}):Play()
			local changedConnection2 = nil
			changedConnection2 = numberValue2.Changed:Connect(function()
				v4.Thickness = numberValue2.Value

				if numberValue2.Value <= 0 then
					changedConnection2:Disconnect()
					changedConnection2 = nil
					v4:Destroy()
				end
			end)
			local v7 = v4
			local v8 = numberValue2
			task.delay(7, function()
				if changedConnection2 then
					v7:Destroy()
					changedConnection2:Disconnect()
					changedConnection2 = nil

					if v8 then
						v8:Destroy()
					end
				end
			end)
			task.wait(number / 10)
		end
	end)
	Emit(clone2)
	task.delay(3, function()
		clone2:Destroy()
	end)
	TweenService:Create(clone2.Attachment.PointLight, TweenInfo.new(0.12, Enum.EasingStyle.Cubic), {
		Brightness = 40
	}):Play()
	task.delay(0.15, function()
		TweenService:Create(clone2.Attachment.PointLight, TweenInfo.new(0.2), {
			Brightness = 0
		}):Play()
	end)

	if raycastResult then
		CraterEffect({
			AnchorPoint = cframe,
			Radius = 12,
			isRandom = {
				MinXAngle = 65,
				MaxXAngle = 115,
				MinYAngle = -30,
				MaxYAngle = 30
			}
		})
	end
end