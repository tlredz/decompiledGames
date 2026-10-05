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
local bisentoZ = FX:WaitForChild("BisentoV1").BisentoZ
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
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
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

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
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

	local bisentoZ2 = bisentoZ
	local v2 = TweenService
	local v3 = {
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.35, Enum.EasingStyle.Sine),
		TweenInfo.new(0.45, Enum.EasingStyle.Quad),
		TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	}
	local cframe = CFrame.new(origin)
	Util.Sound:Play("RubberAxeImpact", origin, 25)
	Util.Sound:Play("DestructDebris", origin, 25, 1, 0.3)
	local clone = bisentoZ2.Blur:Clone()

	if (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 100 then
		clone.Parent = Lighting
	end

	v2:Create(clone, v3[1], {
		Size = 10
	}):Play()
	destroyAfter(clone, 1)
	local cFrame3 = cframe * CFrame.new(0, -3, 0) * CFrame.new(0, 0.25, 0)
	local clone2 = bisentoZ2.Impact:Clone()
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	destroyAfter(clone2, 5)
	local cFrame2 = clone2.CFrame
	local clone3 = bisentoZ2.Mesh:Clone()
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 7)
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame2
	destroyAfter(clone3, 4)
	v2:Create(clone3, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(84.5, 84.5, 84.5),
		Transparency = 0.97
	}):Play()
	local cFrame4 = cframe * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 1.57)
	local clone4 = bisentoZ2.Shockwave:Clone()
	clone4.Parent = _WorldOrigin
	destroyAfter(clone4, 7)
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame4
	destroyAfter(clone4, 1)
	v2:Create(clone4, v3[2], {
		CFrame = clone4.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	v2:Create(clone4.Mesh, v3[3], {
		Scale = createVector(0.33, 1.32, 1.32)
	}):Play()
	v2:Create(clone4.Decal, v3[3], {
		Transparency = 1
	}):Play()
	task.delay(0.14, function()
		v2:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone5 = bisentoZ2.Sphere:Clone()
	clone5.Parent = _WorldOrigin
	destroyAfter(clone5, 7)
	clone5.Name = clone5.Name
	clone5.CFrame = cframe
	clone5.Size = createVector(1, 1, 1)
	clone5.Color = Color3.fromRGB(170, 170, 255)
	clone5.Transparency = 0.5
	v2:Create(clone5, v3[5], {
		Size = createVector(75, 75, 75),
		Transparency = 1
	}):Play()
	destroyAfter(clone5, 0.5)
	local cFrame5 = cframe * CFrame.new(0, 2.5, 0)
	local clone6 = bisentoZ2.Ring:Clone()
	clone6.Parent = _WorldOrigin
	destroyAfter(clone6, 7)
	clone6.Name = clone6.Name
	clone6.CFrame = cFrame5
	clone6.Size = createVector(60, 5, 60)
	clone6.Transparency = 0.85
	v2:Create(clone6, v3[4], {
		Size = createVector(80, 2, 80),
		Transparency = 1
	}):Play()
	destroyAfter(clone6, 0.75)
	local raycastResult = Workspace:Raycast(origin, cframe.upVector * -10, raycastParams)

	if raycastResult then
		local v7 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local cFrame6 = v7 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone7 = bisentoZ2.Dust:Clone()
		clone7.Parent = _WorldOrigin
		destroyAfter(clone7, 7)
		clone7.Name = clone7.Name
		clone7.CFrame = cFrame6
		destroyAfter(clone7, 2.5)

		for _, child in ipairs(clone7.Attachment:GetChildren()) do
			child.Color = ColorSequence.new(raycastResult.Instance.Color)
			child:Emit(child:GetAttribute("EmitCount"))
		end

		local cFrame7 = v7 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone8 = bisentoZ2.Scar:Clone()
		clone8.Parent = _WorldOrigin
		destroyAfter(clone8, 7)
		clone8.Name = clone8.Name
		clone8.CFrame = cFrame7
		clone8.Size *= 1
		destroyAfter(clone8, 2)

		for _, child in ipairs(clone8:GetChildren()) do
			v2:Create(child, v3[6], {
				Transparency = 1
			}):Play()
		end
	end

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:GetAttribute("EmitDelay") == 0 then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			local v7 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end
	end

	craterModule({
		Cframe = cframe * CFrame.new(0, 0, 0),
		Size = 7,
		Ammount = 8,
		Despawn = 1.25,
		Distance = 16
	})
end