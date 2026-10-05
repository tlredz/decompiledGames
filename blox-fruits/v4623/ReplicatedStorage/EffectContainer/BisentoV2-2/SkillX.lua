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
local bisentoZ = FX:WaitForChild("BisentoV2").BisentoZ
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

local craterModule = Util.CraterModule
local _ = Util.ScaleParticle

local function timeScaleParticle(emitter, p)
	emitter.Drag *= p
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min / p, emitter.Lifetime.Max / p)
	emitter.Rate *= p
	emitter.RotSpeed = NumberRange.new(emitter.RotSpeed.Min * p, emitter.RotSpeed.Max * p)
	emitter.Acceleration *= p ^ 2

	if emitter:GetAttribute("EmitDelay") then
		emitter:SetAttribute("EmitDelay", emitter:GetAttribute("EmitDelay") / p)
	end
end

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

	if player == game.Players.LocalPlayer then
		local position = cFrame.Position
		local v = 6 or 8
		local v2 = 12 or 14
		local v3 = 0.2
		local v4 = 0.7

		if (200 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
		end
	end

	local bisentoZ2 = bisentoZ
	local v2 = TweenService
	local v3 = data.delayBeforeExplosion / 0.4
	local v4 = {
		TweenInfo.new(0.4 * v3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.3 * v3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	}
	local clone = bisentoZ2.Blur:Clone()

	if (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 200 then
		clone.Parent = Lighting
	end

	v2:Create(clone, v4[1], {
		Size = 10
	}):Play()
	destroyAfter(clone, 1)
	local cFrame4 = CFrame.lookAt(data.origin, data.targetPos) * CFrame.new(0, 0, -7)
	local position = cFrame4.Position
	Util.Sound:Play("QuakeSphereExplosion", position)
	local clone2 = bisentoZ2.Impact:Clone()
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame4
	destroyAfter(clone2, 4)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		coroutine.wrap(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit(v6:GetAttribute("EmitCount"))
		end)()
	end

	local cFrame5 = cFrame4 * CFrame.new(0, 1, -6) * CFrame.Angles(0, 3.14, 0)
	local clone3 = bisentoZ2.Projectile:Clone()
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 7)
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame5
	destroyAfter(clone3, 7)
	clone3.Anchored = true
	Util.Sound:Play("QuakeSphereProjectile2", clone3)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true

		if emitter.Parent.Name ~= "Pulse" then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
		emitter.Rate *= 3.5
	end

	local targetPos = data.targetPos
	local v8 = nil
	fireClientProjectile(data.fliesFor, 1, data.FXContainer, function(p)
		return origin + (targetPos - origin) * p * 1.1
	end, clone3).Event:Once(function(_: Vector3, p: string)
		if p == "Impact" then
			v8 = true

			for _, descendant in ipairs(clone3:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
					descendant.Enabled = false
				end
			end

			local cFrame2 = clone3.CFrame
			Util.Sound:Play("QuakeSphereProjectile", cFrame2)
			local cFrame3 = clone3.CFrame
			local clone4 = bisentoZ2.Explosion:Clone()
			clone4.Parent = _WorldOrigin
			destroyAfter(clone4, 7)
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame3
			destroyAfter(clone4, 5)
			v2:Create(clone3.Blue, v4[2], {
				Size = createVector(0, 0, 0)
			}):Play()
			v2:Create(clone3, v4[2], {
				Size = createVector(0, 0, 0)
			}):Play()

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				timeScaleParticle(emitter, 1 / v3)
				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 2, lifetime.Max * 2)

				if emitter:GetAttribute("EmitDelay") and emitter:GetAttribute("EmitDelay") ~= 0 then
					local v9 = emitter
					task.delay(emitter:GetAttribute("EmitDelay") * 2.2, function()
						v9:Emit(v9:GetAttribute("EmitCount"))
					end)
				else
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(data.delayBeforeExplosion * 0.6)
			Util.Sound:Play("QuakeSphereExplosion2", cFrame2)
			task.wait(data.delayBeforeExplosion * 0.4)
			craterModule({
				Cframe = cFrame2,
				Size = 7,
				Ammount = 8,
				Despawn = 1.25 * v3,
				Distance = 17
			})
			local position2 = clone3.Position
			local v9 = 8
			local v10 = 14
			local v11 = 0.2
			local v12 = 0.7

			if (120 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
				Util.CameraShaker:ShakeOnce(v9, v10, v11, v12)
			end
		end
	end)
	task.wait(data.fliesFor)

	if not v8 then
		v8 = true
		v2:Create(clone3.Blue, v4[2], {
			Size = createVector(0, 0, 0),
			Transparency = 1
		}):Play()
		v2:Create(clone3, v4[2], {
			Size = createVector(0, 0, 0),
			Transparency = 1
		}):Play()

		for _, descendant in ipairs(clone3:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
				descendant.Enabled = false
			end
		end
	end
end