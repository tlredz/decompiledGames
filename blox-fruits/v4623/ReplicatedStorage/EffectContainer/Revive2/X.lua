local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local revive = FX:WaitForChild("Revive")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
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
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
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
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
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

function EmitAll(items)
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

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function QuadBezier(p, p2, p3, p4)
	local v = p2 + (p3 - p2) * p
	return v + (p3 + (p4 - p3) * p - v) * p
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

function Weld(p, part, cFrame, name)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Part1.CFrame = cFrame
	weldConstraint.Parent = p
	destroyAfter(weldConstraint, 7)

	if name then
		weldConstraint.Name = name
	end
end

function LightOut(folder, duration)
	for _, light in ipairs(folder:GetDescendants()) do
		if light:IsA("PointLight") or light:IsA("SpotLight") then
			TweenService:Create(light, TweenInfo.new(duration), {
				Brightness = 0,
				Range = 0
			}):Play()
		end
	end
end

function LightUp(folder, duration, duration2)
	for _, light in ipairs(folder:GetDescendants()) do
		if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
			continue
		end

		local brightness = light.Brightness
		local brightness2 = light.Brightness
		light.Brightness = 0
		light.Range = 0
		TweenService:Create(light, TweenInfo.new(duration), {
			Brightness = brightness,
			Range = brightness2
		}):Play()
	end

	if duration2 then
		task.delay(duration2, function()
			LightOut(folder, duration)
		end)
	end
end

