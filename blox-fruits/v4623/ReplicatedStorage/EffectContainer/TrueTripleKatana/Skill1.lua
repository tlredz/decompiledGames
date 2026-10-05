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
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://14441639425"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://14441641661"
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill1 = FX:WaitForChild("TrueTripleKatana").Skill1
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
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
	return instance
end

local function getValueOfValueObject(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

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

local function haltUntilCondition(callback, value: number?)
	local v = value or 10
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(callback)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
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

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	return part
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, p4)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function RocksFloat(p, parent, instance)
	coroutine.wrap(function()
		local clone = skill1.BeforeRocks:Clone()
		clone.CFrame = CFrame.new(p.Position)
		clone.Parent = parent
		destroyAfter(clone, 5)
		clone.Attachment.Particle_1:Emit(1)
		task.wait(0.35)
		clone.Attachment.Particle_2:Emit(1)
	end)()

	for i = 1, 20 do
		local v = i
		coroutine.wrap(function()
			if v % 2 == 0 then
				task.wait(0.35)
			end

			local clone = skill1.Rock:Clone()
			clone.Position = p.Position + Vector3.new(math.random(-25, 25) * 2, 0, math.random(-25, 25) * 2)
			clone.Size = Vector3.new(math.random(2, 4) * 2, math.random(2, 4), math.random(2, 4) * 2)
			clone.Material = instance.Material
			clone.Color = instance.Color
			clone.CanCollide = true
			clone.Parent = parent
			rocks:ApplyCollision(clone, nil, true)

			for i2, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			coroutine.wrap(function()
				task.wait(3)
				Util.Sound:Play("4-DragonHurricaneDebris", clone)
				clone.BurnParticle_1.Enabled = true
				clone.BurnParticle_2.Enabled = true
				TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				task.wait(0.4)
				clone.BurnParticle_1.Enabled = false
				clone.BurnParticle_2.Enabled = false
				task.wait(1.6)
				clone:Destroy()
			end)()
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 2600
			bodyVelocity.Parent = clone
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, 200, math.random(-10, 10) / 5)
			).LookVector * math.random(70, 140)
			clone.Attachment0.Orientation = Vector3.new(
				math.random(-90, 90),
				math.random(-90, 90),
				math.random(-90, 90)
			)
			coroutine.wrap(function()
				local v2 = math.random(60, 120)
				local v3 = math.random(60, 120)
				local v4 = math.random(60, 120)
				local v5 = v2 / 10
				local v6 = v3 / 10
				local v7 = v4 / 10

				for i2 = 1, 6 do
					v2 = math.clamp(v2 - v5, 0, 120)
					v3 = math.clamp(v3 - v6, 0, 120)
					v4 = math.clamp(v4 - v7, 0, 120)
					local tween = TweenService:Create(
						clone.Attachment0,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.Attachment0.CFrame * CFrame.Angles(
								math.rad(v2),
								math.rad(v3),
								(math.rad(v4))
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()
				end

				clone.AlignOrientation:Destroy()
			end)()
			task.wait(0.1)
			bodyVelocity:Destroy()
		end)()
	end
end

local function Spin(p, boolValue, numberValue, numberValue2)
	local part = p.Part
	local beams = p.Beams
	coroutine.wrap(function()
		part:SetAttribute("Tweening", true)
		task.wait(0.1)
		part:SetAttribute("Tweening", false)
	end)()

	for _, beam in pairs(beams) do
		local v = beam
		local v2 = beam:GetAttribute("StartDelay")
		coroutine.wrap(function()
			local width0 = v:GetAttribute("Width0")
			local width1 = v:GetAttribute("Width1")
			local tween = TweenService:Create(
				v,
				TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Width0 = width0,
					Width1 = width1
				}
			)
			v.Width0 = 0
			v.Width1 = 0
			task.wait(v2 / 2)
			task.wait(math.random(0, 100) / 1000)

			if boolValue.Value == false then
				tween:Play()
			end
		end)()
	end

	local value = numberValue.Value
	local value2 = numberValue2.Value

	if part.Name ~= "SpinH" and part.Name ~= "SpinG" then
		if part.Name == "SpinF" or part.Name == "SpinE" then
			value *= 0.8
			value2 *= 0.8
		elseif part.Name == "SpinD" or part.Name == "SpinC" then
			value *= 0.5
			value2 *= 0.5
		elseif part.Name == "SpinB" or part.Name == "SpinA" then
			value *= 0.25
			value2 *= 0.25
		end
	end

	if boolValue.Value == false then
		for _ = 1, math.random(3, 5) do
			local vector2 = Vector3.new(value, part.Orientation.Y, value2)
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Orientation = vector2 + Vector3.new(value, 115, value2)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		for _, beam in pairs(beams) do
			TweenService:Create(beam, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end

	local vector2 = Vector3.new(value, part.Orientation.Y, value2)
	TweenService:Create(part, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Orientation = vector2 + Vector3.new(value, 75, value2)
	}):Play()
