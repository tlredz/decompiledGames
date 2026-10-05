local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local revive = FX:WaitForChild("Revive")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
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

local function haltUntilCondition(fn, value: number?)
	local v = value or 10
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(fn)

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

return function(data)
	local player = data.player
	local TryGetColorFolderParent = require(game.ReplicatedStorage.Modules.TryGetColorFolderParent)
	local tryGetColorFolderParent = TryGetColorFolderParent(data)
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir

	if parent:FindFirstChild("ItemsTableFolder") == nil then
		local folder = Instance.new("Folder")
		folder.Name = "ItemsTableFolder"
		folder.Parent = parent
	end

	local parent2 = hrp.Parent
	local parent3 = hrp.Parent
	local lowerTorso = parent3:FindFirstChild("LowerTorso")
	local v2 = {
		[parent3] = {}
	}
	v2[parent3].Body = {}
	v2[parent3].Trail = {}
	local clone = revive["Wandering Soul"].FlightVFX:Clone()
	clone.CFrame = lowerTorso.CFrame
	Util.SetParentOverrideWithColor(clone, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	AllVFX(clone, true)
	Weld(clone, lowerTorso, lowerTorso.CFrame)
	Effect.new("Revive2.Ghostify"):replicate({
		player = player,
		summoner = data.summoner,
		hrp = hrp,
		Duration = 0.1,
		HideEffect = true,
		Enabled = true,
		F = true
	})

	for i = 1, 4 do
		local clone2 = revive["Wandering Soul"].GhostTrail:Clone()
		clone2.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone2, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
		local total = 0
		local v6 = 5 + random:NextNumber(0, 5)
		local v7 = i * 1.5707963267948966
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt * 8
			clone2.CFrame = hrp.CFrame * CFrame.new(v6 * math.sin(total + v7), v6 * math.cos(total + v7), 0)
		end)
		table.insert(v2[parent3].Trail, {
			Trail = clone2,
			Connection = heartbeatConnection
		})
	end

	local v3, v4

	if player == localPlayer then
		v3 = Util.BodyMover.new(parent):Create("BodyVelocity", {
			Priority = 100,
			Velocity = createVector(0, 0, 0)
		})
		v3:SetForce(createVector(800000, 800000, 800000))
		v4 = Util.BodyMover.new(parent):Create("BodyGyro", {
			Priority = 100,
			CFrame = hrp.CFrame
		})
		v4:SetForce(createVector(800000, 800000, 800000))
	else
		v4 = nil
		v3 = nil
	end

	local cFrame = hrp.CFrame
	sound:Play("Ghost.ReviveFruitFIntro", cFrame.Position)
	local v5 = sound:Play("Ghost.ReviveFruitFAmb", clone)
	local lastTime = tick()
	haltUntilCondition(function()
		local v6 = tick() - lastTime
		local v7 = math.min(1, v6 / data.HoldTime)
		local v8 = data.FlightSpeed * ((1 - v7) * 2 + 1) * math.max(
			0.7,
			1 - (1 - humanoid.Health / humanoid.MaxHealth) * 0.3
		)
		local v9 = Mouse.Hit.p - hrp.Position
		local unit = v9.Magnitude >= 1 and v9.Unit or hrp.CFrame.LookVector

		if v4 then
			v4:Set(CFrame.new(createVector(0, 0, 0), unit))
		end

		if v3 then
			v3:Set(unit * v8)
		end

		cFrame = hrp.CFrame
		return data.HoldTime < v6 and not (data.skillFActive.Value and data.Holding.Value) or not hrp:IsDescendantOf(Workspace) or humanoid.Health <= 0 or humanoid.SeatPart ~= nil
	end, 10000000000)

	for _, v6 in v2[parent3].Trail do
		v6.Connection:Disconnect()
		AllVFX(v6.Trail, false)
		destroyAfter(v6.Trail, 2)
		v2[parent3].Trail[v6] = nil
	end

	sound:FadeOut(v5, 0.5)
	sound:Play("Ghost.ReviveFruitFIntro", cFrame.Position, nil, 2)
	AllVFX(clone, false)
	destroyAfter(clone, 3)
	Effect.new("Revive2.Ghostify"):replicate({
		player = player,
		summoner = data.summoner,
		hrp = hrp,
		Duration = 0.1,
		HideEffect = true,
		Enabled = false,
		F = false
	})

	if v4 then
		v4:Destroy()
	end

	if v3 then
		v3:Destroy()
	end

	hrp.Velocity = Vector3.new()
	hrp.RotVelocity = Vector3.new()
	hrp.CFrame = cFrame
	v2[parent3].Body = nil
	v2[parent3] = nil
end