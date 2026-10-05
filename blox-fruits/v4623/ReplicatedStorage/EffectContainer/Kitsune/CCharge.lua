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

local function haltUntilCondition(fn, value: number?)
	local v = value or 14
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(fn)

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

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local function viewerIsClose(p, p2, p3, callback)
		if (p2 - p.CFrame.Position).Magnitude < p3 then
			callback()
		end
	end

	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end

	local function lerp(p, p2, p3)
		return p + (p2 - p) * p3
	end

	local function cubicBezier(p, position, p2, p3, position2)
		local v = position + (p2 - position) * p
		local v2 = p2 + (p3 - p2) * p
		local v3 = p3 + (position2 - p3) * p
		local v4 = v + (v2 - v) * p
		return v4 + (v2 + (v3 - v2) * p - v4) * p
	end

	local kitsuneSkillC = FX:WaitForChild("Kitsune").KitsuneSkillC

	local function Stage1FocusTrail(clone, p, _, _)
		task.spawn(function()
			local clonesByClone = {}

			for _ = 1, 10 do
				local clone2 = kitsuneSkillC.Stage1.FocusTrail:Clone()
				clone2:SetAttribute("Over", false)
				clone2.CFrame = clone.CFrame
				clonesByClone[clone2] = clone2
				Util.SetParentOverrideWithColor(clone2, p, player, "KitsuneFruitVFXColor")
				destroyAfter(clone2, 17)
			end

			local lastTime = os.clock()
			local v = time()

			for _ = 1, 1200 do
				for _, v2 in pairs(clonesByClone) do
					if v2:GetAttribute("Over") ~= false then
						continue
					end

					v2:SetAttribute("Over", true)
					local folder = v2
					coroutine.wrap(function()
						task.wait(math.random(10, 100) / 200)

						if os.clock() - lastTime >= 1 then
							return
						end

						folder.Position = clone.Position + Vector3.new(
							math.random(-10, 10),
							math.random(-10, 10),
							math.random(-10, 10)
						)
						local position = folder.Position
						local position2 = clone.Position
						local magnitude = (position - position2).Magnitude
						folder.CFrame = CFrame.new(position, position2)
						local v3 = (position - position2) / 2
						local position3 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
						local position4 = CFrame.new(CFrame.new(position2) * (v3 / 1.5)).Position
						local v4 = math.random(4, 6) * 2
						local v5 = position3 + Vector3.new(
							math.random(-v4, v4),
							math.random(1, 2),
							math.random(-v4, v4)
						)
						local v6 = position4 + Vector3.new(
							math.random(-v4, v4),
							math.random(1, 2),
							math.random(-v4, v4)
						)

						for i, trail in ipairs(folder:GetDescendants()) do
							if trail:IsA("Trail") then
								trail.Enabled = true
							end
						end

						local v7 = math.random(13, 14) / 15
						local lastTime2 = tick()
						local v8 = magnitude / v7 / 60

						while tick() - lastTime2 < v8 do
							local v9 = (tick() - lastTime2) / v8
							local v10 = cubicBezier(v9, position, v5, v6, position2)
							local v12 = cubicBezier(v9 + 0.001, position, v5, v6, position2)
							folder.CFrame = folder.CFrame:Lerp(CFrame.new(v10, position2), v9)
							folder.CFrame = CFrame.new(folder.Position, v12)
							task.wait()
						end

						for i, trail in ipairs(folder:GetDescendants()) do
							if trail:IsA("Trail") then
								trail.Enabled = false
							end
						end

						task.wait(0.26)
						folder:SetAttribute("Over", false)
					end)()
				end

				task.wait()

				if data.holding.Value == false or os.clock() - lastTime >= 1 or time() - v > 20 then
					break
				end
			end

			if data.holding.Value ~= false then
				clone.SphereHold3.Particle_1.Enabled = false
				task.spawn(function()
					task.spawn(function()
						local v2 = math.random(2, 3)
						local clone2 = kitsuneSkillC.Stage1.Spark:Clone()
						clone2.CFrame = clone.CFrame * CFrame.new(
							math.abs(v2) * math.random(-1, 1),
							math.abs(v2 / 2) * math.random(-1, 1),
							math.abs(v2) * math.random(-1, 1)
						)
						Util.SetParentOverrideWithColor(clone2, p, player, "KitsuneFruitVFXColor")
						destroyAfter(clone2, 17)

						for _, effect in ipairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = true
							elseif effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						local clone3 = kitsuneSkillC.Stage1.OrbitPart:Clone()
						clone3.AlignPosition.Enabled = true
						clone3.AlignPosition.Attachment0 = clone3.Attachment0
						Util.SetParentOverrideWithColor(clone3, clone2, player, "KitsuneFruitVFXColor")
						destroyAfter(clone3, 17)
						local v3 = math.random(4, 8) * 2
						local v4 = math.abs(v3) * math.random(-1, 1)
						local v5 = math.abs(v3) * math.random(-1, 1)
						local v6 = math.abs(v3 / 4) * math.random(-1, 1)

						if v4 == 0 and v5 == 0 then
							local v7 = math.random(1, 2)
							local v8 = math.random(1, 2)

							if v7 == 1 then
								if v8 == 1 then
									v4 = v3
								else
									v4 = -v3
								end
							elseif v8 == 1 then
								v5 = v3
							else
								v5 = -v3
							end
						end

						local numberValue = Instance.new("NumberValue")
						numberValue.Value = (clone.Position - clone2.Position).Magnitude * 2.5
						local tweenInfo = TweenInfo.new(
							math.random(20, 50) / 100,
							Enum.EasingStyle.Linear,
							Enum.EasingDirection.Out,
							0,
							true
						)
						TweenService:Create(numberValue, tweenInfo, {
							Value = math.random(1, 5)
						}):Play()
						local lastTime2 = os.clock()
						clone3.CFrame *= CFrame.Angles(math.rad(v4), math.rad(v5), (math.rad(v6)))
						clone3.AlignPosition.Position = clone3.CFrame * CFrame.new(0, 0, -numberValue.Value).Position
						Util.SetParentOverrideWithColor(clone3.Attachment0, clone2, player, "KitsuneFruitVFXColor")
						os.clock()
						local v7 = time()

						for _ = 1, 1200 do
							clone3.Position = clone.Position
							clone3.CFrame *= CFrame.Angles(math.rad(v4), math.rad(v5), (math.rad(v6)))
							clone3.AlignPosition.Position = clone3.CFrame * CFrame.new(0, 0, -numberValue.Value).Position

							if os.clock() - lastTime2 >= 1 then
								lastTime2 = os.clock()
								TweenService:Create(numberValue, tweenInfo, {
									Value = math.random(1, 5)
								}):Play()
								local v8 = math.random(4, 8) * 1.5
								v4 = math.abs(v8) * math.random(-1, 1)
								v5 = math.abs(v8) * math.random(-1, 1)
								v6 = math.abs(v8 / 4) * math.random(-1, 1)

								if v4 == 0 and v5 == 0 then
									local v9 = math.random(1, 2)
									local v10 = math.random(1, 2)

									if v9 == 1 then
										if v10 == 1 then
											v4 = v8
										else
											v4 = -v8
										end
									elseif v10 == 1 then
										v5 = v8
									else
										v5 = -v8
									end
								end
							end

							task.wait()

							if data.holding.Value == false or time() - v7 > 20 then
								break
							end
						end

						clone3:Destroy()

						for _, effect in ipairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							elseif effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end)
				task.wait(0.6)
			end

			for _, v2 in pairs(clonesByClone) do
				v2:Destroy()
			end
		end)
		coroutine.wrap(function()
			task.wait(0.25)

			if data.holding.Value == true then
				clone.Attachment.Particle_2.Enabled = true
				clone.Attachment.Particle_3.Enabled = true
			end

			task.wait(0.5)

			if data.holding.Value == true then
				clone.Attachment.Particle_2.Enabled = false
				clone.Attachment.Particle_3.Enabled = false
			end
		end)()
	end

	local function StartHoldingStage4(hrp2, p, clone, _, _)
		local clone2 = kitsuneSkillC.Stage4.FlameAura:Clone()
		clone2.CFrame = hrp2.CFrame
		clone2.Weld.Part1.Massless = true
		clone2.Weld.Part0 = hrp2
		Util.SetParentOverrideWithColor(clone2, p, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, 17)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or emitter:GetAttribute("Emit") then
				continue
			end

			emitter.Enabled = true
		end

		local clonesByClone = {}
		local clonesByClone2 = {}
		coroutine.wrap(function()
			for _ = 1, 5 do
				local clone3 = kitsuneSkillC.Stage4.FlameAuraOrbit:Clone()
				clone3:SetAttribute("Speed", math.random(7, 12))
				clone3.CFrame = clone.CFrame
				clone3.Weld.Part0 = clone
				clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.new(
					0,
					0,
					math.random(-3, 3)
				) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(-5, 5))),
					(math.rad((math.random(-90, 90))))
				)
				clonesByClone[clone3] = clone3
				Util.SetParentOverrideWithColor(clone3, p, player, "KitsuneFruitVFXColor")
				destroyAfter(clone3, 17)
				clone3.Attachment.Position = Vector3.new(-math.random(5, 10), 0, 0)
			end

			for _ = 1, 10 do
				local clone3 = kitsuneSkillC.Stage4.SphereTrail:Clone()
				clone3:SetAttribute("Speed", math.random(10, 15))
				clone3.CFrame = clone.CFrame
				clone3.Weld.Part0 = clone
				clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(-5, 5))),
					(math.rad((math.random(-180, 180))))
				)
				clonesByClone2[clone3] = clone3
				destroyAfter(clone3, 17)
				local v = math.random(10, 20) / 10
				local v2 = math.random(7, 12) / 10
				clone3.TrailAttach0.Position = Vector3.new(
					clone3.TrailAttach0.Position.X,
					clone3.TrailAttach0.Position.Y * v2,
					v
				)
				clone3.TrailAttach1.Position = Vector3.new(
					clone3.TrailAttach1.Position.X,
					clone3.TrailAttach1.Position.Y * v2,
					v
				)
				Util.SetParentOverrideWithColor(clone3, p, player, "KitsuneFruitVFXColor")
			end

			while true do
				for _, v in pairs(clonesByClone) do
					v.Weld.C0 = v.Weld.Part0.CFrame:ToObjectSpace(v.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						0,
						-math.rad((v:GetAttribute("Speed")))
					)
				end

				for _, v in pairs(clonesByClone2) do
					v.Weld.C0 = v.Weld.Part0.CFrame:ToObjectSpace(v.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						0,
						(math.rad((v:GetAttribute("Speed"))))
					)
				end

				task.wait()

				if not (data.holding.Value == false or not clone:IsDescendantOf(Workspace)) then
					continue
				end

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, v in pairs(clonesByClone) do
					v:Destroy()
				end

				for _, v in pairs(clonesByClone2) do
					v:Destroy()
				end

				break
			end
		end)()
	end

	local v = _WorldOrigin

	if data.cutsceneTransition then
		Util.Sound:Play("KitsuneMutation_Beam_TapActivate_06", hrp, 15, 1.33)
		local clone = kitsuneSkillC.SphereHoldStart:Clone()
		Util.ResizeModel(clone, 2.5)
		clone.CFrame = hrp.CFrame * CFrame.new(0, -0.25, -5.5)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 3)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end
	else
		local clone = kitsuneSkillC.SphereHoldStart:Clone()
		clone.CFrame = hrp.CFrame * CFrame.new(0, -0.25, -5.5)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 17)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.06666666666666667)
		local stage1 = nil

		if data.transformed == false then
			stage1 = kitsuneSkillC.Stage1
		elseif data.transformed == true then
			stage1 = kitsuneSkillC.Stage4
		end

		local clone2 = stage1.SphereHold:Clone()
		clone2.CFrame = hrp.CFrame
		local flag = true

		if data.transformed and parent:FindFirstChild("Kitsune") and data.mutated then
			task.spawn(function()
				while flag do
					clone2.CFrame = parent.Kitsune.Kitsune.RootPart.Spine["Spine.001"]["Spine.002"]["Spine.003"]["Spine.004"]["Spine.005"].Head["Top Mouth"].TransformedWorldCFrame * CFrame.new(
						1,
						3,
						-6
					) * CFrame.Angles(0.6981317007977318, 0, 0) + createVector(0, 2, 0)
					task.wait()
				end
			end)
		else
			clone2.Weld.Part1.Massless = true
			clone2.Weld.Part0 = hrp
		end

		Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("DelayEnabled") then
				emitter.Enabled = false
			else
				emitter.Enabled = true
			end
		end

		if data.transformed == false then
			Stage1FocusTrail(clone2, v, nil, nil)
		elseif data.transformed == true then
			StartHoldingStage4(hrp, v, clone2, nil, nil)
		end

		local v2 = Util.Sound:Play("KitsuneCCharge", hrp)
		haltUntilCondition(function()
			return data.holding.Value == false
		end)
		flag = false

		if data.cSkill then
			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Clear()
				emitter.Enabled = false
			end
		else
			task.wait(0.03333333333333333)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		Util.Sound:FadeOut(v2, 0.1)
		destroyAfter(clone2, 5)
	end
end