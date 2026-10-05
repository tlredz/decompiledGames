local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
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
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

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

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	local parent = _WorldOrigin
	local origin = data.origin
	local targetPos = data.targetPos
	local projectileRadius = data.projectileRadius
	local magnitude = (targetPos - origin).Magnitude

	local function GetSpiralCFrame(p, p2, p3, p4, p5)
		local v2 = p.LookVector * p5 * magnitude
		local v3 = math.sin(p2 * 0.5) * p3
		local v4 = math.cos(p2 * 0.5) * p3
		local v5 = p + v2

		if p4 then
			v3 = -v3 or v3
		end

		if p4 then
			v4 = -v4 or v4
		end

		return v5 * CFrame.new(v3, v4, 0)
	end

	local function GetSpiralMovementCFrame(p, p2, p3, p4, p5)
		local v2 = p.LookVector * p5 * magnitude
		local v3 = math.sin(p2 * 0.5) * p3
		local v4 = math.cos(p2 * 0.5) * p3
		local v5 = p + v2

		if p4 then
			v3 = -v3 or v3
		end

		if p4 then
			v4 = -v4 or v4
		end

		local v6 = v5 * CFrame.new(v3, v4, 0)
		local v7 = p2 + 0.05
		local v8 = p.LookVector * p5 * magnitude
		local v9 = math.sin(v7 * 0.5) * p3
		local v10 = math.cos(v7 * 0.5) * p3
		local v11 = p + v8

		if p4 then
			v9 = -v9 or v9
		end

		if p4 then
			v10 = -v10 or v10
		end

		local v12 = v11 * CFrame.new(v9, v10, 0)
		return CFrame.lookAt(v6.Position, v12.Position)
	end

	local cframe = CFrame.new(origin, targetPos)
	local clone = FX:WaitForChild("DragonTrident")["Sea Dragon Fury"]:Clone()
	local clone2 = FX:WaitForChild("DragonTrident")["Sea Dragon Fury"]:Clone()
	local clone3 = FX:WaitForChild("DragonTrident").BigMidCast:Clone()
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Changed:Connect(function()
		clone:PivotTo(cFrameValue.Value)
	end)
	destroyAfter(cFrameValue, 7)
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Changed:Connect(function()
		clone2:PivotTo(cFrameValue2.Value)
	end)
	destroyAfter(cFrameValue2, 7)
	local _ = (targetPos - origin).Magnitude
	local v2 = cframe.LookVector * 0 * magnitude
	local v3 = 0 * projectileRadius
	local v4 = 1 * projectileRadius
	local v5 = (cframe + v2) * CFrame.new(v3, v4, 0)
	local v6 = cframe.LookVector * 0 * magnitude
	local v7 = 0.024997395914712332 * projectileRadius
	local v8 = 0.9996875162757026 * projectileRadius
	local v9 = (cframe + v6) * CFrame.new(v7, v8, 0)
	cFrameValue.Value = CFrame.lookAt(v5.Position, v9.Position)
	local v10 = cframe.LookVector * 0 * magnitude
	local v11 = 0 * projectileRadius
	local v12 = 1 * projectileRadius
	local v13 = (cframe + v10) * CFrame.new(-v11 or v11, -v12 or v12, 0)
	local v14 = cframe.LookVector * 0 * magnitude
	local v15 = 0.024997395914712332 * projectileRadius
	local v16 = 0.9996875162757026 * projectileRadius
	local v17 = (cframe + v14) * CFrame.new(-v15 or v15, -v16 or v16, 0)
	cFrameValue2.Value = CFrame.lookAt(v13.Position, v17.Position)
	clone3.CFrame = cframe * CFrame.new(0, 0, -10)
	clone.Parent = parent
	destroyAfter(clone, 7)
	clone2.Parent = parent
	destroyAfter(clone2, 7)
	clone3.Parent = parent
	EmitAll(clone3)
	AllVFX({ clone, clone2 }, true)
	destroyAfter(clone3, 2)
	local v18 = Util.Sound:Play("SharkmanX2", clone2)
	heartbeatLoopFor2(data.fliesFor, function(p, _, p2)
		local v19 = cframe
		local v20 = p * 40
		local projectileRadius2 = projectileRadius
		local v22 = v19.LookVector * p2 * magnitude
		local v23 = math.sin(v20 * 0.5) * projectileRadius2
		local v24 = math.cos(v20 * 0.5) * projectileRadius2
		local v25 = (v19 + v22) * CFrame.new(v23, v24, 0)
		local v26 = v20 + 0.05
		local v27 = v19.LookVector * p2 * magnitude
		local v28 = math.sin(v26 * 0.5) * projectileRadius2
		local v29 = math.cos(v26 * 0.5) * projectileRadius2
		local v30 = (v19 + v27) * CFrame.new(v28, v29, 0)
		cFrameValue.Value = CFrame.lookAt(v25.Position, v30.Position)
		local v31 = cframe
		local v32 = p * 40
		local projectileRadius3 = projectileRadius
		local v34 = v31.LookVector * p2 * magnitude
		local v35 = math.sin(v32 * 0.5) * projectileRadius3
		local v36 = math.cos(v32 * 0.5) * projectileRadius3
		local v37 = (v31 + v34) * CFrame.new(-v35 or v35, -v36 or v36, 0)
		local v38 = v32 + 0.05
		local v39 = v31.LookVector * p2 * magnitude
		local v40 = math.sin(v38 * 0.5) * projectileRadius3
		local v41 = math.cos(v38 * 0.5) * projectileRadius3
		local v42 = (v31 + v39) * CFrame.new(-v40 or v40, -v41 or v41, 0)
		cFrameValue2.Value = CFrame.lookAt(v37.Position, v42.Position)
	end, function()
		if (Workspace.CurrentCamera.CFrame.Position - targetPos).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(10, 14, 0.2, 1.2)
		end

		Util.Sound:FadeOut(v18, 1.5)
		Util.Sound:Play("WaterSplash4", targetPos)
		local clone4 = FX:WaitForChild("DragonTrident").ShootExplosion:Clone()
		clone4.CFrame = CFrame.new(targetPos, origin)
		clone4.Parent = parent
		EmitAll(clone4)
		destroyAfter(clone4, 3)
		AllVFX({ clone, clone2 }, false)
		local a004 = clone:FindFirstChild("a.004")
		destroyAfter(clone, 3)
		local a0042 = clone2:FindFirstChild("a.004")
		destroyAfter(clone2, 3)

		if a004 then
			local tween = TweenService:Create(a004, TweenInfo.new(0.5), {
				Transparency = 1
			})
			tween:Play()
			tween:Destroy()
		end

		if a0042 then
			local tween = TweenService:Create(a0042, TweenInfo.new(0.5), {
				Transparency = 1
			})
			tween:Play()
			tween:Destroy()
		end

		for i = 1, 16 do
			local clone5 = FX:WaitForChild("DragonTrident").Mesh.Sphere:Clone()
			clone5.CFrame = CFrame.new(targetPos, origin) * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			clone5.CFrame *= CFrame.new(0, math.random(20, 30), 0)
			clone5.Size = Vector3.new(2, math.random(72, 108), 2)
			clone5.Color = i % 2 == 0 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(38, 136, 255)
			clone5.Parent = parent
			local tween = TweenService:Create(clone5, TweenInfo.new(0.2), {
				Size = Vector3.new(0, math.random(18, 36), 0),
				CFrame = clone5.CFrame * CFrame.new(0, math.random(20, 40), 0)
			})
			tween:Play()
			tween:Destroy()
			destroyAfter(clone5, 0.2)
		end

		local clone5 = FX:WaitForChild("DragonTrident").Mesh.Sphere:Clone()
		clone5.CFrame = CFrame.new(targetPos, origin)
		clone5.Size = createVector(1, 1, 1)
		clone5.Material = Enum.Material.ForceField
		clone5.Parent = parent
		local tween = TweenService:Create(clone5, TweenInfo.new(0.15), {
			Size = createVector(120, 120, 120),
			Transparency = 1
		})
		tween:Play()
		tween:Destroy()
		destroyAfter(clone5, 0.15)
		local clone6 = FX:WaitForChild("DragonTrident").Mesh.Swirl:Clone()
		clone6.CFrame = CFrame.new(targetPos, origin)
		clone6.Size = createVector(60, 15, 60)
		clone6.Parent = parent
		local tween2 = TweenService:Create(clone6, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			Size = createVector(120, 60, 120),
			Transparency = 1,
			CFrame = clone6.CFrame * CFrame.Angles(0, -3.490658503988659, 0)
		})
		tween2:Play()
		tween2:Destroy()
		destroyAfter(clone6, 0.4)
		local clone7 = FX:WaitForChild("DragonTrident").Mesh.Wind:Clone()
		clone7.CFrame = CFrame.new(targetPos, origin)
		clone7.Size = createVector(60, 5, 60)
		clone7.Parent = parent
		local tween3 = TweenService:Create(clone7, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			Size = createVector(120, 5, 120),
			Transparency = 1,
			CFrame = clone7.CFrame * CFrame.Angles(0, -3.490658503988659, 0)
		})
		tween3:Play()
		tween3:Destroy()
		destroyAfter(clone7, 0.4)
	end)
end