function AutoBeam(folder, duration, duration2)
	for _, beam in ipairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local width0 = beam.Width0
		local width1 = beam.Width1
		beam.Width0 = 0
		beam.Width1 = 0
		TweenService:Create(beam, TweenInfo.new(duration), {
			Width0 = width0,
			Width1 = width1
		}):Play()

		if not duration2 then
			continue
		end

		local v = beam
		task.delay(duration2, function()
			TweenService:Create(v, TweenInfo.new(duration), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
	end
end

function KillBeam(folder, duration)
	for _, beam in ipairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			TweenService:Create(beam, TweenInfo.new(duration), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end
end

function Flipbook(p, list, p2: number)
	if p and list then
		task.spawn(function()
			for i = 1, #list do
				p.TextureId = list[i]
				task.wait(1 / p2)
			end
		end)
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

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

local function RecolorGhostColor(instance, p)
	if instance == nil or typeof(instance) ~= "Instance" or instance.Parent == nil then
		return p
	end

	return Util.WrapColor3Constructor(p, instance, "GhostFruitVFXColor")
end

local clone = revive["Soul Ruler"]:Clone()
clone.Parent = script

-- equivalent calls inferred from this helper; original call sites unknown
local function fn(p, p2)
	return random:NextNumber(p, p2)
end

local function fn2(p, position, position2, position3, position4)
	local v = position + (position2 - position) * p
	local v2 = position2 + (position3 - position2) * p
	local v3 = position3 + (position4 - position3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

for _, emitter in pairs(clone:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.Misc.ScaleParticle(emitter, 1.5)
	end
end

local function getAlternateColor(instance)
	local color = Color3.fromRGB(64, 255, 153)

	if instance then
		local success, result = pcall(function(...)
			local ghostFruitVFXColor = instance:FindFirstChild("GhostFruitVFXColor")

			if ghostFruitVFXColor and ghostFruitVFXColor:GetAttribute("StorageKey") == "GHOSTSKINred" then
				color = Color3.fromRGB(255, 0, 0)
			end
		end)

		if not success then
			warn(result)
		end
	end

	return color
end

return function(data)
	local TryGetColorFolderParent = require(game.ReplicatedStorage.Modules.TryGetColorFolderParent)
	local tryGetColorFolderParent = TryGetColorFolderParent(data)
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local position = cFrame.Position
	local _ = data.fireDir
	local position2 = cFrame.Position
	local v2 = 8
	local v3 = 18 or 14
	local v4 = 0.2
	local v5 = 0.4 or 0.7

	if (100 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
		Util.CameraShaker:ShakeOnce(v2, v3, v4, v5)
	end

	local parent2 = _WorldOrigin
	local cframe = CFrame.new(position)
	local _ = cframe.Position
	local cFrame3 = cframe * CFrame.new(0, -parent.UpperTorso.Size.Y - 0.5, 0)
	local raycastResult = Workspace:Raycast(cframe.Position, createVector(-0, -10, -0), raycastParams)

	if raycastResult then
		local position3 = raycastResult.Position
		local normal = raycastResult.Normal
		cFrame3 = Util.Misc.AlignCFrame(cFrame3 - cFrame3.p + position3, normal) + normal
	end

	local v8 = Workspace:GetServerTimeNow() - data.Timestamp
	local delayUntilFinalBurst = data.delayUntilFinalBurst
	local v9 = math.max(0.01, delayUntilFinalBurst - v8)
	local _ = v8 - (delayUntilFinalBurst - v9)
	sound:Play("Ghost.ReviveFruitX", cFrame3.Position)
	local clone2 = clone.Action:Clone()
	clone2.CFrame = cFrame3
	Util.SetParentOverrideWithColor(clone2, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	AllVFX(clone2, true, v9 + 0.05)
	destroyAfter(clone2, 4)
	local clone3 = clone["Part ( Emit )"]:Clone()
	clone3.CFrame = cFrame3
	Util.SetParentOverrideWithColor(clone3, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	EmitAll(clone3)
	destroyAfter(clone3, 3)
	local v10 = false
	local clone4 = clone.SpinMesh:Clone()
	clone4.CFrame = cFrame3 * CFrame.new(0, 2.5, 0)
	clone4.Size = createVector(90, 7.5, 90)
	Util.SetParentOverrideWithColor(clone4, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone4, 7)
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		if clone4:IsDescendantOf(Workspace) then
			clone4.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
		else
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end)
	local clone5 = nil
	local v11 = nil

	for i = 1, 25 do
		local v12 = i
		task.spawn(function()
			v10 = not v10
			local clone6 = clone.Trail:Clone()
			clone6.CFrame = cFrame3 * CFrame.new(Vector3.new(random:NextNumber(-20, 20), -2, fn(-20, 20)) * 1.5)
			Util.SetParentOverrideWithColor(clone6, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
			destroyAfter(clone6, 7)
			local cFrame2 = clone6.CFrame
			local v13 = clone6.CFrame * CFrame.new(Vector3.new(
				random:NextNumber(-60, 60),
				random:NextNumber(20, 35),
				fn(-60, 60)
			) * 1.5)
			local total = 0
			local v14 = fn(1.5, 3) -- equivalent call inferred; original call site unknown
			local v15 = random:NextNumber(-30, 30) * 1.5 * (v10 and 1 or -1)
			local v16 = v15 * -1
			local v17 = random:NextNumber(-30, 30) * 1.5 * (v10 and 1 or -1)
			local v18 = v17 * -1
			local position3 = (CFrame.lookAt(clone6.Position:Lerp(v13.Position, 0.25), v13.Position) * CFrame.new(
				v17 * 2,
				v15,
				0
			)).Position
			local position4 = (CFrame.lookAt(clone6.Position:Lerp(v13.Position, 0.75), v13.Position) * CFrame.new(
				v18 * 2,
				v16,
				0
			)).Position
			local renderSteppedConnection2 = nil
			renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
				if total >= 1 or not clone6:IsDescendantOf(Workspace) then
					clone6.Position = v13.Position
					AllVFX(clone6, false)
					destroyAfter(clone6, 1)
					renderSteppedConnection2:Disconnect()
				else
					total += dt * v14

					if total > 0.5 then
						v14 -= dt * 2
					end

					clone6.GhostTrail.TrailTrail.Trail.Transparency = NumberSequence.new(total, total)
					local v19 = fn2(total, cFrame2.Position, position3, position4, v13.Position)

					if total < 1 then
						clone6.CFrame = CFrame.new(
							v19,
							(fn2(total + 0.01, cFrame2.Position, position3, position4, v13.Position))
						)
					end
				end
			end)
			clone5 = revive.Sphere:Clone()
			clone5.Size = Vector3.new(1, math.random(48, 72), 1) * 1.5
			clone5.CFrame = cFrame3 * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				(math.rad((math.random(-90, 90))))
			) * CFrame.new(0, clone5.Size.Y / 2, 0)
			local v19 = clone5
			local tryGetColorFolderParent2 = tryGetColorFolderParent
			local color = v12 % 2 == 0 and Color3.fromRGB(0, 0, 0) or getAlternateColor(tryGetColorFolderParent)

			if tryGetColorFolderParent2 ~= nil and typeof(tryGetColorFolderParent2) == "Instance" and tryGetColorFolderParent2.Parent ~= nil then
				color = Util.WrapColor3Constructor(color, tryGetColorFolderParent2, "GhostFruitVFXColor")
			end

			v19.Color = color
			clone5.Parent = parent2
			v11 = TweenService:Create(clone5, TweenInfo.new(0.25), {
				Size = Vector3.new(0, math.random(3, 9), 0),
				CFrame = clone5.CFrame * CFrame.new(0, math.random(-18, 18) * 1.5, 0)
			})
			v11:Play()
			v11:Destroy()
			destroyAfter(clone5, 0.25)
		end)
		task.wait(v9 / 25)
	end

	local position3 = cFrame.Position
	local v12 = 8
	local v13 = 18 or 14
	local v14 = 0.2
	local v15 = 0.4 or 0.7

	if (125 or 300) > (Workspace.CurrentCamera.CFrame.Position - position3).Magnitude then
		Util.CameraShaker:ShakeOnce(v12, v13, v14, v15)
	end

	TweenService:Create(clone4, TweenInfo.new(0.15), {
		Size = createVector(180, 6, 144),
		Transparency = 1
	}):Play()
	destroyAfter(clone4, 0.15)
	local clone6 = clone.Shock:Clone()
	clone6.CFrame = cFrame3
	Util.SetParentOverrideWithColor(clone6, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	EmitAll(clone6)
	destroyAfter(clone6, 3)
	clone5 = revive.Sphere:Clone()
	clone5.CFrame = cFrame3
	clone5.Size = createVector(1, 1, 1)
	clone5.Material = Enum.Material.ForceField
	Util.SetParentOverrideWithColor(clone5, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	v11 = TweenService:Create(clone5, TweenInfo.new(0.15), {
		Size = createVector(144, 144, 144),
		Transparency = 1
	})
	v11:Play()
	v11:Destroy()
	destroyAfter(clone5, 0.15)
	local clone7 = clone.Wind:Clone()
	clone7.CFrame = cFrame3 * CFrame.new(0, 2.5, 0)
	clone7.Size = createVector(90, 20, 90)
	Util.SetParentOverrideWithColor(clone7, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	TweenService:Create(clone7, TweenInfo.new(0.15), {
		Size = createVector(144, 48, 144),
		Transparency = 1
	}):Play()
	destroyAfter(clone7, 0.15)
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(_)
		if clone7:IsDescendantOf(Workspace) then
			clone7.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
		else
			renderSteppedConnection2:Disconnect()
			renderSteppedConnection2 = nil
		end
	end)

	for i = 1, 16 do
		clone5 = revive.Sphere:Clone()
		clone5.Size = Vector3.new(1, math.random(64, 96) * 1.5, 1)
		clone5.CFrame = cFrame3 * CFrame.Angles(
			math.rad((math.random(-90, 90))),
			math.rad((math.random(-90, 90))),
			(math.rad((math.random(-90, 90))))
		) * CFrame.new(0, clone5.Size.Y / 2, 0)
		local color = i % 2 == 0 and Color3.fromRGB(0, 0, 0) or getAlternateColor(tryGetColorFolderParent)

		if tryGetColorFolderParent ~= nil and typeof(tryGetColorFolderParent) == "Instance" and tryGetColorFolderParent.Parent ~= nil then
			color = Util.WrapColor3Constructor(color, tryGetColorFolderParent, "GhostFruitVFXColor")
		end

		clone5.Color = color
		clone5.Parent = parent2
		v11 = TweenService:Create(clone5, TweenInfo.new(0.25), {
			Size = Vector3.new(0, math.random(4, 12) * 1.5, 0),
			CFrame = clone5.CFrame * CFrame.new(0, math.random(-24, 24) * 1.5, 0)
		})
		v11:Play()
		v11:Destroy()
		destroyAfter(clone5, 0.25)
	end
end