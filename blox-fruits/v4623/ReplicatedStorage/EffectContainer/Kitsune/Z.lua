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
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
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

-- equivalent calls inferred from this helper; original call sites unknown
local function getValueOfValueObject(_WorldOrigin2, childName: string)
	local child = _WorldOrigin2:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
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

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

return function(state)
	local player = state.player
	local hrp = state.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local valueOfValueObject = getValueOfValueObject(_WorldOrigin, "KitsuneZOrbHold") -- equivalent call inferred; original call site unknown

	if valueOfValueObject then
		state.originPos = valueOfValueObject.Position
	end

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

	local v = _WorldOrigin
	local kitsuneSkillZ = FX:WaitForChild("Kitsune").KitsuneSkillZ
	local cframe = CFrame.lookAt(state.originPos, state.goalPos)
	coroutine.wrap(function()
		local clone = kitsuneSkillZ.OrbStart:Clone()
		clone.CFrame = cframe * CFrame.new(0, 0, -2)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
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

				Util.EmitFix(v2, v2:GetAttribute("EmitCount"))
			end)()
		end
	end)()
	local index = state.index
	coroutine.wrap(function()
		local clone = kitsuneSkillZ.Orb:Clone()
		clone.CFrame = cframe * CFrame.new(0, 0, -1)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		Util.Sound:Play("Z Attacks- Shoot flames", clone.Position, nil, 1 + math.random(-15, 15) / 100, 0.7)

		for _, effect in ipairs(clone.Trail:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		local goalPos = state.goalPos
		local parent = false
		local v2 = false

		if state.raycastHitSomething == true or state.victimRoot ~= nil then
			if state.victimRoot then
				parent = state.victimRoot.Parent
			else
				v2 = true
			end
		end

		if parent == false then
			local position = clone.Position
			local magnitude = (position - goalPos).Magnitude
			clone.CFrame = CFrame.new(position, goalPos)
			local v3 = (position - goalPos) / 2
			local position2 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
			local position3 = CFrame.new(CFrame.new(goalPos) * (v3 / 1.5)).Position
			local v4 = magnitude / 4
			local position4 = position2 + Vector3.new(math.random(-v4, v4), math.random(-1, 8), math.random(-v4, v4))
			local position5 = position3 + Vector3.new(math.random(-v4, v4), math.random(-1, 8), math.random(-v4, v4))
			awaitHeartbeatLoopFor(state.timeUntilImpact * 0.8, function(_, _, p)
				local v5 = cubicBezier(p, position, position4, position5, goalPos)
				local v7 = cubicBezier(p + 0.04, position, position4, position5, goalPos)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v5, goalPos), p)
				clone.CFrame = CFrame.new(clone.Position, v7)
			end)

			if v2 == true and index ~= 1 then
				position = clone.Position
				goalPos = state.goalPos
				local _, v5 = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(goalPos + createVector(0, 1, 0), CFrame.new(goalPos).UpVector * -2.4),
					raycastParams.FilterDescendantsInstances
				)
				goalPos = v5
				local magnitude2 = (position - goalPos).Magnitude
				clone.CFrame = CFrame.new(position, goalPos)
				local v6 = (position - goalPos) / 2
				position4 = CFrame.new(CFrame.new(position) * (v6 / -1.5)).Position
				position5 = CFrame.new(CFrame.new(goalPos) * (v6 / 1.5)).Position
				local halfMagnitude2 = magnitude2 / 2
				position4 += Vector3.new(
					math.random(-halfMagnitude2, halfMagnitude2),
					math.random(3, 8),
					math.random(-halfMagnitude2, halfMagnitude2)
				)
				position5 += Vector3.new(
					math.random(-halfMagnitude2, halfMagnitude2),
					math.random(3, 8),
					math.random(-halfMagnitude2, halfMagnitude2)
				)
				awaitHeartbeatLoopFor(state.timeUntilImpact * 0.2, function(_, _, p)
					local v8 = cubicBezier(p, position, position4, position5, goalPos)
					local v10 = cubicBezier(p + 0.04, position, position4, position5, goalPos)
					clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, goalPos), p)
					clone.CFrame = CFrame.new(clone.Position, v10)
				end)
			end

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("PointLight") then
					descendant.Enabled = false
				end
			end

			destroyAfter(clone, 3)
			local clone2 = kitsuneSkillZ.OrbEnd:Clone()
			clone2.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			destroyAfter(clone2, 3)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end

			if v2 == true then
				Util.Sound:Play("KitsuneZEmberExplosion", clone.Position, nil, 1 + math.random(-15, 15) / 100, 0.7)
				local _ = clone.CFrame * CFrame.new(0, 1, 1).Position
				local raycastResult = Workspace:Raycast(
					goalPos - clone.CFrame.LookVector,
					clone.CFrame.LookVector * 20,
					raycastParams
				)

				if raycastResult == nil then
					raycastResult = Workspace:Raycast(
						goalPos + createVector(0, 1, 0),
						createVector(-0, -1, -0) * 7,
						raycastParams
					)
				end

				if raycastResult then
					local clone3 = kitsuneSkillZ.WallHit:Clone()
					clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.new(
						0,
						0,
						-0.15
					)
					Util.SetParentOverrideWithColor(clone3, v, player, "KitsuneFruitVFXColor")
					destroyAfter(clone3, 7)
					destroyAfter(clone3, 3)

					for _, emitter in ipairs(clone3:GetDescendants()) do
						if not (emitter:IsA("ParticleEmitter") and emitter.Parent == clone3) then
							continue
						end

						destroyAfter(emitter, 7)

						if not (emitter.Name == "Particle_3" or emitter.Name == "Particle_4") then
							continue
						end

						for _ = 1, 12 do
							local clone4 = emitter:Clone()
							Util.SetParentOverrideWithColor(clone4, emitter.Parent, player, "KitsuneFruitVFXColor")
							destroyAfter(clone4, 7)
							clone4.Drag = emitter.Drag + math.random(-5, 3)
							clone4:SetAttribute("EmitDelay", math.random(10, 100) / 1000)
							coroutine.wrap(function()
								task.wait(math.random(10, 40) / 200)
								clone4.Acceleration = Vector3.new(
									math.random(-40, 40) * math.random(3, 5),
									math.random(-40, 40) * math.random(3, 5),
									math.random(-40, 40) * math.random(3, 5)
								)
								task.wait(math.random(30, 60) / 200)
								clone4.Acceleration = Vector3.new(
									math.random(-20, 20) * math.random(2, 5),
									math.random(-20, 20) * math.random(2, 5),
									math.random(-20, 20) * math.random(2, 5)
								)
								task.wait(math.random(30, 50) / 300)
								clone4.Acceleration = Vector3.new(
									math.random(-20, 20) * math.random(2, 5),
									math.random(-10, 10) * math.random(2, 5),
									math.random(-20, 20) * math.random(2, 5)
								)
							end)()
						end
					end

					clone3.Attachment.Orientation = Vector3.new(0, 0, math.random(-90, 90))

					for _, descendant in ipairs(clone3:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							if descendant:GetAttribute("Color") then
								descendant.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							local v5 = descendant
							coroutine.wrap(function()
								if v5:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v5:GetAttribute("EmitDelay"))
								end

								Util.EmitFix(v5, v5:GetAttribute("EmitCount"))
							end)()

							if descendant.Parent == clone3 then
								destroyAfter(descendant, 7)

								if descendant.Name == "Particle_1" or descendant.Name == "Particle_2" then
									descendant.Enabled = true
									local v6 = descendant
									coroutine.wrap(function()
										task.wait(0.25)
										v6.Enabled = false
									end)()
								end
							end
						elseif descendant:IsA("PointLight") then
							TweenService:Create(
								descendant,
								TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0.25),
								{
									Brightness = 0
								}
							):Play()
						end
					end
				end
			end
		else
			local v3 = state.victimDetonateDelay / 3.4
			local victimRoot = state.victimRoot
			local position = victimRoot.Position
			Util.Sound:Play(
				"KitsuneZSpawnEmber",
				victimRoot.Position or clone.Position,
				nil,
				1 + math.random(-15, 15) / 100,
				1
			)
			local position2 = clone.Position
			local magnitude = (position2 - position).Magnitude
			clone.CFrame = CFrame.new(position2, position)
			local v4 = (position2 - position) / 2
			local position3 = CFrame.new(CFrame.new(position2) * (v4 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position) * (v4 / 1.5)).Position
			local v5 = magnitude / 4
			local v6 = position3 + Vector3.new(math.random(-v5, v5), math.random(-3, 8), math.random(-v5, v5))
			local v7 = position4 + Vector3.new(math.random(-v5, v5), math.random(-3, 8), math.random(-v5, v5))
			local v8 = Util.Sound:Play("KitsuneZFireLoop", clone, nil, 1 + math.random(-15, 15) / 100, 1)
			local position5 = victimRoot.Position
			awaitHeartbeatLoopFor(state.timeUntilImpact, function(_, _, p)
				local v9 = cubicBezier(p, position2, v6, v7, position5)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v9, position5), p)
			end)
			local v9 = false
			coroutine.wrap(function()
				coroutine.wrap(function()
					local clone2 = kitsuneSkillZ.Spark:Clone()
					clone2.CFrame = clone.CFrame * CFrame.new(
						5 * math.random(-1, 1),
						2.5 * math.random(-1, 1),
						5 * math.random(-1, 1)
					)
					Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
					destroyAfter(clone2, 7)

					for _, effect in ipairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = true
						elseif effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					clone2.Anchored = false
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.P = 700
					bodyVelocity.Velocity = CFrame.new(
						clone2.Position,
						clone2.Position + Vector3.new(
							math.random(-150, 150) / 18,
							math.random(25, 60) / 8,
							math.random(-150, 150) / 18
						)
					).LookVector * math.random(30, 50)
					Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "KitsuneFruitVFXColor")
					destroyAfter(bodyVelocity, 0.021)
					task.wait(0.15 * v3)
					clone2.CanCollide = true
					task.wait(0.45 * v3)
					clone2.CanCollide = false
					local bodyVelocity2 = Instance.new("BodyVelocity")
					bodyVelocity2.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity2.P = 700
					destroyAfter(bodyVelocity2, 7)
					Util.SetParentOverrideWithColor(bodyVelocity2, clone2, player, "KitsuneFruitVFXColor")
					bodyVelocity2.Velocity = CFrame.new(clone2.Position, clone2.Position + createVector(0, 100, 0)).LookVector * math.random(
						5,
						10
					)
					task.wait(0.5 * v3)
					TweenService:Create(bodyVelocity2, TweenInfo.new(0.5), {
						Velocity = CFrame.new(
							clone2.Position,
							victimRoot.Position + Vector3.new(
								math.random(-2, 2),
								math.random(-1, 1) * 2,
								math.random(-2, 2)
							)
						).LookVector * math.random(18, 20)
					}):Play()
					task.wait(1 * v3)
					bodyVelocity2:Destroy()
					local clone3 = kitsuneSkillZ.OrbitPart:Clone()
					Util.SetParentOverrideWithColor(clone3, clone2, player, "KitsuneFruitVFXColor")
					destroyAfter(clone3, 7)
					clone3.AlignPosition.Enabled = true
					local v10 = 5 * math.random(-1, 1)
					local v11 = 5 * math.random(-1, 1)
					local v12 = 5 * math.random(-1, 1)

					if v10 == 0 and v11 == 0 then
						local v13 = math.random(1, 2)
						local v14 = math.random(1, 2)

						if v13 == 1 then
							if v14 == 1 then
								v10 = 5
							else
								v10 = -5
							end
						elseif v14 == 1 then
							v11 = 5
						else
							v11 = -5
						end
					end

					local numberValue = Instance.new("NumberValue")
					numberValue.Value = (victimRoot.Position - clone2.Position).Magnitude * 2.5
					TweenService:Create(numberValue, TweenInfo.new(2.5), {
						Value = 2
					}):Play()
					clone3.CFrame *= CFrame.Angles(math.rad(v10), math.rad(v11), (math.rad(v12)))
					clone3.AlignPosition.Position = clone3.CFrame * CFrame.new(0, 0, -numberValue.Value).Position
					Util.SetParentOverrideWithColor(clone3.Attachment0, clone2, player, "KitsuneFruitVFXColor")
					local lastTime = os.clock()
					local v13 = time()

					for _ = 1, 600 do
						clone3.Position = victimRoot.Position
						clone3.CFrame *= CFrame.Angles(math.rad(v10), math.rad(v11), (math.rad(v12)))
						clone3.AlignPosition.Position = clone3.CFrame * CFrame.new(0, 0, -numberValue.Value).Position
						task.wait()
						local v14 = os.clock() - lastTime

						if 1.5 * v3 <= v14 or time() - v13 > 10 then
							break
						end
					end

					for _, effect in ipairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)()
				task.wait(0.1 * v3)
			end)()
			coroutine.wrap(function()
				for _, effect in ipairs(clone.Trail:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				for _, effect in ipairs(clone.Trail2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					elseif effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				clone.Anchored = false
				local clone2 = kitsuneSkillZ.OrbitPart:Clone()
				Util.SetParentOverrideWithColor(clone2, clone, player, "KitsuneFruitVFXColor")
				destroyAfter(clone2, 7)
				Util.SetParentOverrideWithColor(clone2.Attachment0, clone, player, "KitsuneFruitVFXColor")
				clone2.AlignPosition.Enabled = true
				local v10 = 5 * math.random(-1, 1)
				local v11 = 5 * math.random(-1, 1)

				if v10 == 0 and v11 == 0 then
					local v12 = math.random(1, 2)
					local v13 = math.random(1, 2)

					if v12 == 1 then
						if v13 == 1 then
							v10 = 5
						else
							v10 = -5
						end
					elseif v13 == 1 then
						v11 = 5
					else
						v11 = -5
					end
				end

				local v12 = math.random(5, 8)
				local v13 = time()

				for _ = 1, 600 do
					clone2.Position = victimRoot.Position
					clone2.CFrame *= CFrame.Angles(math.rad(v10), math.rad(v11), 0)
					clone2.AlignPosition.Position = clone2.CFrame * CFrame.new(0, 0, -v12).Position
					task.wait()

					if v9 == true or time() - v13 > 10 then
						break
					end
				end
			end)()

			if index == 1 then
				local clone2 = kitsuneSkillZ.OrbTarget:Clone()
				clone2.CFrame = CFrame.new(victimRoot.Position, cframe.Position)
				Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
				destroyAfter(clone2, 7)
				destroyAfter(clone2, 3 * v3)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v10 = emitter
					coroutine.wrap(function()
						if v10:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v10:GetAttribute("EmitDelay"))
						end

						Util.EmitFix(v10, v10:GetAttribute("EmitCount"))
					end)()
				end
			end

			task.wait(3 * v3)
			v9 = true

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("PointLight") then
					descendant.Enabled = false
				end
			end

			destroyAfter(clone, 3 * v3)
			local clone2 = kitsuneSkillZ.OrbExplosion:Clone()
			clone2.CFrame = CFrame.new(victimRoot.Position)
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			destroyAfter(clone2, 3 * v3)

			if v8 then
				v8:Destroy()
			end

			Util.Sound:Play("KitsuneZFireworkExplosion", victimRoot.Position, nil, 1 + math.random(-15, 15) / 100, 1)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Parent == clone2 then
					destroyAfter(emitter, 7)
					emitter.Enabled = true
					local v10 = emitter
					coroutine.wrap(function()
						task.wait(0.25 * v3)
						v10.Enabled = false
					end)()
				else
					local v10 = emitter
					coroutine.wrap(function()
						task.wait(0.25 * v3)

						if v10:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v10:GetAttribute("EmitDelay"))
						end

						Util.EmitFix(v10, v10:GetAttribute("EmitCount"))
					end)()
				end
			end

			if index == 1 then
				local burn = kitsuneSkillZ.Burn

				for _, part in ipairs(victimRoot.Parent:GetChildren()) do
					if not part:IsA("MeshPart") then
						continue
					end

					for _, emitter in ipairs(burn.Attachment2:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local clone3 = emitter:Clone()
						Util.SetParentOverrideWithColor(clone3, part, player, "KitsuneFruitVFXColor")
						destroyAfter(clone3, 7)
						clone3.Enabled = true
						coroutine.wrap(function()
							task.wait(3 * v3)
							clone3.Enabled = false
							destroyAfter(clone3, 2 * v3)
						end)()
					end
				end

				local clone3 = burn:Clone()
				clone3.Attachment2:Destroy()
				clone3.Weld.Part1.Massless = true
				clone3.Weld.Part0 = victimRoot
				Util.SetParentOverrideWithColor(clone3, v, player, "KitsuneFruitVFXColor")
				destroyAfter(clone3, 7)
				coroutine.wrap(function()
					task.wait(3 * v3)

					for _, emitter in ipairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)()
			end
		end
	end)()
	task.wait(0.03)
end