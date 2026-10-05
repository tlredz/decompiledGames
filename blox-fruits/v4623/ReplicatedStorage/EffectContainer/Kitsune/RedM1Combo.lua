local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local redM1Combo = FX:WaitForChild("Kitsune").RedM1Combo
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

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

local function FlySlashForward(folder, cframe: CFrame, p: number, p2: number, p3, player, projectileEnd, groundSpark, cframe2: CFrame?, raycastParams2)
	local clone = folder:Clone()
	clone.Anchored = true
	local weld = clone:FindFirstChild("Weld")

	if weld then
		weld:Destroy()
	end

	clone.CFrame = folder.CFrame.Rotation + cframe.Position + createVector(0, 8, 0)
	Util.SetParentOverrideWithColor(clone, p3, player, "KitsuneFruitVFXColor")
	destroyAfter(clone, p2 + 3)
	local effects = {}

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = true
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effects[#effects + 1] = effect
		end
	end

	local v = math.rad((random:NextInteger(-3, 3)))
	local v2 = math.rad((random:NextInteger(-3, 3)))
	local v3 = p2 / random:NextNumber(1, 2)
	local cFrame = folder.CFrame.Rotation + createVector(0, 8, 0) + (cframe * CFrame.new(0, 0, -p) * CFrame.Angles(
		v,
		0,
		v2
	)).Position
	local tween = TweenService:Create(clone, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
		CFrame = cFrame
	})
	tween:Play()
	local emitters = {}
	local v5 = true
	local clone2

	if groundSpark then
		cframe2 = cframe2 or CFrame.new()
		raycastParams2 = raycastParams2 or raycastParams
		clone2 = groundSpark:Clone()
		clone2.CFrame = clone.CFrame
		Util.SetParentOverrideWithColor(clone2, p3, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, v3 + 3)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emitters[#emitters + 1] = emitter
		end
	else
		clone2 = nil
	end

	task.spawn(function()
		local v6 = 0
		local flag = false

		while v5 and clone.Parent do
			local now = tick()

			if v6 < now then
				v6 = now + 0.015

				for _, v7 in ipairs(effects) do
					v7:Emit(1)
				end
			end

			if clone2 and raycastParams2 then
				local raycastResult = Workspace:Raycast(
					(clone.CFrame * cframe2).Position + createVector(0, 1, 0),
					createVector(-0, -16, -0),
					raycastParams2
				)

				if raycastResult then
					clone2.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

					if not flag then
						flag = true

						for _, v8 in ipairs(emitters) do
							v8.Enabled = true
						end
					end

					for _, v8 in ipairs(emitters) do
						v8:Emit(1)
					end
				elseif flag then
					flag = false

					for _, v8 in ipairs(emitters) do
						v8.Enabled = false
					end
				end
			end

			RunService.Heartbeat:Wait()
		end

		for _, v7 in ipairs(emitters) do
			v7.Enabled = false
		end
	end)
	tween.Completed:Once(function()
		v5 = false

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("Beam") then
				local tween2 = TweenService:Create(
					effect,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				local v6 = effect
				tween2.Completed:Once(function()
					if v6.Parent then
						v6:Destroy()
					end
				end)
			elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		if projectileEnd then
			local clone3 = projectileEnd:Clone()
			clone3.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone3, p3, player, "KitsuneFruitVFXColor")
			destroyAfter(clone3, 5)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local emitDelay = emitter:GetAttribute("EmitDelay") or 0
				local emitCount = emitter:GetAttribute("EmitCount") or 1
				local v7 = emitter
				task.spawn(function()
					if emitDelay > 0 then
						task.wait(emitDelay)
					end

					v7:Emit(emitCount)
				end)
			end
		end
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

	local kitsuneSkillM1T

	if data.transformed == true then
		kitsuneSkillM1T = FX:WaitForChild("Kitsune").KitsuneSkillM1T
	else
		kitsuneSkillM1T = FX:WaitForChild("Kitsune").KitsuneSkillM1
	end

	local function ClawSlash(folder, index, folder2, _, p, p2)
		coroutine.wrap(function()
			task.wait(0.125)

			if index == 3 then
				if data.transformed == false then
					folder2.CFrame = folder.CFrame * CFrame.new(0, -5, -11)
				else
					folder2.CFrame = folder.CFrame * CFrame.new(0, -5, -15)
				end

				local _ = folder.CFrame * CFrame.new(0, 0, -11).Position
				FlySlashForward(
					folder,
					p2 * CFrame.new(0, -5, -14),
					75,
					0.3,
					p,
					player,
					redM1Combo.ProjectileEnd,
					redM1Combo.GroundSpark,
					CFrame.new(0, 0, 0),
					raycastParams
				)
			elseif index == 1 then
				if data.transformed == false then
					folder2.CFrame = folder.CFrame * CFrame.new(0, 0, -9)
				else
					folder2.CFrame = folder.CFrame * CFrame.new(0, 0, -12)
				end

				local v = folder.CFrame * CFrame.new(-5, 0, -8.5).Position
				FlySlashForward(
					folder,
					p2 * CFrame.new(0, -5, -14),
					75,
					0.3,
					p,
					player,
					redM1Combo.ProjectileEnd,
					redM1Combo.GroundSpark,
					CFrame.new(0, 0, 0),
					raycastParams
				)
				local raycastResult = Workspace:Raycast(
					v + createVector(0, 1, 0),
					CFrame.new(v).UpVector * -11,
					raycastParams
				)

				if raycastResult then
					local clone = kitsuneSkillM1T.GroundSlash:Clone()
					clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + p2.LookVector)
					Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone, 7)

					for _, emitter in ipairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v2 = emitter
						coroutine.wrap(function()
							v2.Enabled = true
							task.wait(0.2)
							v2.Enabled = false
						end)()
					end
				end
			elseif index == 2 then
				if data.transformed == false then
					folder2.CFrame = folder.CFrame * CFrame.new(0, 0, -9)
				else
					folder2.CFrame = folder.CFrame * CFrame.new(0, 0, -12)
				end

				local v = folder.CFrame * CFrame.new(-5, 0, -8.5).Position
				FlySlashForward(
					folder,
					p2 * CFrame.new(0, -5, -14),
					75,
					0.3,
					p,
					player,
					redM1Combo.ProjectileEnd,
					redM1Combo.GroundSpark,
					CFrame.new(0, 0, 0),
					raycastParams
				)
				local raycastResult = Workspace:Raycast(
					v + createVector(0, 1, 0),
					CFrame.new(v).UpVector * -11,
					raycastParams
				)

				if raycastResult then
					local clone = kitsuneSkillM1T.GroundSlash2:Clone()
					clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + p2.LookVector)
					Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
					destroyAfter(clone, 7)

					for _, emitter in ipairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v2 = emitter
						coroutine.wrap(function()
							v2.Enabled = true
							task.wait(0.14)
							v2.Enabled = false
						end)()
					end
				end
			end

			for _, emitter in ipairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end
		end)()
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

					if v:IsDescendantOf(folder.Slash2) then
						task.wait(0.05)
					elseif v:IsDescendantOf(folder.Slash3) then
						task.wait(0.08)
					elseif v:IsDescendantOf(folder) and not (v:IsDescendantOf(folder.Slash3) or v:IsDescendantOf(folder.Slash2)) then
						task.wait(0.125)
					end

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
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-2.6179938779914944,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
		}):Play()
	end

	local function ClawSpin(folder, _, hrp2, _)
		coroutine.wrap(function()
			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Enabled = true
					local startDelay = descendant:GetAttribute("StartDelay")
					local v = descendant
					local v2 = descendant:GetAttribute("EndDelay")
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
						task.wait(0.15)
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
				elseif descendant:IsA("Motor6D") and descendant:GetAttribute("Z") then
					local Z = descendant:GetAttribute("Z")
					local ZO = descendant:GetAttribute("ZO")
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.3),
						{
							C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.new(
								0,
								0,
								Z / 2
							) * CFrame.Angles(0, ZO, 0)
						}
					)
					tween:Play()
					local v = descendant
					coroutine.wrap(function()
						tween.Completed:Wait()
						tween = TweenService:Create(v, TweenInfo.new(0.3), {
							C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
								0,
								ZO,
								0
							)
						})
						tween:Play()
					end)()
				end
			end
		end)()
		coroutine.wrap(function()
			local position = hrp2.Position

			if Workspace:Raycast(position + createVector(0, 1, 0), CFrame.new(position).UpVector * -5, raycastParams) then
				local clone = kitsuneSkillM1T.Slash2Wind:Clone()
				clone.Position = hrp2.Position
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "KitsuneFruitVFXColor")
				destroyAfter(clone, 7)
				clone.Weld.Part0 = hrp2
				clone.Weld.Part1.Massless = true

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

		for _ = 1, 4 do
			local tween = TweenService:Create(
				folder.Weld,
				TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						-2.6179938779914944,
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
			CFrame = folder.CFrame * CFrame.Angles(0, -1.3089969389957472, 0)
		}):Play()
	end

	local function TailSlam(folder, folder2, _, p, hrp2)
		coroutine.wrap(function()
			task.wait(0.125)
			folder2.CFrame = hrp2.CFrame * CFrame.new(0, 7, -18)

			for _, emitter in ipairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.025)
			local v = hrp2.CFrame * CFrame.new(0, 0, -18).Position
			local raycastResult = Workspace:Raycast(
				v + createVector(0, 1, 0),
				CFrame.new(v).UpVector * -14,
				raycastParams
			)

			if raycastResult then
				local clone = kitsuneSkillM1T.GroundHit:Clone()
				clone.CFrame = CFrame.new(raycastResult.Position)
				Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
				destroyAfter(clone, 7)
				clone.Attachment.Orientation = Vector3.new(0, math.random(-90, 90), 0)

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
			end
		end)()
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
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-2.6179938779914944,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-1.7453292519943295, 0, 0)
		}):Play()
	end

	local function TailSlash(folder, folder2, _, _, hrp2)
		coroutine.wrap(function()
			task.wait(0.125)

			if data.transformed == false then
				folder2.CFrame = hrp2.CFrame * CFrame.new(0, 3, -25) * CFrame.Angles(0, 0, 1.7453292519943295)
			else
				folder2.CFrame = hrp2.CFrame * CFrame.new(0, 3, -35) * CFrame.Angles(0, 0, 1.7453292519943295)
			end

			for _, emitter in ipairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.025)
		end)()
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
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-2.6179938779914944,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-1.7453292519943295, 0, 0)
		}):Play()
	end

	local index = data.index
	local v = _WorldOrigin
	assert(data.damageDir)
	local cFrame = CFrame.lookAt(createVector(0, 0, 0), data.damageDir) + hrp.CFrame.Position
	local v3 = raycastParams

	if index == 1 then
		Util.Sound:Play("KitsuneMutation_M1_Slashes_01", hrp)
		local clone = kitsuneSkillM1T.Slash:Clone()
		local clone2 = kitsuneSkillM1T.SlashHit:Clone()
		clone.CFrame = cFrame
		clone.Weld.Part0 = hrp
		clone.Weld.Part1.Massless = true
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			-0.7853981633974483
		) * CFrame.Angles(2.9670597283903604, 0, 0)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, 7)
		ClawSlash(clone, 1, clone2, v3, v, cFrame)
	elseif index == 2 then
		Util.Sound:Play("KitsuneMutation_M1_Slashes_02", hrp)
		local clone = kitsuneSkillM1T.Slash:Clone()
		local clone2 = kitsuneSkillM1T.SlashHit:Clone()
		clone.CFrame = cFrame
		clone.Weld.Part0 = hrp
		clone.Weld.Part1.Massless = true
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			-2.0943951023931953
		) * CFrame.Angles(2.9670597283903604, 0, 0)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, 7)
		ClawSlash(clone, 2, clone2, v3, v, cFrame)
	elseif index == 3 then
		Util.Sound:Play("KitsuneMutation_M1_Slashes_03", hrp)
		local clone = kitsuneSkillM1T.Slash2:Clone()
		local clone2 = kitsuneSkillM1T.SlashHit2:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 1, 0)
		clone.Weld.Part0 = hrp
		clone.Weld.Part1.Massless = true
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
			0,
			0,
			1.3089969389957472
		) * CFrame.Angles(2.9670597283903604, 0, 0)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, 7)
		ClawSlash(clone, 3, clone2, v3, v, cFrame)
	elseif index == 4 then
		Util.Sound:Play("Basic Attack 3", hrp)
		local clone = kitsuneSkillM1T.Slash3:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 1, 0)
		clone.Weld.Part0 = hrp
		clone.Weld.Part1.Massless = true
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
			-0.17453292519943295,
			0,
			0.008726646259971648
		)
		Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		ClawSpin(clone, v, hrp)
	elseif index == 5 then
		if data.playerOnGround == false then
			Util.Sound:Play("KitsuneMutation_M1_Slashes_01", hrp)

			if data.transformed == true then
				kitsuneSkillM1T = FX:WaitForChild("Kitsune").KitsuneSkillM1v2T
			else
				kitsuneSkillM1T = FX:WaitForChild("Kitsune").KitsuneSkillM1v2
			end

			local clone = kitsuneSkillM1T.Slash4:Clone()
			local clone2 = kitsuneSkillM1T.SlashHit4:Clone()

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= 1.5
					descendant.CurveSize1 *= 1.5
					descendant.Width0 *= 1.5
					descendant.Width1 *= 1.5
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * 1.5,
						descendant.Position.Y * 1.5,
						descendant.Position.Z * 1.5
					)
				end
			end

			clone.CFrame = cFrame * CFrame.new(0, 5, 3)
			clone.Weld.Part1.Massless = true
			clone.Weld.Part0 = hrp
			clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
				0,
				0,
				1.7453292519943295
			) * CFrame.Angles(3.490658503988659, 0, 0)
			Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone, 7)
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			TailSlash(clone, clone2, v3, v, hrp, v3)
			local position = clone.Position
			local v4 = 5 or 8
			local v5 = 6 or 14
			local v6 = 0.15 or 0.2
			local v7 = 0.25 or 0.7

			if (Workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end
		else
			Util.Sound:Play("KitsuneMutation_M1_FinalSmash_0" .. tostring(math.random(3, 4)), hrp)
			local clone = kitsuneSkillM1T.Slash4:Clone()
			local clone2 = kitsuneSkillM1T.SlashHit4:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 0, 3)
			clone.Weld.Part0 = hrp
			clone.Weld.Part1.Massless = true
			clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
				3.490658503988659,
				0,
				0
			)
			Util.SetParentOverrideWithColor(clone, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone, 7)
			Util.SetParentOverrideWithColor(clone2, v, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 7)
			TailSlam(clone, clone2, v3, v, hrp, v3)
			local position = clone.Position
			local v4 = 5 or 8
			local v5 = 6 or 14
			local v6 = 0.15 or 0.2
			local v7 = 0.25 or 0.7

			if (Workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end
		end
	end
end