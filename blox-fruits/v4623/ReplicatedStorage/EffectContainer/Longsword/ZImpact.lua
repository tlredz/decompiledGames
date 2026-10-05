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

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

local function Rocks(data)
	local folder = Instance.new("Folder")
	folder.Name = "rockmodule_Eff_folder"
	folder.Parent = _WorldOrigin
	destroyAfter(folder, 5)

	for i = 1, data.amount do
		local part = Instance.new("Part")
		part.CastShadow = false
		part.Size = createVector(0.5, 0.5, 0.5)
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = true
		part.CFrame = data.origin * CFrame.fromOrientation(0, math.rad(360 / data.amount * i), 0) * CFrame.new(
			0,
			0,
			data.offset - data.offset / 2
		)
		part.Parent = folder
		local raycastResult = Workspace:Raycast(
			data.origin * CFrame.Angles(0, math.rad(360 / data.amount * i), 0) * CFrame.new(0, 0, data.offset).Position + createVector(
				0,
				10,
				0
			),
			createVector(0, -20, 0),
			raycastParams
		)

		if raycastResult then
			part.Color = raycastResult.Instance.Color
			part.Material = raycastResult.Material
			TweenService:Create(part, TweenInfo.new(data.tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(
					math.random(data.size[1] - data.size[1] / 3.5, data.size[1]),
					math.random(data.size[2] - data.size[2] / 3.5, data.size[2]),
					math.random(data.size[3] - data.size[3] / 3.5, data.size[3])
				),
				CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(
					0,
					math.rad(360 / data.amount * i),
					0
				) * CFrame.Angles(math.rad((math.random(-65, -45))), 0, 0)
			}):Play()
			local v = part
			coroutine.wrap(function()
				task.wait(data.tweenTime + data.waitTime)
				local tween = TweenService:Create(
					v,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = v.Position - Vector3.new(0, data.size[2], 0)
					}
				)
				tween.Completed:Connect(function()
					v:Destroy()
				end)
				tween:Play()
			end)()
		else
			part:Destroy()
		end
	end
end

TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
return function(data)
	local currentCamera = Workspace.CurrentCamera

	if (data.origin - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local _ = data.instance
	local origin = data.origin
	local normal = data.normal
	local v = 8
	local v2 = 14
	local v3 = 0.3 or 0.2
	local v4 = 0.7

	if (90 or 300) > (Workspace.CurrentCamera.CFrame.Position - origin).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end

	local Z = FX:WaitForChild("Longsword").Z
	local cFrame = Util.Misc.AlignCFrame(CFrame.new(origin), normal) + normal * 0.03
	Util.Sound:Play("TremorWave1", cFrame, 25)
	Util.Sound:Play("sSlowImpact", cFrame, 25)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	destroyAfter(folder, 10)
	local vineExplosion = Z.VineExplosion
	local clone = vineExplosion.Vine:Clone()
	clone:SetPrimaryPartCFrame(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0))
	clone.Parent = folder

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local v7 = part
		task.spawn(function()
			local tween = TweenService:Create(
				v7,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = v7.Size,
					CFrame = v7.CFrame
				}
			)
			v7.Size = createVector(0, 0, 0)
			v7.CFrame = v7.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
			tween:Play()
			task.wait(1.5)
			TweenService:Create(v7, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(64, 67, 51)
			}):Play()
			task.wait(1.5)
			TweenService:Create(v7, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(23, 24, 18),
				CFrame = v7.CFrame * CFrame.new(0, -30, 0) * CFrame.Angles(0, -2.9670597283903604, 0)
			}):Play()
		end)
	end

	local flowers = vineExplosion.Flowers
	local flowerA = nil

	for i = 1, 3 do
		if i == 1 then
			flowerA = flowers.FlowerA
		elseif i == 2 then
			flowerA = flowers.FlowerB
		elseif i == 3 then
			flowerA = flowers.FlowerC
		end

		for _ = 1, 10 do
			local v7 = cFrame * CFrame.new(math.random(-25, 25), 0, math.random(-25, 25)) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			local clone2 = flowerA:Clone()
			clone2:SetPrimaryPartCFrame(v7)
			clone2.Parent = folder

			for _, part in pairs(clone2:GetChildren()) do
				if not part:IsA("MeshPart") then
					continue
				end

				local v8 = part
				task.spawn(function()
					local tween = TweenService:Create(
						v8,
						TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = v8.Size,
							CFrame = v8.CFrame
						}
					)
					v8.Size = createVector(0, 0, 0)
					task.wait(math.random(10, 100) / 200)
					tween:Play()
				end)
			end

			task.spawn(function()
				task.wait(1.5)
				task.wait(math.random(10, 100) / 200)

				for i2, part in pairs(clone2:GetChildren()) do
					if not part:IsA("MeshPart") then
						continue
					end

					local v9 = part
					task.spawn(function()
						TweenService:Create(
							v9,
							TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Color = Color3.fromRGB(64, 67, 51)
							}
						):Play()
						task.wait(1.5)
						TweenService:Create(
							v9,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Color = Color3.fromRGB(23, 24, 18),
								Size = createVector(0, 0, 0)
							}
						):Play()
					end)
				end
			end)
		end
	end

	local clone2 = vineExplosion.GrassImpact:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone3 = vineExplosion.LandImpact:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
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

	task.wait(2.7)
	local clone4 = vineExplosion.GrassOut:Clone()
	clone4.CFrame = cFrame * CFrame.new(0, 15, 0)
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			v7.Enabled = true
			task.wait(0.35)
			v7.Enabled = false
		end)
	end
end