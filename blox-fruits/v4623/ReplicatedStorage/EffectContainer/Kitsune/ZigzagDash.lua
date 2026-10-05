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

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, position)
	p.CFrame = p.CFrame.Rotation + position
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

local function mockRootPart(_, cframe: CFrame, player)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cframe
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

local kitsuneDashGround = FX:WaitForChild("Kitsune").KitsuneDashGround

for _, child in pairs(kitsuneDashGround:GetChildren()) do
	if child.Name == "StartBeam" then
		Util.ResizeModel(child, 1.75, child.Position)
	elseif child.Name == "StartImpact" then
		Util.ResizeModel(child, 1.75, child.Position)
	else
		Util.ResizeModel(child, 1.35, child.Position)
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	Util.Sound:Play("Dashes- Transformed_Awakened Dash", hrp, nil, 1, 1)
	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
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

	local cframe = CFrame.lookAt(data.originPos, data.goalPos)
	local v = mockRootPart(hrp, cframe, player)

	if data.index == 1 then
		coroutine.wrap(function()
			for i = 1, 2 do
				local v2 = 2.5
				local v3 = 0.25
				local clone = kitsuneDashGround.StartBeam:Clone()
				clone.CFrame = cframe * CFrame.new(0, 0, 10)
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "KitsuneFruitVFXColor")
				destroyAfter(clone, 7)

				if i == 2 then
					v3 = 0.35
					TweenService:Create(clone, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.new(0, 0, 5)
					}):Play()
					v2 = 4.5
				else
					TweenService:Create(clone, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.new(0, 0, 8)
					}):Play()
				end

				if i == 2 then
					for _, descendant in ipairs(clone:GetDescendants()) do
						if descendant:IsA("Beam") then
							descendant.CurveSize0 /= 3
							descendant.CurveSize1 /= 3
							descendant.Width0 = 7
							descendant.Width1 = 7
						elseif descendant:IsA("Attachment") then
							descendant.Position = Vector3.new(
								descendant.Position.X / 3,
								descendant.Position.Y / 3,
								descendant.Position.Z / 3
							)
						end
					end
				end

				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v4 = descendant
						coroutine.wrap(function()
							TweenService:Create(
								v4,
								TweenInfo.new(v3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v4.CurveSize0 * v2,
									CurveSize1 = v4.CurveSize1 * v2,
									Width0 = v4.Width0 / 2,
									Width1 = v4.Width1 / 2
								}
							):Play()
							task.wait(v3 / 2)
							local tween = TweenService:Create(
								v4,
								TweenInfo.new(v3 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v4:Destroy()
						end)()
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v6 = descendant.Position.X * v2
						local v7 = descendant.Position.Y * v2
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v6, v7, descendant.Position.Z * v2)
						}):Play()
					end
				end
			end
		end)()
	end

	math.random(1, 2)
	local position = cframe.Position
	local _ = data.index
	local magnitude = (data.goalPos - data.originPos).Magnitude
	local clone = kitsuneDashGround.StartImpact:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, 6)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "KitsuneFruitVFXColor")
	destroyAfter(clone, 7)
	local clone2 = kitsuneDashGround.Dash:Clone()
	clone2.CFrame = cframe
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "KitsuneFruitVFXColor")
	destroyAfter(clone2, 7)
	clone.CFrame = cframe

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
		end
	end

	clone2.CFrame = cframe

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
		end
	end

	local _, v2 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(
			cframe.Position,
			CFrame.lookAt(cframe.Position, (cframe * CFrame.new(0, 0, -magnitude)).Position).LookVector * magnitude
		),
		raycastParams.FilterDescendantsInstances
	)
	snapProjectileToFinalPos(v, position) -- equivalent call inferred; original call site unknown
	local magnitude2 = (cframe.Position - v2).Magnitude
	coroutine.wrap(function()
		local v3 = CFrame.lookAt(v.Position, v2) * CFrame.new(0, 0, -magnitude2 / 2).Position
		local part, v4 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(v3, createVector(-0, -10, -0)),
			raycastParams.FilterDescendantsInstances
		)

		if part then
			coroutine.wrap(function()
				local clone3 = kitsuneDashGround.GroundFlame:Clone()
				clone3.CFrame = CFrame.new(v4, v4 + cframe.LookVector)
				clone3.Size = Vector3.new(5, 1, magnitude2)
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "KitsuneFruitVFXColor")
				destroyAfter(clone3, 7)

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local halfRate = emitter.Rate / 2
					local rate = emitter.Rate
					local halfMagnitude2 = magnitude2 / 2
					local v7 = magnitude2
					local v8 = magnitude2

					if v8 <= halfMagnitude2 then
						rate = halfRate
					elseif halfMagnitude2 < v8 and v8 <= v7 then
						rate = halfRate + (rate - halfRate) * ((v8 - halfMagnitude2) / (v7 - halfMagnitude2))
					end

					emitter.Rate = rate
					emitter.Enabled = true
				end

				task.wait(2)

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local clone4 = kitsuneDashGround.GroundFlameEnd:Clone()
				clone4.Size = clone3.Size
				clone4.CFrame = clone3.CFrame
				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "KitsuneFruitVFXColor")
				destroyAfter(clone4, 7)

				for _, emitter in ipairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter:GetAttribute("EmitCount") / 2
					local v6 = emitter:GetAttribute("EmitCount") * 2
					local halfMagnitude2 = magnitude2 / 2
					local v8 = magnitude2
					local v9 = magnitude2

					if v9 <= halfMagnitude2 then
						v6 = v5
					elseif halfMagnitude2 < v9 and v9 <= v8 then
						v6 = v5 + (v6 - v5) * ((v9 - halfMagnitude2) / (v8 - halfMagnitude2))
					end

					Util.EmitFix(emitter, v6)
				end
			end)()
		end
	end)()
end