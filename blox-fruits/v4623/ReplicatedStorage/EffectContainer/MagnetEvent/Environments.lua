local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("FX"))
local Scheduler = require(ReplicatedStorage.Util.Scheduler)
local Util = require(ReplicatedStorage.Util)
local EventConfig = require(ReplicatedStorage.EventConfig)
local magnetEvent26 = EventConfig.MagnetEvent26
local between = Scheduler.between(magnetEvent26.START_AT, magnetEvent26.EVERYTHING_BACK_TO_NORMAL_AT)
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local enemyRegions = _WorldOrigin:WaitForChild("EnemyRegions")
local parent = _WorldOrigin:FindFirstChild("InteractiveEffects")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "InteractiveEffects"
	parent.Parent = _WorldOrigin
end

local scrapModelA = script.ScrapModelA
local parts = {}

for _, part in ipairs(scrapModelA:GetDescendants()) do
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

local sky = script:FindFirstChildWhichIsA("Sky", true)

if not sky then
	warn("[Magnet Storm] no Skybox (a Sky object) found under the effect - the storm sky wont swap")
end

local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local flag = false
local v2 = false
local thread = nil
local parent2 = nil
local v4 = {}
local humanoidRootParts = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function regionKey(p)
	local position = p.Position
	return string.format(
		"%s@%d,%d,%d",
		p.Name,
		math.round(position.X),
		math.round(position.Y),
		(math.round(position.Z))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function regionRadius(instance)
	local dataModelMesh = instance:FindFirstChildWhichIsA("DataModelMesh")
	local v5 = not dataModelMesh and 1 or dataModelMesh.Scale.X
	return instance.Size.X * v5 / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getViewerPosition()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return currentCamera.CFrame.Position
end

local v5 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isEnvironmentDateActive()
	if v5 then
		return true
	end

	if magnetEvent26.ENABLED == false then
		return false
	end

	return between:GetIfActive()
end

local function playEventStartShake()
	if not Util.CameraShaker then
		return
	end

	Util.CameraShaker:ShakeOnce(5, 8, 0.15, 1.1, createVector(1.2, 1.8, 1.2), createVector(2.5, 2.5, 2.5))
end

local v6 = nil
local v7 = nil

local function ensureFlashGui()
	if v6 and v6.Parent then
		return
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MagnetStormFlash"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 9999
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	local frame = Instance.new("Frame")
	frame.Name = "Flash"
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = Color3.new(0.988235, 1, 0.984314)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 9999
	frame.Active = false
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	v6 = screenGui
	v7 = frame
end

local function flashScreen(apply)
	ensureFlashGui()
	local v8 = v7

	if v8 then
		v8.BackgroundTransparency = 1
		local tween = TweenService:Create(v8, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		})
		tween.Completed:Once(function()
			if apply then
				apply()
			end

			TweenService:Create(v8, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
		end)
		tween:Play()
	elseif apply then
		apply()
	end
end

local v8 = {
	ClockTime = 16.25,
	Brightness = 1.8,
	Ambient = Color3.fromRGB(130, 136, 152),
	OutdoorAmbient = Color3.fromRGB(118, 124, 140),
	FogStart = 80,
	FogEnd = 450,
	FogColor = Color3.fromRGB(120, 125, 140)
}
local v9 = {
	Color = Color3.fromRGB(73, 206, 255),
	Glare = 0,
	Haze = 2
}
local flag2 = false
local v10 = nil
local v11 = nil
local renderSteppedConnection = nil
local v12 = nil
local count = 0

local function applyStormLighting(p: number, data)
	Lighting.ClockTime = data.ClockTime + (v8.ClockTime - data.ClockTime) * p
	Lighting.Brightness = data.Brightness + (v8.Brightness - data.Brightness) * p
	Lighting.Ambient = data.Ambient:Lerp(v8.Ambient, p)
	Lighting.OutdoorAmbient = data.OutdoorAmbient:Lerp(v8.OutdoorAmbient, p)
	Lighting.FogStart = data.FogStart + (v8.FogStart - data.FogStart) * p
	Lighting.FogEnd = data.FogEnd + (v8.FogEnd - data.FogEnd) * p
	Lighting.FogColor = data.FogColor:Lerp(v8.FogColor, p)
end

local function beginStormLighting()
	count += 1
	local v13 = {
		ClockTime = Lighting.ClockTime,
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		FogColor = Lighting.FogColor
	}
	v12 = v13

	if v10 then
		v10:Cancel()
		v10 = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v11 then
		v11:Destroy()
		v11 = nil
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	v11 = numberValue
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v11 then
			applyStormLighting(v11.Value, v13)
		end
	end)
	v10 = TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = 1
	})
	v10:Play()
