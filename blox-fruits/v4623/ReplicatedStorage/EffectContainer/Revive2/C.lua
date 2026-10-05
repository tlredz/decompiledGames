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
local Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
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

return function(data)
	local DISTANCE_THRESHOLD = 1
	local player = data.player
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

	local v2 = Workspace:GetServerTimeNow() - data.Timestamp
	local origin = data.origin
	local fireDir = data.fireDir
	local holding = data.Holding
	local mousePos = data.MousePos

	if player == game.Players.LocalPlayer then
		local position = cFrame.Position
		local v3 = 10 or 8
		local v4 = 18 or 14
		local v5 = 0.2
		local v6 = 0.4 or 0.7

		if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v3, v4, v5, v6)
		end
	end

	local parent2 = _WorldOrigin
	local damageFor = data.damageFor
	local v4 = math.max(0.01, damageFor - v2)
	local _ = v2 - (damageFor - v4)
	local duration2 = data.Scene and 999 or v4
	local v6 = CFrame.lookAt(createVector(0, 0, 0), fireDir) + origin
	local v7

	if player == localPlayer then
		v7 = Util.BodyMover.new(parent):Create("BodyGyro", {
			Priority = 10,
			CFrame = CFrame.new(createVector(0, 0, 0), fireDir),
			Duration = duration2
		})
		v7:SetForce(createVector(800000, 800000, 800000))
	end

	local clone = revive.Scream.Scream:Clone()
	clone.CFrame = v6 * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	AllVFX(clone, true, duration2)
	destroyAfter(clone, duration2 + 2)
	local clone2 = revive.Scream.ScreanEmit:Clone()
	clone2.CFrame = clone.CFrame
	Util.SetParentOverrideWithColor(clone2, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	EmitAll(clone2)
	destroyAfter(clone2, duration2 + 2)
	local clone3 = revive.Scream.ScreamBeam:Clone()
	clone3:PivotTo(clone.CFrame)
	Util.SetParentOverrideWithColor(clone3, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	destroyAfter(clone3, duration2 + 2)
	local clone4 = revive.Scream.MouthPart:Clone()
	clone4.CFrame = v6 * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone4, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
	AllVFX(clone4, true, duration2)
	destroyAfter(clone4, duration2 + 2)

	for _, beam in clone3:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local width0 = beam.Width0
		local width1 = beam.Width1
		beam.Width0 = 0
		beam.Width1 = 0
		TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
			Width0 = width0,
			Width1 = width1
		}):Play()
	end

	local function ghost(data2)
		local clone5 = revive["Wandering Soul"].GhostTrail:Clone()
		clone5.CFrame = data2.getRootCFrame()
		Util.SetParentOverrideWithColor(clone5, parent2, tryGetColorFolderParent, "GhostFruitVFXColor")
		local length = data2.Length or 10
		local radius = data2.Radius or 10
		local speed = data2.Speed or random:NextNumber(4, 8)
		local duration = data2.Duration or 1
		clone5.Trails.Position *= random:NextNumber(1, 2)
		clone5.Trails.Attachment.Position *= random:NextNumber(1, 2)
		clone5.Trails.Attachment.Trail.Lifetime *= 1
		Util.Debris:AddItem(clone5, duration + 2)
		local offset = data2.Offset or random:NextNumber(-1, 1) * 3.141592653589793
		local now = tick()
		local v8 = 0.016666666666666666
		local total = 0

		while true do
			local lastTime = tick()
			local v9 = math.min(1, (lastTime - now) / duration)
			total += v8 * speed
			clone5.CFrame = data2.getRootCFrame() * CFrame.new(Vector3.new(
				radius * math.sin(total + offset),
				radius * math.cos(total + offset),
				-length
			) * v9)

			if v9 == 1 then
				break
			end

			RunService.RenderStepped:Wait()
			v8 = tick() - lastTime
		end

		task.wait(clone5.Trails.Attachment.Trail.Lifetime)
		clone5:Destroy()
	end

	local v8 = 0
	local now = tick()
	local v9 = 0.016666666666666666
	local _ = mousePos.Value

	if player == localPlayer then
		local _ = Mouse.Hit.p
	end

	local v10 = mousePos.Value - origin
	local v11 = origin + (v10.Magnitude >= DISTANCE_THRESHOLD and v10.Unit * math.min(data.Length, v10.Magnitude) or hrp.CFrame.LookVector)
	local v12 = random:NextNumber(-1, 1) * 3.141592653589793
	local v13 = sound:Play("Ghost.ReviveFruitC", clone)

	while true do
		local lastTime = tick()
		local v14 = lastTime - now

		if not mousePos:IsDescendantOf(Workspace) or not holding:IsDescendantOf(Workspace) or not holding.Value and data.MinHoldTime < v14 or duration2 < v14 or parent.Humanoid.Health <= 0 or not hrp:IsDescendantOf(Workspace) then
			break
		end

		local v15 = math.min(1, v14 / 0.2)
		local position = hrp.Position
		local value = mousePos.Value

		if player == localPlayer then
			value = Mouse.Hit.p
		end

		if data.Scene then
			value = position + hrp.CFrame.LookVector * data.Length
		end

		local v16 = value - position
		v11 = v11:Lerp(
			position + (v16.Magnitude >= DISTANCE_THRESHOLD and v16.Unit * math.min(data.Length, v16.Magnitude) or hrp.CFrame.LookVector),
			data.TurnSpeed
		)
		local v17 = v11 - position
		local unit = v17.Magnitude >= DISTANCE_THRESHOLD and v17.Unit or hrp.CFrame.LookVector
		local v18 = CFrame.new(createVector(0, 0, 0), unit) + position

		if v7 then
			v7:Set(CFrame.new(createVector(0, 0, 0), unit))
		end

		clone.CFrame = v18 * CFrame.new(0, 0, -3)
		clone2.CFrame = clone.CFrame
		clone3:PivotTo(clone.CFrame * CFrame.Angles(0, 0, -v12))
		clone4.CFrame = v18 * CFrame.new(0, 0, -3)
		clone3.End.CFrame = v18 * CFrame.new(0, 0, v15 * -95)

		if lastTime - v8 >= 0.03333333333333333 then
			local v19 = v18
			task.spawn(ghost, {
				Radius = data.Radius * 2,
				Length = data.Length,
				Duration = random:NextNumber(0.3, 0.5),
				getRootCFrame = function()
					return v19
				end
			})
			v8 = lastTime
		end

		v12 = v12 % 6.283185307179586 + 3.141592653589793 * v9 * 3
		RunService.RenderStepped:Wait()
		v9 = tick() - lastTime
	end

	sound:FadeOut(v13, 0.5)

	if v7 then
		v7:Destroy()
	end

	for _, beam in clone3:GetDescendants() do
		if beam:IsA("Beam") then
			TweenService:Create(beam, TweenInfo.new(0.3), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end

	for _, v14 in pairs({ clone, clone4 }) do
		AllVFX(v14, false)
	end
end