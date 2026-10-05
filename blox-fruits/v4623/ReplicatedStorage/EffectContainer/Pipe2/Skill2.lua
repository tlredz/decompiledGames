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
local pipeSkill2 = FX:WaitForChild("Pipe").PipeSkill2
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

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
local function snapProjectileToFinalPos(part, p, p2)
	if not p2 then
		part.CFrame = part.CFrame.Rotation + p
		return
	end

	local position = part.Position
	heartbeatLoopFor2(0.1, function(_, _, p3)
		part.CFrame = part.CFrame.Rotation + position + (p - position) * p3
	end, function()
		part.CFrame = part.CFrame.Rotation + p
	end)
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
		local v2 = part
		local impactPos = instance:GetAttribute("ImpactPos")
		local position = v2.Position
		heartbeatLoopFor2(0.1, function(_, _, p5)
			v2.CFrame = v2.CFrame.Rotation + position + (impactPos - position) * p5
		end, function()
			snapProjectileToFinalPos(v2, impactPos, false) -- equivalent call inferred; original call site unknown
		end)
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

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
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

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
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

	Util.Sound:Play("PipeXFire", hrp.Position)
	local parent = _WorldOrigin
	local cframe = CFrame.lookAt(data.origin, data.targetPos)
	local magnitude = (data.targetPos - data.origin).Magnitude
	local clone = pipeSkill2.StartImpact:Clone()
	clone.CFrame = cframe
	clone.Parent = parent
	destroyAfter(clone, 2)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		coroutine.wrap(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)()
	end

	local clone2 = pipeSkill2.Dragon:Clone()
	clone2.PrimaryPart.CFrame = cframe
	clone2.Parent = parent
	destroyAfter(clone2, 5)
	task.wait()

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local tween = TweenService:Create(
		clone2.PrimaryPart,
		TweenInfo.new(data.fliesFor, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, -magnitude),
			Size = Vector3.new(clone2.PrimaryPart.Size.X, clone2.PrimaryPart.Size.Y, clone2.PrimaryPart.Size.Z * 2.5)
		}
	)
	local bodyFlame = clone2.PrimaryPart.BodyFlame
	local v2 = false
	coroutine.wrap(function()
		bodyFlame.C0 = bodyFlame.Part0.CFrame:ToObjectSpace(bodyFlame.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			(math.rad((math.random(-360, 360))))
		)
		local v3 = time()

		for _ = 1, 600 do
			bodyFlame.C0 = bodyFlame.Part0.CFrame:ToObjectSpace(bodyFlame.Part1.CFrame) * CFrame.Angles(
				0,
				0,
				0.5235987755982988
			)
			task.wait()

			if v2 == true or time() - v3 > 10 then
				break
			end
		end
	end)()
	local clone3 = pipeSkill2.GroundFlame:Clone()
	clone3.CFrame = cframe * CFrame.new(0, 0, -5)
	clone3.Parent = parent
	destroyAfter(clone3, 5)
	TweenService:Create(
		clone3,
		TweenInfo.new(data.fliesFor + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0.15),
		{
			CFrame = clone3.CFrame * CFrame.new(0, 0, -magnitude)
		}
	):Play()
	local position = clone3.Position
	local v3 = 12
	local part, _ = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(
			position + Vector3.new(0, v3 / 10, 0),
			CFrame.new(position + Vector3.new(0, v3 / 10, 0), position + Vector3.new(0, -v3, 0)).LookVector * v3
		),
		raycastParams.FilterDescendantsInstances
	)

	if part then
		coroutine.wrap(function()
			local clone4 = pipeSkill2.GroundFlameTrail:Clone()
			clone4.CFrame = clone3.CFrame
			clone4.Parent = parent
			destroyAfter(clone4, 3)
			local tween2 = TweenService:Create(
				clone4,
				TweenInfo.new(data.fliesFor, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					CFrame = clone4.CFrame * CFrame.new(0, 0, -magnitude)
				}
			)
			tween2:Play()
			v3 = 12
			local lastTime = os.clock()
			local v4 = time()

			for _ = 1, 600 do
				task.wait(0.01)
				local part2, _ = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(
						clone4.Position + Vector3.new(0, v3 / 2, 0),
						CFrame.new(
							clone4.Position + Vector3.new(0, v3 / 10, 0),
							clone4.Position + Vector3.new(0, -v3, 0)
						).LookVector * v3
					),
					raycastParams.FilterDescendantsInstances
				)

				if part2 then
					if os.clock() - lastTime >= 0.25 or time() - v4 > 10 then
						break
					end
				else
					tween2:Pause()
					break
				end
			end
		end)()
	end

	coroutine.wrap(function()
		for _, emitter in ipairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.defer(function()
			tween:Play()
		end)
		tween.Completed:Wait()
		v2 = true

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Util.Sound:Play("PipeXExplosion", clone2.PrimaryPart.Position)
		local clone4 = pipeSkill2.Explosion:Clone()
		clone4.Position = clone2.PrimaryPart.Position
		clone4.Parent = parent
		destroyAfter(clone4, 3)
		local position2 = clone4.Position
		local v4 = 9 or 8
		local v5 = 14
		local v6 = 0.2
		local v7 = 0.8 or 0.7

		if (80 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
			Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
		end

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v8 = emitter
			coroutine.wrap(function()
				if v8:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v8:GetAttribute("EmitDelay"))
				end

				v8:Emit(v8:GetAttribute("EmitCount"))
			end)()
		end

		clone2.PrimaryPart.Transparency = 1

		if data.circleOfFlamesExists then
			local clone5 = pipeSkill2.Burn:Clone()
			local rayMap, v8, v9 = Util.RayMap(clone4.Position + createVector(0, 0.1, 0), createVector(-0, -12, -0))
			clone5.CFrame = CFrame.new(v8, v8 + (not rayMap and createVector(0, 1, 0) or v9)) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			clone5.Parent = parent
			destroyAfter(clone5, 4)
			local v10 = Util.Sound:Play("PipeXAmbiance", v8)

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			coroutine.wrap(function()
				task.wait(data.fireDamageFor)
				Util.Sound:FadeOut(v10, 0.5)

				for _, effect in ipairs(clone5:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end)()
		end

		task.wait(0.15)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)()
end