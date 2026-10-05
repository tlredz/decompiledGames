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
local bisentoX = FX:WaitForChild("BisentoV1").BisentoX
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
		local v = 8
		local v2 = 14
		local v3 = 0.2
		local v4 = 0.7

		if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
		end
	end

	local bisentoX2 = bisentoX
	local v2 = TweenService
	local v3 = { TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true) }
	local cframe = CFrame.lookAt(data.origin, data.targetPos)
	local position = cframe.Position
	Util.Sound:Play("WindBreakerAttack", cframe)

	if player == game.Players.LocalPlayer then
		local clone = bisentoX2.Blur:Clone()
		clone.Parent = Lighting
		v2:Create(clone, v3[1], {
			Size = 7
		}):Play()
		destroyAfter(clone, 1)
	end

	local raycastResult = Workspace:Raycast(position, cframe.upVector * -10, raycastParams)

	if raycastResult then
		local alignCFrame = Util.Misc.AlignCFrame(cframe - cframe.p + raycastResult.Position, raycastResult.Normal)
		local cFrame2 = alignCFrame * CFrame.new(0, 0.0005, 0)
		local clone = bisentoX2.GroundImpact:Clone()
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		destroyAfter(clone, 4)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and (emitter.Parent ~= clone or raycastResult)) then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 3, lifetime.Max * 3)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		if raycastResult then
			craterModule({
				Cframe = alignCFrame * CFrame.new(0, 1, 0),
				Size = 3,
				Ammount = 5,
				Despawn = 1,
				Distance = 4.25
			})
		end
	end

	local clone = bisentoX2.Projectile:Clone()
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	clone.Name = clone.Name
	clone.CFrame = cframe
	destroyAfter(clone, 5)

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
		elseif effect:IsA("Beam") then
			local v4 = v2:Create(effect, TweenInfo.new(0.15), {
				Width0 = effect.Width0,
				Width1 = effect.Width1
			})
			effect.Width0 = 0
			effect.Width1 = 0
			v4:Play()
		end
	end

	local targetPos = data.targetPos
	fireClientProjectile(data.fliesFor, 1, data.FXContainer, function(p)
		return origin + (targetPos - origin) * p * 1.1
	end, clone)
	task.wait(data.fliesFor - 0.1)

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			v2:Create(effect, TweenInfo.new(0.08), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end
end