local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
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

local v = {
	"rbxassetid://13171102973",
	"rbxassetid://13171102879",
	"rbxassetid://13171102704",
	"rbxassetid://13171102430",
	"rbxassetid://13171098077",
	"rbxassetid://13171097989",
	"rbxassetid://13171097889",
	"rbxassetid://13171097733",
	"rbxassetid://13171097641",
	"rbxassetid://13171097525",
	"rbxassetid://13171093138",
	"rbxassetid://13171093018",
	"rbxassetid://13171092895",
	"rbxassetid://13171092761",
	"rbxassetid://13171092651",
	"rbxassetid://13171092463"
}

local function fn(p, p2)
	return random:NextNumber(p, p2)
end

for k, v2 in pairs(v) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v[k] = Graphics.ScaleDown(v2)
end

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local v2 = {}

if atmosphere then
	for _, v3 in pairs({
		"Density",
		"Offset",
		"Color",
		"Decay",
		"Glare",
		"Haze"
	}) do
		v2[v3] = atmosphere[v3]
	end
end

return function(data)
	local player = data.player
	local v3

	if typeof(player) == "Instance" and player.Parent ~= nil then
		v3 = player:IsA("Player") or player:FindFirstChild("GhostFruitVFXColor") ~= nil
	else
		v3 = false
	end

	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local _ = data.origin
	local _ = data.fireDir

	if parent:FindFirstChild("ItemsTableFolder") == nil then
		local folder = Instance.new("Folder")
		folder.Name = "ItemsTableFolder"
		folder.Parent = parent
	end

	local parent2 = _WorldOrigin
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = Lighting
	local v5 = {
		Color = Color3.fromRGB(199, 170, 107),
		Decay = Color3.fromRGB(92, 60, 13),
		Glare = 0,
		Haze = 0,
		Offset = 0,
		Density = 0.6
	}
	local atmosphere2 = nil

	if atmosphere then
		for k, v6 in pairs(v5) do
			atmosphere[k] = v6
		end
	else
		atmosphere2 = Instance.new("Atmosphere")

		for k, v6 in pairs(v5) do
			atmosphere2[k] = v6
		end

		atmosphere2.Parent = Lighting
	end

	local parent3 = localPlayer.PlayerGui:FindFirstChild("Revive/" .. script.Name) or Instance.new("ScreenGui")
	parent3.Name = "Revive/" .. script.Name
	parent3.Parent = localPlayer.PlayerGui
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundTransparency = 1
	imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.Selectable = false
	imageButton.Parent = parent3
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageButton

	for _, v7 in pairs({ colorCorrectionEffect, atmosphere2, parent3 }) do
		if v7 == nil then
			continue
		end

		if typeof(data.lastsFor) == "number" then
			destroyAfter(v7, 7 + data.lastsFor)
		else
			destroyAfter(v7, 10)
		end
	end

	local tween = TweenService:Create(imageButton, TweenInfo.new(1), {
		Size = UDim2.new(0.5, 0, 0.5, 0),
		ImageTransparency = 1
	})
	tween:Play()
	tween:Destroy()
	task.spawn(function()
		for i = 1, #v do
			imageButton.Image = v[i]
			task.wait(0.0625)
		end

		parent3:Destroy()
	end)
	local brightness = colorCorrectionEffect.Brightness
	local tintColor = colorCorrectionEffect.TintColor
	local color = Color3.fromRGB(75, 255, 228)

	if v3 then
		color = Util.WrapColor3ConstructorForTintColor(color, player, "GhostFruitVFXColor")
	end

	local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Brightness = 0.075,
		TintColor = color
	})
	tween2:Play()
	tween2:Destroy()
	local v7 = true
	task.spawn(function()
		local lastTime = tick()
		local v8 = false

		while v7 and not (tick() - lastTime > 10) do
			v8 = not v8
			local v9 = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -10)
			local clone = revive["Soul Ruler"].Trail:Clone()
			clone.CFrame = v9 * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			)

			if v3 then
				Util.SetParentOverrideWithColor(clone, parent2, player, "GhostFruitVFXColor")
			else
				clone.Parent = parent2
			end

			destroyAfter(clone, 10)
			local v10 = clone.CFrame * CFrame.new(random:NextNumber(-60, 60), random:NextNumber(10, 35), fn(-60, -100))
			local v11 = v9 * CFrame.new(random:NextNumber(-50, 50), random:NextNumber(5, 10), fn(20, 50))
			local total = 0
			local v12 = random:NextNumber(-30, 30) * (v8 and 1 or -1)
			local v13 = random:NextNumber(-30, 30) * (v8 and 1 or -1)
			local heartbeatConnection = nil
			local position = (CFrame.lookAt(clone.Position:Lerp(v11.Position, 0.25), v11.Position) * CFrame.new(
				v13 * 2,
				v12,
				0
			)).Position
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt * 1

				if total >= 1 then
					heartbeatConnection:Disconnect()
				end

				clone.GhostTrail.TrailTrail.Trail.Transparency = NumberSequence.new(total, total)
				local v18 = total
				local position2 = v10.Position
				local position6 = position
				local position3 = v11.Position
				local v20 = position2 + (position6 - position2) * v18
				local v21 = v20 + (position6 + (position3 - position6) * v18 - v20) * v18

				if total >= 1 then
					clone.Position = v11.Position
					AllVFX(clone, false)
					destroyAfter(clone, 1)
				else
					local v22 = clone
					local v23 = total + 0.01
					local position4 = v10.Position
					local position7 = position
					local position5 = v11.Position
					local v25 = position4 + (position7 - position4) * v23
					v22.CFrame = CFrame.new(v21, v25 + (position7 + (position5 - position7) * v23 - v25) * v23)
				end
			end)
			task.wait(0.022222222222222223)
		end
	end)

	if typeof(data.lastsFor) == "number" then
		task.wait(data.lastsFor)
	elseif typeof(data.lastsFor) == "Instance" then
		local lastTime = tick()

		while data.lastsFor:IsDescendantOf(Workspace) and not (tick() - lastTime > 10) do
			task.wait(0.016666666666666666)
		end
	end

	v7 = false
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Brightness = brightness,
		TintColor = tintColor
	}):Play()

	if atmosphere then
		TweenService:Create(atmosphere, TweenInfo.new(0.5), v2):Play()
	else
		TweenService:Create(atmosphere2, TweenInfo.new(0.5), v2):Play()
	end

	task.wait(0.5)
	colorCorrectionEffect:Destroy()

	if atmosphere2 then
		atmosphere2:Destroy()
	end
end