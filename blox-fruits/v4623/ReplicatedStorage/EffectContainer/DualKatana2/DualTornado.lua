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

local v = { TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	destroyAfter(clone, 7)
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	local v2 = TweenService
	local dualTornado = FX:WaitForChild("DualKatana").DualTornado
	local cframe = CFrame.new(origin)
	local clone = dualTornado.Charge:Clone()
	destroyAfter(clone, 7)
	clone.Name = clone.Name
	clone.CFrame = cframe
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 1)

	for _, emitter in ipairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.1)
	local position = hrp.Position
	local part, _, _ = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(position, createVector(0, -5, 0)),
		raycastParams.FilterDescendantsInstances
	)
	local cFrame = cframe * CFrame.new(0, 12.5, 0)
	local clone2 = dualTornado.TornadoPart:Clone()
	destroyAfter(clone2, 7)
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 4)
	local descendants = clone2:GetDescendants()

	for _, emitter in pairs(descendants) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter.Parent.Name == "Ground" then
			if part and emitter.Name ~= "Halo" then
				if emitter.Name ~= "GroundSlash" then
					local speed = emitter.Speed
					emitter.Speed = NumberRange.new(speed.Min * 1.5, speed.Max * 1.5)
					emitter.Color = ColorSequence.new(part.Color)
				end

				emitter.Enabled = true
			elseif emitter.Name ~= "Halo" then
				emitter.Enabled = false
			end
		elseif emitter.Name ~= "NA" then
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
			local speed = emitter.Speed
			emitter.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
			local acceleration = emitter.Acceleration
			emitter.Acceleration = Vector3.new(acceleration.X * 2, acceleration.Y * 2, acceleration.Z * 2)
			emitter.Rate *= 2
		end
	end

	if player == game.Players.LocalPlayer then
		local clone3 = dualTornado.Blur:Clone()
		clone3.Parent = Lighting
		destroyAfter(clone3, 2)
		v2:Create(clone3, v[1], {
			Size = 4
		}):Play()
		task.spawn(function()
			task.wait(0.05)
			v2:Create(clone3, v[1], {
				Size = 0
			}):Play()
		end)
	end

	task.wait(0.05)
	local folder = nil
	task.spawn(function()
		local cFrame2 = clone2.CFrame * CFrame.new(0, 2, 0)
		local clone3 = dualTornado.SpinPart:Clone()
		destroyAfter(clone3, 7)
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame2
		clone3.Parent = _WorldOrigin
		folder = clone3
		local v5 = time()

		for _ = 1, 600 do
			if folder == nil or folder.Parent == nil or time() - v5 > 10 then
				break
			end

			folder.CFrame *= CFrame.Angles(0, -0.2617993877991494, 0)
			task.wait()
		end
	end)
	task.wait(data.damageFor)

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	destroyAfter(folder, 0.3)

	for _, beam in ipairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			Util.BoatTween:Create(beam, {
				Time = 0.25,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				}
			}):Play()
		end
	end
end