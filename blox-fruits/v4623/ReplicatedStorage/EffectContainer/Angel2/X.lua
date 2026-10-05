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
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local cameraShaker = Util.CameraShaker

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local rescheduleDestruction

rescheduleDestruction = function(instance, duration: number, flag: boolean?)
	if (flag == nil or flag) == true or instance:GetAttribute("PrevTimeDestructInitiated") == nil then
		instance:SetAttribute("PrevTimeDestructInitiated", time())
	end

	local destructionDepth = instance:GetAttribute("DestructionDepth") or 0
	instance:SetAttribute("DestructionDepth", destructionDepth + 1)

	if destructionDepth >= 100 then
		instance:Destroy()
		warn("rescheduleDestruction: Maximum re-entrancy depth of 100 exceeded")
	else
		task.delay(duration, function()
			local prevTimeDestructInitiated = instance:GetAttribute("PrevTimeDestructInitiated")

			if duration - (time() - prevTimeDestructInitiated) < 0.2 and instance ~= nil and instance.Parent ~= nil then
				instance:Destroy()
				return
			end

			if instance == nil or instance.Parent == nil then
				return
			end

			rescheduleDestruction(instance, duration, false)
		end)
	end
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
	rescheduleDestruction(instance, value or 60)
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

local function createDefaultProjectile(p: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(4, 4, 4)
	part.Transparency = 1
	part.Name = "Projectile"
	part.Parent = _WorldOrigin
	destroyAfter(part, p + 7)
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
end

local function fireClientProjectile(p: number, callback, p2, part, callback2)
	local v = callback2 or function(_)
		return CFrame.new()
	end
	local v2 = p2 or Instance.new("Folder")

	if not part then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(4, 4, 4)
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * v(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v4 = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p3)
		local v5 = v2
		local v6

		if v5:GetAttribute("ProjectileActive") == true or v5:GetAttribute("ImpactPos") == nil then
			v6 = false
		else
			v6 = v5:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v6 then
			part.CFrame = CFrame.lookAt(callback(p3), callback(p3 + 0.01)) * v(p3)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, v2:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(v2:GetAttribute("ImpactPos"), "Impact")
		v4 = true
	end, function()
		if v4 == true then
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

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function haltUntilCondition(callback, value: number?)
	local v = value or 14
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

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local angelBeam = FX:WaitForChild("Angel2").AngelBeam

	local function TornadoSlash(parent, data2)
		local multiplier = data2.Multiplier
		local multiplier2 = data2.Multiplier2
		local mutliplier2Time = data2.Mutliplier2Time
		local beamOutTime = data2.BeamOutTime
		local slashAngle = data2.SlashAngle
		local slashAngle2 = data2.SlashAngle2
		local yPosition = data2.YPosition
		local yPosition2 = data2.YPosition2
		local slashType = data2.SlashType
		local slashCFrame = data2.SlashCFrame
		local slashSpeed = data2.SlashSpeed
		local slashSpeed2 = data2.SlashSpeed2
		local spinIterations = data2.SpinIterations
		local clone = slashType:Clone()
		clone.CFrame = slashCFrame * CFrame.new(0, yPosition, 0)
		clone.Parent = parent
		destroyAfter(clone, 7)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= multiplier
				descendant.CurveSize1 *= multiplier
				descendant.Width0 *= multiplier
				descendant.Width1 *= multiplier
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * multiplier,
					descendant.Position.Y * multiplier,
					descendant.Position.Z * multiplier
				)
			end
		end

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.Enabled = true
				local v = descendant
				task.spawn(function()
					local tween = TweenService:Create(
						v,
						TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * multiplier2,
							CurveSize1 = v.CurveSize1 * multiplier2,
							Width0 = v.Width0 * multiplier2,
							Width1 = v.Width1 * multiplier2
						}
					)
					v.Width0 = 0
					v.Width1 = 0
					tween:Play()
				end)
			elseif descendant:IsA("Attachment") then
				TweenService:Create(
					descendant,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Position = Vector3.new(
							descendant.Position.X * multiplier2,
							descendant.Position.Y * multiplier2,
							descendant.Position.Z * multiplier2
						)
					}
				):Play()
			end
		end

		for _ = 1, spinIterations do
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, yPosition2, 0) * slashAngle
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		for _, beam in ipairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v = beam
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v:Destroy()
			end)
		end

		TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * slashAngle2
		}):Play()
	end

	local function GroundRocks(cframe, parent, _, instance)
		for _ = 1, 10 do
			task.spawn(function()
				local clone = angelBeam.Rock:Clone()
				clone.Position = cframe.Position + Vector3.new(
					math.random(-25, 25) * 1.5,
					math.random(1, 15),
					math.random(-25, 25) * 1.5
				)
				clone.Size = Vector3.new(math.random(3, 6), math.random(3, 6), math.random(3, 6))
				clone.Material = instance.Material
				clone.Color = instance.Color
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				destroyAfter(clone, 14)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
				bodyVelocity.P = 3000
				bodyVelocity.Velocity = CFrame.new(
					clone.Position,
					(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-0
					)).Position + Vector3.new(
						math.random(-50, 50) * 1.5,
						math.random(200, 250),
						math.random(-50, 50) * 1.5
					)
				).LookVector * math.random(50, 100) * 1.15
				bodyVelocity.Parent = clone
				destroyAfter(bodyVelocity, 0.05)
				clone.Attachment0.Orientation = Vector3.new(
					math.random(-90, 90),
					math.random(-90, 90),
					math.random(-90, 90)
				)
				local v = math.random(60, 120)
				local v2 = math.random(60, 120)
				local v3 = math.random(60, 120)
				local v4 = v / 10
				local v5 = v2 / 10
				local v6 = v3 / 10

				for _ = 1, 4 do
					v = math.clamp(v - v4, 0, 120)
					v2 = math.clamp(v2 - v5, 0, 120)
					v3 = math.clamp(v3 - v6, 0, 120)
					local tween = TweenService:Create(
						clone.Attachment0,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()
				end

				clone.AlignOrientation:Destroy()
				destroyAfter(clone, 10)
				task.wait(2 + math.random(10, 200) / 1000)
				TweenService:Create(clone, TweenInfo.new(0.25), {
					Size = createVector(0, 0, 0)
				}):Play()
			end)
		end
	end

	local parent2 = _WorldOrigin
	local ray = Util.Ray
	local v2 = data.impactPos + createVector(0, 0.1, 0)
	local v3 = { Workspace.Characters, Workspace.Enemies }
	local _, v4 = ray(v2, createVector(-0, -40, -0), v3)
	local cframe = CFrame.new(v4)
	local v5 = data.delayUntilImpact - (Workspace:GetServerTimeNow() - data.started)
	local clone = angelBeam.BeamStartBeams:Clone()
	clone.CFrame = cframe
	clone.Parent = parent2
	destroyAfter(clone, 7)

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
			local v6 = descendant
			task.spawn(function()
				task.wait(v5)
				v6.Enabled = false
			end)
		elseif descendant:IsA("Weld") then
			local tween = TweenService:Create(
				descendant,
				TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					C0 = descendant.C0
				}
			)
			descendant.C0 = CFrame.new(0, 0, 0)
			tween:Play()
		elseif descendant:IsA("Beam") then
			local v6 = descendant
			task.spawn(function()
				task.wait(v5)
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v6:Destroy()
			end)
		end
	end

	TweenService:Create(clone, TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	local clone2 = angelBeam.BeamStartGround:Clone()
	clone2.Position = cframe.Position
	alignWithGround(
		clone2,
		Workspace:Raycast(clone2.Position + createVector(0, 1, 0), createVector(-0, -14, -0), raycastParams)
	)
	clone2.Parent = parent2
	destroyAfter(clone2, 7)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local beamStartSlashes = angelBeam.BeamStartSlashes
	task.spawn(function()
		TornadoSlash(parent2, {
			Multiplier = 0.75,
			Multiplier2 = 2,
			Mutliplier2Time = 0.25,
			BeamOutTime = 0.1,
			SlashAngle = CFrame.Angles(0, -2.9670597283903604, 0),
			SlashAngle2 = CFrame.Angles(0, -2.9670597283903604, 0),
			YPosition = 50,
			YPosition2 = 2,
			SlashType = beamStartSlashes.Slash1,
			SlashCFrame = cframe,
			SlashSpeed = 0.05,
			SlashSpeed2 = 0.35,
			SpinIterations = 5
		})
	end)
	task.spawn(function()
		TornadoSlash(parent2, {
			Multiplier = 0.25,
			Multiplier2 = 5,
			Mutliplier2Time = 0.5,
			BeamOutTime = 0.2,
			SlashAngle = CFrame.Angles(0, -1.7453292519943295, 0),
			SlashAngle2 = CFrame.Angles(0, -2.9670597283903604, 0),
			YPosition = 45,
			YPosition2 = 0,
			SlashType = beamStartSlashes.Slash1,
			SlashCFrame = cframe,
			SlashSpeed = 0.07,
			SlashSpeed2 = 0.5,
			SpinIterations = 4
		})
	end)
	task.spawn(function()
		TornadoSlash(parent2, {
			Multiplier = 1,
			Multiplier2 = 2,
			Mutliplier2Time = 0.5,
			BeamOutTime = 0.2,
			SlashAngle = CFrame.Angles(0, -2.6179938779914944, 0),
			SlashAngle2 = CFrame.Angles(0, -2.9670597283903604, 0),
			YPosition = 5,
			YPosition2 = 2,
			SlashType = beamStartSlashes.Slash1,
			SlashCFrame = cframe,
			SlashSpeed = 0.1,
			SlashSpeed2 = 0.5,
			SpinIterations = 5
		})
	end)
	task.spawn(function()
		TornadoSlash(parent2, {
			Multiplier = 2,
			Multiplier2 = 0.85,
			Mutliplier2Time = 0.25,
			BeamOutTime = 0.25,
			SlashAngle = CFrame.Angles(0, 1.7453292519943295, 0),
			SlashAngle2 = CFrame.Angles(0, 2.9670597283903604, 0),
			YPosition = 50,
			YPosition2 = 0,
			SlashType = beamStartSlashes.Slash2,
			SlashCFrame = cframe,
			SlashSpeed = 0.175,
			SlashSpeed2 = 0.75,
			SpinIterations = 2
		})
	end)
	local clone3 = angelBeam.StartClouds:Clone()
	clone3.Position = cframe.Position + createVector(0, 150, 0)
	clone3.Parent = parent2
	destroyAfter(clone3, 7)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	local v6 = Util.Sound:Play("AngelCHolyFire", cframe.Position + createVector(0, 160, 0), nil, 0.65, 1.5)
	task.spawn(function()
		local clone4 = angelBeam.StartClouds2:Clone()
		clone4.Position = cframe.Position + createVector(0, 160, 0)
		clone4.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		clone4.Parent = parent2
		destroyAfter(clone4, 7)
		local descendants = clone4:GetDescendants()

		for _, emitter in ipairs(descendants) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter.TimeScale = 0
			emitter.Transparency = NumberSequence.new(0, 1)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local lastTime = tick()
		local v7 = time()

		for _ = 1, 600 do
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone4.CFrame * CFrame.Angles(0, 0.12217304763960307, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()

			if v5 <= tick() - lastTime or time() - v7 > 10 then
				break
			end
		end

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in ipairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				emitter.TimeScale = 1
			end
		end

		task.wait(1)
		clone4:Destroy()
	end)
	task.wait(v5)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone4 = angelBeam.CloudsEnd:Clone()
	clone4.Position = clone3.Position + createVector(0, 20, 0)
	clone4.Parent = parent2
	destroyAfter(clone4, 7)

	for _, emitter in ipairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone5 = angelBeam.BeamExplosion:Clone()
	clone5.CFrame = cframe
	local raycastResult = Workspace:Raycast(
		clone5.Position + createVector(0, 1, 0),
		createVector(-0, -14, -0),
		raycastParams
	)
	clone5.Parent = parent2
	destroyAfter(clone5, 7)

	for _, emitter in ipairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			if v7:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v7:GetAttribute("EmitDelay"))
			end

			v7:Emit(v7:GetAttribute("EmitCount"))
		end)
	end

	task.spawn(function()
		local clone6 = angelBeam.ProjectileStartImpact:Clone()
		clone6.CFrame = cframe * CFrame.new(0, 170, 0)
		clone6.Parent = parent2
		destroyAfter(clone6, 7)
		Util.Sound:Play("AngelCArrow", cframe, nil, 0.8, 1)

		for _, emitter in ipairs(clone6:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone7 = angelBeam.BeamProjectile:Clone()
		clone7.CFrame = clone6.CFrame
		clone7.Parent = parent2
		destroyAfter(clone7, 7)
		TweenService:Create(clone7, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = cframe
		}):Play()

		for _, emitter in ipairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(0.2125)

		for _, emitter in ipairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	task.spawn(function()
		task.wait(0.2)
		local clone6 = angelBeam.BeamExplosionImpact:Clone()
		clone6.CFrame = cframe
		alignWithGround(clone6, raycastResult)
		clone6.Parent = parent2
		destroyAfter(clone6, 7)

		if (cframe.p - Workspace.CurrentCamera.CFrame.p).Magnitude < 100 then
			local _ = Workspace.CurrentCamera
			task.spawn(function()
				local angelC = FX:WaitForChild("Angel2").AngelC
				cameraShaker:ShakeOnce(16, 12, 0.15, 0.75)
				task.spawn(function()
					local clone7 = angelC.Phase2.Bloom:Clone()
					clone7.Parent = game.Lighting
					local tween = TweenService:Create(clone7, TweenInfo.new(0.1), {
						Size = 28,
						Threshold = 0.25
					})
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(clone7, TweenInfo.new(0.25), {
						Size = 4,
						Threshold = 2
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone7:Destroy()
				end)
			end)
		end

		Util.Sound:Play("Angel B- Explosion", cframe, nil, 0.7, 1)
		task.spawn(function()
			if v6 then
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Volume = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()

				if v6 then
					v6:Destroy()
				end
			end
		end)

		for _, emitter in ipairs(clone6:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local raycastResult2 = Workspace:Raycast(
			cframe.Position + createVector(0, 1, 0),
			CFrame.new(cframe.Position).UpVector * -5,
			raycastParams
		)

		if raycastResult2 then
			local cframe2 = CFrame.lookAt(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal)
			local clone7 = angelBeam.GroundCrack:Clone()
			clone7.CFrame = cframe2 * CFrame.new(0, 0, -0.25) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone7.Parent = parent2
			destroyAfter(clone7, 7)

			for _, emitter in ipairs(clone7:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("Color") then
					emitter.Color = ColorSequence.new(raycastResult2.Instance.Color, raycastResult2.Instance.Color)
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			GroundRocks(cframe2, parent2, raycastResult2.Position, raycastResult2.Instance)
		end
	end)
end