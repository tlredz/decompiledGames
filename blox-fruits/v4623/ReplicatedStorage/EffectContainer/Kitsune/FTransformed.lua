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

local function putFolder(instance, name: string)
	local v = instance:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		Util.SetParentOverrideWithColor(v, instance, player, "KitsuneFruitVFXColor")
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

local function putValueAsValueObject(instance, name: string, p, value: number)
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
	local instance2 = instance:FindFirstChild(name)

	if instance2 == nil then
		instance2 = Instance.new(v2[typeof(p)])
		instance2.Name = name
		Util.SetParentOverrideWithColor(instance2, instance, player, "KitsuneFruitVFXColor")
	end

	instance2.Value = p
	rescheduleDestruction(instance2, value or 60)
	return instance2
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
	Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "KitsuneFruitVFXColor")
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

local function fireClientProjectile(p: number, callback, p2, p3, callback2)
	local v = callback2 or function(_)
		return CFrame.new()
	end
	local v2 = p2 or Instance.new("Folder")
	local v3 = p3 or createDefaultProjectile(p)
	v3.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * v(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v4 = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		local v5 = v2
		local v6

		if v5:GetAttribute("ProjectileActive") == true or v5:GetAttribute("ImpactPos") == nil then
			v6 = false
		else
			v6 = v5:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v6 then
			v3.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * v(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(v3, v2:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(v2:GetAttribute("ImpactPos"), "Impact")
		v4 = true
	end, function()
		if v4 == true then
			return
		end

		snapProjectileToFinalPos(v3, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, v3, connection
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
	Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "KitsuneFruitVFXColor")
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
	local player2 = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	Util.Sound:Play("Dashes- Character Horizontal Dash", hrp)
	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local kitsuneSkillFAwaken = FX:WaitForChild("Kitsune").KitsuneSkillFAwaken

	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
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

	local function GetNumberDependingDistance(p, p2, p3, p4, p5)
		if p <= p4 then
			return p2
		end

		if p4 < p and p <= p5 then
			return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
		end

		return p3
	end

	local v = _WorldOrigin
	local magnitude = (data.goalPos - data.originPos).Magnitude
	local cframe = CFrame.lookAt(data.originPos, data.goalPos)
	local _, v2 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(
			cframe.Position,
			CFrame.new(cframe.Position, (cframe * CFrame.new(0, 0, -magnitude)).Position).LookVector * magnitude
		),
		raycastParams.FilterDescendantsInstances
	)
	local magnitude2 = (v2 + createVector(0, 1.5, 0) - cframe.Position).Magnitude
	local clone = kitsuneSkillFAwaken.Start:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, v, player2, "KitsuneFruitVFXColor")
	destroyAfter(clone, 7)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true

		if not emitter:GetAttribute("Funky") then
			continue
		end

		for _ = 1, 10 do
			local clone2 = emitter:Clone()
			clone2:SetAttribute("Funky", nil)
			Util.SetParentOverrideWithColor(clone2, emitter.Parent, player2, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			clone2.Drag = emitter.Drag + math.random(-2, 3)
			coroutine.wrap(function()
				for i = 1, 14 do
					clone2.Acceleration = Vector3.new(
						math.random(-50, 50) * 2.5,
						math.random(-50, 50) * 2.5,
						math.random(-50, 50) * 2.5
					)
					task.wait(math.random(10, 20) / 200)
				end
			end)()
		end
	end

	local clone2 = kitsuneSkillFAwaken.Dash:Clone()
	clone2.CFrame = cframe
	clone2.Weld.Part1.Massless = true
	clone2.Weld.Part0 = hrp
	Util.SetParentOverrideWithColor(clone2, v, player2, "KitsuneFruitVFXColor")
	destroyAfter(clone2, 7)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		task.wait(0.1)
		clone2.Attachment2.Particle_1.Enabled = false
	end)
	local tween = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude2)
	})
	tween:Play()
	coroutine.wrap(function()
		tween.Completed:Wait()

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone2.Weld.Enabled = false
		clone2.Anchored = true

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.01)

		for i = 1, 4 do
			local v3 = i
			coroutine.wrap(function()
				local clone3 = kitsuneSkillFAwaken.DashTrail:Clone()

				if v3 == 1 then
					clone3.Position = cframe * CFrame.new(7, 0, 0).Position
				elseif v3 == 2 then
					clone3.Position = cframe * CFrame.new(-7, 0, 0).Position
				elseif v3 == 3 then
					clone3.Position = cframe * CFrame.new(0, 7, 0).Position
				elseif v3 == 4 then
					clone3.Position = cframe * CFrame.new(0, -7, 0).Position
				end

				Util.SetParentOverrideWithColor(clone3, v, player2, "KitsuneFruitVFXColor")
				destroyAfter(clone3, 7)
				local position = clone3.Position
				local v4 = nil

				if v3 == 1 then
					v4 = cframe * CFrame.new(2, 0, -magnitude2).Position
				elseif v3 == 2 then
					v4 = cframe * CFrame.new(-2, 0, -magnitude2).Position
				elseif v3 == 3 then
					v4 = cframe * CFrame.new(0, 2, -magnitude2).Position
				elseif v3 == 4 then
					v4 = cframe * CFrame.new(0, -2, -magnitude2).Position
				end

				local magnitude3 = (position - v4).Magnitude
				clone3.CFrame = CFrame.new(position, v4)
				local v5 = (position - v4) / 2
				local position2 = CFrame.new(CFrame.new(position) * (v5 / -1.5)).Position
				local position3 = CFrame.new(CFrame.new(v4) * (v5 / 1.5)).Position
				local v6 = math.random(4, 6) * 8
				local v7 = position2 + Vector3.new(math.random(-v6, v6), math.random(-v6, v6), math.random(-v6, v6))
				local v8 = position3 + Vector3.new(
					math.random(-v6, v6),
					math.random(-v6 / 10, v6),
					math.random(-v6, v6)
				)

				for i2, effect in ipairs(clone3:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end

				local v9 = magnitude2
				local v10 = v9 <= 5 and 3 or not (v9 > 5 and v9 <= 150) and 7 or 3 + 4 * ((v9 - 5) / 145)

				for i2 = 1, magnitude3, v10 do
					local v11 = i2 / magnitude3
					local v12 = cubicBezier(v11, position, v7, v8, v4)
					local v14 = cubicBezier((i2 + v10) / magnitude3, position, v7, v8, v4)
					clone3.CFrame = clone3.CFrame:Lerp(CFrame.new(v12, v4), v11)
					clone3.CFrame = CFrame.new(clone3.Position, v14)
					task.wait()
				end

				for i2, effect in ipairs(clone3:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					end
				end
			end)()
		end
	end)()
	local clone3 = kitsuneSkillFAwaken.StartImpact:Clone()
	clone3.CFrame = cframe
	Util.SetParentOverrideWithColor(clone3, v, player2, "KitsuneFruitVFXColor")
	destroyAfter(clone3, 1)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
		end
	end

	local originPos = data.originPos
	local part, v3, v4 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(originPos + createVector(0, 0.1, 0), createVector(-0, -10, -0)),
		raycastParams.FilterDescendantsInstances
	)
	local part2, _ = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(data.goalPos + createVector(0, 0.1, 0), createVector(-0, -10, -0)),
		raycastParams.FilterDescendantsInstances
	)

	if part and part2 then
		coroutine.wrap(function()
			local clone4 = kitsuneSkillFAwaken.GroundFlameTrail:Clone()
			clone4.CFrame = Util.Misc.AlignCFrame(cframe - cframe.p + v3, v4) * CFrame.new(0, 0.1, 0)
			Util.SetParentOverrideWithColor(clone4, v, player2, "KitsuneFruitVFXColor")
			destroyAfter(clone4, 7)
			local tween2 = TweenService:Create(
				clone4,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					CFrame = clone4.CFrame * CFrame.new(0, 0, -magnitude2)
				}
			)
			tween2:Play()
			local clone5 = kitsuneSkillFAwaken.GroundFlameTrail2:Clone()
			clone5.Size = Vector3.new(clone5.Size.X, clone5.Size.Y, 15)
			clone5.CFrame = clone4.CFrame
			Util.SetParentOverrideWithColor(clone5, v, player2, "KitsuneFruitVFXColor")
			destroyAfter(clone5, 7)
			local tween3 = TweenService:Create(
				clone5,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone5.CFrame * CFrame.new(0, 0, -magnitude2 / 2),
					Size = Vector3.new(clone5.Size.X, clone5.Size.Y, magnitude2)
				}
			)
			tween3:Play()

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter.Rate / 5
				local rate = emitter.Rate
				local v6 = magnitude2

				if v6 <= 25 then
					rate = v5
				elseif v6 > 25 and v6 <= 150 then
					rate = v5 + (rate - v5) * ((v6 - 25) / 125)
				end

				emitter.Rate = rate
				emitter.Enabled = true
			end

			local lastTime = os.clock()
			local v5 = time()

			for _ = 1, 600 do
				task.wait(0.01)
				local part3, _ = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(data.originPos + createVector(0, 0.1, 0), createVector(-0, -10, -0)),
					raycastParams.FilterDescendantsInstances
				)

				if part3 then
					if os.clock() - lastTime >= 0.25 or time() - v5 > 10 then
						break
					end
				else
					tween2:Pause()
					tween2:Destroy()
					tween3:Pause()
					tween3:Destroy()
					break
				end
			end

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v6 = emitter.Rate / 3
				local rate = emitter.Rate
				local Z = clone5.Size.Z

				if Z <= 25 then
					rate = v6
				elseif Z > 25 and Z <= 150 then
					rate = v6 + (rate - v6) * ((Z - 25) / 125)
				end

				emitter.Rate = rate
				emitter.Enabled = true
			end

			task.spawn(function()
				local Z = clone5.Size.Z
				local v6 = clone5.CFrame * CFrame.new(0, 0, -Z / 5)

				for i = 1, 2 do
					local clone6 = kitsuneSkillFAwaken.DashFlame:Clone()

					if i == 1 then
						clone6.CFrame = v6 * CFrame.new(-7, 0, 0) * CFrame.Angles(0, 0.17453292519943295, 0)
					elseif i == 2 then
						clone6.CFrame = v6 * CFrame.new(7, 0, 0) * CFrame.Angles(0, -0.17453292519943295, 0)
					end

					Util.SetParentOverrideWithColor(clone6, v, player2, "KitsuneFruitVFXColor")
					destroyAfter(clone6, 7)

					for _, emitter in ipairs(clone6:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
						end
					end

					local clone7 = kitsuneSkillFAwaken.DashFlameEnd:Clone()
					clone7.CFrame = clone6.CFrame * CFrame.new(0, 0, -clone6.Size.Z / 2)
					Util.SetParentOverrideWithColor(clone7, v, player2, "KitsuneFruitVFXColor")
					destroyAfter(clone7, 7)

					for _, emitter in ipairs(clone7:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
						end
					end
				end
			end)
			coroutine.wrap(function()
				local Z = clone5.Size.Z
				local clone6 = kitsuneSkillFAwaken.GroundFlameBeam:Clone()
				clone6.Size = Vector3.new(clone6.Size.X, 1, Z)
				clone6.CFrame = clone5.CFrame
				Util.SetParentOverrideWithColor(clone6, v, player2, "KitsuneFruitVFXColor")
				destroyAfter(clone6, 7)
				local v6 = clone6.Size.Z / 2 + 3
				clone6.Attach0.Position = Vector3.new(0, 0.1, -v6)
				clone6.Attach1.Position = Vector3.new(0, 0.1, v6)

				for _, beam in ipairs(clone6:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v7 = beam
					coroutine.wrap(function()
						local tween4 = TweenService:Create(
							v7,
							TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = v7.Width0,
								Width1 = v7.Width1
							}
						)
						v7.Width0 = 0
						v7.Width1 = 0
						tween4:Play()
						task.wait(0.35)
						local tween5 = TweenService:Create(
							v7,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween5:Play()
						tween5.Completed:Wait()
						v7:Destroy()
					end)()
				end
			end)()
			task.wait(0.15)

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(1.85)

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone6 = kitsuneSkillFAwaken.GroundFlameTrail2End:Clone()
			clone6.Size = clone5.Size
			clone6.CFrame = clone5.CFrame
			Util.SetParentOverrideWithColor(clone6, v, player2, "KitsuneFruitVFXColor")
			destroyAfter(clone6, 7)

			for _, emitter in ipairs(clone6:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v6 = emitter:GetAttribute("EmitCount") / 2
				local v7 = emitter:GetAttribute("EmitCount") * 2
				local v8 = magnitude2

				if v8 <= 25 then
					v7 = v6
				elseif v8 > 25 and v8 <= 150 then
					v7 = v6 + (v7 - v6) * ((v8 - 25) / 125)
				end

				Util.EmitFix(emitter, v7)
			end
		end)()
	end
end