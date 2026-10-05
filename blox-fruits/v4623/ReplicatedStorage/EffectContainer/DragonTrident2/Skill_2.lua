local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
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
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function safeSetRootCFrame(instance, cFrame: CFrame, flag: boolean)
	local v = flag == nil or flag

	if instance == nil then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	if not v then
		instance.CFrame = cFrame
		return
	end

	local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

	if raycastResult then
		instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
	else
		instance.CFrame = cFrame
	end
end

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos"))
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1))
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function EmitAll(clone)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(clone) ~= "table" then
		Emit(clone)
		return
	end

	for _, item in clone do
		Emit(item)
	end
end

function AllVFX(items, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled
		end

		if duration then
			task.delay(duration, function()
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end)
		end
	end

	if typeof(items) ~= "table" then
		Emit(items, enabled2, p2)
		return
	end

	for _, item in items do
		Emit(item, enabled2, p2)
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local CraterModes = require(script.Parent:WaitForChild("CraterModes"))

local function fn(p, data)
	local function fn2(data2, range, vector2)
		local v = -data2.UpVector * range
		local raycastResult = Workspace:Raycast(data2.Position, v, raycastParams)
		local instance, position, material, normal

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
			material = raycastResult.Material
			normal = raycastResult.Normal
		else
			instance = false
		end

		if not instance then
			return
		end

		local cFrame = Util.Misc.AlignCFrame(data2 - data2.p + position, normal) + normal * 0.1
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Material = material
		part.Size = vector2
		part.Color = instance.Color
		part.Reflectance = instance.Reflectance
		part.Transparency = instance.Transparency
		part.CFrame = cFrame
		part.Parent = _WorldOrigin
		destroyAfter(part, 10)

		for _, child in ipairs(part:GetChildren()) do
			child:Destroy()
		end

		for _, texture in ipairs(instance:GetChildren()) do
			if not texture:IsA("Texture") then
				continue
			end

			local clone = texture:Clone()
			clone.Parent = part
		end

		return part, position, normal
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn3(p2, p3)
		return random:NextNumber(p2, p3)
	end

	local blockSize = data.BlockSize or { 2, 3.5 }
	local partCount = data.PartCount or 10
	local radius = data.Radius or 8
	local range = data.Range or 5
	local angle = data.Angle or { 45, 65 }
	local height = data.Height or { 0, 0 }
	local tilt = data.Tilt or { 0, 0 }
	local partOffset = data.PartOffset or { 0, 0 }
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local circleComplete = data.CircleComplete or 1
	local v = (function(p2, p3, p4, _)
		local result = {}

		for i = 1, p4 + 1 do
			local v2 = i * (6.283185307179586 / p4)
			result[i] = p2 * Vector3.new(math.cos(v2) * p3, 0, math.sin(v2) * p3)
		end

		return result
	end)(CFrame.identity, radius, partCount)
	local v2 = {}
	local v3 = 1

	for i = 1, math.floor(#v * circleComplete + 0.5) do
		if v[i + 1] == nil then
			continue
		end

		local v4 = v[i]
		local magnitude = (v4 - v[i + 1]).Magnitude
		local v7 = fn3(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local vector2 = Vector3.new(magnitude + 0.5, v7, v7)
		local v8 = math.atan2(-v4.X, -v4.Z)
		local v9, v10, v11 = fn2(p * CFrame.Angles(0, v8, 0) + v4, range, vector2)

		if not v9 then
			continue
		end

		local v14 = Util.Misc.AlignCFrame(CFrame.Angles(0, v8, 0) + v10, v11) * CFrame.new(
			0,
			random:NextNumber(height[1], height[2]),
			fn3(partOffset[1], partOffset[2])
		)
		local v15 = angle[1]
		local v16 = angle[2]
		local v17 = math.rad((random:NextNumber(v15, v16)))
		local v18 = tilt[1]
		local v19 = tilt[2]
		local v20 = {
			CFrame = v14 * CFrame.fromEulerAnglesXYZ(v17, math.rad((random:NextNumber(v18, v19))), 0)
		}
		local v21 = v9
		task.spawn(function()
			v2[#v2 + 1] = v21
		end)
		CraterModes[flourishTypes.Entrance or "Grow"](v9, flourishTypes.EntranceSpeed or 0.3, v20)

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision == "Iterate" then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end
		elseif math.floor((math.floor(#v * circleComplete + 0.5) - 1) * (v3 / (iterateSpeed.EntranceDivision or 3))) == i and i ~= math.floor(#v * circleComplete + 0.5) - 1 then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end

			v3 += 1
		end
	end

	task.wait(data.HoldTime or 5)
	local v4 = 1

	for i = 1, #v2 do
		CraterModes[flourishTypes.Exit or "Melt"](v2[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit then
			if iterateSpeed.ExitDivision == "Iterate" then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end
			elseif math.floor(#v2 * (v4 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v2 then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end

				v4 += 1
			end
		end

		destroyAfter(v2[i], (flourishTypes.ExitSpeed or 0.3) + 0.15)
	end
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
	local v2 = CFrame.lookAt(createVector(0, 0, 0), v) * inverse

	if typeof(folder) == "CFrame" then
		local position = folder.Position
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
		local v3

		if math.abs(Y) < 0.1 then
			v3 = position.Y
		else
			v3 = (dot - X2 * X - Z2 * Z) / Y
		end

		local vector2 = Vector3.new(X2, v3, Z2)
		local v4 = vector2 + v * (position.Y - vector2.Y)
		return v2 * folder.Rotation + v4
	else
		if typeof(folder) == "Instance" and folder:IsA("BasePart") then
			local position = folder.CFrame.Position
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
			local v3

			if math.abs(Y) < 0.1 then
				v3 = position.Y
			else
				v3 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v3, Z2)
			local v4 = vector2 + v * (position.Y - vector2.Y)
			folder.CFrame = v2 * folder.CFrame.Rotation + v4
		else
			if typeof(folder) ~= "Instance" or not folder:IsA("Model") then
				warn("alignWithGround: Failed to align with ground for object of type " .. typeof(folder))
				return
			end

			local pivot = folder:GetPivot()
			local position = pivot.Position
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
			local v3

			if math.abs(Y) < 0.1 then
				v3 = position.Y
			else
				v3 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v3, Z2)
			local v4 = vector2 + v * (position.Y - vector2.Y)
			folder:PivotTo(v2 * pivot.Rotation + v4)
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local parent = _WorldOrigin
	local multiplier = data.Multiplier
	local _ = data.Center
	local start = data.Start
	local goal = data.Goal
	local _ = data.Goal
	local clone = FX:WaitForChild("DragonTrident")["Dragon Head"]:Clone()
	clone:PivotTo(start)
	clone.Parent = parent
	destroyAfter(clone, 7)
	local position = (CFrame.lookAt(clone.PrimaryPart.Position:Lerp(goal.Position, 0.25), goal.Position) * CFrame.new(
		0,
		180,
		0
	)).Position
	local total = 0

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	local connection = nil
	connection = heartbeatLoopFor2(10, function(_, p)
		total += p * multiplier
		local v2 = total
		local position2 = start.Position
		local position6 = position
		local position3 = goal.Position
		local v4 = position2 + (position6 - position2) * v2
		local v5 = v4 + (position6 + (position3 - position6) * v2 - v4) * v2

		if total >= 1 then
			local position4 = clone.PrimaryPart.Position
			local v6 = 8
			local v7 = 8 or 14
			local v8 = 0.3 or 0.2
			local v9 = 0.3 or 0.7

			if (125 or 300) > (Workspace.CurrentCamera.CFrame.Position - position4).Magnitude then
				Util.CameraShaker:ShakeOnce(v6, v7, v8, v9)
			end

			Util.Sound:Play("WaterSplash4", clone.PrimaryPart.Position)
			local raycastResult = Workspace:Raycast(
				clone.PrimaryPart.Position,
				createVector(-0, -25, -0),
				raycastParams
			)
			AllVFX(clone, false)
			connection:Disconnect()
			local tween = TweenService:Create(clone["a.004"], TweenInfo.new(0.5), {
				Transparency = 1
			})
			tween:Play()
			tween:Destroy()
			destroyAfter(clone, 3)

			if raycastResult then
				local cFrame = Util.Misc.AlignCFrame(
					clone.PrimaryPart.CFrame - clone.PrimaryPart.Position + raycastResult.Position,
					raycastResult.Normal
				) + raycastResult.Normal * 0.5
				local clone2 = FX:WaitForChild("DragonTrident")["Water Explosion"]:Clone()
				clone2.CFrame = cFrame
				clone2.Parent = parent
				EmitAll(clone2)
				destroyAfter(clone2, 3)
				local clone3 = FX:WaitForChild("DragonTrident").Mesh.Ring:Clone()
				clone3.Size = createVector(90, 1, 90)
				clone3.CFrame = cFrame
				clone3.Parent = parent
				local tween2 = TweenService:Create(clone3, TweenInfo.new(0.25), {
					Size = createVector(120, 0, 120),
					Transparency = 1
				})
				tween2:Play()
				tween2:Destroy()
				destroyAfter(clone3, 0.25)
				local clone4 = FX:WaitForChild("DragonTrident").Mesh.Ring:Clone()
				clone4.Size = createVector(90, 2, 90)
				clone4.CFrame = cFrame
				clone4.Parent = parent
				local tween3 = TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(75, 0, 75),
					Transparency = 1,
					CFrame = clone4.CFrame * CFrame.new(0, 18, 0)
				})
				tween3:Play()
				tween3:Destroy()
				destroyAfter(clone4, 0.2)

				for i = 1, 8 do
					local clone5 = FX:WaitForChild("DragonTrident").Mesh.Sphere:Clone()
					clone5.Size = Vector3.new(1, math.random(72, 84), 1)
					clone5.Color = i % 2 == 0 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
					clone5.CFrame = cFrame * CFrame.Angles(
						math.rad((math.random(-70, 70))),
						math.rad((math.random(-70, 70))),
						(math.rad((math.random(-70, 70))))
					) * CFrame.new(0, clone5.Size.Y / 2, 0)
					clone5.Parent = parent
					local tween4 = TweenService:Create(clone5, TweenInfo.new(0.15), {
						Size = Vector3.new(0, math.random(0, 8), 0),
						CFrame = clone5.CFrame * CFrame.new(0, math.random(-6, 6), 0)
					})
					tween4:Play()
					tween4:Destroy()
					destroyAfter(clone5, 0.15)
				end

				local clone5 = FX:WaitForChild("DragonTrident").Mesh.Sphere:Clone()
				clone5.Size = createVector(4, 4, 4)
				clone5.CFrame = cFrame
				clone5.Parent = parent
				local tween4 = TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(0, 90, 0),
					CFrame = clone5.CFrame * CFrame.new(0, 45, 0)
				})
				tween4:Play()
				tween4:Destroy()
				destroyAfter(clone5, 0.2)
				fn(cFrame, {
					BlockSize = { 2.5, 3.5 },
					Radius = 30,
					Range = 100,
					PartCount = 15,
					IterateSpeed = {
						Entrance = "Stepped",
						EntranceDivision = "Iterate",
						Exit = "Stepped"
					},
					HoldTime = 1
				})
			end
		else
			local v7 = total + 0.01
			local position4 = start.Position
			local position7 = position
			local position5 = goal.Position
			local v9 = position4 + (position7 - position4) * v7
			clone:PivotTo(CFrame.new(v5, v9 + (position7 + (position5 - position7) * v7 - v9) * v7))
		end
	end)
end