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

local function fireClientProjectile(dashFor: number, fn, fXContainer, part, callback)
	local v = callback or function(_)
		return CFrame.new()
	end
	local v2 = fXContainer or Instance.new("Folder", Workspace._WorldOrigin)

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
		destroyAfter(part, dashFor + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * v(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v4 = false
	local connection = nil
	connection = heartbeatLoopFor2(dashFor, function(_, _, p)
		local v5 = v2
		local v6

		if v5:GetAttribute("ProjectileActive") == true or v5:GetAttribute("ImpactPos") == nil then
			v6 = false
		else
			v6 = v5:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v6 then
			part.CFrame = CFrame.lookAt(fn(p), fn(p + 0.01)) * v(p)
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

		snapProjectileToFinalPos(part, fn(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(fn(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraShakeAt(value: number, value2: number, value3: number, value4: number)
	Util.CameraShaker:ShakeOnce(value or 8, value2 or 14, value3 or 0.2, value4 or 0.7)
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

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function SwordSlash(folder, _, _)
	coroutine.wrap(function()
		for _, beam in ipairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay / 2)
				tween:Play()
				task.wait(v2 / 2)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	task.spawn(function()
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-1.7453292519943295,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-0.8726646259971648, 0, 0)
		}):Play()
	end)
end

local function SwordSlashSpin(folder, _, part, _)
	coroutine.wrap(function()
		for _, beam in ipairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	coroutine.wrap(function()
		local position = part.Position

		if Workspace:Raycast(position + createVector(0, 1, 0), CFrame.new(position).UpVector * -5, raycastParams) then
			local clone = FX:WaitForChild("TrueTripleKatana").Skill2.Slash2Wind:Clone()
			clone.Position = part.Position
			clone.Parent = _WorldOrigin
			destroyAfter(clone, 4)
			clone.Weld.Part0 = part

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.3)
			clone.Weld.Enabled = false
			clone.Anchored = true

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)()
	task.spawn(function()
		for _ = 1, 5 do
			local tween = TweenService:Create(
				folder.Weld,
				TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						2.6179938779914944,
						0
					)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
		}):Play()
	end)
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local targetPos = data.targetPos
	local v = Util.MasterClock:GetTime() - data.serverTime
	TweenService:Create(
		hrp,
		TweenInfo.new(
			math.clamp(data.dashFor - v + 0.05, 0, data.dashFor) + 0.03333333333333333,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		),
		{
			CFrame = CFrame.new(targetPos, targetPos + fireDir)
		}
	):Play()
	Util.Sound:Play("WolfFangRushLunge", hrp)

	if data.found then
		task.delay(0.06, function()
			Util.Sound:Play("WolfFangRushAttack", hrp)
		end)
	end

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	local parent = _WorldOrigin
	local skill2 = FX:WaitForChild("TrueTripleKatana").Skill2
	local cframe = CFrame.lookAt(origin, origin + fireDir)
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
	fireClientProjectile(data.dashFor, function(p)
		return origin + (targetPos - origin) * p
	end, data.FXContainer, part)
	local cFrame = part.CFrame
	local clone = skill2.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent
	destroyAfter(clone, 4)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local magnitude = (targetPos - origin).Magnitude
	local dashFor = data.dashFor
	local _, v3 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(
			cFrame.Position,
			CFrame.new(cFrame.Position, (cFrame * CFrame.new(0, 0, -magnitude)).Position).LookVector * magnitude
		),
		raycastParams.FilterDescendantsInstances
	)
	local magnitude2 = (cFrame.Position - v3).Magnitude
	local clone2 = skill2.DashSlash:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -2)
	clone2.Parent = parent
	destroyAfter(clone2, 4)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone3 = skill2.Dash:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = parent
	destroyAfter(clone3, 4)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local v4 = true
	coroutine.wrap(function()
		local v5 = time()

		for _ = 1, 600 do
			local clone4 = skill2.DashTornado:Clone()
			clone4.CFrame = clone2.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-90, 90)))))
			clone4.Parent = parent
			destroyAfter(clone4, 4)
			local v6 = math.random(2, 3)

			for _, descendant in ipairs(clone4:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v6
					descendant.CurveSize1 *= v6
					descendant.Width0 *= math.clamp(v6 / 2, 2, 3)
					descendant.Width1 *= math.clamp(v6 / 2, 2, 3)
					local width0 = descendant.Width0
					local width1 = descendant.Width1
					descendant.Width0 = 0
					descendant.Width1 = 0
					local v7 = descendant
					coroutine.wrap(function()
						local tween = TweenService:Create(
							v7,
							TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = width0,
								Width1 = width1
							}
						)
						task.wait(0.025)
						tween:Play()
						task.wait(0.075)
						local tween2 = TweenService:Create(
							v7,
							TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween2:Play()
						tween2.Completed:Wait()
						v7:Destroy()
					end)()
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v6,
						descendant.Position.Y * v6,
						descendant.Position.Z * v6
					)
				end
			end

			coroutine.wrap(function()
				local tween = TweenService:Create(
					clone4,
					TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.Angles(0, 0, 2.6179938779914944)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.Angles(0, 0, 1.3089969389957472)
				}):Play()
			end)()
			task.wait(math.random(10, 20) / 1200)

			if v4 == false or time() - v5 > 10 then
				break
			end
		end
	end)()
	coroutine.wrap(function()
		task.wait(dashFor / 3)

		for i = 1, 7 do
			local v5 = i
			coroutine.wrap(function()
				task.wait(math.random(1, 5) / 100)
				local clone4 = skill2.DashTrail:Clone()
				clone4.Position = v3 + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				clone4.Parent = parent
				destroyAfter(clone4, 4)
				local position = clone4.Position

				if magnitude2 == nil then
					magnitude2 = 5
				end

				local v6 = (CFrame.new(position, cFrame.Position) * CFrame.new(0, 0, math.random(-magnitude2 / 2, 0))).Position + Vector3.new(
					math.random(-100, 100) / 10,
					math.random(-25, 100) / 10,
					math.random(-100, 100) / 10
				)
				local magnitude3 = (position - v6).Magnitude
				clone4.CFrame = CFrame.new(position, v6)
				local v7 = (position - v6) / 2
				local position2 = CFrame.new(CFrame.new(position) * (v7 / -1.5)).Position
				local position3 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
				local v8 = math.random(4, 6) * 5
				local v9 = position2 + Vector3.new(math.random(-v8, v8), math.random(1, 2), math.random(-v8, v8))
				local v10 = position3 + Vector3.new(math.random(-v8, v8), math.random(1, 2), math.random(-v8, v8))

				for i2, effect in ipairs(clone4:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end

				local v11 = math.random(15, 30) / 20
				local lastTime = tick()
				local v12 = magnitude3 / v11 / 60

				while tick() - lastTime < v12 do
					local v13 = (tick() - lastTime) / v12
					local v14 = cubicBezier(v13, position, v9, v10, v6)
					local v15 = (v5 + v11) / magnitude3
					local v16 = cubicBezier(v15, position, v9, v10, v6)
					clone4.CFrame = clone4.CFrame:Lerp(CFrame.new(v14, v6), v13)
					clone4.CFrame = CFrame.new(clone4.Position, v16)
					task.wait()
				end

				for i2, effect in ipairs(clone4:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					end
				end
			end)()
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.05)
		local position = cFrame.Position
		local part2, _ = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(
				position + createVector(0, 1, 0),
				CFrame.new(position + createVector(0, 1, 0), position + createVector(0, -10, 0)).LookVector * 10
			),
			raycastParams.FilterDescendantsInstances
		)

		if part2 then
			coroutine.wrap(function()
				task.wait(0.015)
				local clone4 = skill2.GroundSpark:Clone()
				clone4.CFrame = cFrame
				clone4.Parent = parent
				destroyAfter(clone4, 4)

				for _ = 1, 10 do
					local v5 = cFrame * CFrame.new(math.random(-5, 5), 0, math.random(-magnitude2, 1)).Position
					local part3, v6 = Workspace:FindPartOnRayWithIgnoreList(
						Ray.new(
							v5 + createVector(0, 5, 0),
							CFrame.new(v5 + createVector(0, 1, 0), v5 + createVector(0, -10, 0)).LookVector * 10
						),
						raycastParams.FilterDescendantsInstances
					)

					if part3 then
						clone4.Position = v6 + createVector(0, 0.25, 0)
						clone4.Size = Vector3.new(math.random(5, 10), 1, math.random(1, 5))

						for _, emitter in ipairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end

					task.wait(math.random(10, 30) / 1000)
				end
			end)()
		end
	end)()
	local tween = TweenService:Create(
		clone2,
		TweenInfo.new(dashFor, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = clone2.CFrame * CFrame.new(0, 0, -magnitude2)
		}
	)
	tween:Play()
	TweenService:Create(clone3, TweenInfo.new(dashFor, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.new(0, 0, -magnitude2)
	}):Play()
	tween.Completed:Wait()
	v4 = false

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if not data.found then
		return
	end

	coroutine.wrap(function()
		local slashes = skill2.Slashes
		local v5 = data.slashForAfterDash / 7

		for i = 1, 5 do
			if i == 1 then
				local clone4 = slashes.SlashA:Clone()
				local slashHit = clone4.SlashHit
				local cframe2 = CFrame.Angles(0, 0, -0.7853981633974483)
				local cframe3 = CFrame.Angles(2.6179938779914944, 0, 0)

				for _, descendant in ipairs(clone4:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 *= 1.65
						descendant.CurveSize1 *= 1.65
						descendant.Width0 *= 2.4749999999999996
						descendant.Width1 *= 2.4749999999999996
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * 1.65,
							descendant.Position.Y * 1.65,
							descendant.Position.Z * 1.65
						)
					end
				end

				slashHit.CFrame = part.CFrame * CFrame.new(0, 0, -16) * cframe2

				for _, emitter in ipairs(slashHit:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					coroutine.wrap(function()
						task.wait(v5)
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)()
				end

				clone4.CFrame = part.CFrame
				clone4.Weld.Part0 = part
				clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * cframe2 * cframe3
				clone4.Parent = parent
				destroyAfter(clone4, 4)

				if player == game.Players.LocalPlayer then
					cameraShakeAt(5, 6, 0.15, 0.25) -- equivalent call inferred; original call site unknown
				end

				SwordSlash(clone4, nil, parent, cFrame)
			elseif i == 2 then
				local clone4 = slashes.SlashA:Clone()
				local slashHit = clone4.SlashHit
				local cframe2 = CFrame.Angles(0, 0, 1.9198621771937625)
				local cframe3 = CFrame.Angles(2.0943951023931953, 0, 0)

				for _, descendant in ipairs(clone4:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 *= 1.65
						descendant.CurveSize1 *= 1.65
						descendant.Width0 *= 2.4749999999999996
						descendant.Width1 *= 2.4749999999999996
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * 1.65,
							descendant.Position.Y * 1.65,
							descendant.Position.Z * 1.65
						)
					end
				end

				slashHit.CFrame = part.CFrame * CFrame.new(0, 0, -16) * cframe2

				for _, emitter in ipairs(slashHit:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					coroutine.wrap(function()
						task.wait(v5)
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)()
				end

				clone4.CFrame = part.CFrame
				clone4.Weld.Part0 = part
				clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * cframe2 * cframe3
				clone4.Parent = parent
				destroyAfter(clone4, 4)

				if player == game.Players.LocalPlayer then
					cameraShakeAt(5, 6, 0.15, 0.25) -- equivalent call inferred; original call site unknown
				end

				SwordSlash(clone4, nil, parent, cFrame)
			elseif i == 3 then
				for i2 = 1, 2 do
					local v6 = i2
					coroutine.wrap(function()
						local clone4 = slashes.SlashA:Clone()
						local slashHit = clone4.SlashHit
						local cframe2 = CFrame.Angles(0, 0, -0.9599310885968813)

						if v6 == 2 then
							cframe2 = CFrame.Angles(0, 0, 0.9599310885968813)
						end

						local cframe3 = CFrame.Angles(2.6179938779914944, 0, 0)

						for i3, descendant in ipairs(clone4:GetDescendants()) do
							if descendant:IsA("Beam") then
								descendant.CurveSize0 *= 2
								descendant.CurveSize1 *= 2
								descendant.Width0 *= 3
								descendant.Width1 *= 3
							elseif descendant:IsA("Attachment") then
								descendant.Position = Vector3.new(
									descendant.Position.X * 2,
									descendant.Position.Y * 2,
									descendant.Position.Z * 2
								)
							end
						end

						slashHit.CFrame = part.CFrame * CFrame.new(0, 0, -18) * cframe2

						for i3, emitter in ipairs(slashHit:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v7 = emitter
							coroutine.wrap(function()
								task.wait(v5)
								v7:Emit(v7:GetAttribute("EmitCount"))
							end)()
						end

						clone4.CFrame = part.CFrame
						clone4.Weld.Part0 = part
						clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * cframe2 * cframe3
						clone4.Parent = parent
						destroyAfter(clone4, 4)

						if player == game.Players.LocalPlayer then
							cameraShakeAt(5, 6, 0.15, 0.25) -- equivalent call inferred; original call site unknown
						end

						SwordSlash(clone4, nil, parent, cFrame)
					end)()
				end
			elseif i == 4 then
				local v6 = 1.5

				for i2 = 1, 3 do
					local v7 = i2
					coroutine.wrap(function()
						local v8 = nil

						if v7 == 1 then
							CFrame.Angles(0, 0, -0.08726646259971647)
							v8 = 4
						elseif v7 == 2 then
							v8 = 2
							CFrame.Angles(0, 0, 0.08726646259971647)
							v6 = 1.65
						elseif v7 == 3 then
							v8 = 0
							CFrame.Angles(0, 0, -0.04363323129985824)
							v6 = 1.8
						end

						local clone4 = slashes.SlashB:Clone()
						clone4.CFrame = part.CFrame
						clone4.Weld.Part0 = part
						clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * CFrame.new(
							0,
							v8,
							0
						)
						clone4.Parent = parent
						destroyAfter(clone4, 4)

						for i3, descendant in ipairs(clone4:GetDescendants()) do
							if descendant:IsA("Beam") then
								descendant.CurveSize0 *= v6
								descendant.CurveSize1 *= v6
								descendant.Width0 *= v6
								descendant.Width1 *= v6
							elseif descendant:IsA("Attachment") then
								descendant.Position = Vector3.new(
									descendant.Position.X * v6,
									descendant.Position.Y * v6,
									descendant.Position.Z * v6
								)
							end
						end

						SwordSlashSpin(clone4, parent, part, nil)
					end)()
					task.wait(v5)
				end
			elseif i == 5 then
				local clone4 = slashes.SlashC:Clone()
				local slashHit = clone4.SlashHit
				local cframe2 = CFrame.Angles(0, 0, -1.6580627893946132)
				local cframe3 = CFrame.Angles(2.443460952792061, 0, 0)

				for _, descendant in ipairs(clone4:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 *= 2.5
						descendant.CurveSize1 *= 2.5
						descendant.Width0 *= 3.75
						descendant.Width1 *= 3.75
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * 2.5,
							descendant.Position.Y * 2.5,
							descendant.Position.Z * 2.5
						)
					end
				end

				slashHit.CFrame = part.CFrame * CFrame.new(0, 0, -22) * cframe2

				for _, emitter in ipairs(slashHit:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					coroutine.wrap(function()
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)()
				end

				local slashHit2 = clone4.SlashHit2
				slashHit2.CFrame = part.CFrame

				for _, emitter in ipairs(slashHit2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v6 = emitter
					coroutine.wrap(function()
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)()
				end

				clone4.CFrame = part.CFrame
				clone4.Weld.Part0 = part
				clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * cframe2 * cframe3
				clone4.Parent = parent
				destroyAfter(clone4, 4)

				if player == game.Players.LocalPlayer then
					cameraShakeAt(5, 6, 0.15, 0.25) -- equivalent call inferred; original call site unknown
				end

				SwordSlash(clone4, nil, parent, cFrame)
			end

			task.wait(v5)
		end
	end)()
end