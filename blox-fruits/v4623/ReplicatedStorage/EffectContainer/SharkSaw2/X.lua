local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("SharkSaw").X
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

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local _ = Util.CraterModule
local scaleParticle = Util.ScaleParticle
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local v = X
	local v2 = TweenService
	local v3 = _WorldOrigin
	local localPlayer2 = localPlayer
	local v5 = {
		TweenInfo.new(0.35, Enum.EasingStyle.Sine),
		TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		TweenInfo.new(0.235, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	}
	task.spawn(function()
		local cFrame = hrp.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(3.141592653589793, 0, 3.141592653589793)
		local spinPart = v.SpinPart
		local v7 = "KiribachiCircle" .. localPlayer2.Name
		local clone = spinPart:Clone()
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		clone.Name = v7 or clone.Name
		clone.CFrame = cFrame
		clone.Massless = true
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Parent = clone
		destroyAfter(weldConstraint, 7)
		weldConstraint.Part0 = hrp
		weldConstraint.Part1 = clone
		Util.Sound:Play("SharkSawX", hrp)
		local cFrame2 = hrp.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		local dust = v.Dust
		local v9 = "KiribachiDust" .. localPlayer2.Name
		local clone2 = dust:Clone()
		clone2.Parent = _WorldOrigin
		destroyAfter(clone2, 7)
		clone2.Name = v9 or clone2.Name
		clone2.CFrame = cFrame2
		local v10 = time()
		local now = 0

		for _ = 1, 600 do
			if clone2 == nil or clone2.Parent == nil or clone.Name ~= "KiribachiCircle" .. localPlayer2.Name or time() - v10 > 10 then
				break
			end

			local part = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(hrp.Position, createVector(0, -10, 0)),
				raycastParams.FilterDescendantsInstances
			)

			if part == nil or clone2 == nil then
				clone2.Attachment.ParticleEmitter.Enabled = false
				clone2.Attachment.ParticleEmitter2.Enabled = false
			else
				clone2.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
				clone2.Attachment.ParticleEmitter2.Color = ColorSequence.new(part.Color)
				clone2.Orientation = hrp.Orientation - createVector(0, 180, 0)
				clone2.CFrame = hrp.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				clone2.Attachment.ParticleEmitter.Enabled = true
				clone2.Attachment.ParticleEmitter2.Enabled = true
			end

			if tick() - now > 0.1 then
				clone.Attachment.RedSlashes:Emit(1)
				clone.Attachment.BlackSpinSlash1:Emit(1)
				now = tick()
			end

			task.wait(0.065)
		end
	end)
	task.delay(data.lastsFor, function()
		local child = v3:FindFirstChild("KiribachiCircle" .. localPlayer2.Name)

		if child then
			child.Name = "OldSpinny"

			for _, emitter in pairs(child.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				else
					v2:Create(emitter, v5[1], {
						Brightness = 0,
						Range = 0
					}):Play()
				end
			end

			child:FindFirstChildOfClass("WeldConstraint"):Destroy()
			child.Anchored = true
			destroyAfter(child, 1)
		end

		local child2 = v3:FindFirstChild("KiribachiDust" .. localPlayer2.Name)

		if child2 then
			child2.Attachment.ParticleEmitter.Enabled = false
			child2.Attachment.ParticleEmitter2.Enabled = false
			destroyAfter(child2, 1)
		end

		task.wait(0.1)
		local cFrame = hrp.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 0, 3.141592653589793)
		local clone = v.Slash:Clone()
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 7)
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Attachment.Orientation = createVector(0, -90, 0)

		for _, child3 in ipairs(clone.Attachment:GetChildren()) do
			scaleParticle({
				Emitter = child3,
				Scale = 1.65,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			child3:Emit(child3:GetAttribute("EmitCount"))
		end

		for i = 1, 2 do
			local cFrame2 = hrp.CFrame * CFrame.Angles(1.57, -1.57, 3.141592653589793)
			local clone2 = (i == 1 and v.wave1 or v.wave2):Clone()
			clone2.Parent = _WorldOrigin
			destroyAfter(clone2, 7)
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame2
			destroyAfter(clone2, 1)

			for _, decal in ipairs(clone2.Dec:GetChildren()) do
				if decal:IsA("Decal") then
					v2:Create(decal, v5[2], {
						Transparency = 1
					}):Play()
				end
			end

			v2:Create(clone2, v5[3], {
				CFrame = clone2.CFrame * CFrame.Angles(-2.355, 0, 0)
			}):Play()
		end

		local cFrame3 = hrp.CFrame * CFrame.new(-12, 0, -12) * CFrame.Angles(0, 0, 3.141592653589793)
		local clone2 = v.Sparks:Clone()
		clone2.Parent = _WorldOrigin
		destroyAfter(clone2, 7)
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame3
		destroyAfter(clone2, 2)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		if Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(hrp.Position, createVector(0, -10, 0)),
			raycastParams.FilterDescendantsInstances
		) then
			local cFrame2 = hrp.CFrame * CFrame.new(0, -2.25, 0)
			local clone3 = v.Dust2:Clone()
			clone3.Parent = _WorldOrigin
			destroyAfter(clone3, 7)
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame2
			destroyAfter(clone3, 1.5)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				scaleParticle({
					Emitter = emitter,
					Scale = 2.5,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
				emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
			end
		end
	end)
end