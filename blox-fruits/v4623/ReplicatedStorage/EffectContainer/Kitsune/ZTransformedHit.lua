local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
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

local function mockRootPart(_, cFrame: CFrame, player)
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

local kitsuneSkillZAwaken = FX:WaitForChild("Kitsune").KitsuneSkillZAwaken
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local delayBeforePelletExplosion = data.delayBeforePelletExplosion

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

	local function cubicBezier(p, position, p2, p3, pelletTargetPosition)
		local v = position + (p2 - position) * p
		local v2 = p2 + (p3 - p2) * p
		local v3 = p3 + (pelletTargetPosition - p3) * p
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ThrowOrbs(cFrame, p, p2, _)
		coroutine.wrap(function()
			for i = 1, data.numPellets do
				local v = i
				task.delay(math.random() * 0.2, function()
					local clone = kitsuneSkillZAwaken.Orb:Clone()
					clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone, 7)

					for i2, descendant in ipairs(clone:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						elseif descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = false
						end
					end

					local pelletTargetPosition = data.pelletTargetPositions[v]
					clone.CFrame = CFrame.new(clone.Position, pelletTargetPosition)

					for i2, descendant in ipairs(clone:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = true
						elseif descendant:IsA("Trail") then
							descendant.Enabled = true
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = true
						end
					end

					local clone2 = kitsuneSkillZAwaken.OrbStart:Clone()
					clone2.CFrame = CFrame.new(clone.Position, cFrame.Position)
					Util.SetParentOverrideWithColor(clone2, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone2, 7)
					destroyAfter(clone2, 1.5)
					Util.Sound:Play("KitsuneZTransformedBullet", p2, nil, math.random(95, 110) / 100, 1)

					for i2, emitter in ipairs(clone2:GetDescendants()) do
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

					local position = clone.Position
					local magnitude = (position - pelletTargetPosition).Magnitude
					clone.CFrame = CFrame.new(position, pelletTargetPosition)
					local v2 = (position - pelletTargetPosition) / 2
					local position2 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
					local new = CFrame.new
					new = new(CFrame.new(pelletTargetPosition) * (v2 / 1.5)).Position
					local v3 = magnitude / 3
					local v4 = clone.CFrame * CFrame.new(-25, 0, -10).Position
					local v5 = clone.CFrame * CFrame.new(-50, 0, -20).Position
					awaitHeartbeatLoopFor(data.pelletFliesFor, function(p3, p4, p5)
						local v6 = cubicBezier(p5, position, v4, v5, pelletTargetPosition)
						local v8 = cubicBezier(p5 + 0.01, position, v4, v5, pelletTargetPosition)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v6, pelletTargetPosition), p5)
						clone.CFrame = CFrame.new(clone.Position, v8)
					end)

					for i2, effect in ipairs(clone.Trail:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					clone.CFrame = CFrame.new(clone.Position)
					task.wait(delayBeforePelletExplosion)

					for i2, descendant in ipairs(clone:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = false
						end
					end

					local clone3 = kitsuneSkillZAwaken.OrbEnd:Clone()
					clone3.CFrame = clone.CFrame
					Util.SetParentOverrideWithColor(clone3, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone3, 7)

					for i2, emitter in ipairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
						end
					end

					local clone4 = kitsuneSkillZAwaken.OrbExplosion:Clone()
					clone4.CFrame = CFrame.new(clone3.Position)
					Util.SetParentOverrideWithColor(clone4, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone4, 7)
					Util.Sound:Play(
						"KitsuneZTransformedMiniExplosion",
						clone3.Position,
						nil,
						math.random(95, 120) / 100,
						1
					)

					for i2, emitter in ipairs(clone4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter.Parent == clone4 then
							destroyAfter(emitter, 7)
							emitter.Enabled = true
							local v6 = emitter
							coroutine.wrap(function()
								task.wait(0.25)
								v6.Enabled = false
							end)()
						else
							local v6 = emitter
							coroutine.wrap(function()
								task.wait(0.25)

								if v6:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v6:GetAttribute("EmitDelay"))
								end

								Util.EmitFix(v6, v6:GetAttribute("EmitCount"))
							end)()
						end
					end

					coroutine.wrap(function()
						local raycastResult = Workspace:Raycast(
							clone4.CFrame * CFrame.new(0, 1, 1).Position,
							CFrame.new(clone4.Position).UpVector * -15,
							raycastParams
						)

						if raycastResult then
							local clone5 = kitsuneSkillZAwaken.WallHit:Clone()
							clone5.CFrame = CFrame.new(
								raycastResult.Position,
								raycastResult.Position + raycastResult.Normal
							) * CFrame.new(0, 0, -0.15)
							Util.SetParentOverrideWithColor(clone5, p, player, "KitsuneFruitVFXColor")
							destroyAfter(clone5, 7)

							for i2, emitter in ipairs(clone5:GetDescendants()) do
								if not (emitter:IsA("ParticleEmitter") and emitter.Parent == clone5) then
									continue
								end

								destroyAfter(emitter, 7)

								if not (emitter.Name == "Particle_3" or emitter.Name == "Particle_4") then
									continue
								end

								for i3 = 1, 12 do
									local clone6 = emitter:Clone()
									Util.SetParentOverrideWithColor(
										clone6,
										emitter.Parent,
										player,
										"KitsuneFruitVFXColor"
									)
									destroyAfter(clone6, 7)
									clone6.Drag = emitter.Drag + math.random(-5, 3)
									clone6:SetAttribute("EmitDelay", math.random(10, 100) / 1000)
									coroutine.wrap(function()
										task.wait(math.random(10, 40) / 200)
										clone6.Acceleration = Vector3.new(
											math.random(-40, 40) * math.random(3, 5),
											math.random(-40, 40) * math.random(3, 5),
											math.random(-40, 40) * math.random(3, 5)
										)
										task.wait(math.random(30, 60) / 200)
										clone6.Acceleration = Vector3.new(
											math.random(-20, 20) * math.random(2, 5),
											math.random(-20, 20) * math.random(2, 5),
											math.random(-20, 20) * math.random(2, 5)
										)
										task.wait(math.random(30, 50) / 300)
										clone6.Acceleration = Vector3.new(
											math.random(-20, 20) * math.random(2, 5),
											math.random(-10, 10) * math.random(2, 5),
											math.random(-20, 20) * math.random(2, 5)
										)
									end)()
								end
							end

							clone5.Attachment.Orientation = Vector3.new(0, 0, math.random(-90, 90))

							for i2, descendant in ipairs(clone5:GetDescendants()) do
								if descendant:IsA("ParticleEmitter") then
									if descendant:GetAttribute("Color") then
										descendant.Color = ColorSequence.new(
											raycastResult.Instance.Color,
											raycastResult.Instance.Color
										)
									end

									local v7 = descendant
									coroutine.wrap(function()
										if v7:GetAttribute("EmitDelay") ~= 0 then
											task.wait(v7:GetAttribute("EmitDelay"))
										end

										Util.EmitFix(v7, v7:GetAttribute("EmitCount"))
									end)()

									if descendant.Parent == clone5 then
										destroyAfter(descendant, 7)

										if descendant.Name == "Particle_1" or descendant.Name == "Particle_2" then
											descendant.Enabled = true
											local v8 = descendant
											coroutine.wrap(function()
												task.wait(0.25)
												v8.Enabled = false
											end)()
										end
									end
								elseif descendant:IsA("PointLight") then
									TweenService:Create(
										descendant,
										TweenInfo.new(
											0.15,
											Enum.EasingStyle.Quart,
											Enum.EasingDirection.In,
											0,
											false,
											0.25
										),
										{
											Brightness = 0
										}
									):Play()
								end
							end
						end
					end)()
				end)
			end
		end)()
	end

	local function AttackMiss(_, p, _, _)
		local part = mockRootPart(
			hrp,
			CFrame.lookAt(createVector(0, 0, 0), data.fireDir) + data.pelletOriginPos,
			player
		)
		local cFrame = part.CFrame
		ThrowOrbs(cFrame, p, part) -- equivalent call inferred; original call site unknown
		local clone = kitsuneSkillZAwaken.TailSpin:Clone()
		clone.CFrame = cFrame
		clone.Weld.Part0 = part
		clone.Weld.Part1.Massless = true
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			0.017453292519943295
		)
		Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Beam") then
				local tween = TweenService:Create(
					effect,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Width0 = effect.Width0,
						Width1 = effect.Width1
					}
				)
				effect.Width0 = 0
				effect.Width1 = 0
				tween:Play()
			end
		end

		local lastTime = os.clock()
		local v2 = time()

		for _ = 1, 600 do
			local tween = TweenService:Create(
				clone.Weld,
				TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						-2.6179938779914944,
						0
					)
				}
			)
			tween:Play()
			tween.Completed:Wait()

			if os.clock() - lastTime >= 0.15 or time() - v2 > 10 then
				break
			end
		end

		clone.Weld.Enabled = false
		clone.Anchored = true
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -1.3089969389957472, 0)
		}):Play()
		destroyAfter(clone, 2)

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.15), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end
	end

	local v = _WorldOrigin
	local victimRoot = data.victimRoot

	if victimRoot == nil then
		if not data.pelletOriginPos then
			return
		end

		if (Workspace.CurrentCamera.CFrame.Position - data.pelletOriginPos).Magnitude < 100 then
			coroutine.wrap(function()
				coroutine.wrap(function()
					local clone = kitsuneSkillZAwaken.Bloom:Clone()
					Util.SetParentOverrideWithColor(clone, Lighting, player, "KitsuneFruitVFXColor")
					destroyAfter(clone, 7)
					local tween = TweenService:Create(clone, TweenInfo.new(0.1), {
						Size = 50,
						Threshold = 1.25
					})
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = 24,
						Threshold = 2
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone:Destroy()
				end)()
				local pelletOriginPos = data.pelletOriginPos
				local v2 = 5 or 8
				local v3 = 15 or 14
				local v4 = 0.3 or 0.2
				local v5 = 0.5 or 0.7

				if (Workspace.CurrentCamera.CFrame.Position - pelletOriginPos).Magnitude < 100 then
					Util.CameraShaker:ShakeOnce(v2, v3, v4, v5)
				end

				local clone = kitsuneSkillZAwaken.ScreenColor:Clone()
				Util.SetParentOverrideWithColor(clone, Lighting, player, "KitsuneFruitVFXColor")
				destroyAfter(clone, 7)
				local clone2 = kitsuneSkillZAwaken.CameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
				end)
				task.delay(0.2, function()
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end
				end)
				destroyAfter(clone2, 0.2)
				local tween = TweenService:Create(clone, TweenInfo.new(0.05), {
					Brightness = clone.Brightness,
					Contrast = clone.Contrast,
					Saturation = clone.Saturation,
					TintColor = clone.TintColor
				})
				clone.Brightness = 0
				clone.Contrast = 0
				clone.Saturation = 0
				clone.TintColor = Util.WrapColor3Constructor(
					Color3.fromRGB(255, 255, 255),
					player,
					"KitsuneFruitVFXColor"
				)
				tween:Play()
				task.wait(0.2)
				local tween2 = TweenService:Create(clone, TweenInfo.new(0.2), {
					TintColor = Util.WrapColor3Constructor(
						Color3.fromRGB(255, 255, 255),
						player,
						"KitsuneFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween2:Play()
				tween2.Completed:Wait()
				clone:Destroy()
			end)()
		end

		AttackMiss(nil, v, nil, raycastParams)
	else
		coroutine.wrap(function()
			task.wait(0.1)
			local clone = kitsuneSkillZAwaken.TailGrab:Clone()
			clone.CFrame = victimRoot.CFrame
			Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone, 7)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end
		end)()
		Util.Sound:Play("KitsuneZSpawnEmber", hrp, nil, 1, 1)
		Util.Sound:Play("Z Attacks- Spawn Effect", hrp, nil, 1, 1.3)
		task.wait(data.delayBeforeThrow)
		local cframe = CFrame.lookAt(victimRoot.Position, hrp.Position)
		coroutine.wrap(function()
			local clone = kitsuneSkillZAwaken.TailKnockback:Clone()
			clone.CFrame = victimRoot.CFrame
			clone.Weld.Part1.Massless = true
			clone.Anchored = true
			Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone, 4)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local burn = kitsuneSkillZAwaken.Burn

			for _, part in ipairs(victimRoot.Parent:GetChildren()) do
				if not part:IsA("MeshPart") then
					continue
				end

				for _, emitter in ipairs(burn.Attachment2:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone2 = emitter:Clone()
					Util.SetParentOverrideWithColor(clone2, part, player, "KitsuneFruitVFXColor")
					destroyAfter(clone2, 7)
					clone2.Enabled = true
					coroutine.wrap(function()
						task.wait(3)
						clone2.Enabled = false
						destroyAfter(clone2, 2)
					end)()
				end
			end

			local clone2 = burn:Clone()
			clone2.Attachment2:Destroy()
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			clone2.Weld.Part0 = victimRoot
			coroutine.wrap(function()
				task.wait(3)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)()
			local lastTime = tick()

			while tick() - lastTime < 0.2 do
				clone.CFrame = CFrame.new(victimRoot.Position) * (cframe - cframe.p) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
				task.wait()
			end

			clone.CFrame = CFrame.new(victimRoot.Position) * (cframe - cframe.p) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)()
		coroutine.wrap(function()
			task.wait(0.55)
			local stage1 = kitsuneSkillZAwaken.Stage1
			local clone = stage1.Sphere:Clone()
			clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), data.victimTargetPos - data.victimOrigin) + victimRoot.Position
			Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone, 7)

			for _, effect in ipairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				elseif effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			local clone2 = stage1.SphereShoot:Clone()
			clone2.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, emitter in ipairs(clone2:GetDescendants()) do
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

			heartbeatLoopFor2(data.victimFliesFor, function(_, _, _)
				clone.CFrame = clone.CFrame.Rotation + victimRoot.Position
			end)
			local v2 = true
			coroutine.wrap(function()
				for _ = 1, 4 do
					coroutine.wrap(function()
						local clone3 = stage1.SphereTrail:Clone()
						clone3.CFrame = clone.CFrame
						Util.SetParentOverrideWithColor(clone3, v, player, "KitsuneFruitVFXColor")
						destroyAfter(clone3, 7)
						clone3.Weld.Part0 = clone
						clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.Angles(
							0,
							0,
							(math.rad((math.random(-180, 180))))
						)

						for _, effect in ipairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = true
							elseif effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						local v3 = time()

						for _ = 1, 600 do
							clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.Angles(
								0,
								0,
								0.2617993877991494
							)
							task.wait()

							if v2 == false or time() - v3 > 10 then
								break
							end
						end

						for _, effect in ipairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							elseif effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)()
				end
			end)()
			task.wait(data.victimFliesFor * 0.8)
			local _ = clone.CFrame
			v2 = false
			clone.Transparency = 1

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone, 3)
		end)()
	end
end