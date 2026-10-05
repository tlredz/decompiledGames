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
local X = FX:WaitForChild("Longsword").X
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

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
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
	local X2 = unit.X
	local Y = unit.Y
	local Z = unit.Z
	local X3 = vector2.X
	local Z2 = vector2.Z
	local dot = vector4:Dot(unit)
	local v

	if math.abs(Y) < 0.1 then
		v = vector2.Y
	else
		v = (dot - X3 * X2 - Z2 * Z) / Y
	end

	return (Vector3.new(X3, v, Z2))
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
		local X2 = unit.X
		local Y = unit.Y
		local Z = unit.Z
		local X3 = position.X
		local Z2 = position.Z
		local dot = position2:Dot(unit)
		local v2

		if math.abs(Y) < 0.1 then
			v2 = position.Y
		else
			v2 = (dot - X3 * X2 - Z2 * Z) / Y
		end

		local vector2 = Vector3.new(X3, v2, Z2)
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
			local X2 = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X3 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X3 * X2 - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X3, v2, Z2)
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
			local X2 = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X3 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X3 * X2 - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X3, v2, Z2)
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

local function StartProjectileSlash(cFrame, folder, raycastParams2, fliesFor, magnitude)
	local v = X
	local clone = v.Phase2.ProjectileSlash:Clone()
	clone.CFrame = cFrame * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = folder

	for _, beam in pairs(clone:GetDescendants()) do
		if beam:IsA("Beam") then
			beam.Enabled = true
		end
	end

	local v2 = math.rad((math.random(-3, 3)))
	local v3 = math.rad((math.random(-3, 3)))
	local v4 = math.random(10, 20) / 10
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(fliesFor / v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.Angles(v2, 0, v3)
		}
	)
	tween:Play()
	local v5 = true
	local v6 = false
	task.spawn(function()
		local clone2 = v.Phase2.GroundGrass:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local v7 = false

		while true do
			local raycastResult = Workspace:Raycast(
				clone.Position + createVector(0, 1, 0),
				CFrame.new(clone.Position).UpVector * -10,
				raycastParams2
			)

			if raycastResult then
				clone2.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

				if not v6 then
					v6 = true
					local v9 = Util.Sound:Play("sSlowImpact", clone2, 20, 1.33, 0.33)
					task.delay(1.25, function()
						Util.Sound:FadeOut(v9, 1.25)
					end)
				end

				if v7 == false then
					v7 = true

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			elseif v7 == true then
				v7 = false

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			task.wait()

			if v5 ~= false then
				continue
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			break
		end
	end)
	tween.Completed:Wait()
	v5 = false
	local clone2 = v.Phase2.ProjectileImpact:Clone()
	clone2.CFrame = clone.CFrame
	clone2.Parent = folder

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			local v7 = effect
			task.spawn(function()
				local tween2 = TweenService:Create(
					v7,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v7:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
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
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local cframe = CFrame.new(origin, origin + fireDir)
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
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 7)
	local cFrame2 = part.CFrame
	Util.Sound:Play("SpikeHit", cFrame2)
	local clone = X.Phase2.Slash:Clone()
	clone.CFrame = cFrame2
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	if player == game.Players.LocalPlayer then
		local position = cFrame.Position
		local v2 = 6 or 8
		local v3 = 10 or 14
		local v4 = 0.2
		local v5 = 0.4 or 0.7

		if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v2, v3, v4, v5)
		end
	end

	local clone2 = X.Phase2.ProjectileStartImpact:Clone()
	clone2.CFrame = cFrame2 * CFrame.new(0, 0, -18)
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.IgnoreWater = false
	raycastParams2.FilterDescendantsInstances = { Workspace.Characters, Workspace.Enemies, Workspace._WorldOrigin }
	StartProjectileSlash(cFrame2, folder, raycastParams2, data.fliesFor, (data.origin - data.targetPos).Magnitude)
end