local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bisentoX = FX:WaitForChild("BisentoV2").BisentoX
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
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function safeSetRootCFrame(instance, cFrame: CFrame, p, flag: boolean)
	local v = flag == nil or flag

	if cFrame ~= cFrame or (instance == nil or p == nil) then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	p.PlatformStand = true

	if v then
		local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

		if raycastResult then
			instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
		else
			instance.CFrame = cFrame
		end
	else
		instance.CFrame = cFrame
	end

	instance.AssemblyLinearVelocity = createVector(0, 0, 0)
	instance.AssemblyAngularVelocity = createVector(0, 0, 0)
	task.wait()
	p.PlatformStand = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(fliesFor, p, fXContainer, fn, part, p2)
	local fn2 = p2 == nil and function(_)
		return CFrame.new()
	end or p2

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p, p, p) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, fliesFor + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * fn2(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p3)
		if fXContainer:GetAttribute("ProjectileActive") == true or fXContainer:GetAttribute("ImpactPos") == nil or not (fXContainer:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(fn(p3), fn(p3 + 0.01)) * fn2(p3)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, fXContainer:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(fXContainer:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, fn(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(fn(1), "NonImpact")
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

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
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

local craterModule = Util.CraterModule
local scaleParticle = Util.ScaleParticle
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir
	local bisentoX2 = bisentoX
	local v2 = TweenService
	local v3 = { TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true) }
	local cframe = CFrame.lookAt(data.origin, data.targetPos)
	local position = cframe.Position

	if data.index == 1 then
		Util.Sound:Play("WindBreakerAttack", position)
		local clone = bisentoX2.Blur:Clone()

		if (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 200 then
			clone.Parent = Lighting
		end

		v2:Create(clone, v3[1], {
			Size = 7
		}):Play()
		destroyAfter(clone, 1)
		local raycastResult = Workspace:Raycast(
			position + createVector(0, 10, 0),
			createVector(-0, -22, -0),
			raycastParams
		)

		if raycastResult then
			local alignCFrame = Util.Misc.AlignCFrame(cframe - cframe.p + raycastResult.Position, raycastResult.Normal)
			local cFrame2 = alignCFrame * CFrame.new(0, 0.0005, 0)
			local clone2 = bisentoX2.GroundImpact:Clone()
			clone2.Parent = _WorldOrigin
			destroyAfter(clone2, 7)
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame2
			alignWithGround(clone2, raycastResult)
			destroyAfter(clone2, 4)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 3, lifetime.Max * 3)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			craterModule({
				Cframe = alignWithGround(alignCFrame * CFrame.new(0, 1, 0), raycastResult),
				Size = 3,
				Ammount = 5,
				Despawn = 1,
				Distance = 5
			})

			if player == game.Players.LocalPlayer then
				local position2 = cFrame.Position
				local v5 = 8
				local v6 = 14
				local v7 = 0.2
				local v8 = 0.7

				if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
					Util.CameraShaker:ShakeOnce(v5, v6, v7, v8)
				end
			end
		end
	end

	local targetPos = data.targetPos
	local clone = bisentoX2.Projectile2:Clone()
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	clone.Name = clone.Name
	clone.CFrame = cframe
	destroyAfter(clone, 5)

	local function fn(p)
		return origin + (targetPos - origin) * p * 1.1
	end

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Parent.Name ~= "Release" then
			emitter.Enabled = true
		end
	end

	fireClientProjectile(data.fliesFor, 1, data.FXContainer, fn, clone)
	task.spawn(function()
		task.wait(0.2)
		local lastTime = tick()
		local raycastResult = Workspace:Raycast(position, cframe.upVector * -30, raycastParams)
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = position + cframe.upVector * -30
		end

		local v4 = time()

		for _ = 1, 600 do
			if clone == nil or clone.Parent == nil or time() - v4 > 10 or tick() - lastTime > 0.4 then
				break
			end

			local part, v5 = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(clone.Position, createVector(0, -10, 0)),
				raycastParams.FilterDescendantsInstances
			)

			if part and raycastResult then
				local magnitude = (v5 - position2).Magnitude

				if magnitude > 2 then
					local cFrame2 = CFrame.new(position2, v5) * CFrame.new(0, 0, -magnitude / 2)
					local clone2 = bisentoX2.burnTrail:Clone()
					clone2.Parent = _WorldOrigin
					destroyAfter(clone2, 7)
					clone2.Name = clone2.Name
					clone2.CFrame = cFrame2
					destroyAfter(clone2, 2)
					v2:Create(clone2, TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(0.3, 0.3, magnitude)
					}):Play()
					v2:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Color = Color3.fromRGB(0, 0, 0)
					}):Play()
					v2:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end

			wait()
			position2 = v5
		end

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false

			if emitter.Parent.Name ~= "Release" then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 0.65, lifetime.Max * 0.65)
			scaleParticle({
				Emitter = emitter,
				Scale = 1.65,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Sine,
				EasingDirection = Enum.EasingDirection.Out
			})
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end)
end