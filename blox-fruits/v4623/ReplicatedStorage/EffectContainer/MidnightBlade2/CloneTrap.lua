local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
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

local function safeSetRootCFrame(instance, cFrame: CFrame, flag: boolean)
	local v = flag == nil or flag

	if instance == nil then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	if not v then
		instance.CFrame = cFrame
		return
	end

	local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

	if raycastResult then
		instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
	else
		instance.CFrame = cFrame
	end
end

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
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
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos"))
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1))
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	return clone
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

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

return function(data)
	local _ = data.player
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
	local fireDir = data.fireDir
	local v = TweenService
	local cloneTrap = FX:WaitForChild("MidnightBlade").CloneTrap
	local cFrame2 = CFrame.lookAt(createVector(0, 0, 0), data.fireDir) * CFrame.new(0, 0, -7) + origin
	local scaleParticle = Util.ScaleParticle
	local v3 = math.max(0, Util.MasterClock:GetTime() - data.ClockTime)
	local fadeIn = data.fadeIn or 0.3
	local dashTime = data.dashTime or 0.55
	local teleportDelay = data.teleportDelay or 0.5
	local magnitude = data.endPoint.Magnitude
	local v4 = math.max(0.01, fadeIn - v3)
	local _ = v3 - (fadeIn - v4)
	local v5 = math.max(0.01, dashTime - v3)
	local _ = v3 - (dashTime - v5)
	local v7 = math.max(0.01, teleportDelay - v3)
	local _ = v3 - (teleportDelay - v7)
	local _ = {
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.533333333, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(0.325, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	}
	local cFrame3 = cFrame2 * CFrame.new(0, 0, -7)
	local effect = createEffect(cFrame3 * CFrame.new(0, -2, 0), cloneTrap.Spawn)
	destroyAfter(effect, 2)

	for _, emitter in ipairs(effect:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.9, lifetime.Max * 0.9)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	local ray = Util.Ray
	local position = effect.Position
	local v9 = { hrp.Parent }
	local v10, v11, lookDir = ray(position, createVector(-0, -10, -0), v9)

	if v10 then
		Effect.new("Portal.CreatePortal"):replicate({
			origin = v11 + lookDir * 0.1,
			lookDir = lookDir,
			lastsFor = v7 + 0.5,
			chargeParticlesEnabled = true
		})
	end

	task.wait(v4 * 0.66)
	cameraShakeAt(cFrame.Position, 70, 4, 7, 0.1, 0.35) -- equivalent call inferred; original call site unknown
	local effect2 = createEffect(cFrame3, cloneTrap.Clonee)
	effect2.Name = "MIDNIGHTBLADE/CLONE_" .. data.EffectId
	destroyAfter(effect2, 7)
	local humanoidRootPart = effect2.HumanoidRootPart
	humanoidRootPart.CFrame = cFrame3
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = cFrame2
	bodyGyro.MaxTorque = createVector(10000, 10000, 10000)
	bodyGyro.Parent = humanoidRootPart
	local clone = script.AlignPosition:Clone()
	clone.MaxVelocity = 0
	local attachmentPair = Util.AttachmentPair.new()
	local attachment0 = attachmentPair.attachment0
	local attachment1 = attachmentPair.attachment1
	attachment0.Parent = humanoidRootPart
	attachment1.WorldPosition = data.endPoint
	clone.Attachment0 = attachment0
	clone.Attachment1 = attachment1
	task.delay(7, function()
		attachmentPair:destroy()
	end)
	clone.Parent = humanoidRootPart
	local midnightBladeCloneDash = Util.Anims:Get(effect2, "MidnightBladeCloneDash")
	midnightBladeCloneDash:Play()
	midnightBladeCloneDash:AdjustSpeed(0.4166666666666667 / (v4 + v5 + v7))
	task.wait(v4 * 0.33)
	local effect3 = createEffect(humanoidRootPart.CFrame, cloneTrap.Forward)
	destroyAfter(effect3, 3)
	effect3.Weld.Part0 = humanoidRootPart
	local trail1 = effect3.Trail1
	local trail2 = effect3.Trail2
	trail1.Burn.Enabled = false
	trail1.Parent = Workspace.Terrain
	trail2.Parent = Workspace.Terrain
	local v13 = trail1.Position - trail2.Position

	for _, emitter in ipairs(effect3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Rate *= 1
		end
	end

	task.spawn(function()
		local lastTime = tick()

		while true do
			local v14 = tick() - lastTime
			local part, v15, v16 = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(humanoidRootPart.Position, createVector(0, -10, 0)),
				raycastParams.FilterDescendantsInstances
			)

			if part then
				local v17 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v15, v16) + v16 * 0.05
				trail1.WorldCFrame = v17 * CFrame.new(-v13)
				trail2.WorldCFrame = v17 * CFrame.new(v13)
			end

			trail1.Burn.Enabled = part and true or false

			if v14 > 2 then
				destroyAfter(trail1, trail1.Burn.Lifetime)
				destroyAfter(trail2, trail1.Burn.Lifetime)
				break
			else
				task.wait(0.016666666666666666)
			end
		end
	end)
	clone.MaxVelocity = (data.endPoint - humanoidRootPart.Position).Magnitude / v5
	local v14 = {
		"rbxassetid://12558376366",
		"rbxassetid://12558376101",
		"rbxassetid://12558375916",
		"rbxassetid://12558375736",
		"rbxassetid://12558375599",
		"rbxassetid://12558375321",
		"rbxassetid://12558375128",
		"rbxassetid://12558374890",
		"rbxassetid://12558374679"
	}
	task.spawn(function()
		for _ = 1, 6 do
			local effect4 = createEffect(
				humanoidRootPart.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-360, 360))))),
				cloneTrap.spiral
			)
			v:Create(effect4.Mesh, TweenInfo.new(0.18 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.09, 0.09, 0.011)
			}):Play()
			v:Create(effect4.Decal, TweenInfo.new(0.18 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.1
			}):Play()
			task.spawn(function()
				for i = 1, #v14 do
					local decal = effect4:FindFirstChild("Decal")
					decal.Texture = v14[i]
					task.wait(0.016666666666666666)
				end

				effect4:Destroy()
			end)
			task.wait(0.06 * v5)
		end
	end)
	task.wait(0.12 * v5)
	effect3.SpotLight.Enabled = true
	local effect4 = createEffect(
		cFrame2 * CFrame.new(0, 0, 8) * CFrame.Angles(0, 4.71, 0),
		cloneTrap.TexturedShockwave1
	)
	v:Create(effect4, TweenInfo.new(0.32 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = effect4.CFrame * CFrame.new(-magnitude, 0, 0) * CFrame.Angles(-3.141592653589793, 0, 0)
	}):Play()
	v:Create(effect4.Mesh, TweenInfo.new(0.32 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), {
		Scale = createVector(1, 0.3, 0.3)
	}):Play()
	v:Create(effect4.Texture, TweenInfo.new(0.54 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	destroyAfter(effect4, 0.2)
	local effect5 = createEffect(
		cFrame2 * CFrame.new(0, 0, 8) * CFrame.Angles(0, 4.71, 0),
		cloneTrap.TexturedShockwave2
	)
	v:Create(effect5, TweenInfo.new(0.32 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = effect5.CFrame * CFrame.new(-magnitude, 0, 0)
	}):Play()
	v:Create(effect5.Mesh, TweenInfo.new(0.21 * v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = createVector(1, 0.25, 0.25)
	}):Play()
	v:Create(effect5.Texture, TweenInfo.new(0.32 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	destroyAfter(effect5, 0.2)
	task.wait(0.32 * v5)

	for _, descendant in ipairs(effect3:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("SpotLight") then
			v:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Range = 0
			}):Play()
		end
	end

	task.wait(0.56 * v5)
	local effect6 = createEffect(humanoidRootPart.CFrame * CFrame.new(0, 0, 0), cloneTrap.SlashStart)
	destroyAfter(effect6, 1)

	for _, child in ipairs(effect6.Attachment:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	task.wait(0.5 * v7)
	local position3 = humanoidRootPart.Position
	local v15 = 8
	local v16 = 14
	local v17 = 0.2
	local v18 = 0.7

	if (70 or 300) > (Workspace.CurrentCamera.CFrame.Position - position3).Magnitude then
		Util.CameraShaker:ShakeOnce(v15, v16, v17, v18)
	end

	effect2.Handle.Aura1.Enabled = true
	local effect7 = createEffect(humanoidRootPart.CFrame * CFrame.new(0, 0, -1), cloneTrap.Slash)
	destroyAfter(effect7, 3)
	effect7.Attachment.Orientation = createVector(0, 180, 15)
	effect7.Wind.Orientation = createVector(0, 180, 15)

	for _, emitter in ipairs(effect7:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Parent.Name ~= "Slash") then
			continue
		end

		if emitter.Parent.Name == "Attachment" then
			emitter.Rotation = NumberRange.new(emitter.Rotation.Min - 110, emitter.Rotation.Max - 110)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	local part, v19, v20 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(humanoidRootPart.Position, createVector(0, -10, 0)),
		raycastParams.FilterDescendantsInstances
	)

	if part then
		local effect8 = createEffect(
			Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v19, v20) + v20 * 0.05,
			cloneTrap.Dust
		)
		destroyAfter(effect8, 1.5)

		for _, emitter in ipairs(effect8:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
			scaleParticle({
				Emitter = emitter,
				Scale = 1.6,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.29000000000000004 * v7)

	for _, child in ipairs(effect7.Slash:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end
end