end

local function endStormLighting()
	local v13 = count

	if v10 then
		v10:Cancel()
		v10 = nil
	end

	if v11 then
		v10 = TweenService:Create(v11, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 0
		})
		v10:Play()
		v10.Completed:Once(function()
			if v13 ~= count then
				return
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			if v11 then
				v11:Destroy()
				v11 = nil
			end

			v10 = nil
			v12 = nil
		end)
	elseif renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceEndStormLighting()
	count += 1

	if v10 then
		v10:Cancel()
		v10 = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v11 then
		v11:Destroy()
		v11 = nil
	end

	if v12 then
		applyStormLighting(0, v12)
		v12 = nil
	end
end

local sky2 = nil
local v13 = nil
local v14 = false

local function applySky(flag3: boolean)
	if flag3 == v14 then
		return
	end

	if flag3 then
		if not sky then
			return
		end

		sky2 = Lighting:FindFirstChildOfClass("Sky")

		if sky2 then
			sky2.Parent = nil
		end

		local clone = sky:Clone()
		clone.Parent = Lighting
		v13 = clone
		v14 = true
	else
		if v13 then
			v13:Destroy()
			v13 = nil
		end

		if sky2 then
			sky2.Parent = Lighting
			sky2 = nil
		end

		v14 = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceRestoreSky()
	if v14 == false then
		return
	end

	if v13 then
		v13:Destroy()
		v13 = nil
	end

	if sky2 then
		sky2.Parent = Lighting
		sky2 = nil
	end

	v14 = false
end

local v15 = nil
local v16 = nil
local v17 = nil

local function beginStormAtmosphere()
	local lightingLayers = Lighting:FindFirstChild("LightingLayers")

	if not lightingLayers then
		return
	end

	if not (v15 and v15.Parent) then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "MagnetStormAtmosphere"
		atmosphere.Color = v9.Color
		atmosphere.Glare = v9.Glare
		atmosphere.Haze = v9.Haze
		atmosphere:SetAttribute("Ignore", "Density,Decay,Offset")
		atmosphere:SetAttribute("ZIndex", 1000000)
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Intensity"
		numberValue.Value = 0
		numberValue.Parent = atmosphere
		atmosphere.Parent = lightingLayers
		v15 = atmosphere
		v16 = numberValue
	end

	if v17 then
		v17:Cancel()
		v17 = nil
	end

	local v18 = v16

	if v18 then
		local tween = TweenService:Create(v18, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 1
		})
		v17 = tween
		tween:Play()
	end
end

