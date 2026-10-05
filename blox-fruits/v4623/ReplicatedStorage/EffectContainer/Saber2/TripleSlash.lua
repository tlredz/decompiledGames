local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Effect)
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tripleSlash = FX:WaitForChild("Saber").TripleSlash
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

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function scaleFX(folder, modelScale)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale / (modelScale2 == nil and 1 or modelScale2)

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= v
		elseif descendant:IsA("Beam") then
			descendant.TextureLength *= v
			descendant.CurveSize0 *= v
			descendant.CurveSize1 *= v
			descendant.Width0 *= v
			descendant.Width1 *= v
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, v)
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	return clone
end

local _ = Util.CraterModule
local _ = Util.ScaleParticle
return function(data)
	local player = data.player
	local hrp = data.hrp
	local evolution = data.evolution

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local _ = data.origin
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

	local tripleSlash2 = tripleSlash
	local v2 = TweenService
	local v3 = {
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		TweenInfo.new(data.fliesFor, Enum.EasingStyle.Linear),
		TweenInfo.new(data.fliesFor - 0.15, Enum.EasingStyle.Quad)
	}
	local cframe = CFrame.lookAt(data.origin, data.targetPos)

	if data.double then
		Util.Sound:Play("DeadlyRushProjectile", cframe)
	else
		Util.Sound:Play("SaberProjectile", cframe)
	end

	local cFrame2 = cframe * CFrame.new(0, 0, -6) * CFrame.new(0, 1.5, 0) * CFrame.new(0, 3, 0)
	local clone = tripleSlash2.Start:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	local v5 = 0

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		v5 = math.max(v5, emitter.Lifetime.Max)
	end

	destroyAfter(clone, v5)
	local cFrame4 = cframe * CFrame.new(0, 0, -3) * CFrame.Angles(1.57, 0, 0)
	local clone2 = tripleSlash2.release:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame4
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	destroyAfter(clone2, 1)

	for _, child in ipairs(clone2.Attachment:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local v7 = data.double and 2 or 3 + (evolution and 2 or 0)
	local clones = {}

	for i = 1, v7 do
		local clone3 = nil

		if i == 1 then
			local cFrame3 = cframe * CFrame.new(0, 0, -10) * CFrame.new(0, 3, 0) * CFrame.Angles(
				0,
				0,
				0.8726646259971648
			)
			clone3 = tripleSlash2.Slash:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
		elseif i == 2 then
			local cFrame3 = cframe * CFrame.new(0, 0, -10) * CFrame.new(0, 3, 0) * CFrame.Angles(
				0,
				0,
				-0.8726646259971648
			)
			clone3 = tripleSlash2.Slash:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
		elseif i == 3 then
			local cFrame3 = cframe * CFrame.new(0, 0, -10) * CFrame.new(0, 3, 0)
			clone3 = tripleSlash2.Slash:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
			local trailAttach1 = clone3:FindFirstChild("TrailAttach1")

			if trailAttach1 then
				for _, child in ipairs(trailAttach1:GetChildren()) do
					child.Enabled = true
				end
			end
		elseif i == 4 then
			local cFrame3 = cframe * CFrame.new(0, 0, -10) * CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, 0)
			clone3 = tripleSlash2.Slash:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
			scaleFX(clone3, 1.25)
		elseif i == 5 then
			local cFrame3 = cframe * CFrame.new(0, 0, -10) * CFrame.new(0, 3, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			clone3 = tripleSlash2.Slash:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
			scaleFX(clone3, 1.25)
		end

		if evolution then
			scaleFX(clone3, 1.5)
		end

		destroyAfter(clone3, data.fliesFor + 1)

		for _, effect in ipairs(clone3:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				if effect.Name == "Smoke" then
					effect.Rate /= v7 / 1.75
				else
					effect.Rate /= v7 / 2.5
				end

				effect.Rate *= 0.65
				effect.Enabled = true
			elseif effect:IsA("Beam") then
				local v8 = v2:Create(effect, v3[1], {
					Width0 = effect.Width0,
					Width1 = effect.Width1
				})
				effect.Width0 = 0
				effect.Width1 = 0
				v8:Play()
			end
		end

		v2:Create(clone3, v3[2], {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -(data.targetPos - data.origin).Magnitude) * CFrame.Angles(
				0,
				0,
				-0.5235987755982988
			)
		}):Play()
		task.delay(0.15, function()
			for _, beam in ipairs(clone3:GetDescendants()) do
				if beam:IsA("Beam") then
					v2:Create(beam, v3[3], {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			task.wait(data.fliesFor - 0.15)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local cFrame3 = clone3.CFrame
			local clone4 = tripleSlash2.End:Clone()
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame3
			clone4.Parent = _WorldOrigin
			destroyAfter(clone4, 7)
			local v11 = 0

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				v11 = math.max(v11, emitter.Lifetime.Max)
			end

			destroyAfter(clone4, v11 + 0.5)
		end)
		table.insert(clones, clone3)
	end

	for _, v8 in pairs(clones) do
		v8.Attachment.Particle_1.Enabled = false
		v8.Attachment2.Particle_1.Enabled = false
		v8.Attachment2.Particle_2.Enabled = false
		v8.Attachment2.Particle_3.Enabled = false
		v8.Attachment2.Particle_4.Enabled = false
		v8.Lightning.Enabled = false
		v8.Lightning2.Enabled = false
	end

	local lastTime = tick()
	local count = 0

	while tick() - lastTime < data.fliesFor - 0.15 do
		for _, v8 in pairs(clones) do
			v8.Attachment.Particle_1:Emit(1)
			v8.Attachment2.Particle_1:Emit(1)
			v8.Attachment2.Particle_2:Emit(1)
			v8.Attachment2.Particle_3:Emit(1)
			v8.Attachment2.Particle_4:Emit(1)
			count += 1

			if not (count <= 3) then
				continue
			end

			v8.Lightning:Emit(1)
			v8.Lightning2:Emit(1)
		end

		task.wait(0.075)
	end
end