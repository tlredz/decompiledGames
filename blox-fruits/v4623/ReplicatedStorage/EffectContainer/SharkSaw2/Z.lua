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
local Z = FX:WaitForChild("SharkSaw").Z
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
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	return clone
end

local _ = Util.CraterModule
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
	local v = Z
	local v2 = TweenService
	local v3 = {
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(data.fliesFor, Enum.EasingStyle.Sine),
		TweenInfo.new(data.fliesFor, Enum.EasingStyle.Sine)
	}
	local targetPos = data.targetPos
	local cframe = CFrame.lookAt(origin, targetPos)
	local position = cframe.Position
	local index = data.index

	if index == 1 then
		Util.Sound:Play("SharkSawZ", cframe)
	end

	if player == game.Players.LocalPlayer then
		if index == 3 then
			local position2 = cFrame.Position
			local v4 = 8
			local v5 = 14
			local v6 = 0.2
			local v7 = 0.7

			if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end
		else
			local position2 = cFrame.Position
			local v4 = 6 or 8
			local v5 = 10 or 14
			local v6 = 0.2
			local v7 = 0.7

			if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end
		end
	end

	local cFrame2 = cframe * CFrame.new(0, 1, 0) * CFrame.Angles(
		3.14,
		0,
		index == 1 and 1.256 or index == 2 and -1.256 or 0
	)
	local clone = (index ~= 3 and v.Normal or v.Big):Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	destroyAfter(clone, 1)
	local cFrame3 = cframe * CFrame.new(0, 0.5, 0)
	local clone2 = v.release:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	destroyAfter(clone2, 1)

	if index == 1 then
		clone2.Attachment.Orientation = createVector(0, 180, -15)
	elseif index == 2 then
		clone2.Attachment.Orientation = createVector(180, 0, 15)
	else
		clone2.Attachment.Orientation = createVector(90, 0, 90)
	end

	for _, child in ipairs(clone2.Attachment:GetChildren()) do
		if index == 3 then
			scaleParticle({
				Emitter = child,
				Scale = 1.65,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	v2:Create(clone, index ~= 3 and v3[2] or v3[3], {
		CFrame = clone.CFrame * CFrame.new(0, 0, (targetPos - origin).Magnitude)
	}):Play()

	if Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(position, createVector(0, -10, 0)),
		raycastParams.FilterDescendantsInstances
	) then
		local cFrame4 = cframe * CFrame.new(0, index == 3 and 1 or -2.25, 0) * CFrame.Angles(
			index == 3 and 1.57 or 0,
			0,
			index == 3 and 1.57 or 0
		)
		local clone3 = v.Dust:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame4
		clone3.Parent = _WorldOrigin
		destroyAfter(clone3, 7)
		destroyAfter(clone3, 1.5)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if index == 3 then
				scaleParticle({
					Emitter = emitter,
					Scale = 2.5,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			else
				scaleParticle({
					Emitter = emitter,
					Scale = 1.6,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local raycastResult = index == 3 and Workspace:Raycast(position, createVector(-0, -30, -0), raycastParams)

	if raycastResult then
		local position2 = raycastResult.Position
		local lastTime = tick()
		task.spawn(function()
			local v6 = time()

			for _ = 1, 600 do
				if clone == nil or clone.Parent == nil or time() - v6 > 10 or tick() - lastTime > 0.3 then
					break
				end

				local part, v7 = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(clone.Position, createVector(0, -10, 0)),
					raycastParams.FilterDescendantsInstances
				)

				if part then
					local magnitude = (v7 - position2).Magnitude

					if magnitude > 5 then
						local cFrame4 = CFrame.new(position2, v7) * CFrame.new(0, 0, -magnitude / 2)
						local clone3 = v.burnTrail:Clone()
						clone3.Name = clone3.Name
						clone3.CFrame = cFrame4
						clone3.Parent = _WorldOrigin
						destroyAfter(clone3, 7)
						destroyAfter(clone3, 2)
						v2:Create(clone3, TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Size = Vector3.new(0.2, 0.2, magnitude)
						}):Play()
						v2:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Color = Color3.fromRGB(0, 0, 0)
						}):Play()
						v2:Create(clone3, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end
				end

				position2 = v7
				task.wait()
			end
		end)
	end

	task.delay(data.fliesFor * (index == 3 and 1 or 0.5), function()
		for i, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
				Util.BoatTween:Create(descendant, {
					Time = i == 3 and 0.4 or 0.5,
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
			elseif descendant:IsA("PointLight") then
				v2:Create(descendant, v3[2], {
					Range = 0,
					Brightness = 0
				}):Play()
			end
		end
	end)

	if index ~= 1 and index ~= 3 then
		task.wait(0.35)
		local clone3 = v.charge:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cframe
		clone3.Parent = _WorldOrigin
		destroyAfter(clone3, 7)
		destroyAfter(clone3, 1)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.1)
	end
end