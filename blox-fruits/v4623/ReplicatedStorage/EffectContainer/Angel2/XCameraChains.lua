local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
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

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
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
	rescheduleDestruction(instance, value or 60)
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

return function(p)
	local angelBeam = FX:WaitForChild("Angel2").AngelBeam
	local lastsFor = p.lastsFor

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getHorizontalFov()
		local fieldOfView = Workspace.CurrentCamera.FieldOfView
		local viewportSize = Workspace.CurrentCamera.ViewportSize
		local v = viewportSize.X / viewportSize.Y
		return (math.deg(math.atan(math.tan(math.rad(fieldOfView) * 0.5) * v) * 2))
	end

	local function CameraChain(parent)
		task.spawn(function()
			local fieldOfView = Workspace.CurrentCamera.FieldOfView
			local v = fieldOfView + (getHorizontalFov() - fieldOfView) / 1.65
			local v2 = {
				topLeft = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), math.rad(v / 2), 0) * CFrame.new(
					0,
					0,
					-5
				),
				topRight = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), -math.rad(v / 2), 0) * CFrame.new(
					0,
					0,
					-5
				),
				bottomLeft = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), math.rad(v / 2), 0) * CFrame.new(
					0,
					0,
					-5
				),
				bottomRight = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), -math.rad(v / 2), 0) * CFrame.new(
					0,
					0,
					-5
				)
			}
			local magnitude = (v2.topLeft.Position - v2.topRight.Position).magnitude
			local magnitude2 = (v2.topLeft.Position - v2.bottomLeft.Position).magnitude
			local currentCamera = Workspace.CurrentCamera
			local clone = angelBeam.CameraFocus:Clone()
			clone.Size = Vector3.new(magnitude, magnitude2, magnitude)
			clone.Parent = parent
			destroyAfter(clone, 7)
			local renderSteppedConnection = nil
			local v3 = time()
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not (time() - v3 > 7) then
					clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 0)
				elseif renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					local v4 = descendant
					task.spawn(function()
						if v4.Name == "Beam" then
							v4.TextureSpeed = 1
							local tween = TweenService:Create(
								v4,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									TextureSpeed = 7
								}
							)
							tween:Play()
							tween.Completed:Wait()
							TweenService:Create(
								v4,
								TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
								{
									TextureSpeed = 0
								}
							):Play()
							task.wait(0.25)

							for i = 0, 10 do
								v4.Transparency = NumberSequence.new(i / 10, i / 10)
								task.wait(0.025)
							end
						elseif v4.Name == "Beam2" then
							task.wait(0.5)
							v4.TextureSpeed = 1
							task.spawn(function()
								for i = 10, 0, -1 do
									v4.Transparency = NumberSequence.new(i / 10, i / 10)
									task.wait(0.025)
								end
							end)
							local tween = TweenService:Create(
								v4,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									TextureSpeed = 7
								}
							)
							tween:Play()
							tween.Completed:Wait()
							TweenService:Create(
								v4,
								TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
								{
									TextureSpeed = 0
								}
							):Play()
						end
					end)
				elseif descendant:IsA("Attachment") then
					local v4 = descendant
					task.spawn(function()
						if v4.Name == "Attach_1A" then
							local tween = TweenService:Create(
								v4,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Position = v4.Position
								}
							)
							v4.Position = v4.Parent.Attach_0A.Position
							task.wait(math.random(20, 50) / 100)
							tween:Play()
						end
					end)
				end
			end

			Util.Sound:Play("AngelXChains", clone, nil, 0.9 + math.random(-15, 15) / 100, 0.35)
			task.wait(lastsFor)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					local v4 = descendant
					task.spawn(function()
						if v4.Name == "Beam2" then
							for i = 0, 50 do
								v4.Transparency = NumberSequence.new(i / 50)
								task.wait(0.015)
							end
						end
					end)
				elseif descendant:IsA("Attachment") then
					local v4 = descendant
					task.spawn(function()
						if v4.Name == "Attach_1A" then
							TweenService:Create(
								v4,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Position = v4.Parent.Attach_0A.Position
								}
							):Play()
						end
					end)
				end
			end

			task.wait(1)
			renderSteppedConnection:Disconnect()
			clone:Destroy()
		end)
	end

	local parent2 = _WorldOrigin
	task.spawn(function()
		local fieldOfView = Workspace.CurrentCamera.FieldOfView
		local v2 = fieldOfView + (getHorizontalFov() - fieldOfView) / 1.65
		local v3 = {
			topLeft = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), math.rad(v2 / 2), 0) * CFrame.new(
				0,
				0,
				-5
			),
			topRight = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), -math.rad(v2 / 2), 0) * CFrame.new(
				0,
				0,
				-5
			),
			bottomLeft = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), math.rad(v2 / 2), 0) * CFrame.new(
				0,
				0,
				-5
			),
			bottomRight = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), -math.rad(v2 / 2), 0) * CFrame.new(
				0,
				0,
				-5
			)
		}
		local magnitude = (v3.topLeft.Position - v3.topRight.Position).magnitude
		local magnitude2 = (v3.topLeft.Position - v3.bottomLeft.Position).magnitude
		local currentCamera = Workspace.CurrentCamera
		local clone = angelBeam.CameraFocus:Clone()
		clone.Size = Vector3.new(magnitude, magnitude2, magnitude)
		clone.Parent = parent2
		destroyAfter(clone, 7)
		local renderSteppedConnection = nil
		local v4 = time()
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not (time() - v4 > 7) then
				clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 0)
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v5 = descendant
				task.spawn(function()
					if v5.Name == "Beam" then
						v5.TextureSpeed = 1
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								TextureSpeed = 7
							}
						)
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
							TextureSpeed = 0
						}):Play()
						task.wait(0.25)

						for i = 0, 10 do
							v5.Transparency = NumberSequence.new(i / 10, i / 10)
							task.wait(0.025)
						end
					elseif v5.Name == "Beam2" then
						task.wait(0.5)
						v5.TextureSpeed = 1
						task.spawn(function()
							for i = 10, 0, -1 do
								v5.Transparency = NumberSequence.new(i / 10, i / 10)
								task.wait(0.025)
							end
						end)
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								TextureSpeed = 7
							}
						)
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
							TextureSpeed = 0
						}):Play()
					end
				end)
			elseif descendant:IsA("Attachment") then
				local v5 = descendant
				task.spawn(function()
					if v5.Name == "Attach_1A" then
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Position = v5.Position
							}
						)
						v5.Position = v5.Parent.Attach_0A.Position
						task.wait(math.random(20, 50) / 100)
						tween:Play()
					end
				end)
			end
		end

		Util.Sound:Play("AngelXChains", clone, nil, 0.9 + math.random(-15, 15) / 100, 0.35)
		task.wait(lastsFor)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v5 = descendant
				task.spawn(function()
					if v5.Name == "Beam2" then
						for i = 0, 50 do
							v5.Transparency = NumberSequence.new(i / 50)
							task.wait(0.015)
						end
					end
				end)
			elseif descendant:IsA("Attachment") then
				local v5 = descendant
				task.spawn(function()
					if v5.Name == "Attach_1A" then
						TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = v5.Parent.Attach_0A.Position
						}):Play()
					end
				end)
			end
		end

		task.wait(1)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end