end

local function SpinOut(p)
	local v = math.random(0, 100) / 1000
	local beams = p.Beams

	for _, beam in pairs(beams) do
		TweenService:Create(beam, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartRotating(items, tornadoDamageFor)
	coroutine.wrap(function()
		local lastTime = os.clock()
		local boolValue = Instance.new("BoolValue")
		boolValue.Value = false
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Value = 0
		coroutine.wrap(function()
			TweenService:Create(
				numberValue,
				TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
				{
					Value = 5
				}
			):Play()
			TweenService:Create(
				numberValue2,
				TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
				{
					Value = 5
				}
			):Play()
		end)()

		while true do
			if tornadoDamageFor <= os.clock() - lastTime then
				break
			end

			for _, item in pairs(items) do
				if item.Part:GetAttribute("Tweening") ~= false then
					continue
				end

				local v2 = item
				coroutine.wrap(function()
					Spin(v2, boolValue, numberValue, numberValue2)
				end)()
			end

			task.wait(math.random(0, 100) / 1000)

			if tornadoDamageFor <= os.clock() - lastTime then
				break
			end
		end

		boolValue.Value = true

		for _, item in pairs(items) do
			local v = item
			coroutine.wrap(function()
				task.wait(math.random(0, 100) / 300)
				SpinOut(v)
			end)()
		end

		task.wait(1)
		boolValue:Destroy()
	end)()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartRotatingPart(foldersByFolder, tornadoDamageFor)
	coroutine.wrap(function()
		local lastTime = os.clock()

		repeat
			coroutine.wrap(function()
				for _, item in pairs(foldersByFolder) do
					local v = item:GetAttribute("Speed") * 0.5
					TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = item.CFrame * CFrame.Angles(0, math.rad(v), 0)
					}):Play()
					task.wait()
				end
			end)()
			task.wait(0.3)
			local v = os.clock() - lastTime
		until tornadoDamageFor + 0.25 <= v

		for _, item in pairs(foldersByFolder) do
			local folder = item
			coroutine.wrap(function()
				local speed = folder:GetAttribute("Speed")
				TweenService:Create(folder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = folder.CFrame * CFrame.Angles(0, math.rad(speed * 1.5), 0)
				}):Play()
				task.wait(math.random(0, 25) / 100)

				for i, emitter in ipairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)()
		end
	end)()
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

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1200 then
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

	local parent2 = _WorldOrigin
	local cframe = CFrame.lookAt(origin, data.targetPos)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cframe
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	local cFrame3 = part.CFrame * CFrame.new(0, 0, -5)
	local clone = skill1.StartBefore:Clone()
	clone.CFrame = cFrame3
	clone.Parent = parent2
	destroyAfter(clone, 7)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	clone.Particle_1.Enabled = true
	clone.Particle_2.Enabled = true
	local clone2 = skill1.Start:Clone()
	clone2.CFrame = cFrame3
	clone2.Parent = parent2
	destroyAfter(clone2, 7)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	clone.Particle_1.Enabled = false
	clone.Particle_2.Enabled = false
	local v3 = Util.MasterClock:GetTime() - data.timestamp
	local v4 = data.fliesFor - v3
	local duration = v4 < 0.025 and 0.025 or v4
	Util.Sound:Play("2-DragonHurricane Fire", cFrame3)
	local clone3 = skill1.Dragon:Clone()
	clone3:SetPrimaryPartCFrame(cFrame3)
	clone3.Parent = parent2
	destroyAfter(clone3, 7)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true

		if not emitter:GetAttribute("Funky") then
			continue
		end

		local v6 = emitter
		coroutine.wrap(function()
			task.wait(0.2)

			for i = 1, 10 do
				v6.Acceleration = Vector3.new(
					math.random(-50, 50) * 1.5,
					math.random(-50, 50) * 1.5,
					math.random(-50, 50) * 1.5
				)
				task.wait(math.random(10, 20) / 200)
			end
		end)()

		for _ = 1, 3 do
			local clone4 = emitter:Clone()
			clone4.Parent = emitter.Parent
			clone4.Drag = emitter.Drag + math.random(-2, 3)
			coroutine.wrap(function()
				task.wait(0.2)

				for i = 1, 10 do
					clone4.Acceleration = Vector3.new(
						math.random(-50, 50) * 1.5,
						math.random(-50, 50) * 1.5,
						math.random(-50, 50) * 1.5
					)
					task.wait(math.random(10, 20) / 200)
				end
			end)()
		end
	end

	clone3.AnimationController.Animator:LoadAnimation(animation):Play()
	local magnitude = (data.targetPos - origin).Magnitude
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = clone3:GetPrimaryPartCFrame()
	local v6 = clone3:GetPrimaryPartCFrame() * CFrame.new(0, 0, -magnitude + 5)
	cFrameValue:GetPropertyChangedSignal("Value"):connect(function()
		if clone3.PrimaryPart then
			clone3:SetPrimaryPartCFrame(cFrameValue.Value)
		end
	end)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{
			Value = v6
		}
	)
	tween.Completed:connect(function()
		cFrameValue:Destroy()
	end)
	tween:Play()
	local Effect = require(game.ReplicatedStorage.Effect)
	Effect.new("SuperhumanV2.Travel"):replicate({
		Anchor = clone3.PrimaryPart,
		Scale = 6,
		Color = clone3.Body.Color,
		Duration = duration,
		StopWithoutSurface = true,
		IgnoreTrail = true,
		IgnoreParticles = true,
		Fast = true
	})
	coroutine.wrap(function()
		task.wait(duration)
		local clone4 = skill1.Bite:Clone()
		clone4.Parent = parent2
		destroyAfter(clone4, 7)
		clone4.Weld.Part1 = clone3.Teeth
		clone4.Weld.Enabled = true
		task.wait()
		clone4.Attachment2.WorldCFrame = CFrame.new(clone4.Attachment2.WorldPosition + createVector(0, 1, 0))

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			coroutine.wrap(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)()
		end

		task.wait(0.05)
		clone3.AnimationController.Animator:LoadAnimation(animation2):Play()
		task.wait(0.15)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GroundSlashes(cFrame2, parent, instance)
			coroutine.wrap(function()
				task.wait(0.5)
				local clone5 = skill1.GroundSlashes:Clone()
				clone5.CFrame = cFrame2
				clone5.Parent = parent
				destroyAfter(clone5, 7)
				local descendants = clone5:GetDescendants()

				for _, emitter in ipairs(descendants) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter:GetAttribute("Color") then
						emitter.Color = ColorSequence.new(instance.Color, instance.Color)
					end

					emitter.Enabled = true
				end

				task.wait(data.tornadoDamageFor)

				for _, emitter in ipairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)()
		end

		local raycastResult = Workspace:Raycast(
			v6.Position + createVector(0, 1, 0),
			createVector(-0, -11, -0),
			raycastParams
		)

		if raycastResult then
			local cFrame2 = CFrame.new(
				raycastResult.Position + raycastResult.Normal * 0.1,
				raycastResult.Position + raycastResult.Normal
			) * CFrame.Angles(-1.5707963267948966, 0, 0)
			RocksFloat(cFrame2, parent2, raycastResult.Instance)
			GroundSlashes(cFrame2, parent2, raycastResult.Instance) -- equivalent call inferred; original call site unknown
		end

		coroutine.wrap(function()
			task.wait(0.05)
			local clone5 = skill1.TornadoBefore:Clone()
			clone5.CFrame = CFrame.new(v6.Position) * CFrame.new(0, 10, 0)
			clone5.Parent = parent2
			destroyAfter(clone5, 7)

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v7 = emitter
				coroutine.wrap(function()
					if v7:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v7:GetAttribute("EmitDelay"))
					end

					v7:Emit(v7:GetAttribute("EmitCount"))
				end)()
			end
		end)()
	end)()
	task.wait(duration * 0.75)
	local descendants = clone3:GetDescendants()
	coroutine.wrap(function()
		task.wait(0.1)

		for _, effect in ipairs(descendants) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end
	end)()
	task.wait(duration * 0.25)

	for _, part2 in ipairs(descendants) do
		if part2:IsA("BasePart") then
			part2.Transparency = 1
		end
	end

	local function viewerIsClose(p, p2, callback)
		if (Workspace.CurrentCamera.CFrame.Position - p).Magnitude < p2 then
			callback()
		end
	end

	local position = v6.Position

	if (Workspace.CurrentCamera.CFrame.Position - position).Magnitude < 120 then
		coroutine.wrap(function()
			local clone4 = skill1.Bloom:Clone()
			clone4.Parent = Lighting
			local tween2 = TweenService:Create(
				clone4,
				TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = 50,
					Threshold = 2
				}
			)
			tween2:Play()
			tween2.Completed:Wait()
			local tween3 = TweenService:Create(clone4, TweenInfo.new(0.15), {
				Size = 24,
				Threshold = 2
			})
			tween3:Play()
			tween3.Completed:Wait()
			task.wait(0.15)
			local tween4 = TweenService:Create(
				clone4,
				TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = 50,
					Threshold = 1
				}
			)
			tween4:Play()
			tween4.Completed:Wait()
			local tween5 = TweenService:Create(clone4, TweenInfo.new(0.15), {
				Size = 24,
				Threshold = 2
			})
			tween5:Play()
			tween5.Completed:Wait()
			clone4:Destroy()
		end)()
	end

	Util.Sound:Play("3-DragonHurricane Explosion", v6)
	task.wait(data.delayUntilTornado * 5)
	local v7 = {}
	local foldersByFolder = {}

	for i = 1, 3 do
		local v8 = i
		coroutine.wrap(function()
			local clone4 = nil

			if v8 == 1 then
				clone4 = skill1.Tornado:Clone()
			elseif v8 == 2 then
				clone4 = skill1.Tornado2:Clone()
			elseif v8 == 3 then
				clone4 = skill1.Tornado3:Clone()
			end

			clone4.CFrame = CFrame.new(v6.Position)
			clone4.Parent = parent2
			destroyAfter(clone4, 7)
			task.wait()

			for i2, child in ipairs(clone4:GetChildren()) do
				if child:IsA("Part") then
					child.Anchored = true
				elseif child:IsA("Weld") then
					child:Destroy()
				end
			end

			for i2, child in ipairs(clone4:GetChildren()) do
				local folder = child
				coroutine.wrap(function()
					local v9

					if folder.Name == "SpinA" then
						v9 = 2.5
					elseif folder.Name == "SpinB" then
						v9 = 3
					elseif folder.Name == "SpinC" then
						v9 = 3.5
					elseif folder.Name == "SpinD" then
						v9 = 4
					elseif folder.Name == "SpinE" then
						v9 = 4.5
					elseif folder.Name == "SpinF" then
						v9 = 4.75
					elseif folder.Name == "SpinG" then
						v9 = 5
					elseif folder.Name == "SpinH" then
						v9 = 5
					else
						v9 = 1
					end

					if v8 == 1 then
						math.clamp(v9 / 3, 1, 2.5)
					end

					v7[folder] = {
						Part = folder,
						Beams = {}
					}
					folder:SetAttribute("Tweening", false)

					for i3, descendant in ipairs(folder:GetDescendants()) do
						if descendant:IsA("Beam") then
							v7[folder].Beams[descendant] = descendant
							descendant.CurveSize0 *= v9
							descendant.CurveSize1 *= v9
							descendant.Width0 *= math.clamp(v9 / 2, 2, 3)
							descendant.Width1 *= math.clamp(v9 / 2, 2, 3)
							descendant:SetAttribute("Width0", descendant.Width0)
							descendant:SetAttribute("Width1", descendant.Width1)
							descendant.Width0 = 0
							descendant.Width1 = 0
						elseif descendant:IsA("Attachment") then
							descendant.Position = Vector3.new(
								descendant.Position.X * v9,
								descendant.Position.Y * v9,
								descendant.Position.Z * v9
							)
						end
					end

					if v8 == 3 then
						local v10

						if folder.Name == "SpinA" then
							v10 = 2
						elseif folder.Name == "SpinB" then
							v10 = 2.25
						elseif folder.Name == "SpinC" then
							v10 = 2.5
						elseif folder.Name == "SpinD" then
							v10 = 2.75
						elseif folder.Name == "SpinE" then
							v10 = 3
						elseif folder.Name == "SpinF" then
							v10 = 3.25
						elseif folder.Name == "SpinG" then
							v10 = 3.5
						elseif folder.Name == "SpinH" then
							v10 = 4
						else
							v10 = v9
						end

						folder.Size = Vector3.new(folder.Size.X * v10, folder.Size.Y * v10, folder.Size.Z * v10)
						foldersByFolder[folder] = folder
						folder:SetAttribute("Speed", math.random(40, 80))
					end
				end)()
			end
		end)()
	end

	StartRotating(v7, data.tornadoDamageFor) -- equivalent call inferred; original call site unknown
	StartRotatingPart(foldersByFolder, data.tornadoDamageFor) -- equivalent call inferred; original call site unknown
	coroutine.wrap(function()
		local clone4 = skill1.Tornado4:Clone()
		clone4.CFrame = CFrame.new(v6.Position) * CFrame.new(0, clone4.Size.Y, 0)
		clone4.Parent = parent2
		destroyAfter(clone4, data.tornadoDamageFor + 3)
		local descendants2 = clone4:GetDescendants()

		for _, emitter in ipairs(descendants2) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(data.tornadoDamageFor - 0.15)

		for _, emitter in ipairs(descendants2) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)()
	local lastTime = os.clock()
	local v8 = time()

	for _ = 1, 600 do
		coroutine.wrap(function()
			local tornadoTrails = skill1.TornadoTrails
			local clone4 = nil
			local v9 = math.random(1, #tornadoTrails:GetChildren())

			if v9 == 1 then
				clone4 = tornadoTrails.TrailA:Clone()
			elseif v9 == 2 then
				clone4 = tornadoTrails.TrailB:Clone()
			end

			clone4.CFrame = CFrame.new(v6.Position) * CFrame.new(
				math.random(-40, 40),
				math.random(2, 10),
				math.random(-40, 40)
			)
			clone4.Parent = parent2
			local position2 = clone4.Position
			local v10 = clone4.Position + Vector3.new(0, math.random(30, 60), 0)
			local magnitude2 = (position2 - v10).Magnitude
			clone4.CFrame = CFrame.new(position2, v10)
			local v11 = (position2 - v10) / 2
			local position3 = CFrame.new(CFrame.new(position2) * (v11 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(v10) * (v11 / 1.5)).Position
			local halfMagnitude2 = magnitude2 / 2
			local v13 = position3 + Vector3.new(
				math.random(-halfMagnitude2, halfMagnitude2),
				math.random(-halfMagnitude2 / 2, halfMagnitude2),
				math.random(-halfMagnitude2, halfMagnitude2)
			)
			local v14 = position4 + Vector3.new(
				math.random(-halfMagnitude2, halfMagnitude2),
				math.random(-halfMagnitude2 / 2, halfMagnitude2),
				math.random(-halfMagnitude2, halfMagnitude2)
			)
			local v15 = math.random(23, 30) / 10
			local lastTime2 = tick()
			local v16 = magnitude2 / v15 / 60

			while tick() - lastTime2 < v16 do
				local v17 = (tick() - lastTime2) / v16
				local v18 = cubicBezier(v17, position2, v13, v14, v10)
				clone4.CFrame = clone4.CFrame:Lerp(CFrame.new(v18, v10), v17)
				task.wait()
			end

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone4, 1)
		end)()

		for _ = 1, math.random(1, 4) do
			coroutine.wrap(function()
				local tornadoTrails2 = skill1.TornadoTrails2
				local clone4 = nil
				local v9 = math.random(1, #tornadoTrails2:GetChildren())

				if v9 == 1 then
					clone4 = tornadoTrails2.TrailA:Clone()
				elseif v9 == 2 then
					clone4 = tornadoTrails2.TrailB:Clone()
				elseif v9 == 3 then
					clone4 = tornadoTrails2.TrailC:Clone()
				elseif v9 == 4 then
					clone4 = tornadoTrails2.TrailD:Clone()
				end

				clone4.CFrame = CFrame.new(v6.Position)
				clone4.Orientation = Vector3.new(0, math.random(-180, 180), 0)
				clone4.Parent = parent2
				local v10 = math.random(20, 40) / 100
				local tweenInfo = TweenInfo.new(v10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local v11 = clone4.TrailAttach0.Position.Z * math.random(15, 30) / 5

				for _, child in ipairs(clone4:GetChildren()) do
					if child.Name == "TrailAttach0" then
						TweenService:Create(child, tweenInfo, {
							Position = child.Position + Vector3.new(0, 0, v11)
						}):Play()
					else
						TweenService:Create(child, tweenInfo, {
							Position = child.Position + Vector3.new(0, 0, v11 + 2.5)
						}):Play()
					end
				end

				local tween2 = TweenService:Create(clone4, tweenInfo, {
					Position = clone4.Position + Vector3.new(0, math.random(40, 50), 0),
					Orientation = clone4.Orientation + createVector(0, 280, 0)
				})
				tween2:Play()
				tween2.Completed:Wait()

				for _, emitter in ipairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				destroyAfter(clone4, 1)
			end)()
		end

		task.wait(math.random(20, 30) / 100)

		if os.clock() - lastTime >= 2 or time() - v8 > 10 then
			break
		end
	end
end