local function endStormAtmosphere()
	local v18 = v16
	local v19 = v15

	if v17 then
		v17:Cancel()
		v17 = nil
	end

	if not (v18 and v19) then
		return
	end

	local tween = TweenService:Create(v18, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = 0
	})
	v17 = tween
	tween:Play()
	tween.Completed:Once(function()
		if v17 ~= tween then
			return
		end

		if v19 then
			v19:Destroy()
		end

		if v15 == v19 then
			v15 = nil
			v16 = nil
		end

		v17 = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceRemoveStormAtmosphere()
	if v17 then
		v17:Cancel()
		v17 = nil
	end

	local v18 = v15
	local v19 = v16
	v15 = nil
	v16 = nil

	if v19 then
		v19.Value = 0
	end

	if v18 then
		task.defer(function()
			v18:Destroy()
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startStorm(flag3: boolean?)
	if flag2 then
		return
	end

	flag2 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply()
		if v14 ~= true and sky then
			sky2 = Lighting:FindFirstChildOfClass("Sky")

			if sky2 then
				sky2.Parent = nil
			end

			local clone = sky:Clone()
			clone.Parent = Lighting
			v13 = clone
			v14 = true
		end

		beginStormLighting()
		beginStormAtmosphere()
	end

	if flag3 then
		flashScreen(apply)
		return
	end

	apply() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStorm(flag3: boolean?)
	if not flag2 then
		return
	end

	flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply()
		forceRestoreSky() -- equivalent call inferred; original call site unknown
		endStormLighting()
		endStormAtmosphere()
	end

	if flag3 then
		flashScreen(apply)
		return
	end

	apply() -- equivalent call inferred; original call site unknown
end

local function isGoodMapPart(data)
	return not not data.CanCollide and not (data.Transparency >= 0.98) and not (data.Size.Magnitude <= 1)
end

local getScrapPart

getScrapPart = function()
	if #parts == 0 then
		return nil
	end

	local clone = parts[math.random(1, #parts)]:Clone()

	for _, descendant in ipairs(clone:GetDescendants()) do
		if not (descendant:IsA("WeldConstraint") or descendant:IsA("Weld") or descendant:IsA("Motor6D")) then
			continue
		end

		descendant:Destroy()
	end

	local X = clone.Size.X
	local Y = clone.Size.Y
	local Z = clone.Size.Z
	local v18 = math.max(X, Y, Z)
	local v19 = math.min(X, Y, Z)

	if v18 <= 0.01 then
		clone:Destroy()
		return nil
	end

	if v19 / v18 < 0.18 then
		clone:Destroy()
		return getScrapPart()
	end

	local v20 = (v18 + (X + Y + Z - v18 - v19)) * 0.5
	local v21 = math.random(150, 350) / 100 / v20
	local model = Instance.new("Model")
	clone.Parent = model
	model.PrimaryPart = clone
	model:ScaleTo(v21)
	clone.Parent = nil
	model:Destroy()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CastShadow = false
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setScrapPhysics(part, anchored: boolean, canCollide: boolean)
	part.Anchored = anchored
	part.CanCollide = canCollide
	part.CanTouch = false
	part.CanQuery = false

	if anchored then
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

local function getPartSupportOffset(scrapPart, normal: Vector3)
	local unit = normal.Unit
	local dot = unit:Dot(scrapPart.Position)
	local cFrame = scrapPart.CFrame
	local v18 = scrapPart.Size * 0.5
	local v19 = {
		cFrame * Vector3.new(v18.X, v18.Y, v18.Z),
		cFrame * Vector3.new(v18.X, v18.Y, -v18.Z),
		cFrame * Vector3.new(v18.X, -v18.Y, v18.Z),
		cFrame * Vector3.new(v18.X, -v18.Y, -v18.Z),
		cFrame * Vector3.new(-v18.X, v18.Y, v18.Z),
		cFrame * Vector3.new(-v18.X, v18.Y, -v18.Z),
		cFrame * Vector3.new(-v18.X, -v18.Y, v18.Z),
		cFrame * Vector3.new(-v18.X, -v18.Y, -v18.Z)
	}
	local v20 = 1e999

	for _, v21 in ipairs(v19) do
		v20 = math.min(v20, unit:Dot(v21))
	end

	if v20 == 1e999 then
		return 0
	end

	return dot - v20
end

local function makeRayParams(instances)
	local filterDescendantsInstances = {}

	for _, v19 in ipairs(instances) do
		if v19 then
			table.insert(filterDescendantsInstances, v19)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = true
	return raycastParams
end

local function castRegionGround(p: number, p2: number, Y: number, p3: number)
	local instances = {
		parent,
		enemyRegions,
		workspace:FindFirstChild("Characters"),
		workspace:FindFirstChild("Enemies")
	}
	local v18 = Y + p3 + 40
	local v19 = (p3 + 40) * 2

	for _ = 1, 6 do
		local rayParams = makeRayParams(instances)
		local vector2 = Vector3.new(p, v18, p2)
		local raycastResult = workspace:Raycast(vector2, createVector(0, 1, 0) * -v19, rayParams)

		if not raycastResult then
			return nil
		end

		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			local v20

			if instance.CanCollide and not (instance.Transparency >= 0.98) then
				v20 = not (instance.Size.Magnitude <= 1)
			else
				v20 = false
			end

			if v20 and raycastResult.Normal.Y >= 0.6 then
				return raycastResult
			end
		end

		table.insert(instances, instance)
	end

	return nil
end

local function hasCeilingAbove(position: Vector3)
	local instances = {
		parent,
		enemyRegions,
		workspace:FindFirstChild("Characters"),
		workspace:FindFirstChild("Enemies")
	}

	for _ = 1, 6 do
		local rayParams = makeRayParams(instances)
		local raycastResult = workspace:Raycast(position + createVector(0, 2, 0), createVector(0, 50, 0), rayParams)

		if not raycastResult then
			return false
		end

		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			local v18

			if instance.CanCollide and not (instance.Transparency >= 0.98) then
				v18 = not (instance.Size.Magnitude <= 1)
			else
				v18 = false
			end

			if v18 then
				return true
			end
		end

		table.insert(instances, instance)
	end

	return false
end

local function makeGroundCFrame(position: Vector3, normal: Vector3)
	local unit = normal.Unit
	local v18 = createVector(0, 0, 1)
	local unit2 = (math.abs((unit:Dot(v18))) > 0.95 and createVector(1, 0, 0) or v18):Cross(unit).Unit
	local unit3 = unit:Cross(unit2).Unit
	return CFrame.fromMatrix(position, unit2, unit, -unit3) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
end

local function nearestMagnetRoot(position: Vector3)
	local v18 = 55
	local v19 = nil

	for _, v20 in ipairs(humanoidRootParts) do
		if not v20.Parent then
			continue
		end

		local magnitude = (v20.Position - position).Magnitude

		if not (magnitude <= v18) then
			continue
		end

		v19 = v20
		v18 = magnitude
	end

	return v19
end

local function pickOrbitTarget(p)
	local position = p.GroundCF.Position
	local orbitTarget = p.OrbitTarget

	if orbitTarget and orbitTarget.Parent and (orbitTarget.Position - position).Magnitude <= 85 then
		return orbitTarget
	end

	return (nearestMagnetRoot(position))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFloatingScrap(scrap, flag3: boolean)
	if not scrap.Part.Parent then
		return
	end

	scrap.Floating = false
	scrap.OrbitTarget = nil
	scrap.FloatCF = nil

	if flag3 then
		scrap.Dropping = true
		setScrapPhysics(scrap.Part, false, true) -- equivalent call inferred; original call site unknown
		task.delay(2.5, function()
			if not scrap.Part.Parent or scrap.Floating then
				return
			end

			local part2 = scrap.Part
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.AssemblyLinearVelocity = createVector(0, 0, 0)
			part2.AssemblyAngularVelocity = createVector(0, 0, 0)
			scrap.GroundCF = scrap.Part.CFrame
			scrap.BaseRotation = scrap.GroundCF.Rotation
			scrap.Dropping = false
		end)
	else
		local part = scrap.Part
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
		scrap.Part.CFrame = scrap.GroundCF
		scrap.Dropping = false
	end
end

local states = {}
local renderSteppedConnection2 = nil

local function stepFloatingScraps(p: number)
	local now = os.clock()

	for i = #states, 1, -1 do
		local v18 = states[i]
		local part = v18.Part

		if v18.Floating and part.Parent then
			v18.Spin += math.rad(v18.SpinSpeed) * p
			local v19 = math.sin((now - v18.FloatStart + v18.PhaseOffset) * (6.283185307179586 / v18.BobPeriod)) * v18.BobHeight
			local orbitTarget = v18.OrbitTarget
			local v20 = false
			local v21

			if orbitTarget and orbitTarget.Parent then
				v18.OrbitAngle += p * 1.4
				local vector2 = Vector3.new(
					math.cos(v18.OrbitAngle) * v18.OrbitRadius,
					v18.OrbitHeight + v19,
					math.sin(v18.OrbitAngle) * v18.OrbitRadius
				)
				v21 = CFrame.new(orbitTarget.Position + vector2) * v18.BaseRotation * v18.TiltCF * CFrame.Angles(
					0,
					v18.Spin,
					0
				)
				v20 = true
			else
				local upVector = v18.GroundCF.UpVector
				local v22 = v18.GroundCF.Position + upVector * (v18.FloatHeight + v19)
				v21 = CFrame.new(v22) * v18.BaseRotation * v18.TiltCF * CFrame.Angles(0, v18.Spin, 0)
			end

			local v22 = 1 - math.exp(-(v20 and 13 or 6) * p)
			local lerped = (v18.FloatCF or part.CFrame):Lerp(v21, v22)
			v18.FloatCF = lerped
			part.CFrame = lerped
		else
			table.remove(states, i)
		end
	end

	if #states == 0 and renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end
end

local function startFloatingScrap(scrap)
	if scrap.Floating or scrap.Dropping or not scrap.Part.Parent then
		return
	end

	scrap.Floating = true
	scrap.Spin = 0
	scrap.FloatStart = os.clock()
	scrap.FloatCF = scrap.Part.CFrame
	local part = scrap.Part
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.AssemblyLinearVelocity = createVector(0, 0, 0)
	part.AssemblyAngularVelocity = createVector(0, 0, 0)
	table.insert(states, scrap)

	if not renderSteppedConnection2 then
		renderSteppedConnection2 = RunService.RenderStepped:Connect(stepFloatingScraps)
	end
end

local function cleanupRegion(p: string)
	local v18 = v4[p]

	if not v18 then
		return
	end

	for _, scrap in ipairs(v18.Scraps) do
		stopFloatingScrap(scrap, false) -- equivalent call inferred; original call site unknown
	end

	if v18.Folder then
		v18.Folder:Destroy()
	end

	v4[p] = nil
end

local function fadeOutRegion(k: string)
	local v18 = v4[k]

	if not v18 then
		return
	end

	v4[k] = nil

	for _, scrap in ipairs(v18.Scraps) do
		stopFloatingScrap(scrap, false) -- equivalent call inferred; original call site unknown
	end

	local folder = v18.Folder

	if not folder then
		return
	end

	for _, scrap in ipairs(v18.Scraps) do
		local part = scrap.Part

		if part and part.Parent then
			TweenService:Create(part, tweenInfo, {
				Size = createVector(0, 0, 0)
			}):Play()
		end
	end

	task.delay(0.45, function()
		if folder.Parent then
			folder:Destroy()
		end
	end)
end

local function getRegions()
	local parts2 = {}

	for _, part in ipairs(enemyRegions:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(parts2, part)
		end
	end

	return parts2
end

local function makeRegionDebris(p: string, instance)
	if v4[p] or not parent2 then
		return
	end

	local position = instance.Position
	local radius = regionRadius(instance) -- equivalent call inferred; original call site unknown

	if radius <= 0 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "MagnetGrindDebris_" .. instance.Name
	folder.Parent = parent2
	local scraps = {}
	local v20 = math.clamp(math.floor(radius / 8), 10, 45)
	local v21 = radius * 0.92
	local v22 = {
		Folder = folder,
		Scraps = scraps,
		Center = position,
		Radius = radius
	}
	v4[p] = v22
	local count2 = 0
	local positions = {}

	for _ = 1, v20 do
		for _ = 1, 12 do
			count2 += 1

			if count2 >= 8 then
				task.wait()

				if v4[p] ~= v22 or not folder.Parent then
					return
				end

				count2 = 0
			end

			local v23 = math.random() * 3.141592653589793 * 2
			local v24 = math.sqrt((math.random())) * v21
			local v27 = castRegionGround(
				position.X + math.cos(v23) * v24,
				position.Z + math.sin(v23) * v24,
				position.Y,
				radius
			)

			if not v27 then
				continue
			end

			local position2 = v27.Position
			local normal = v27.Normal

			if hasCeilingAbove(position2) then
				continue
			end

			local v28 = false

			for _, v30 in ipairs(positions) do
				if not ((v30 - position2).Magnitude < 10) then
					continue
				end

				v28 = true
				break
			end

			if v28 then
				continue
			end

			local scrapPart = getScrapPart()

			if not scrapPart then
				continue
			end

			table.insert(positions, position2)
			local groundCFrame = makeGroundCFrame(position2, normal)
			scrapPart.CFrame = groundCFrame
			local partSupportOffset = getPartSupportOffset(scrapPart, normal)
			local v30 = groundCFrame + normal.Unit * (partSupportOffset + 0.04)
			scrapPart.CFrame = v30
			scrapPart.Parent = folder
			table.insert(scraps, {
				Part = scrapPart,
				GroundCF = v30,
				BaseRotation = v30.Rotation,
				FloatHeight = math.random(4, 12),
				BobHeight = math.random(1, 2),
				SpinSpeed = math.random(18, 32),
				BobPeriod = math.random(220.00000000000003, 340) / 100,
				PhaseOffset = math.random(0, 628) / 100,
				TiltCF = CFrame.Angles(
					math.rad((math.random(-70, 70))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(-70, 70))))
				),
				OrbitAngle = math.random(0, 628) / 100,
				OrbitRadius = math.random(300, 700) / 100,
				OrbitHeight = math.random(100, 600) / 100,
				OrbitTarget = nil,
				Floating = false,
				Dropping = false,
				Spin = 0,
				FloatStart = 0,
				FloatCF = nil
			})
			break
		end
	end

	if #scraps <= 0 then
		folder:Destroy()

		if v4[p] == v22 then
			v4[p] = nil
		end
	end
end

local function regionHasMagnetEnemy(vector2: Vector3, p: number)
	for _, v18 in ipairs(humanoidRootParts) do
		if v18.Parent and (v18.Position - vector2).Magnitude <= p then
			return true
		end
	end

	return false
end

local function scanRegions()
	local viewerPosition = getViewerPosition() -- equivalent call inferred; original call site unknown
	local count2 = 0

	for _, v18 in ipairs((getRegions())) do
		local v19 = regionRadius(v18) -- equivalent call inferred; original call site unknown
		local position = v18.Position

		if not ((viewerPosition - position).Magnitude <= v19 + 600 and regionHasMagnetEnemy(position, v19)) then
			continue
		end

		local v20 = regionKey(v18) -- equivalent call inferred; original call site unknown

		if v4[v20] or not (count2 < 2) then
			continue
		end

		task.spawn(makeRegionDebris, v20, v18)
		count2 += 1
	end

	for k, v18 in pairs(v4) do
		if (viewerPosition - v18.Center).Magnitude >= v18.Radius + 1000 then
			cleanupRegion(k)
		elseif regionHasMagnetEnemy(v18.Center, v18.Radius) then
			v18.EmptySince = nil
		else
			local emptySince = v18.EmptySince

			if emptySince then
				if os.clock() - emptySince >= 20 then
					fadeOutRegion(k)
				end
			else
				v18.EmptySince = os.clock()
			end
		end
	end
end

local function scanMagnetEnemies()
	table.clear(humanoidRootParts)
	local enemies = workspace:FindFirstChild("Enemies")

	if not enemies then
		return
	end

	for _, model in ipairs(enemies:GetChildren()) do
		if not (model:IsA("Model") and model:GetAttribute("MagnetEnemy") == true) then
			continue
		end

		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			table.insert(humanoidRootParts, humanoidRootPart)
		end
	end
end

local function updateFloatingScraps(flag3: boolean)
	local viewerPosition = getViewerPosition() -- equivalent call inferred; original call site unknown

	for _, v18 in pairs(v4) do
		local v19 = (viewerPosition - v18.Center).Magnitude <= v18.Radius + 150
		local v20 = v2 and v19

		for _, scrap in ipairs(v18.Scraps) do
			if scrap.Dropping then
				continue
			end

			if v20 then
				local position = scrap.GroundCF.Position
				local orbitTarget = scrap.OrbitTarget

				if not (orbitTarget and orbitTarget.Parent and (orbitTarget.Position - position).Magnitude <= 85) then
					orbitTarget = nearestMagnetRoot(position)
				end

				if scrap.OrbitTarget and not orbitTarget then
					stopFloatingScrap(scrap, true) -- equivalent call inferred; original call site unknown
				else
					scrap.OrbitTarget = orbitTarget
					startFloatingScrap(scrap)
				end
			elseif scrap.Floating then
				stopFloatingScrap(scrap, flag3 or v2 and v19)
			end
		end
	end
end

local function cleanupAll()
	flag = false
	v2 = false
	stopStorm(false) -- equivalent call inferred; original call site unknown
	forceEndStormLighting() -- equivalent call inferred; original call site unknown
	forceRemoveStormAtmosphere() -- equivalent call inferred; original call site unknown
	forceRestoreSky() -- equivalent call inferred; original call site unknown
	local v18 = {}

	for k in pairs(v4) do
		table.insert(v18, k)
	end

	for _, v19 in ipairs(v18) do
		cleanupRegion(v19)
	end

	if parent2 then
		parent2:Destroy()
		parent2 = nil
	end

	if v6 then
		v6:Destroy()
		v6 = nil
		v7 = nil
	end

	thread = nil

	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	table.clear(states)
	table.clear(humanoidRootParts)
	table.clear(v4)
end

local function startStageOne()
	if flag then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not isEnvironmentDateActive() then
		cleanupAll()
		return
	end

	flag = true
	v2 = false
	local folder = Instance.new("Folder")
	folder.Name = "MagnetEventEnvironment"
	folder.Parent = parent
	parent2 = folder
	scanMagnetEnemies()
	scanRegions()
	thread = task.spawn(function()
		while flag do
			-- equivalent call inferred; original call site unknown
			if not isEnvironmentDateActive() then
				cleanupAll()
				break
			end

			scanMagnetEnemies()
			scanRegions()
			updateFloatingScraps(false)
			task.wait(1)
		end
	end)
end

return function(data)
	local v18 = not data and 1 or data.Stage or 1

	if data and data.Forced ~= nil then
		v5 = data.Forced == true
	end

	if v18 == 1 then
		startStageOne()
	elseif v18 == 2 then
		if not flag then
			startStageOne()
		end

		v2 = true
		startStorm(true) -- equivalent call inferred; original call site unknown

		if data and data.Shake == true and Util.CameraShaker then
			Util.CameraShaker:ShakeOnce(5, 8, 0.15, 1.1, createVector(1.2, 1.8, 1.2), createVector(2.5, 2.5, 2.5))
		end

		scanMagnetEnemies()
		scanRegions()
		updateFloatingScraps(false)
	elseif v18 == 3 then
		v2 = false
		stopStorm(true) -- equivalent call inferred; original call site unknown
		table.clear(humanoidRootParts)
		updateFloatingScraps(true)
	else
		if v18 ~= 4 and v18 ~= 0 and (not data or data.Enabled ~= false) then
			return
		end

		cleanupAll()
	end
end