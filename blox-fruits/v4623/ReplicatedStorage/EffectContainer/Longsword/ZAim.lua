local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local longsword = FX:WaitForChild("Longsword")
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
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

local function parabolic(value, value2, value3)
	local v = value or 0
	local v2 = value3 or 1
	return 4 * ((value2 or 0) / v2) * (-v ^ 2 / v2 + v)
end

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, value: number, p: number)
	local v = vector2 + (vector3 - vector2) * p
	local v2 = p * (vector3 - vector2).Magnitude or 0
	local magnitude = (vector3 - vector2).Magnitude or 1
	return v + createVector(0, 1, 0) * (4 * ((value or 0) / magnitude) * (-v2 ^ 2 / magnitude + v2))
end

local function getBezierControlPointsForBallistic(vector2: Vector3, vector3: Vector3, p: number)
	local v = vector3 - vector2
	local magnitude = v.Magnitude
	return
		vector2,
		vector2 + v.Unit * (magnitude / 3) + createVector(0, 1, 0) * (p * 4 / 3),
		vector2 + v.Unit * (2 * magnitude / 3) + createVector(0, 1, 0) * (p * 4 / 3),
		vector3,
		math.sqrt(magnitude ^ 2 + p ^ 2 * 16) * 0.3333333333333333
end

local attachmentPair = Util.AttachmentPair
local v = {}
return function(data)
	local player = data.player

	if player ~= localPlayer then
		return
	end

	if data.skillHeld == true then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
			warn("Missing hrp, effect code aborted")
			return
		end

		local currentCamera = Workspace.CurrentCamera

		if (humanoidRootPart.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
			return
		end

		v[player] = true
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local position = humanoidRootPart.Position
		local holding = data.holding
		local mouse = data.mouse
		local v2 = attachmentPair.new()
		local attachment0 = v2.attachment0
		local attachment1 = v2.attachment1
		local clone = longsword.AimBeam:Clone()
		clone.Attachment0 = attachment0
		clone.Attachment1 = attachment1
		clone.Parent = attachment0
		local clone2 = longsword.AimParticle:Clone()
		clone2.Parent = attachment1
		local clone3 = longsword.Z.windstuff:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
		clone3.Parent = _WorldOrigin
		local v3 = 0

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
			v3 = math.max(v3, emitter.Lifetime.Max)
		end

		Util.Debris:AddItem(clone3, v3)
		local maxZRange = data.maxZRange
		local maxZHeightOffset = data.maxZHeightOffset

		local function calculateGoal(p, value)
			local v4 = value - p
			local v5 = createVector(0, 1, 0) * v4 + (createVector(1, 0.01, 1) * v4).Unit * math.min(
				maxZRange,
				(createVector(1, 0.01, 1) * v4).Magnitude
			)
			local v6 = createVector(1, 0, 1) * v5 + math.sign(v5.Y) * math.min(maxZHeightOffset, (math.abs(v5.Y))) * createVector(
				0,
				1,
				0
			)
			local raycastResult = Workspace:Raycast(
				p + v6 + createVector(0, 0.6, 0),
				createVector(-0, -2.5, -0) * maxZHeightOffset,
				raycastParams
			)
			local v7

			if raycastResult then
				local v8 = raycastResult.Position + raycastResult.Normal * 0.6 - p
				v7 = createVector(1, 0, 1) * v8 + math.sign(v8.Y) * math.min(maxZHeightOffset, (math.abs(v8.Y))) * createVector(
					0,
					1,
					0
				)
			else
				v7 = createVector(1, 0, 1) * v6 - createVector(0, 1, 0) * maxZHeightOffset
			end

			local selected = p + v7

			if selected.Y < -20 then
				selected = selected * createVector(1, 0, 1) + createVector(0, -20, 0)
			end

			return
				selected,
				maxZHeightOffset * math.clamp(((selected - p) * createVector(1, 0, 1)).Magnitude / maxZRange, 0, 1)
		end

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local position2 = position
			local value = mouse.Value

			if holding.Value then
				value = Mouse.Hit.p
			end

			local v5, v6 = calculateGoal(position2, value)
			local v7 = v5 - position2
			local magnitude = v7.Magnitude
			local v8 = position2 + v7.Unit * (magnitude / 3) + createVector(0, 1, 0) * (v6 * 4 / 3)
			local v9 = position2 + v7.Unit * (2 * magnitude / 3) + createVector(0, 1, 0) * (v6 * 4 / 3)
			local curveSize = math.sqrt(magnitude ^ 2 + v6 ^ 2 * 16) * 0.3333333333333333
			local unit = (position2 - v5).unit
			local unit2 = (v8 - position2).unit
			local unit3 = unit2:Cross(unit).unit
			local unit4 = (v9 - v5).unit
			local unit5 = unit4:Cross(unit).unit
			local unit6 = unit3:Cross(unit2).unit
			local cframe = CFrame.new(
				position2.x,
				position2.y,
				position2.z,
				unit2.x,
				unit3.x,
				unit6.x,
				unit2.y,
				unit3.y,
				unit6.y,
				unit2.z,
				unit3.z,
				unit6.z
			)
			local cframe2 = CFrame.new(
				v5.x,
				v5.y,
				v5.z,
				unit4.x,
				unit5.x,
				unit6.x,
				unit4.y,
				unit5.y,
				unit6.y,
				unit4.z,
				unit5.z,
				unit6.z
			)
			attachment0.WorldCFrame = cframe
			attachment1.WorldCFrame = cframe2
			local v11 = clone
			local v12 = clone
			local curveSize2 = -curveSize
			v11.CurveSize0 = curveSize
			v12.CurveSize1 = curveSize2

			if character:IsDescendantOf(Workspace) and humanoid.Health ~= 0 and v[player] then
				return
			end

			v[player] = nil
			task.delay(0, function()
				v2:destroy()
			end)
			heartbeatConnection:Disconnect()
		end)
		clone2:Emit(1)
	elseif data.skillHeld == false then
		if not v[player] then
			return
		end

		v[player] = nil
	end
end