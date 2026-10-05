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

local kitsuneSkillZAwaken = FX:WaitForChild("Kitsune").KitsuneSkillZAwaken

for _, part in pairs(kitsuneSkillZAwaken:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	part.Size *= 1.7
	Util.ResizeModel(part, 1.7, part.Position)
end

for _, part in pairs(kitsuneSkillZAwaken.Stage1:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	part.Size *= 1.7
	Util.ResizeModel(part, 1.7, part.Position)
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

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 900 then
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

	local function cubicBezier(p, p2, p3, p4, p5)
		local v = p2 + (p3 - p2) * p
		local v2 = p3 + (p4 - p3) * p
		local v3 = p4 + (p5 - p4) * p
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

	local function Dash(cFrame, _, p, part, _)
		local dashTargetPos = data.dashTargetPos
		local magnitude = (cFrame.Position - dashTargetPos).Magnitude
		local clone = kitsuneSkillZAwaken.Start:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, p, player, "KitsuneFruitVFXColor")
		destroyAfter(clone, 7)
		Util.Sound:Play("KitsuneZSpawnEmber", part or clone, nil, 1, 1.5)

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
				Util.SetParentOverrideWithColor(clone2, emitter.Parent, player, "KitsuneFruitVFXColor")
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

		TweenService:Create(clone, TweenInfo.new(data.dashFor, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
		}):Play()
		local clone2 = kitsuneSkillZAwaken.Dash:Clone()
		clone2.CFrame = cFrame
		clone2.Weld.Part0 = part
		clone2.Weld.Part1.Massless = true
		Util.SetParentOverrideWithColor(clone2, p, player, "KitsuneFruitVFXColor")
		destroyAfter(clone2, 7)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(data.dashFor)

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
	end

	Dash(
		CFrame.lookAt(data.dashOriginPos, data.dashTargetPos),
		nil,
		_WorldOrigin,
		nil,
		(data.dashTargetPos - data.dashOriginPos).Magnitude
	)
end