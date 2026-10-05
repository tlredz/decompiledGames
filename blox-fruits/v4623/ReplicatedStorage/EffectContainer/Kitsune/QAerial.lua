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

local kitsuneDashAerial = FX:WaitForChild("Kitsune").KitsuneDashAerial
local clone = kitsuneDashAerial:Clone()

for _, child in pairs(clone:GetChildren()) do
	Util.ResizeModel(child, 0.55, child.Position)
end

for _, child in pairs(kitsuneDashAerial:GetChildren()) do
	if child.Name == "StartBeam" then
		Util.ResizeModel(child, 1.05, child.Position)
	elseif child.Name == "StartImpact" then
		Util.ResizeModel(child, 1.25, child.Position)
	else
		Util.ResizeModel(child, 1.8, child.Position)
	end
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

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	Util.Sound:Play("Dashes- Character Horizontal Dash", hrp, nil, 1, 1)
	local v = hrp.Parent:FindFirstChild("Kitsune") and kitsuneDashAerial or clone
	local v2 = _WorldOrigin
	local cFrame = CFrame.lookAt(createVector(0, 0, 0), data.travelDir) + data.originPos
	coroutine.wrap(function()
		task.wait(0.1)

		for i = 1, 2 do
			local v4 = 2.5
			local v5 = 0.25
			local clone2 = v.StartBeam:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, v2, player, "KitsuneFruitVFXColor")
			destroyAfter(clone2, 2)

			if i == 2 then
				v5 = 0.35
				TweenService:Create(clone2, TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
				}):Play()
				v4 = 4.5
			else
				TweenService:Create(clone2, TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 0, 8)
				}):Play()
			end

			local descendants = clone2:GetDescendants()

			if i == 2 then
				for _, instance in ipairs(descendants) do
					if instance:IsA("Beam") then
						instance.CurveSize0 /= 3
						instance.CurveSize1 /= 3
						instance.Width0 = 7
						instance.Width1 = 7
					elseif instance:IsA("Attachment") then
						instance.Position = Vector3.new(
							instance.Position.X / 3,
							instance.Position.Y / 3,
							instance.Position.Z / 3
						)
					end
				end
			end

			for _, instance in ipairs(descendants) do
				if instance:IsA("Beam") then
					local v6 = instance
					coroutine.wrap(function()
						TweenService:Create(v6, TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v6.CurveSize0 * v4,
							CurveSize1 = v6.CurveSize1 * v4,
							Width0 = v6.Width0 / 2,
							Width1 = v6.Width1 / 2
						}):Play()
						task.wait(v5 / 2)
						local tween = TweenService:Create(
							v6,
							TweenInfo.new(v5 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v6:Destroy()
					end)()
				elseif instance:IsA("Attachment") then
					local tweenInfo = TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					local v8 = instance.Position.X * v4
					local v9 = instance.Position.Y * v4
					TweenService:Create(instance, tweenInfo, {
						Position = Vector3.new(v8, v9, instance.Position.Z * v4)
					}):Play()
				end
			end
		end
	end)()
	local clone2 = v.StartImpact:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, v2, player, "KitsuneFruitVFXColor")
	destroyAfter(clone2, 1)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
		end
	end

	local clone3 = v.Dash:Clone()
	clone3.CFrame = cFrame
	clone3.Weld.Part1.Massless = true
	clone3.Anchored = true
	Util.SetParentOverrideWithColor(clone3, v2, player, "KitsuneFruitVFXColor")
	destroyAfter(clone3, 3)
	local descendants = clone3:GetDescendants()

	for _, effect in ipairs(descendants) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
		elseif effect:IsA("Trail") then
			effect.Enabled = not data.trailDisabled
		end
	end

	task.defer(function()
		local lastTime = tick()

		while tick() - lastTime < 0.25 do
			local velocity = hrp.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cFrame.LookVector
			end

			clone3.CFrame = CFrame.new(hrp.Position, hrp.Position + velocity)
			task.wait()
		end
	end)
	task.wait(0.25)

	for _, emitter in ipairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end