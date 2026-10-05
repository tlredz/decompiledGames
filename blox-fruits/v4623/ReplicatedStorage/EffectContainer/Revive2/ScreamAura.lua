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
local revive = FX:WaitForChild("Revive")
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

return function(data)
	local TryGetColorFolderParent = require(game.ReplicatedStorage.Modules.TryGetColorFolderParent)
	local tryGetColorFolderParent = TryGetColorFolderParent(data)
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 400 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local parent = _WorldOrigin
	local victimAuraDuration = data.victimAuraDuration
	local victimRoot = data.victimRoot

	if not (victimRoot and victimRoot.Parent) then
		return
	end

	local clone = revive.Skill_4.GhostHitVFX:Clone()
	clone.CFrame = victimRoot.CFrame
	Util.SetParentOverrideWithColor(clone, parent, tryGetColorFolderParent, "GhostFruitVFXColor")
	EmitAll(clone)
	destroyAfter(clone, 4)
	local v3 = {}

	for _, child in revive.Skill_4.AuraCharacter.UpperTorso:GetChildren() do
		local clone2 = child:Clone()
		Util.SetParentOverrideWithColor(
			clone2,
			victimRoot.Parent.UpperTorso,
			tryGetColorFolderParent,
			"GhostFruitVFXColor"
		)
		destroyAfter(clone2, 7)

		if clone2:IsA("Attachment") then
			if typeof(victimAuraDuration) == "number" then
				AllVFX(clone2, true, victimAuraDuration)
				destroyAfter(clone2, victimAuraDuration + 2)
			else
				AllVFX(clone2, true)
				destroyAfter(clone2, 10)
			end

			table.insert(v3, clone2)
		end

		if not clone2:IsA("ParticleEmitter") then
			continue
		end

		clone2.Enabled = true
		table.insert(v3, clone2)
	end

	if typeof(victimAuraDuration) == "number" then
		task.wait(victimAuraDuration)
	elseif typeof(victimAuraDuration) == "Instance" then
		local lastTime = tick()

		while victimAuraDuration:IsDescendantOf(Workspace) and not (tick() - lastTime > 10) do
			task.wait(0.016666666666666666)
		end
	end

	for k, instance in pairs(v3) do
		if instance:IsA("Attachment") then
			AllVFX(instance, false)
		end

		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
		end

		v3[k] = nil
	end

	local clone2 = revive.Skill_4.PossessionDisable:Clone()
	clone2.CFrame = CFrame.new(victimRoot.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
	Util.SetParentOverrideWithColor(clone2, parent, tryGetColorFolderParent, "GhostFruitVFXColor")
	EmitAll(clone2)
	destroyAfter(clone2, 2)
end