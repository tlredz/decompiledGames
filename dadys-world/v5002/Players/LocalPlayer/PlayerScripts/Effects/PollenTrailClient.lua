local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:FindFirstChild("Modules")
local zones = modules and modules:FindFirstChild("Zones")
local pollenTrailConfig = zones and zones:FindFirstChild("PollenTrailConfig")
local module

if pollenTrailConfig then
	module = require(pollenTrailConfig)
end

if not (module and module.ENABLED) then
	return
end

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local JUICE = module and module.JUICE or {}
_G.PollenJuice = JUICE
local pollenConfig = ReplicatedStorage:FindFirstChild("PollenConfig") or ReplicatedStorage:WaitForChild(
	"PollenConfig",
	5
)

-- equivalent calls inferred from this helper; original call sites unknown
local function isDebugMode()
	if not pollenConfig then
		return false
	end

	local debugMode = pollenConfig:FindFirstChild("DebugMode")
	return debugMode and debugMode.Value or false
end

local function getCfg(childName, value)
	if not pollenConfig then
		return value
	end

	local child = pollenConfig:FindFirstChild(childName)

	if child then
		value = child.Value or value
	end

	return value
end

local function readTrailConfig(child)
	local v = {}

	if not child then
		return v
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rv(childName)
		local child2 = child:FindFirstChild(childName)
		return child2 and child2.Value or nil
	end

	v.color1 = rv("Color1")
	v.color2 = rv("Color2")
	v.color3 = rv("Color3")
	v.lightEmission = rv("LightEmission")
	v.textureId = rv("TextureId")
	v.lifetime = rv("Lifetime")
	return v
end

local v = {}

local function getPreset(childName)
	if not childName or childName == "" then
		return nil
	end

	if v[childName] ~= nil then
		return v[childName] or nil
	end

	local pollenPresets = ReplicatedStorage:FindFirstChild("PollenPresets")

	if pollenPresets then
		local child = pollenPresets:FindFirstChild(childName)

		if child then
			local v2 = {
				trailSettings = {},
				effects = {}
			}

			for _, child2 in ipairs(child:GetChildren()) do
				if child2:IsA("Configuration") and child2.Name == "TrailConfig" then
					v2.trailSettings = readTrailConfig(child2)
				elseif child2:IsA("ParticleEmitter") or child2:IsA("PointLight") then
					table.insert(v2.effects, child2)
				end
			end

			v[childName] = v2
		else
			v[childName] = false
		end
	else
		v[childName] = false
	end

	return v[childName] or nil
end

local v2 = {}
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharHeight(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.HipHeight + 3
	end

	return 4.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHalfHeight(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.HipHeight + 0.5
	end

	return 2.5
end

local function createTrailOnCharacter(instance, trailColor1, trailColor2, trailColor3, trailEmission, pollenPreset)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local preset = getPreset(pollenPreset)
	local v3 = not preset and {} or preset.trailSettings or {}
	local color1 = v3.color1 or trailColor1 or Color3.fromRGB(255, 240, 160)
	local color2 = v3.color2 or trailColor2 or Color3.fromRGB(255, 215, 60)
	local color3 = v3.color3 or trailColor3 or Color3.fromRGB(255, 175, 30)
	local lightEmission = v3.lightEmission or trailEmission or 0.7
	local textureId = v3.textureId or ""
	local lifetime = v3.lifetime or 10
	local halfHeight = getHalfHeight(instance) -- equivalent call inferred; original call site unknown
	local charHeight = getCharHeight(instance) -- equivalent call inferred; original call site unknown
	local value

	if pollenConfig then
		local trailMode = pollenConfig:FindFirstChild("TrailMode")
		value = trailMode and trailMode.Value or "beam"
	else
		value = "beam"
	end

	local value2

	if pollenConfig then
		local groundTrailWidth = pollenConfig:FindFirstChild("GroundTrailWidth")
		value2 = groundTrailWidth and groundTrailWidth.Value or 3.5
	else
		value2 = 3.5
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "PollenBottomAtt"
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "PollenTopAtt"

	if value == "ground" then
		attachment.Position = Vector3.new(-value2 / 2, -halfHeight, 0)
		attachment2.Position = Vector3.new(value2 / 2, -halfHeight, 0)
	else
		attachment.Position = Vector3.new(0, -halfHeight, 0)
		attachment2.Position = Vector3.new(0, charHeight - halfHeight, 0)
	end

	attachment.Parent = humanoidRootPart
	attachment2.Parent = humanoidRootPart
	local trail = Instance.new("Trail")
	trail.Name = "PollenTrail"
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = lifetime
	trail.MaxLength = 200
	trail.FaceCamera = false
	trail.LightEmission = lightEmission
	trail.LightInfluence = value == "ground" and 0.4 or 0.15
	trail.MinLength = 0.2
	trail.Enabled = true
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(0.15, color2),
		ColorSequenceKeypoint.new(0.5, color3),
		ColorSequenceKeypoint.new(0.85, color2),
		ColorSequenceKeypoint.new(1, color1)
	})

	if value == "ground" then
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.1, 0.05),
			NumberSequenceKeypoint.new(0.5, 0.02),
			NumberSequenceKeypoint.new(0.85, 0.1),
			NumberSequenceKeypoint.new(1, 0.5)
		})
	else
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.1, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.08),
			NumberSequenceKeypoint.new(0.9, 0.2),
			NumberSequenceKeypoint.new(1, 0.7)
		})
	end

	if value == "ground" then
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.6, 0.95),
			NumberSequenceKeypoint.new(0.85, 0.7),
			NumberSequenceKeypoint.new(1, 0.1)
		})
	else
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(0.8, 0.55),
			NumberSequenceKeypoint.new(1, 0)
		})
	end

	if textureId ~= "" then
		trail.Texture = textureId
		trail.TextureLength = 1.5
		trail.TextureMode = Enum.TextureMode.Wrap
	end

	trail.Parent = humanoidRootPart

	for _, child in ipairs(humanoidRootPart:GetChildren()) do
		if child.Name:sub(1, 7) == "Pollen_" then
			child:Destroy()
		end
	end

	if preset and #preset.effects > 0 then
		for _, effect in ipairs(preset.effects) do
			local clone = effect:Clone()
			clone.Name = "Pollen_" .. clone.Name
			clone.Parent = humanoidRootPart
		end

		return lifetime
	else
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "Pollen_Rise"
		particleEmitter.Rate = 14
		particleEmitter.Lifetime = NumberRange.new(0.8, 2)
		particleEmitter.Speed = NumberRange.new(2, 5)
		particleEmitter.EmissionDirection = Enum.NormalId.Top
		particleEmitter.SpreadAngle = Vector2.new(35, 35)
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.04, 0.4),
			NumberSequenceKeypoint.new(0.25, 0.2),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.04, 0),
			NumberSequenceKeypoint.new(0.35, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		local HSV, v4, v5 = color2:ToHSV()
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(HSV, math.max(0, v4 - 0.15), (math.min(1, v5 + 0.1)))),
			ColorSequenceKeypoint.new(1, color2)
		})
		particleEmitter.LightEmission = 0.85
		particleEmitter.LightInfluence = 0.1
		particleEmitter.Drag = 1.5
		particleEmitter.Brightness = 2
		particleEmitter.Parent = humanoidRootPart
		local particleEmitter2 = Instance.new("ParticleEmitter")
		particleEmitter2.Name = "Pollen_Amb"
		particleEmitter2.Rate = 6
		particleEmitter2.Lifetime = NumberRange.new(2, 4)
		particleEmitter2.Speed = NumberRange.new(0.15, 0.7)
		particleEmitter2.SpreadAngle = Vector2.new(360, 360)
		particleEmitter2.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 0.22),
			NumberSequenceKeypoint.new(0.5, 0.16),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0.4),
			NumberSequenceKeypoint.new(0.6, 0.6),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter2.Color = ColorSequence.new(color1)
		particleEmitter2.LightEmission = 0.6
		particleEmitter2.LightInfluence = 0.2
		particleEmitter2.Acceleration = createVector(0, 0.5, 0)
		particleEmitter2.RotSpeed = NumberRange.new(-40, 40)
		particleEmitter2.Drag = 3
		particleEmitter2.Brightness = 1.2
		particleEmitter2.Parent = humanoidRootPart
		local pointLight = Instance.new("PointLight")
		pointLight.Name = "Pollen_Light"
		pointLight.Color = color2
		pointLight.Brightness = 0.8
		pointLight.Range = 8
		pointLight.Parent = humanoidRootPart
		return lifetime
	end
end

local v3 = {}

local function cleanupPollenEffects(instance, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v4 = (v3[instance] or 0) + 1
	v3[instance] = v4
	local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")
	local lifetime

	if pollenTrail then
		pollenTrail.Enabled = false
		lifetime = pollenTrail.Lifetime
	else
		lifetime = 10
	end

	for _, child in ipairs(humanoidRootPart:GetChildren()) do
		if child.Name:sub(1, 7) ~= "Pollen_" then
			continue
		end

		if child:IsA("ParticleEmitter") then
			child.Enabled = false
		elseif child:IsA("PointLight") then
			child:Destroy()
		end
	end

	if p then
		task.delay(lifetime + 0.5, function()
			if not (v3[instance] == v4 and (humanoidRootPart and humanoidRootPart.Parent)) then
				return
			end

			for _, child in ipairs(humanoidRootPart:GetChildren()) do
				if not (child.Name:sub(1, 7) == "Pollen_" or child.Name == "PollenBottomAtt" or child.Name == "PollenTopAtt" or child.Name == "PollenTrail") then
					continue
				end

				child:Destroy()
			end
		end)
		return
	end

	for _, child in ipairs(humanoidRootPart:GetChildren()) do
		if not (child.Name:sub(1, 7) == "Pollen_" or child.Name == "PollenBottomAtt" or child.Name == "PollenTopAtt" or child.Name == "PollenTrail") then
			continue
		end

		child:Destroy()
	end
end

local function updateTrailColorsInPlace(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

	if not pollenTrail then
		return false
	end

	local trailColor1 = instance:GetAttribute("TrailColor1")
	local trailColor2 = instance:GetAttribute("TrailColor2")
	local trailColor3 = instance:GetAttribute("TrailColor3")
	local trailEmission = instance:GetAttribute("TrailEmission") or 0.7

	if not (trailColor1 and trailColor2 and trailColor3) then
		return false
	end

	pollenTrail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, trailColor1),
		ColorSequenceKeypoint.new(0.15, trailColor2),
		ColorSequenceKeypoint.new(0.5, trailColor3),
		ColorSequenceKeypoint.new(0.85, trailColor2),
		ColorSequenceKeypoint.new(1, trailColor1)
	})
	pollenTrail.LightEmission = trailEmission
	local pollen_Rise = humanoidRootPart:FindFirstChild("Pollen_Rise")

	if pollen_Rise and pollen_Rise:IsA("ParticleEmitter") then
		local HSV, v4, v5 = trailColor2:ToHSV()
		pollen_Rise.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(HSV, math.max(0, v4 - 0.15), (math.min(1, v5 + 0.1)))),
			ColorSequenceKeypoint.new(1, trailColor2)
		})
	end

	local pollen_Amb = humanoidRootPart:FindFirstChild("Pollen_Amb")

	if pollen_Amb and pollen_Amb:IsA("ParticleEmitter") then
		pollen_Amb.Color = ColorSequence.new(trailColor1)
	end

	local pollen_Light = humanoidRootPart:FindFirstChild("Pollen_Light")

	if pollen_Light and pollen_Light:IsA("PointLight") then
		pollen_Light.Color = trailColor2
	end

	return true
end

local v4 = {}

local function startTracking(instance)
	local v5 = v4[instance]
	local trailColor1 = instance:GetAttribute("TrailColor1")

	if v5 and v5.active and v5.col1 == trailColor1 then
		return
	end

	cleanupPollenEffects(instance, false)
	local trailColor2 = instance:GetAttribute("TrailColor2")
	local trailColor3 = instance:GetAttribute("TrailColor3")
	local trailEmission = instance:GetAttribute("TrailEmission") or 0.7
	local pollenPreset = instance:GetAttribute("PollenPreset") or ""
	v4[instance] = {
		active = true,
		col1 = trailColor1,
		lifetime = createTrailOnCharacter(instance, trailColor1, trailColor2, trailColor3, trailEmission, pollenPreset)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTracking(p)
	local v5 = v4[p]

	if v5 and v5.active then
		v5.active = false
		cleanupPollenEffects(p, true)
	end
end

local Debris = game:GetService("Debris")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

local function makeSound(parent, playbackSpeed, volume, value)
	return Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Volume = volume,
		PlaybackSpeed = playbackSpeed,
		RollOffMaxDistance = value or 50,
		RollOffMinDistance = 8,
		Parent = parent
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playComboTriggerSound(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local playbackSpeed = 1.8 + math.random() * 0.8
	Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Volume = 0.5 + math.random() * 0.2,
		PlaybackSpeed = playbackSpeed,
		RollOffMaxDistance = 50,
		RollOffMinDistance = 8,
		Parent = humanoidRootPart
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playPollinationSound(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Volume = 0.35,
		PlaybackSpeed = 1 + math.random() * 0.4,
		RollOffMaxDistance = 40,
		RollOffMinDistance = 8,
		Parent = humanoidRootPart
	})
end

local function playPollinationBurst(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local trailColor1 = instance:GetAttribute("TrailColor1") or Color3.fromRGB(255, 220, 160)
	local attachment = Instance.new("Attachment")
	attachment.Parent = humanoidRootPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(trailColor1, Color3.fromRGB(255, 255, 240))
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Speed = NumberRange.new(6, 12)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.3, 0.5),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.RotSpeed = NumberRange.new(-180, 180)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Enabled = false
	particleEmitter.Parent = attachment
	particleEmitter:Emit(20)
	Debris:AddItem(attachment, 1.5)
end

local v5 = 0

local function playTrailWalkSound(instance)
	local now = tick()

	if now - v5 < 2 then
		return
	end

	v5 = now
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Volume = 0.2,
		PlaybackSpeed = 2.2 + math.random() * 0.6,
		RollOffMaxDistance = 30,
		RollOffMinDistance = 8,
		Parent = humanoidRootPart
	})
end

local flag = false

local function playBuffExpiryWarning(instance)
	if flag then
		return
	end

	flag = true
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Volume = 0.25,
		PlaybackSpeed = 1.4 + math.random() * 0.3,
		RollOffMaxDistance = 30,
		RollOffMinDistance = 8,
		Parent = humanoidRootPart
	})
end

local v6 = {}

local function tryCloneBuffTemplate(childName)
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local buffParticles = parts and parts:FindFirstChild("BuffParticles")
	local skillCheck = buffParticles and buffParticles:FindFirstChild("SkillCheck")
	local child = skillCheck and skillCheck:FindFirstChild(childName)

	if child then
		return child:Clone()
	end

	return nil
end

local function createBuffParticles(instance)
	if v6[instance] then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local pollenBuffColor = instance:GetAttribute("PollenBuffColor") or Color3.fromRGB(255, 220, 160)
	local HSV, v7, v8 = pollenBuffColor:ToHSV()
	local color = Color3.fromHSV(HSV, math.max(0, v7 - 0.35), (math.min(1, v8 + 0.2)))
	local color2 = Color3.fromHSV((HSV + 0.08) % 1, v7, v8)
	local color3 = Color3.fromHSV(HSV, math.min(1, v7 + 0.1), (math.max(0, v8 * 0.6)))
	local attachment = Instance.new("Attachment")
	attachment.Name = "PollenBuffAtt"
	attachment.Parent = humanoidRootPart
	local v9 = tryCloneBuffTemplate("BuffParticle")

	if v9 then
		v9.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.35, pollenBuffColor),
			ColorSequenceKeypoint.new(0.7, color2),
			ColorSequenceKeypoint.new(1, color)
		})
		v9.Enabled = true
		v9.Parent = attachment
	else
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "PollenBuffSparkle"
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.35, pollenBuffColor),
			ColorSequenceKeypoint.new(0.7, color2),
			ColorSequenceKeypoint.new(1, color)
		})
		particleEmitter.Lifetime = NumberRange.new(1, 1.8)
		particleEmitter.Rate = 8
		particleEmitter.Speed = NumberRange.new(1.5, 3.5)
		particleEmitter.SpreadAngle = Vector2.new(45, 45)
		particleEmitter.VelocityInheritance = 0.3
		particleEmitter.Acceleration = createVector(0, 2.5, 0)
		particleEmitter.EmissionDirection = Enum.NormalId.Top
		particleEmitter.LightEmission = 0.7
		particleEmitter.LightInfluence = 0.2
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, 0.6),
			NumberSequenceKeypoint.new(1, 0.15)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.2, 0.1),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.RotSpeed = NumberRange.new(-120, 120)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.Enabled = true
		particleEmitter.Parent = attachment
	end

	local v10 = tryCloneBuffTemplate("Glow")

	if v10 then
		v10.Color = ColorSequence.new(pollenBuffColor)
		v10.Enabled = true
		v10.Parent = attachment
	else
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "PollenBuffGlow"
		particleEmitter.Color = ColorSequence.new(pollenBuffColor)
		particleEmitter.Lifetime = NumberRange.new(0.6, 1)
		particleEmitter.Rate = 4
		particleEmitter.Speed = NumberRange.new(0, 0.3)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.LightEmission = 0.9
		particleEmitter.LightInfluence = 0.05
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 1.4),
			NumberSequenceKeypoint.new(1, 0.6)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.3, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Enabled = true
		particleEmitter.Parent = attachment
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Name = "PollenBuffLight"
	pointLight.Color = pollenBuffColor
	pointLight.Brightness = 0.6
	pointLight.Range = 10
	pointLight.Parent = attachment
	local highlight = Instance.new("Highlight")
	highlight.Name = "PollenBuffHighlight"
	highlight.FillColor = color3
	highlight.FillTransparency = 0.92
	highlight.OutlineColor = pollenBuffColor
	highlight.OutlineTransparency = 0.5
	highlight.Adornee = instance
	highlight.Parent = instance
	v6[instance] = attachment
end

local function removeBuffParticles(instance)
	local v7 = v6[instance]

	if not v7 then
		return
	end

	v6[instance] = nil
	local pollenBuffHighlight = instance:FindFirstChild("PollenBuffHighlight")

	if pollenBuffHighlight then
		pollenBuffHighlight:Destroy()
	end

	for _, child in ipairs(v7:GetChildren()) do
		if child:IsA("ParticleEmitter") then
			child.Enabled = false
		elseif child:IsA("PointLight") then
			child:Destroy()
		end
	end

	Debris:AddItem(v7, 2.5)
end

local currentCamera = workspace.CurrentCamera
local fieldOfView = not currentCamera and 70 or currentCamera.FieldOfView or 70
local v8 = nil
local v9 = nil
local blurEffect = nil
local colorCorrectionEffect = nil
local v10 = nil
local v11 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getSpeedFXIntensity(p)
	if p and not (p <= 1) then
		return (math.clamp((p - 1.04) / 0.15999999999999992, 0, 1))
	end

	return 0
end

local function applyFOVBoost(value)
	if not currentCamera then
		return
	end

	local speedFXIntensity = getSpeedFXIntensity(value or 1.08) -- equivalent call inferred; original call site unknown
	local v13 = 2 + speedFXIntensity * 4

	if v8 then
		v8:Cancel()
	end

	v8 = TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fieldOfView + v13
	})
	v8:Play()

	if not blurEffect then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "PollenSpeedBlur"
		blurEffect.Size = 0
		blurEffect.Parent = Lighting
	end

	local size = 1 + speedFXIntensity * 2

	if v10 then
		v10:Cancel()
	end

	v10 = TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = size
	})
	v10:Play()

	if not colorCorrectionEffect then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PollenSpeedColor"
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.Brightness = 0
		colorCorrectionEffect.Contrast = 0
		colorCorrectionEffect.Parent = Lighting
	end

	local saturation = 0.05 + speedFXIntensity * 0.1
	local brightness = speedFXIntensity * 0.03

	if v11 then
		v11:Cancel()
	end

	v11 = TweenService:Create(
		colorCorrectionEffect,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Saturation = saturation,
			Brightness = brightness
		}
	)
	v11:Play()
end

local function removeFOVBoost()
	if not currentCamera then
		return
	end

	if v8 then
		v8:Cancel()
	end

	if v9 then
		v9:Cancel()
		v9 = nil
	end

	v8 = TweenService:Create(currentCamera, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fieldOfView
	})
	v8:Play()

	if blurEffect then
		if v10 then
			v10:Cancel()
		end

		v10 = TweenService:Create(blurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		})
		v10:Play()
	end

	if colorCorrectionEffect then
		if v11 then
			v11:Cancel()
		end

		v11 = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Saturation = 0,
				Brightness = 0
			}
		)
		v11:Play()
	end
end

local colorCorrectionEffect2 = nil
local v12 = nil

local function applyDebuffFX()
	if not currentCamera then
		return
	end

	if v9 then
		v9:Cancel()
	end

	v9 = TweenService:Create(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fieldOfView - 1.5
	})
	v9:Play()

	if not colorCorrectionEffect2 then
		colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect2.Name = "PollenDebuffColor"
		colorCorrectionEffect2.Saturation = 0
		colorCorrectionEffect2.Brightness = 0
		colorCorrectionEffect2.TintColor = Color3.fromRGB(255, 255, 255)
		colorCorrectionEffect2.Parent = Lighting
	end

	if v12 then
		v12:Cancel()
	end

	v12 = TweenService:Create(
		colorCorrectionEffect2,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Saturation = -0.1,
			Brightness = -0.02,
			TintColor = Color3.fromRGB(220, 200, 240)
		}
	)
	v12:Play()
end

local function removeDebuffFX()
	if not currentCamera then
		return
	end

	if v9 then
		v9:Cancel()
		v9 = nil
	end

	if colorCorrectionEffect2 then
		if v12 then
			v12:Cancel()
		end

		v12 = TweenService:Create(
			colorCorrectionEffect2,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Saturation = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		)
		v12:Play()
	end
end

local renderSteppedConnection = nil

local function juiceScreenShake()
	if not JUICE.ScreenShake then
		return
	end

	local currentCamera2 = workspace.CurrentCamera

	if not currentCamera2 then
		return
	end

	local screenShakeIntensity = JUICE.ScreenShakeIntensity or 0.4
	local screenShakeDuration = JUICE.ScreenShakeDuration or 0.25
	local lastTime = tick()
	local _ = currentCamera2.CFrame

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v13 = tick() - lastTime

		if screenShakeDuration <= v13 then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		else
			local v15 = screenShakeIntensity * (1 - v13 / screenShakeDuration)
			local vector2 = Vector3.new((math.random() - 0.5) * 2 * v15, (math.random() - 0.5) * 2 * v15, 0)
			currentCamera2.CFrame *= CFrame.new(vector2)
		end
	end)
end

local depthOfFieldEffect = nil
local v13 = nil

local function juiceDoFPulse()
	if not JUICE.DepthOfFieldPulse then
		return
	end

	local doFDuration = JUICE.DoFDuration or 0.5

	if not depthOfFieldEffect then
		depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
		depthOfFieldEffect.Name = "PollenDoFPulse"
		depthOfFieldEffect.FarIntensity = 0
		depthOfFieldEffect.NearIntensity = 0
		depthOfFieldEffect.FocusDistance = 20
		depthOfFieldEffect.InFocusRadius = 50
		depthOfFieldEffect.Parent = Lighting
	end

	depthOfFieldEffect.NearIntensity = 0.5
	depthOfFieldEffect.FarIntensity = 0.3
	depthOfFieldEffect.FocusDistance = JUICE.DoFInDistance or 5
	depthOfFieldEffect.InFocusRadius = JUICE.DoFFarDistance or 50

	if v13 then
		v13:Cancel()
	end

	v13 = TweenService:Create(
		depthOfFieldEffect,
		TweenInfo.new(doFDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			NearIntensity = 0,
			FarIntensity = 0
		}
	)
	v13:Play()
end

local sunRaysEffect = nil
local v14 = nil

local function juiceSunRaysFlash(_)
	if not JUICE.SunRaysFlash then
		return
	end

	local sunRaysIntensity = JUICE.SunRaysIntensity or 0.35
	local sunRaysDuration = JUICE.SunRaysDuration or 0.6

	if not sunRaysEffect then
		sunRaysEffect = Instance.new("SunRaysEffect")
		sunRaysEffect.Name = "PollenSunFlash"
		sunRaysEffect.Intensity = 0
		sunRaysEffect.Spread = 0.8
		sunRaysEffect.Parent = Lighting
	end

	sunRaysEffect.Intensity = sunRaysIntensity

	if v14 then
		v14:Cancel()
	end

	v14 = TweenService:Create(
		sunRaysEffect,
		TweenInfo.new(sunRaysDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Intensity = 0
		}
	)
	v14:Play()
end

local function juiceSquashStretch(instance)
	if not (JUICE.SquashStretch and instance:FindFirstChildOfClass("Humanoid")) then
		return
	end

	local squashAmount = JUICE.SquashAmount or 0.85
	local stretchAmount = JUICE.StretchAmount or 1.15
	local squashStretchSpeed = JUICE.SquashStretchSpeed or 0.15
	local bodyHeightScale = instance:FindFirstChild("BodyHeightScale")

	if not bodyHeightScale then
		return
	end

	local value = bodyHeightScale.Value
	local tween = TweenService:Create(
		bodyHeightScale,
		TweenInfo.new(squashStretchSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Value = value * squashAmount
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if not bodyHeightScale.Parent then
			return
		end

		local tween2 = TweenService:Create(
			bodyHeightScale,
			TweenInfo.new(squashStretchSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Value = value * stretchAmount
			}
		)
		tween2:Play()
		tween2.Completed:Connect(function()
			if not bodyHeightScale.Parent then
				return
			end

			TweenService:Create(
				bodyHeightScale,
				TweenInfo.new(squashStretchSpeed * 1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
				{
					Value = value
				}
			):Play()
		end)
	end)
end

local v15 = {}

local function startFootstepSparkles(instance)
	if not JUICE.FootstepSparkles or v15[instance] then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local footstepRate = JUICE.FootstepRate or 6
	local v16 = 0
	v15[instance] = humanoid.Running:Connect(function(p)
		if p < 2 then
			return
		end

		local now = tick()
		local v17 = math.clamp(4 / p, 0.15, 0.5)

		if now - v16 < v17 then
			return
		end

		v16 = now
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local trailColor1 = instance:GetAttribute("TrailColor1") or Color3.fromRGB(255, 240, 160)
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(
			(math.random() - 0.5) * 1.5,
			-(humanoid.HipHeight or 2),
			(math.random() - 0.5) * 0.5
		)
		attachment.Parent = humanoidRootPart
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Color = ColorSequence.new(trailColor1, Color3.new(1, 1, 1))
		particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
		particleEmitter.Speed = NumberRange.new(1, 3)
		particleEmitter.SpreadAngle = Vector2.new(40, 40)
		particleEmitter.EmissionDirection = Enum.NormalId.Top
		particleEmitter.LightEmission = 0.8
		particleEmitter.LightInfluence = 0.1
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.5, 0.25),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.RotSpeed = NumberRange.new(-90, 90)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.Enabled = false
		particleEmitter.Parent = attachment
		particleEmitter:Emit(footstepRate)
		Debris:AddItem(attachment, 1)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFootstepSparkles(p)
	if v15[p] then
		v15[p]:Disconnect()
		v15[p] = nil
	end
end

local function juiceHighlightFlash(instance)
	if not JUICE.HighlightFlash then
		return
	end

	local highlightFlashDuration = JUICE.HighlightFlashDuration or 0.15
	local highlight = Instance.new("Highlight")
	highlight.Name = "PollenPickupFlash"
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.3
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 0
	highlight.Adornee = instance
	highlight.Parent = instance
	task.delay(highlightFlashDuration, function()
		if not highlight.Parent then
			return
		end

		TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
		Debris:AddItem(highlight, 0.5)
	end)
end

local renderSteppedConnection2 = nil

local function startTrailBreathing()
	if renderSteppedConnection2 or not JUICE.TrailBreathing then
		return
	end

	local trailBreathSpeed = JUICE.TrailBreathSpeed or 2.5
	local trailBreathAmount = JUICE.TrailBreathAmount or 0.12
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		if not JUICE.TrailBreathing then
			return
		end

		local now = tick()
		local _ = 1 + math.sin(now * trailBreathSpeed) * trailBreathAmount

		for k, v16 in pairs(v4) do
			if not v16.active then
				continue
			end

			local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

			if not (pollenTrail and pollenTrail.Enabled) then
				continue
			end

			if not pollenTrail:GetAttribute("BaseWidthScale") then
				pollenTrail:SetAttribute("BaseWidthScale", true)
			end

			local baseBrightness = pollenTrail:GetAttribute("BaseBrightness") or pollenTrail.Brightness

			if not pollenTrail:GetAttribute("BaseBrightness") then
				pollenTrail:SetAttribute("BaseBrightness", pollenTrail.Brightness)
			end

			pollenTrail.Brightness = baseBrightness * (math.sin(now * trailBreathSpeed * 1.3) * 0.15 + 0.9)
		end
	end)
end

local function juiceProximityColorShift(instance, pollenNearCombo)
	if not JUICE.ComboProximityShift then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

	if not pollenTrail then
		return
	end

	if pollenNearCombo then
		local proximityShiftAmount = JUICE.ProximityShiftAmount or 0.4
		local color = Color3.fromRGB(255, 240, 180)
		local trailColor1 = instance:GetAttribute("TrailColor1") or Color3.fromRGB(255, 240, 160)
		local trailColor2 = instance:GetAttribute("TrailColor2") or Color3.fromRGB(255, 215, 60)
		local lerped = trailColor1:Lerp(color, proximityShiftAmount)
		local lerped2 = trailColor2:Lerp(color, proximityShiftAmount)
		pollenTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, lerped),
			ColorSequenceKeypoint.new(0.5, lerped2),
			ColorSequenceKeypoint.new(1, lerped)
		})
	else
		local trailColor1 = instance:GetAttribute("TrailColor1") or Color3.fromRGB(255, 240, 160)
		local trailColor2 = instance:GetAttribute("TrailColor2") or Color3.fromRGB(255, 215, 60)
		local trailColor3 = instance:GetAttribute("TrailColor3") or Color3.fromRGB(255, 175, 30)
		pollenTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, trailColor1),
			ColorSequenceKeypoint.new(0.15, trailColor2),
			ColorSequenceKeypoint.new(0.5, trailColor3),
			ColorSequenceKeypoint.new(0.85, trailColor2),
			ColorSequenceKeypoint.new(1, trailColor1)
		})
	end
end

local v16 = {}

local function createCubeGroundGlow(part)
	if not JUICE.GroundGlow then
		return
	end

	local groundGlowRadius = JUICE.GroundGlowRadius or 5
	local color = part.Color or Color3.fromRGB(255, 220, 140)
	local part2 = Instance.new("Part")
	part2.Name = "CubeGroundGlow"
	part2.Shape = Enum.PartType.Cylinder
	part2.Size = Vector3.new(0.05, groundGlowRadius * 2, groundGlowRadius * 2)
	part2.Material = Enum.Material.Neon
	part2.Color = color
	part2.Transparency = 0.8
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.Anchored = true
	part2.CFrame = CFrame.new(part.Position.X, part.Position.Y - part.Size.Y / 2 - 0.1, part.Position.Z) * CFrame.Angles(
		0,
		0,
		1.5707963267948966
	)
	part2.Parent = workspace.Terrain
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 0.4
	pointLight.Range = groundGlowRadius
	pointLight.Parent = part2
	v16[part] = part2

	if JUICE.GroundGlowPulse then
		task.spawn(function()
			while part2 and part2.Parent and part and part.Parent do
				TweenService:Create(part2, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Transparency = 0.7
				}):Play()
				TweenService:Create(pointLight, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Brightness = 0.6
				}):Play()
				task.wait(1.2)

				if not part2.Parent then
					break
				end

				TweenService:Create(part2, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Transparency = 0.85
				}):Play()
				TweenService:Create(pointLight, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Brightness = 0.3
				}):Play()
				task.wait(1.2)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCubeGroundGlow(p)
	local v17 = v16[p]

	if v17 then
		v16[p] = nil
		v17:Destroy()
	end
end

local colorCorrectionEffect3 = nil
local v17 = nil

local function juiceAtmosphereTint()
	if not JUICE.AtmosphereTint then
		return
	end

	local atmoTintColor = JUICE.AtmoTintColor or Color3.fromRGB(255, 240, 200)
	local atmoTintDuration = JUICE.AtmoTintDuration or 0.8

	if not colorCorrectionEffect3 then
		colorCorrectionEffect3 = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect3.Name = "PollenAtmoTint"
		colorCorrectionEffect3.Brightness = 0
		colorCorrectionEffect3.Contrast = 0
		colorCorrectionEffect3.Saturation = 0
		colorCorrectionEffect3.TintColor = Color3.new(1, 1, 1)
		colorCorrectionEffect3.Parent = Lighting
	end

	colorCorrectionEffect3.TintColor = atmoTintColor
	colorCorrectionEffect3.Brightness = 0.08
	colorCorrectionEffect3.Saturation = 0.15

	if v17 then
		v17:Cancel()
	end

	v17 = TweenService:Create(
		colorCorrectionEffect3,
		TweenInfo.new(atmoTintDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			TintColor = Color3.new(1, 1, 1),
			Brightness = 0,
			Saturation = 0
		}
	)
	v17:Play()
end

local v18 = {}

local function startCubeIdleBob(part)
	if not JUICE.CubeIdleBob or v18[part] then
		return
	end

	local cubeBobHeight = JUICE.CubeBobHeight or 0.6
	local cubeBobSpeed = JUICE.CubeBobSpeed or 1.8
	local cubeRotateSpeed = JUICE.CubeRotateSpeed or 25
	local Y = part.Position.Y
	local lastTime = tick()
	v18[part] = RunService.Heartbeat:Connect(function()
		if part and part.Parent then
			local v19 = tick() - lastTime
			local v20 = Y + math.sin(v19 * cubeBobSpeed) * cubeBobHeight
			local v21 = v19 * cubeRotateSpeed
			part.CFrame = CFrame.new(part.Position.X, v20, part.Position.Z) * CFrame.Angles(0, math.rad(v21), 0)
		elseif v18[part] then
			v18[part]:Disconnect()
			v18[part] = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCubeIdleBob(p)
	if v18[p] then
		v18[p]:Disconnect()
		v18[p] = nil
	end
end

local v19 = {
	value = 0,
	velocity = 0
}

local function springUpdate(p, p2)
	if not JUICE.SpringTimerBar then
		return p
	end

	local springFrequency = JUICE.SpringFrequency or 8
	local springDamping = JUICE.SpringDamping or 0.6
	local v20 = springFrequency * 3.141592653589793 * 2
	local v21 = v19.value - p
	local v22 = -v20 * v20 * v21
	local v23 = -2 * springDamping * v20 * v19.velocity
	v19.velocity += (v22 + v23) * p2
	v19.value += v19.velocity * p2
	return (math.clamp(v19.value, 0, 1.15))
end

local function juiceNumberPop(_, text, pollenBuffColor)
	if not JUICE.NumberPop then
		return
	end

	local numberPopDuration = JUICE.NumberPopDuration or 1.5
	local numberPopRise = JUICE.NumberPopRise or 40
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	local parent = playerGui:FindFirstChild("PollenNumberPops")

	if not parent then
		parent = Instance.new("ScreenGui")
		parent.Name = "PollenNumberPops"
		parent.ResetOnSpawn = false
		parent.DisplayOrder = 12
		parent.IgnoreGuiInset = false
		parent.Parent = playerGui
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.4, 0, 0, 30)
	textLabel.Position = UDim2.new(0.3, 0, 0.62, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = pollenBuffColor or Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 18
	textLabel.TextTransparency = 0
	textLabel.Parent = parent
	textLabel.TextSize = 10
	TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = 20
	}):Play()
	TweenService:Create(textLabel, TweenInfo.new(numberPopDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.3, 0, 0.62, -numberPopRise)
	}):Play()
	task.delay(numberPopDuration * 0.6, function()
		if not textLabel.Parent then
			return
		end

		TweenService:Create(
			textLabel,
			TweenInfo.new(numberPopDuration * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		):Play()
	end)
	Debris:AddItem(textLabel, numberPopDuration + 0.2)
end

local v20 = nil

local function startTrailCue(instance)
	if v20 then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "PollenTrailCue"
	attachment.Position = createVector(0, -1, 0)
	attachment.Parent = humanoidRootPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "TrailFlowCue"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 240, 180))
	particleEmitter.Lifetime = NumberRange.new(0.4, 0.7)
	particleEmitter.Rate = 12
	particleEmitter.Speed = NumberRange.new(4, 7)
	particleEmitter.SpreadAngle = Vector2.new(120, 30)
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.LightEmission = 0.8
	particleEmitter.LightInfluence = 0.1
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.RotSpeed = NumberRange.new(-90, 90)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Enabled = true
	particleEmitter.Parent = attachment
	v20 = attachment
end

local function stopTrailCue()
	if not v20 then
		return
	end

	local v21 = v20
	v20 = nil

	for _, emitter in ipairs(v21:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(v21, 1)
end

local fn2
local fn3
local fn4

local function watchCharacter(instance)
	if not instance:FindFirstChild("HumanoidRootPart") then
		instance:WaitForChild("HumanoidRootPart", 10)
	end

	local renderSteppedConnection3 = nil

	if instance:GetAttribute("Pollinated") then
		startTracking(instance)
	end

	instance:GetAttributeChangedSignal("Pollinated"):Connect(function()
		local pollinated = instance:GetAttribute("Pollinated")

		-- equivalent call inferred; original call site unknown
		if isDebugMode() then
			print(
				"[PollenClient] Pollinated changed:",
				instance.Name,
				"→",
				pollinated,
				"preset:",
				instance:GetAttribute("PollenPreset") or "none"
			)
		end

		if pollinated then
			startTracking(instance)

			if Players:GetPlayerFromCharacter(instance) == localPlayer then
				playPollinationSound(instance) -- equivalent call inferred; original call site unknown
				fn4(instance)
				juiceDoFPulse()
				startFootstepSparkles(instance)
			end

			playPollinationBurst(instance)
		else
			stopTracking(instance) -- equivalent call inferred; original call site unknown
			stopFootstepSparkles(instance) -- equivalent call inferred; original call site unknown
		end
	end)
	instance:GetAttributeChangedSignal("TrailColor1"):Connect(function()
		if instance:GetAttribute("Pollinated") then
			local v21 = v4[instance]

			if v21 and v21.active and updateTrailColorsInPlace(instance) then
				v21.col1 = instance:GetAttribute("TrailColor1")
				return
			end

			cleanupPollenEffects(instance, false)
			v4[instance] = nil
			startTracking(instance)
		end
	end)
	instance:GetAttributeChangedSignal("PollenComboTrigger"):Connect(function()
		-- equivalent call inferred; original call site unknown
		if isDebugMode() then
			print(
				"[PollenClient] ComboTrigger on",
				instance.Name,
				"value:",
				instance:GetAttribute("PollenComboTrigger") or "nil"
			)
		end

		playComboTriggerSound(instance) -- equivalent call inferred; original call site unknown

		if Players:GetPlayerFromCharacter(instance) == localPlayer then
			juiceScreenShake()
			juiceHighlightFlash(instance)
			local pollenBuffPreset = instance:GetAttribute("PollenBuffPreset") or ""
			local pollenBuffColor = instance:GetAttribute("PollenBuffColor")
			local pollenBuffMultiplier = instance:GetAttribute("PollenBuffMultiplier")

			if pollenBuffMultiplier and pollenBuffMultiplier > 1 then
				juiceNumberPop(
					instance,
					"+" .. math.round((pollenBuffMultiplier - 1) * 100) .. "% " .. ((pollenBuffPreset == "" or not pollenBuffPreset) and "Speed!" or pollenBuffPreset),
					pollenBuffColor
				)
			end
		end
	end)
	local v21 = Players:GetPlayerFromCharacter(instance) == localPlayer

	if instance:GetAttribute("PollenBuff") then
		createBuffParticles(instance)

		if v21 then
			applyFOVBoost(instance:GetAttribute("PollenBuffMultiplier"))
			fn2(instance)
		end
	end

	instance:GetAttributeChangedSignal("PollenBuff"):Connect(function()
		local pollenBuff = instance:GetAttribute("PollenBuff")

		-- equivalent call inferred; original call site unknown
		if isDebugMode() then
			print(
				"[PollenClient] PollenBuff changed:",
				instance.Name,
				"→",
				pollenBuff,
				"preset:",
				instance:GetAttribute("PollenBuffPreset") or "none",
				"expires:",
				instance:GetAttribute("PollenBuffExpires") or 0
			)
		end

		if pollenBuff then
			removeBuffParticles(instance)
			createBuffParticles(instance)

			if v21 then
				applyFOVBoost(instance:GetAttribute("PollenBuffMultiplier"))
				juiceSquashStretch(instance)
				fn2(instance)
			end
		else
			removeBuffParticles(instance)

			if v21 then
				fn3()

				if instance:GetAttribute("PollenDebuff") then
					applyDebuffFX()
				elseif instance:GetAttribute("PollenTrailWalking") then
					local pollenTrailWalkMultiplier = instance:GetAttribute("PollenTrailWalkMultiplier") or 1.08
					applyFOVBoost(pollenTrailWalkMultiplier)
				elseif instance:GetAttribute("PollenOwnerBoost") then
					applyFOVBoost(instance:GetAttribute("PollenOwnerBoostMultiplier") or 1.05)
				else
					removeFOVBoost()
					stopTrailCue()
				end
			end
		end
	end)

	if v21 then
		instance:GetAttributeChangedSignal("PollenTrailWalking"):Connect(function()
			if instance:GetAttribute("PollenTrailWalking") then
				startTrailCue(instance)
				playTrailWalkSound(instance)

				if not instance:GetAttribute("PollenBuff") then
					local pollenTrailWalkMultiplier = instance:GetAttribute("PollenTrailWalkMultiplier") or 1.08
					applyFOVBoost(pollenTrailWalkMultiplier)
				end
			else
				stopTrailCue()

				if instance:GetAttribute("PollenBuff") then
					return
				end

				if instance:GetAttribute("PollenDebuff") then
					applyDebuffFX()
				elseif instance:GetAttribute("PollenCreateBoost") then
					applyFOVBoost(instance:GetAttribute("PollenCreateBoost"))
				elseif instance:GetAttribute("PollenOwnerBoost") then
					applyFOVBoost(instance:GetAttribute("PollenOwnerBoostMultiplier") or 1.05)
				else
					removeFOVBoost()
				end
			end
		end)
		instance:GetAttributeChangedSignal("PollenCreateBoost"):Connect(function()
			local pollenCreateBoost = instance:GetAttribute("PollenCreateBoost")

			if pollenCreateBoost then
				if not instance:GetAttribute("PollenBuff") then
					applyFOVBoost(pollenCreateBoost)
				end
			else
				if instance:GetAttribute("PollenBuff") then
					return
				end

				if instance:GetAttribute("PollenDebuff") then
					applyDebuffFX()
				elseif instance:GetAttribute("PollenTrailWalking") then
					local pollenTrailWalkMultiplier = instance:GetAttribute("PollenTrailWalkMultiplier") or 1.08
					applyFOVBoost(pollenTrailWalkMultiplier)
				elseif instance:GetAttribute("PollenOwnerBoost") then
					applyFOVBoost(instance:GetAttribute("PollenOwnerBoostMultiplier") or 1.05)
				else
					removeFOVBoost()
				end
			end
		end)
		instance:GetAttributeChangedSignal("PollenDebuff"):Connect(function()
			if instance:GetAttribute("PollenDebuff") then
				applyDebuffFX()
				return
			end

			removeDebuffFX()

			if instance:GetAttribute("PollenBuff") then
				applyFOVBoost(instance:GetAttribute("PollenBuffMultiplier"))
			elseif instance:GetAttribute("PollenCreateBoost") then
				applyFOVBoost(instance:GetAttribute("PollenCreateBoost"))
			elseif instance:GetAttribute("PollenTrailWalking") then
				local pollenTrailWalkMultiplier = instance:GetAttribute("PollenTrailWalkMultiplier") or 1.08
				applyFOVBoost(pollenTrailWalkMultiplier)
			elseif instance:GetAttribute("PollenOwnerBoost") then
				applyFOVBoost(instance:GetAttribute("PollenOwnerBoostMultiplier") or 1.05)
			else
				removeFOVBoost()
			end
		end)
		instance:GetAttributeChangedSignal("PollenOwnerBoost"):Connect(function()
			if instance:GetAttribute("PollenOwnerBoost") then
				if not (instance:GetAttribute("PollenBuff") or instance:GetAttribute("PollenDebuff") or instance:GetAttribute("PollenCreateBoost") or instance:GetAttribute("PollenTrailWalking")) then
					applyFOVBoost(instance:GetAttribute("PollenOwnerBoostMultiplier") or 1.05)
				end
			else
				if instance:GetAttribute("PollenBuff") then
					return
				end

				if instance:GetAttribute("PollenDebuff") then
					applyDebuffFX()
				elseif instance:GetAttribute("PollenCreateBoost") then
					applyFOVBoost(instance:GetAttribute("PollenCreateBoost"))
				elseif instance:GetAttribute("PollenTrailWalking") then
					local pollenTrailWalkMultiplier = instance:GetAttribute("PollenTrailWalkMultiplier") or 1.08
					applyFOVBoost(pollenTrailWalkMultiplier)
				else
					removeFOVBoost()
				end
			end
		end)
		local tweens = {}
		instance:GetAttributeChangedSignal("PollenNearCombo"):Connect(function()
			local pollenNearCombo = instance:GetAttribute("PollenNearCombo")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			juiceProximityColorShift(instance, pollenNearCombo)

			for _, v22 in ipairs(tweens) do
				v22:Cancel()
			end

			tweens = {}

			if pollenNearCombo then
				local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

				if pollenTrail then
					local tween = TweenService:Create(
						pollenTrail,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							LightEmission = 1,
							Brightness = 3
						}
					)
					tween:Play()
					table.insert(tweens, tween)
				end

				local pollen_Rise = humanoidRootPart:FindFirstChild("Pollen_Rise")

				if pollen_Rise then
					local tween = TweenService:Create(pollen_Rise, TweenInfo.new(0.2), {
						Brightness = 4
					})
					tween:Play()
					table.insert(tweens, tween)
					pollen_Rise.Rate = 28
				end

				local pollen_Light = humanoidRootPart:FindFirstChild("Pollen_Light")

				if pollen_Light then
					local tween = TweenService:Create(pollen_Light, TweenInfo.new(0.2), {
						Brightness = 3,
						Range = 14
					})
					tween:Play()
					table.insert(tweens, tween)
				end

				if renderSteppedConnection3 then
					renderSteppedConnection3:Disconnect()
				end

				renderSteppedConnection3 = RunService.RenderStepped:Connect(function()
					if pollenTrail and pollenTrail.Parent then
						pollenTrail.Brightness = math.abs((math.sin(tick() * 6))) * 1.5 + 2
					end
				end)
			else
				if renderSteppedConnection3 then
					renderSteppedConnection3:Disconnect()
					renderSteppedConnection3 = nil
				end

				local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

				if pollenTrail then
					local tween = TweenService:Create(
						pollenTrail,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							LightEmission = 0.7,
							Brightness = 1
						}
					)
					tween:Play()
					table.insert(tweens, tween)
				end

				local pollen_Rise = humanoidRootPart:FindFirstChild("Pollen_Rise")

				if pollen_Rise then
					local tween = TweenService:Create(pollen_Rise, TweenInfo.new(0.3), {
						Brightness = 2
					})
					tween:Play()
					table.insert(tweens, tween)
					pollen_Rise.Rate = 14
				end

				local pollen_Light = humanoidRootPart:FindFirstChild("Pollen_Light")

				if pollen_Light then
					local tween = TweenService:Create(pollen_Light, TweenInfo.new(0.3), {
						Brightness = 1.5,
						Range = 10
					})
					tween:Play()
					table.insert(tweens, tween)
				end
			end
		end)
	end

	local renderSteppedConnection4 = nil
	local v22 = nil

	local function createGatherBeams(humanoidRootPart)
		if v22 then
			return
		end

		local trailColor2 = instance:GetAttribute("TrailColor2") or Color3.fromRGB(255, 220, 160)
		local HSV, v23, v24 = trailColor2:ToHSV()
		local color = Color3.fromHSV(HSV, math.max(0, v23 - 0.2), (math.min(1, v24 + 0.15)))
		local anchors = {}
		local beams = {}
		local v27 = humanoidRootPart:FindFirstChild("PollenGatherCenter")

		if not v27 then
			v27 = Instance.new("Attachment")
			v27.Name = "PollenGatherCenter"
			v27.Position = createVector(0, -2, 0)
			v27.Parent = humanoidRootPart
		end

		for i = 1, 4 do
			local v28 = (i - 1) * 1.5707963267948966 + 0.7853981633974483
			local v29 = humanoidRootPart.Position + Vector3.new(math.cos(v28) * 3, -2, math.sin(v28) * 3)
			local part = Instance.new("Part")
			part.Name = "GatherAnchor_" .. i
			part.Size = createVector(0.1, 0.1, 0.1)
			part.Transparency = 1
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = true
			part.CFrame = CFrame.new(v29)
			part.Parent = workspace.Terrain
			local attachment = Instance.new("Attachment")
			attachment.Parent = part
			local beam = Instance.new("Beam")
			beam.Name = "GatherBeam_" .. i
			beam.Attachment0 = attachment
			beam.Attachment1 = v27
			beam.FaceCamera = true
			beam.Segments = 12
			beam.TextureSpeed = 2.5
			beam.TextureLength = 0.8
			beam.Texture = "rbxasset://textures/Beam001.png"
			beam.LightEmission = 1
			beam.LightInfluence = 0
			beam.CurveSize0 = 2 + math.random() * 1.5
			beam.CurveSize1 = -1 - math.random() * 0.5
			beam.Width0 = 0.4
			beam.Width1 = 0.08
			beam.Brightness = 2
			beam.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(0.6, trailColor2),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			})
			beam.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.3, 0.2),
				NumberSequenceKeypoint.new(0.7, 0.3),
				NumberSequenceKeypoint.new(1, 0.7)
			})
			beam.Parent = part
			table.insert(anchors, part)
			table.insert(beams, beam)
		end

		local renderSteppedConnection5 = nil
		renderSteppedConnection5 = RunService.RenderStepped:Connect(function()
			if not (humanoidRootPart and humanoidRootPart.Parent) then
				renderSteppedConnection5:Disconnect()
				return
			end

			local now = tick()
			local position = humanoidRootPart.Position

			for i = 1, 4 do
				if anchors[i] and anchors[i].Parent then
					local v28 = (i - 1) * 1.5707963267948966 + 0.7853981633974483 + now * 0.8
					anchors[i].CFrame = CFrame.new(
						position.X + math.cos(v28) * 3,
						position.Y - 2,
						position.Z + math.sin(v28) * 3
					)
				end

				if not (beams[i] and beams[i].Parent) then
					continue
				end

				beams[i].Brightness = math.sin(now * 5 + i * 1.5) * 1 + 1.5
				beams[i].Width0 = math.sin(now * 3 + i) * 0.15 + 0.25
			end
		end)
		v22 = {
			anchors = anchors,
			beams = beams,
			centerAtt = v27,
			conn = renderSteppedConnection5
		}
	end

	local function removeGatherBeams()
		if not v22 then
			return
		end

		local v23 = v22
		v22 = nil

		if v23.conn then
			v23.conn:Disconnect()
		end

		for _, anchor in ipairs(v23.anchors) do
			if anchor and anchor.Parent then
				anchor:Destroy()
			end
		end

		if v23.centerAtt then
			v23.centerAtt:Destroy()
		end
	end

	if v21 then
		instance:GetAttributeChangedSignal("PollenComboReady"):Connect(function()
			local pollenComboReady = instance:GetAttribute("PollenComboReady")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if pollenComboReady then
				local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

				if pollenTrail then
					TweenService:Create(
						pollenTrail,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							LightEmission = 1,
							Brightness = 2.5
						}
					):Play()
				end

				local pollen_Rise = humanoidRootPart:FindFirstChild("Pollen_Rise")

				if pollen_Rise then
					pollen_Rise.Rate = 24
					TweenService:Create(pollen_Rise, TweenInfo.new(0.2), {
						Brightness = 4
					}):Play()
				end

				local pollen_Light = humanoidRootPart:FindFirstChild("Pollen_Light")

				if pollen_Light then
					TweenService:Create(pollen_Light, TweenInfo.new(0.2), {
						Brightness = 3,
						Range = 16
					}):Play()
				end

				if renderSteppedConnection4 then
					renderSteppedConnection4:Disconnect()
				end

				renderSteppedConnection4 = RunService.RenderStepped:Connect(function()
					local pollenTrail2 = humanoidRootPart:FindFirstChild("PollenTrail")

					if pollenTrail2 and pollenTrail2.Parent then
						pollenTrail2.Brightness = math.abs((math.sin(tick() * 4))) * 1.2 + 2
					end
				end)
				createGatherBeams(humanoidRootPart)
			else
				if renderSteppedConnection4 then
					renderSteppedConnection4:Disconnect()
					renderSteppedConnection4 = nil
				end

				local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

				if pollenTrail then
					TweenService:Create(
						pollenTrail,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							LightEmission = 0.7,
							Brightness = 1
						}
					):Play()
				end

				local pollen_Rise = humanoidRootPart:FindFirstChild("Pollen_Rise")

				if pollen_Rise then
					pollen_Rise.Rate = 14
					TweenService:Create(pollen_Rise, TweenInfo.new(0.3), {
						Brightness = 2
					}):Play()
				end

				local pollen_Light = humanoidRootPart:FindFirstChild("Pollen_Light")

				if pollen_Light then
					TweenService:Create(pollen_Light, TweenInfo.new(0.3), {
						Brightness = 1.5,
						Range = 10
					}):Play()
				end

				removeGatherBeams()
			end
		end)
	end

	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			removeBuffParticles(instance)

			if v21 then
				removeFOVBoost()
				removeDebuffFX()
				fn3()

				if v9 then
					v9:Cancel()
					v9 = nil
				end

				if currentCamera then
					if v8 then
						v8:Cancel()
					end

					currentCamera.FieldOfView = fieldOfView
				end

				stopTrailCue()
				stopFootstepSparkles(instance) -- equivalent call inferred; original call site unknown

				if renderSteppedConnection3 then
					renderSteppedConnection3:Disconnect()
					renderSteppedConnection3 = nil
				end

				if renderSteppedConnection4 then
					renderSteppedConnection4:Disconnect()
					renderSteppedConnection4 = nil
				end

				removeGatherBeams()

				if v2 then
					for k in pairs(v2) do
						fn(k)
					end
				end
			end

			v4[instance] = nil
			v3[instance] = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPlayerAdded(player)
	if player.Character then
		watchCharacter(player.Character)
	end

	player.CharacterAdded:Connect(watchCharacter)
end

for _, v21 in ipairs(Players:GetPlayers()) do
	onPlayerAdded(v21) -- equivalent call inferred; original call site unknown
end

Players.PlayerAdded:Connect(onPlayerAdded)
local v21 = {}

local function onTwistedAdded(model)
	if not model:IsA("Model") or v21[model] then
		return
	end

	v21[model] = true

	-- equivalent call inferred; original call site unknown
	if isDebugMode() then
		print("[PollenClient] Watching Twisted:", model.Name)
	end

	watchCharacter(model)
end

for _, v22 in ipairs(CollectionService:GetTagged("Twisted")) do
	task.spawn(onTwistedAdded, v22)
end

CollectionService:GetInstanceAddedSignal("Twisted"):Connect(onTwistedAdded)
CollectionService:GetInstanceRemovedSignal("Twisted"):Connect(function(p)
	v21[p] = nil
	v4[p] = nil
	v3[p] = nil
end)

local function playComboSound(part)
	Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
		Name = "FairyDing1",
		Volume = 0.7 + math.random() * 0.3,
		PlaybackSpeed = 1.5 + math.random() * 1,
		RollOffMaxDistance = 80,
		RollOffMinDistance = 10,
		Parent = part
	})
	task.delay(0.06, function()
		if not part.Parent then
			return
		end

		Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
			Name = "FairyDing2",
			Volume = 0.3 + math.random() * 0.2,
			PlaybackSpeed = 2.2 + math.random() * 1.3,
			RollOffMaxDistance = 60,
			RollOffMinDistance = 10,
			Parent = part
		})
	end)
end

local v22 = {
	Bloom = {
		name = "Bloom!",
		color = Color3.fromRGB(160, 255, 120)
	},
	Haste = {
		name = "Haste!",
		color = Color3.fromRGB(255, 200, 80)
	},
	Endure = {
		name = "Endure!",
		color = Color3.fromRGB(180, 140, 255)
	},
	Harmony = {
		name = "Harmony!",
		color = Color3.fromRGB(255, 255, 180)
	},
	FairyLoop = {
		name = "Fairy Loop!",
		color = Color3.fromRGB(255, 240, 200)
	},
	MysteryMix = {
		name = "Mystery Mix!",
		color = Color3.fromRGB(220, 220, 220)
	}
}
local v23 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCubeLabelMode()
	if not pollenConfig then
		return "off"
	end

	local cubeLabelMode = pollenConfig:FindFirstChild("CubeLabelMode")
	return cubeLabelMode and cubeLabelMode.Value or "off"
end

local function createCubeLabel(parent)
	local cubeLabelMode = getCubeLabelMode() -- equivalent call inferred; original call site unknown

	if cubeLabelMode == "off" then
		return
	end

	local reactionType = parent:GetAttribute("ReactionType") or "MysteryMix"
	local v24 = v22[reactionType] or v22.MysteryMix
	local spawnTime = parent:GetAttribute("SpawnTime") or workspace:GetServerTimeNow()
	local cubeLifetime = parent:GetAttribute("CubeLifetime") or 15
	local color = v24.color
	local color2 = Color3.new(color.R * 0.6 + 0.4, color.G * 0.6 + 0.4, color.B * 0.6 + 0.4)

	if cubeLabelMode == "billboard" then
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "CubeLabel"
		billboardGui.Size = UDim2.new(0, 120, 0, 50)
		billboardGui.StudsOffset = createVector(0, 3, 0)
		billboardGui.AlwaysOnTop = false
		billboardGui.MaxDistance = 60
		billboardGui.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ReactionName"
		textLabel.Size = UDim2.new(1, 0, 0.55, 0)
		textLabel.Position = UDim2.new(0, 0, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = v24.name
		textLabel.TextColor3 = color
		textLabel.TextTransparency = 0.3
		textLabel.TextStrokeTransparency = 1
		textLabel.TextSize = 16
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Parent = billboardGui
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Timer"
		textLabel2.Size = UDim2.new(1, 0, 0.45, 0)
		textLabel2.Position = UDim2.new(0, 0, 0.55, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = ""
		textLabel2.TextColor3 = color2
		textLabel2.TextTransparency = 0.4
		textLabel2.TextStrokeTransparency = 1
		textLabel2.TextSize = 12
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.Parent = billboardGui
		v23[parent] = RunService.Heartbeat:Connect(function()
			if not parent.Parent then
				return
			end

			local v25 = math.max(0, cubeLifetime - (workspace:GetServerTimeNow() - spawnTime))
			textLabel2.Text = string.format("%.1fs", v25)
			local v26 = math.clamp(v25 / cubeLifetime, 0, 1)
			textLabel.TextTransparency = (1 - v26) * 0.4 + 0.3
			textLabel2.TextTransparency = (1 - v26) * 0.4 + 0.4
		end)
	elseif cubeLabelMode == "surface" then
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "CubeLabel"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.CanvasSize = Vector2.new(200, 120)
		surfaceGui.LightInfluence = 0
		surfaceGui.AlwaysOnTop = false
		surfaceGui.MaxDistance = 60
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surfaceGui.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ReactionName"
		textLabel.Size = UDim2.new(1, 0, 0.55, 0)
		textLabel.Position = UDim2.new(0, 0, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = v24.name
		textLabel.TextColor3 = color
		textLabel.TextTransparency = 0.3
		textLabel.TextStrokeTransparency = 1
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Parent = surfaceGui
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Timer"
		textLabel2.Size = UDim2.new(1, 0, 0.45, 0)
		textLabel2.Position = UDim2.new(0, 0, 0.55, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = ""
		textLabel2.TextColor3 = color2
		textLabel2.TextTransparency = 0.4
		textLabel2.TextStrokeTransparency = 1
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.Parent = surfaceGui
		v23[parent] = RunService.Heartbeat:Connect(function()
			if not parent.Parent then
				return
			end

			local v25 = math.max(0, cubeLifetime - (workspace:GetServerTimeNow() - spawnTime))
			textLabel2.Text = string.format("%.1fs", v25)
			local v26 = math.clamp(v25 / cubeLifetime, 0, 1)
			textLabel.TextTransparency = (1 - v26) * 0.4 + 0.3
			textLabel2.TextTransparency = (1 - v26) * 0.4 + 0.4
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCubeLabel(instance)
	local connection = v23[instance]

	if connection then
		connection:Disconnect()
		v23[instance] = nil
	end

	local cubeLabel = instance:FindFirstChild("CubeLabel")

	if cubeLabel then
		cubeLabel:Destroy()
	end
end

local function onComboCubeAdded(part)
	if not part:IsA("BasePart") then
		return
	end

	-- equivalent call inferred; original call site unknown
	if isDebugMode() then
		print(
			"[PollenClient] Combo cube appeared:",
			part.Name,
			"at",
			tostring(part.Position),
			"reaction:",
			part:GetAttribute("ReactionType") or "?"
		)
	end

	playComboSound(part)
	createCubeLabel(part)
	juiceSunRaysFlash(part.Color)
	createCubeGroundGlow(part)
	startCubeIdleBob(part)

	if (part:GetAttribute("Contributors") or 2) >= 3 then
		juiceAtmosphereTint()
	end

	local HSV, v24, v25 = (part.Color or Color3.fromRGB(255, 220, 140)):ToHSV()
	local color = Color3.fromHSV(HSV, math.min(1, v24 + 0.1), (math.max(0, v25 * 0.4)))
	local color2 = Color3.fromHSV((HSV + 0.04) % 1, math.max(0, v24 - 0.15), (math.min(1, v25 + 0.2)))
	local highlight = Instance.new("Highlight")
	highlight.Name = "CubeHighlight"
	highlight.FillColor = color
	highlight.FillTransparency = 0.92
	highlight.OutlineColor = color2
	highlight.OutlineTransparency = 0.45
	highlight.Adornee = part
	highlight.Parent = part
	part.Destroying:Connect(function()
		local connection = v23[part]

		if connection then
			connection:Disconnect()
			v23[part] = nil
		end

		removeCubeGroundGlow(part) -- equivalent call inferred; original call site unknown
		stopCubeIdleBob(part) -- equivalent call inferred; original call site unknown
	end)
end

local cubeLabelMode = pollenConfig and pollenConfig:FindFirstChild("CubeLabelMode")

if cubeLabelMode then
	cubeLabelMode.Changed:Connect(function()
		for _, v24 in ipairs(CollectionService:GetTagged("PollenCombinedSeg")) do
			if not (v24 and v24.Parent) then
				continue
			end

			removeCubeLabel(v24) -- equivalent call inferred; original call site unknown
			createCubeLabel(v24)
		end
	end)
end

for _, v24 in ipairs(CollectionService:GetTagged("PollenCombinedSeg")) do
	task.spawn(onComboCubeAdded, v24)
end

CollectionService:GetInstanceAddedSignal("PollenCombinedSeg"):Connect(onComboCubeAdded)
CollectionService:GetInstanceRemovedSignal("PollenCombinedSeg"):Connect(function(instance)
	removeCubeLabel(instance) -- equivalent call inferred; original call site unknown
end)

if pollenConfig then
	local function rebuildAll()
		local v24 = {}

		for k, v25 in pairs(v4) do
			if v25.active and k.Parent then
				table.insert(v24, k)
			end
		end

		for _, v25 in ipairs(v24) do
			cleanupPollenEffects(v25, false)
			v4[v25] = nil
			startTracking(v25)
		end
	end

	local trailMode = pollenConfig:FindFirstChild("TrailMode")

	if trailMode then
		trailMode.Changed:Connect(rebuildAll)
	end

	local groundTrailWidth = pollenConfig:FindFirstChild("GroundTrailWidth")

	if groundTrailWidth then
		groundTrailWidth.Changed:Connect(rebuildAll)
	end
end

local v24 = {}
local v25 = {}
local v26 = nil

local function createCubeAttractionBeam(part)
	local character = localPlayer.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "CubeBeamAtt"
	attachment.Parent = part
	local attachment2 = humanoidRootPart:FindFirstChild("PollenCubeBeamAtt")

	if not attachment2 then
		attachment2 = Instance.new("Attachment")
		attachment2.Name = "PollenCubeBeamAtt"
		attachment2.Parent = humanoidRootPart
	end

	local color = part.Color or Color3.fromRGB(255, 220, 140)
	local HSV, v28, v29 = color:ToHSV()
	local color2 = Color3.fromHSV(HSV, math.max(0, v28 - 0.2), (math.min(1, v29 + 0.15)))
	local beam = Instance.new("Beam")
	beam.Name = "CubeAttractionBeam"
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.FaceCamera = true
	beam.Segments = 20
	beam.TextureSpeed = 1.5
	beam.TextureLength = 1.2
	beam.Texture = "rbxasset://textures/Beam001.png"
	beam.LightEmission = 0.9
	beam.LightInfluence = 0.05
	beam.CurveSize0 = 4
	beam.CurveSize1 = -2
	beam.Width0 = 0.3
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color2),
		ColorSequenceKeypoint.new(0.5, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 240))
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 0.3),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 0.8)
	})
	beam.Brightness = 1.5
	beam.Parent = part
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "AttractionGlow"
	pointLight.Color = color
	pointLight.Brightness = 0.5
	pointLight.Range = 6
	pointLight.Parent = part
	return {
		cubeAtt = attachment,
		beam = beam,
		light = pointLight
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCubeAttractionBeam(k)
	local v27 = v24[k]

	if not v27 then
		return
	end

	v24[k] = nil

	if v27.beam then
		v27.beam:Destroy()
	end

	if v27.cubeAtt then
		v27.cubeAtt:Destroy()
	end

	if v27.light then
		v27.light:Destroy()
	end
end

local function updateCubeAttractionBeam(p, magnitude)
	if not (p and p.beam and p.beam.Parent) then
		return
	end

	local v27 = 1 - math.clamp(magnitude / 18, 0, 1)
	local v28 = v27 * v27
	p.beam.Width0 = v28 * 0.8 + 0.15
	p.beam.Width1 = v28 * 0.4 + 0.08
	p.beam.Brightness = v28 * 3 + 0.8
	p.beam.TextureSpeed = v28 * 3 + 1
	p.beam.CurveSize0 = (1 - v28) * 5 + 2
	p.beam.CurveSize1 = -1 - (1 - v28) * 3

	if p.light then
		p.light.Brightness = v28 * 1.5 + 0.3
		p.light.Range = v28 * 8 + 4
	end

	p.beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6 - v28 * 0.3),
		NumberSequenceKeypoint.new(0.3, 0.4 - v28 * 0.25),
		NumberSequenceKeypoint.new(0.7, 0.5 - v28 * 0.25),
		NumberSequenceKeypoint.new(1, 0.85 - v28 * 0.3)
	})
end

local function createTetherBeam(character)
	local character2 = localPlayer.Character

	if not character2 then
		return nil
	end

	local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return nil
	end

	local attachment2 = humanoidRootPart:FindFirstChild("PollenTetherAtt")

	if not attachment2 then
		attachment2 = Instance.new("Attachment")
		attachment2.Name = "PollenTetherAtt"
		attachment2.Position = createVector(0, 0.5, 0)
		attachment2.Parent = humanoidRootPart
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "TetherAtt_" .. character.Name
	attachment.Position = createVector(0, 0.5, 0)
	attachment.Parent = humanoidRootPart2
	local trailColor2 = character2:GetAttribute("TrailColor2") or Color3.fromRGB(255, 220, 160)
	local trailColor22 = character:GetAttribute("TrailColor2") or Color3.fromRGB(200, 200, 255)
	local beam = Instance.new("Beam")
	beam.Name = "TetherBeam"
	beam.Attachment0 = attachment2
	beam.Attachment1 = attachment
	beam.FaceCamera = true
	beam.Segments = 15
	beam.TextureSpeed = 0.8
	beam.TextureLength = 2
	beam.Texture = "rbxasset://textures/Beam001.png"
	beam.LightEmission = 0.7
	beam.LightInfluence = 0.1
	beam.CurveSize0 = 3
	beam.CurveSize1 = 3
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, trailColor2),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 230)),
		ColorSequenceKeypoint.new(1, trailColor22)
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.3, 0.5),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 0.7)
	})
	beam.Brightness = 1.2
	beam.Parent = humanoidRootPart
	return {
		att1 = attachment,
		beam = beam
	}
end

fn = function(k)
	local v27 = v2[k]

	if not v27 then
		return
	end

	v2[k] = nil

	if v27.beam then
		v27.beam:Destroy()
	end

	if v27.att1 then
		v27.att1:Destroy()
	end
end

local function updateTetherBeam(p, magnitude)
	if not (p and p.beam and p.beam.Parent) then
		return
	end

	local v27 = 1 - math.clamp(magnitude / 22, 0, 1)
	p.beam.Width0 = v27 * 0.35 + 0.1
	p.beam.Width1 = v27 * 0.35 + 0.1
	p.beam.Brightness = v27 * 2 + 0.6
	p.beam.CurveSize0 = (1 - v27) * 4 + 1
	p.beam.CurveSize1 = (1 - v27) * 4 + 1
	p.beam.TextureSpeed = v27 * 1.5 + 0.5
	p.beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8 - v27 * 0.3),
		NumberSequenceKeypoint.new(0.3, 0.6 - v27 * 0.3),
		NumberSequenceKeypoint.new(0.7, 0.6 - v27 * 0.3),
		NumberSequenceKeypoint.new(1, 0.8 - v27 * 0.3)
	})
end

fn2 = function(instance)
	if v26 then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local pollenBuffColor = instance:GetAttribute("PollenBuffColor") or Color3.fromRGB(255, 220, 160)
	local HSV, v27, v28 = pollenBuffColor:ToHSV()
	local color = Color3.fromHSV((HSV + 0.1) % 1, math.max(0, v27 - 0.15), (math.min(1, v28 + 0.1)))
	local beams = {}
	local innerAtts = {}
	local outerAtts = {}

	for i = 1, 3 do
		local v32 = (i - 1) * 2.0943951023931953
		local attachment = Instance.new("Attachment")
		attachment.Name = "AuraIn_" .. i
		attachment.Position = Vector3.new(math.cos(v32) * 0.8800000000000001, -2, math.sin(v32) * 0.8800000000000001)
		attachment.Parent = humanoidRootPart
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "AuraOut_" .. i
		attachment2.Position = Vector3.new(math.cos(v32) * 2.2, -1.7, math.sin(v32) * 2.2)
		attachment2.Parent = humanoidRootPart
		local beam = Instance.new("Beam")
		beam.Name = "AuraBeam_" .. i
		beam.Attachment0 = attachment
		beam.Attachment1 = attachment2
		beam.FaceCamera = true
		beam.Segments = 8
		beam.TextureSpeed = 2
		beam.TextureLength = 0.6
		beam.Texture = "rbxasset://textures/Beam001.png"
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.CurveSize0 = 1.5
		beam.CurveSize1 = -0.5
		beam.Width0 = 0.08
		beam.Width1 = 0.25
		beam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.4, pollenBuffColor),
			ColorSequenceKeypoint.new(1, color)
		})
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.3, 0.15),
			NumberSequenceKeypoint.new(0.7, 0.2),
			NumberSequenceKeypoint.new(1, 0.7)
		})
		beam.Brightness = 2.5
		beam.Parent = humanoidRootPart
		table.insert(beams, beam)
		table.insert(innerAtts, attachment)
		table.insert(outerAtts, attachment2)
	end

	local renderSteppedConnection3 = nil
	renderSteppedConnection3 = RunService.RenderStepped:Connect(function()
		if not (humanoidRootPart and humanoidRootPart.Parent) then
			renderSteppedConnection3:Disconnect()
			return
		end

		local now = tick()

		for i = 1, 3 do
			local v32 = (i - 1) * 2.0943951023931953 + now * 2.5
			local v33 = math.sin(now * 3 + i) * 0.15

			if innerAtts[i] and innerAtts[i].Parent then
				innerAtts[i].Position = Vector3.new(
					math.cos(v32) * 0.8800000000000001,
					v33 + -2,
					math.sin(v32) * 0.8800000000000001
				)
			end

			if outerAtts[i] and outerAtts[i].Parent then
				outerAtts[i].Position = Vector3.new(math.cos(v32) * 2.2, v33 * 0.5 + -1.7, math.sin(v32) * 2.2)
			end

			if beams[i] and beams[i].Parent then
				beams[i].Brightness = math.sin(now * 4 + i * 2) * 0.8 + 2
			end
		end
	end)
	v26 = {
		beams = beams,
		innerAtts = innerAtts,
		outerAtts = outerAtts,
		conn = renderSteppedConnection3
	}
end

fn3 = function()
	if not v26 then
		return
	end

	local v27 = v26
	v26 = nil

	if v27.conn then
		v27.conn:Disconnect()
	end

	for _, beam in ipairs(v27.beams) do
		if beam and beam.Parent then
			beam:Destroy()
		end
	end

	for _, innerAtt in ipairs(v27.innerAtts) do
		if innerAtt and innerAtt.Parent then
			innerAtt:Destroy()
		end
	end

	for _, outerAtt in ipairs(v27.outerAtts) do
		if outerAtt and outerAtt.Parent then
			outerAtt:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCubeNetworkKey(part, part2)
	local v27 = tostring(part)
	local v28 = tostring(part2)

	if v28 < v27 then
		return v28 .. "_" .. v27
	end

	return v27 .. "_" .. v28
end

local function createCubeNetworkBeam(part, part2)
	local attachment = Instance.new("Attachment")
	attachment.Name = "NetAtt"
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "NetAtt"
	attachment2.Parent = part2
	local color = part.Color or Color3.fromRGB(255, 220, 140)
	local color2 = part2.Color or Color3.fromRGB(200, 200, 255)
	local color3 = Color3.new((color.R + color2.R) / 2, (color.G + color2.G) / 2, (color.B + color2.B) / 2)
	local beam = Instance.new("Beam")
	beam.Name = "NetworkBeam"
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.FaceCamera = true
	beam.Segments = 12
	beam.TextureSpeed = 0.6
	beam.TextureLength = 3
	beam.Texture = "rbxasset://textures/Beam001.png"
	beam.LightEmission = 0.8
	beam.LightInfluence = 0.1
	beam.CurveSize0 = 2
	beam.CurveSize1 = -2
	beam.Width0 = 0.12
	beam.Width1 = 0.12
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, color3),
		ColorSequenceKeypoint.new(1, color2)
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.3, 0.5),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 0.7)
	})
	beam.Brightness = 1.5
	beam.Parent = part
	return {
		attA = attachment,
		attB = attachment2,
		beam = beam
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCubeNetworkBeam(k)
	local v27 = v25[k]

	if not v27 then
		return
	end

	v25[k] = nil

	if v27.beam then
		v27.beam:Destroy()
	end

	if v27.attA then
		v27.attA:Destroy()
	end

	if v27.attB then
		v27.attB:Destroy()
	end
end

fn4 = function(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v27 = 20
	local v28 = nil

	for _, instance2 in ipairs(CollectionService:GetTagged("PollenFlower")) do
		local position = nil

		if instance2:IsA("BasePart") then
			position = instance2.Position
		elseif instance2:IsA("Model") then
			local primaryPart = instance2.PrimaryPart or instance2:FindFirstChildWhichIsA("BasePart")

			if primaryPart then
				position = primaryPart.Position
			end
		end

		if not position then
			continue
		end

		local magnitude = (position - humanoidRootPart.Position).Magnitude

		if not (magnitude < v27) then
			continue
		end

		v28 = position
		v27 = magnitude
	end

	if not v28 then
		return
	end

	local trailColor1 = instance:GetAttribute("TrailColor1") or Color3.fromRGB(255, 240, 160)
	local trailColor2 = instance:GetAttribute("TrailColor2") or Color3.fromRGB(255, 215, 60)
	local part = Instance.new("Part")
	part.Name = "PollinBeamAnchor"
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.CFrame = CFrame.new(v28)
	part.Parent = workspace.Terrain
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "PollinBurstAtt"
	attachment2.Parent = humanoidRootPart
	local beam = Instance.new("Beam")
	beam.Name = "PollinationBurst"
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.FaceCamera = true
	beam.Segments = 24
	beam.TextureSpeed = 4
	beam.TextureLength = 0.8
	beam.Texture = "rbxasset://textures/Beam001.png"
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = 0.8
	beam.Width1 = 0.1
	beam.Brightness = 4
	beam.CurveSize0 = 8
	beam.CurveSize1 = -5
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, trailColor1),
		ColorSequenceKeypoint.new(0.5, trailColor2),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.5)
	})
	beam.Parent = part
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "PollinFlash"
	pointLight.Color = trailColor1
	pointLight.Brightness = 3
	pointLight.Range = 10
	pointLight.Parent = part
	TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CurveSize0 = 1,
		CurveSize1 = -0.5,
		Width0 = 0.15
	}):Play()
	TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0.5,
		Range = 4
	}):Play()
	task.delay(0.25, function()
		if not beam.Parent then
			return
		end

		TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Brightness = 0,
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	Debris:AddItem(part, 0.8)
	Debris:AddItem(attachment2, 0.8)
end

local v27 = 0
RunService.Heartbeat:Connect(function()
	local now = tick()

	if now - v27 < 0.15 then
		return
	end

	v27 = now
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position
	local pollinated = character:GetAttribute("Pollinated")
	local v28 = {}

	for _, part in ipairs(CollectionService:GetTagged("PollenCombinedSeg")) do
		if not (part:IsA("BasePart") and part.Parent) then
			continue
		end

		local magnitude = (part.Position - position).Magnitude

		if not (magnitude <= 18) then
			continue
		end

		v28[part] = true

		if not v24[part] then
			v24[part] = createCubeAttractionBeam(part)
		end

		updateCubeAttractionBeam(v24[part], magnitude)
	end

	for k in pairs(v24) do
		if v28[k] then
			continue
		end

		removeCubeAttractionBeam(k) -- equivalent call inferred; original call site unknown
	end

	local v29 = {}

	if pollinated then
		for _, v30 in ipairs(Players:GetPlayers()) do
			if v30 == localPlayer then
				continue
			end

			local character2 = v30.Character

			if not (character2 and character2:GetAttribute("Pollinated")) then
				continue
			end

			local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				continue
			end

			local magnitude = (humanoidRootPart2.Position - position).Magnitude

			if not (magnitude <= 22) then
				continue
			end

			v29[character2] = true

			if not v2[character2] then
				v2[character2] = createTetherBeam(character2)
			end

			updateTetherBeam(v2[character2], magnitude)
		end
	end

	for k in pairs(v2) do
		if not v29[k] then
			fn(k)
		end
	end

	local tagged = CollectionService:GetTagged("PollenCombinedSeg")
	local v30 = {}

	for i = 1, #tagged - 1 do
		local part = tagged[i]

		if not (part:IsA("BasePart") and part.Parent) then
			continue
		end

		for i2 = i + 1, #tagged do
			local part2 = tagged[i2]

			if not (part2:IsA("BasePart") and part2.Parent and (part.Position - part2.Position).Magnitude <= 28) then
				continue
			end

			local cubeNetworkKey = getCubeNetworkKey(part, part2) -- equivalent call inferred; original call site unknown
			v30[cubeNetworkKey] = true

			if not v25[cubeNetworkKey] then
				v25[cubeNetworkKey] = createCubeNetworkBeam(part, part2)
			end

			if v25[cubeNetworkKey] and v25[cubeNetworkKey].beam then
				v25[cubeNetworkKey].beam.Brightness = math.sin(now * 3) * 0.8 + 1
			end
		end
	end

	for k in pairs(v25) do
		if v30[k] then
			continue
		end

		removeCubeNetworkBeam(k) -- equivalent call inferred; original call site unknown
	end
end)
local screenGui = nil
local frame = nil
local v28 = {}

local function ensureDebugGui()
	if screenGui and screenGui.Parent then
		return frame
	end

	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PollenDebugOverlay"
	screenGui.DisplayOrder = 100
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "DebugBG"
	frame2.Size = UDim2.new(0, 340, 0, 272)
	frame2.Position = UDim2.new(0, 8, 1, -280)
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BackgroundTransparency = 0.6
	frame2.BorderSizePixel = 0
	frame2.Parent = screenGui
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0, 6)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -8, 0, 18)
	textLabel.Position = UDim2.new(0, 4, 0, 2)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "Pollen Debug"
	textLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
	textLabel.TextSize = 11
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame2
	frame = Instance.new("Frame")
	frame.Name = "Entries"
	frame.Size = UDim2.new(1, -8, 1, -22)
	frame.Position = UDim2.new(0, 4, 0, 20)
	frame.BackgroundTransparency = 1
	frame.Parent = frame2
	return frame
end

local function addDebugEntry(p, p2, color)
	local debugGui = ensureDebugGui()

	if not debugGui then
		return
	end

	local v29 = (#v28 + 1 - 1) * 22
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 20)
	textLabel.Position = UDim2.new(0, 0, 0, v29)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = string.format("[%s] %s", p, p2)
	textLabel.TextColor3 = color
	textLabel.TextSize = 11
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = debugGui
	table.insert(v28, {
		label = textLabel,
		addedAt = tick()
	})

	while #v28 > 12 do
		local v30 = table.remove(v28, 1)

		if v30.label and v30.label.Parent then
			v30.label:Destroy()
		end
	end

	for i, v30 in ipairs(v28) do
		v30.label.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		local now = tick()
		local v29 = 1
		local flag2 = false

		while v29 <= #v28 do
			local v30 = v28[v29]
			local v31 = now - v30.addedAt

			if v31 > 6 then
				if v30.label and v30.label.Parent then
					v30.label:Destroy()
				end

				table.remove(v28, v29)
				flag2 = true
			else
				if v31 > 4 and v30.label and v30.label.Parent then
					v30.label.TextTransparency = (v31 - 4) / 2
				end

				v29 += 1
			end
		end

		if not flag2 then
			continue
		end

		for i, v30 in ipairs(v28) do
			v30.label.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function watchDebugLog(instance)
	instance:GetAttributeChangedSignal("PollenDebugLog"):Connect(function()
		local pollenDebugLog = instance:GetAttribute("PollenDebugLog")

		if not pollenDebugLog or pollenDebugLog == "" then
			return
		end

		local v29 = string.split(pollenDebugLog, "|")

		if #v29 < 4 then
			return
		end

		local v30 = v29[2]
		local v31 = v29[3]
		local v32 = string.split(v29[4], ",")
		addDebugEntry(
			v30,
			v31,
			Color3.fromRGB(tonumber(v32[1]) or 200, tonumber(v32[2]) or 200, tonumber(v32[3]) or 200)
		)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateDebugVisibility()
	local debugMode = pollenConfig and pollenConfig:FindFirstChild("DebugMode")
	local enabled = debugMode and debugMode.Value or false

	if screenGui then
		screenGui.Enabled = enabled
	end

	if enabled then
		ensureDebugGui()

		if screenGui then
			screenGui.Enabled = true
		end
	end
end

local debugMode = pollenConfig and pollenConfig:FindFirstChild("DebugMode")

if debugMode then
	debugMode.Changed:Connect(updateDebugVisibility)
end

local function setupDebugForCharacter(instance)
	if not instance then
		return
	end

	watchDebugLog(instance) -- equivalent call inferred; original call site unknown
	updateDebugVisibility() -- equivalent call inferred; original call site unknown
end

local character = localPlayer.Character and localPlayer.Character

if character then
	character:GetAttributeChangedSignal("PollenDebugLog"):Connect(function()
		local pollenDebugLog = character:GetAttribute("PollenDebugLog")

		if not pollenDebugLog or pollenDebugLog == "" then
			return
		end

		local v29 = string.split(pollenDebugLog, "|")

		if #v29 < 4 then
			return
		end

		local v30 = v29[2]
		local v31 = v29[3]
		local v32 = string.split(v29[4], ",")
		addDebugEntry(
			v30,
			v31,
			Color3.fromRGB(tonumber(v32[1]) or 200, tonumber(v32[2]) or 200, tonumber(v32[3]) or 200)
		)
	end)
	updateDebugVisibility() -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(setupDebugForCharacter)
local frame2 = nil
local textLabel = nil
local playerGui = localPlayer:FindFirstChild("PlayerGui")

if playerGui then
	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = "PollenBuffTimer"
	screenGui2.ResetOnSpawn = false
	screenGui2.DisplayOrder = 9
	screenGui2.IgnoreGuiInset = false
	screenGui2.Parent = playerGui
	local frame3 = Instance.new("Frame")
	frame3.Name = "TimerContainer"
	frame3.Size = UDim2.new(0, 140, 0, 8)
	frame3.Position = UDim2.new(0.5, -70, 0.75, 0)
	frame3.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame3.BackgroundTransparency = 0.4
	frame3.BorderSizePixel = 0
	frame3.Visible = false
	frame3.Parent = screenGui2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 4)
	uICorner.Parent = frame3
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	uIStroke.Transparency = 0.7
	uIStroke.Thickness = 1
	uIStroke.Parent = frame3
	frame2 = Instance.new("Frame")
	frame2.Name = "Fill"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.Position = UDim2.new(0, 0, 0, 0)
	frame2.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
	frame2.BackgroundTransparency = 0.15
	frame2.BorderSizePixel = 0
	frame2.Parent = frame3
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 4)
	uICorner2.Parent = frame2
	textLabel = Instance.new("TextLabel")
	textLabel.Name = "Label"
	textLabel.Size = UDim2.new(1, 0, 0, 14)
	textLabel.Position = UDim2.new(0, 0, -1.8, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 11
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Text = ""
	textLabel.Parent = frame3
	RunService.RenderStepped:Connect(function()
		local character2 = localPlayer.Character

		if not character2 then
			frame3.Visible = false
			return
		end

		local pollenBuff = character2:GetAttribute("PollenBuff")
		local pollenBuffExpires = character2:GetAttribute("PollenBuffExpires")

		if pollenBuff and pollenBuffExpires and pollenBuffExpires > 0 then
			local v29 = pollenBuffExpires - workspace:GetServerTimeNow()

			if v29 > 0 then
				local pollenBuffPreset = character2:GetAttribute("PollenBuffPreset") or ""
				local pollenBuffColor = character2:GetAttribute("PollenBuffColor")
				local v30 = math.clamp(v29 / math.max(character2:GetAttribute("PollenBuffDuration") or v29, 0.1), 0, 1)
				frame3.Visible = true
				local v31 = springUpdate(v30, 0.016666666666666666)
				frame2.Size = UDim2.new(v31, 0, 1, 0)

				if pollenBuffColor then
					frame2.BackgroundColor3 = pollenBuffColor
					uIStroke.Color = pollenBuffColor
				end

				textLabel.Text = ((pollenBuffPreset == "" or not pollenBuffPreset) and "Pollen Buff" or pollenBuffPreset) .. " " .. string.format(
					"%.1fs",
					v29
				)

				if v29 < 3 then
					frame2.BackgroundTransparency = math.abs((math.sin(tick() * 4))) * 0.25 + 0.15

					if flag then
						return
					end

					flag = true
					local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						return
					end

					Audio:Play("rbxasset://sounds/electronicpingshort.wav", {
						Volume = 0.25,
						PlaybackSpeed = 1.4 + math.random() * 0.3,
						RollOffMaxDistance = 30,
						RollOffMinDistance = 8,
						Parent = humanoidRootPart
					})
					return
				else
					frame2.BackgroundTransparency = 0.15
					flag = false
					return
				end
			end
		end

		local pollenDebuff = character2:GetAttribute("PollenDebuff")
		local pollenDebuffExpires = character2:GetAttribute("PollenDebuffExpires")

		if pollenDebuff and pollenDebuffExpires and pollenDebuffExpires > 0 then
			local v29 = pollenDebuffExpires - workspace:GetServerTimeNow()

			if v29 > 0 then
				local v30 = math.clamp(v29 / (character2:GetAttribute("PollenDebuffDuration") or 5), 0, 1)
				frame3.Visible = true
				frame2.Size = UDim2.new(v30, 0, 1, 0)
				frame2.BackgroundColor3 = Color3.fromRGB(100, 50, 130)
				uIStroke.Color = Color3.fromRGB(100, 50, 130)
				frame2.BackgroundTransparency = 0.15
				textLabel.Text = "Slowed! " .. string.format("%.1fs", v29)
				return
			end
		end

		frame3.Visible = false
	end)
end

local playerGui2 = localPlayer:FindFirstChild("PlayerGui")
local frame3

if playerGui2 then
	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = "PollenNotifications"
	screenGui2.ResetOnSpawn = false
	screenGui2.DisplayOrder = 8
	screenGui2.IgnoreGuiInset = false
	screenGui2.Parent = playerGui2
	frame3 = Instance.new("Frame")
	frame3.Name = "Container"
	frame3.Size = UDim2.new(0.5, 0, 0.2, 0)
	frame3.Position = UDim2.new(0.25, 0, 0.06, 0)
	frame3.BackgroundTransparency = 1
	frame3.Parent = screenGui2
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 6)
	uIListLayout.Parent = frame3
else
	frame3 = nil
end

local function showPollenNotification(joined, color)
	if not frame3 then
		return
	end

	local textColor = color or Color3.new(1, 1, 1)
	local HSV, v30, v31 = textColor:ToHSV()
	local color2 = Color3.fromHSV(HSV, math.min(1, v30 + 0.1), (math.max(0, v31 * 0.25)))
	local color3 = Color3.fromHSV(HSV, math.max(0, v30 - 0.2), (math.min(1, v31 + 0.15)))
	local children = frame3:GetChildren()
	local count = 0

	for _, frame4 in ipairs(children) do
		if frame4:IsA("Frame") then
			count += 1
		end
	end

	if count >= 3 then
		for _, frame4 in ipairs(children) do
			if not frame4:IsA("Frame") then
				continue
			end

			frame4:Destroy()
			break
		end
	end

	local frame4 = Instance.new("Frame")
	frame4.Size = UDim2.new(0.7, 0, 0, 38)
	frame4.AnchorPoint = Vector2.new(0.5, 0)
	frame4.Position = UDim2.new(0.5, 0, 0, 0)
	frame4.BackgroundColor3 = color2
	frame4.BackgroundTransparency = 0.25
	frame4.BorderSizePixel = 0
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.Parent = frame4
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = color3
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.3
	uIStroke.Parent = frame4
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 14)
	uIPadding.PaddingRight = UDim.new(0, 14)
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.PaddingBottom = UDim.new(0, 4)
	uIPadding.Parent = frame4

	for _, v32 in ipairs({ 0.02, 0.98 }) do
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.new(0, 18, 0, 18)
		textLabel2.Position = UDim2.new(v32, 0, 0.5, 0)
		textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = "✨"
		textLabel2.TextColor3 = color3
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextTransparency = 0.2
		textLabel2.Parent = frame4
		local v33 = v32
		task.spawn(function()
			local v35 = v33 * 100
			local renderSteppedConnection3 = nil
			renderSteppedConnection3 = RunService.RenderStepped:Connect(function()
				if not textLabel2.Parent then
					renderSteppedConnection3:Disconnect()
					return
				end

				textLabel2.Rotation = math.sin(tick() * 3 + v35) * 15
				textLabel2.TextTransparency = math.abs((math.sin(tick() * 2 + v35))) * 0.4 + 0.1
			end)
		end)
	end

	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -32, 1, 0)
	textLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextColor3 = textColor
	textLabel2.Text = joined or ""
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.TextStrokeTransparency = 0.3
	textLabel2.TextStrokeColor3 = color2
	textLabel2.Parent = frame4
	local size = frame4.Size
	frame4.Size = UDim2.new(size.X.Scale * 0.3, 0, 0, 12)
	frame4.BackgroundTransparency = 0.8
	frame4.Rotation = math.random(-8, 8)
	textLabel2.TextTransparency = 1
	uIStroke.Transparency = 1
	frame4.Parent = frame3
	TweenService:Create(frame4, TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Size = size,
		Rotation = 0,
		BackgroundTransparency = 0.25
	}):Play()
	task.delay(0.1, function()
		if not textLabel2.Parent then
			return
		end

		TweenService:Create(textLabel2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.3
		}):Play()
	end)
	task.delay(0.5, function()
		if not frame4.Parent then
			return
		end

		TweenService:Create(uIStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), {
			Transparency = 0.6,
			Thickness = 3
		}):Play()
	end)
	task.delay(2.5, function()
		if not frame4.Parent then
			return
		end

		local tween = TweenService:Create(frame4, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(size.X.Scale * 0.4, 0, 0, 8),
			BackgroundTransparency = 1,
			Rotation = math.random(-12, 12)
		})
		local tween2 = TweenService:Create(
			textLabel2,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		local tween3 = TweenService:Create(
			uIStroke,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween2:Play()
		tween3:Play()
		tween.Completed:Connect(function()
			frame4:Destroy()
		end)
	end)
end

local function watchPollenNotifications(instance)
	if not instance then
		return
	end

	instance:GetAttributeChangedSignal("PollenNotification"):Connect(function()
		local pollenNotification = instance:GetAttribute("PollenNotification")

		if not pollenNotification or pollenNotification == "" then
			return
		end

		local v29 = string.split(pollenNotification, "|")

		if #v29 < 3 then
			return
		end

		local v30 = string.split(v29[#v29], ",")
		local color = Color3.fromRGB(tonumber(v30[1]) or 255, tonumber(v30[2]) or 255, tonumber(v30[3]) or 255)
		showPollenNotification(table.concat(v29, "|", 2, #v29 - 1), color)
	end)
end

local character2 = localPlayer.Character and localPlayer.Character

if character2 then
	character2:GetAttributeChangedSignal("PollenNotification"):Connect(function()
		local pollenNotification = character2:GetAttribute("PollenNotification")

		if not pollenNotification or pollenNotification == "" then
			return
		end

		local v29 = string.split(pollenNotification, "|")

		if #v29 < 3 then
			return
		end

		local v30 = string.split(v29[#v29], ",")
		local color = Color3.fromRGB(tonumber(v30[1]) or 255, tonumber(v30[2]) or 255, tonumber(v30[3]) or 255)
		showPollenNotification(table.concat(v29, "|", 2, #v29 - 1), color)
	end)
end

localPlayer.CharacterAdded:Connect(watchPollenNotifications)

if not renderSteppedConnection2 and JUICE.TrailBreathing then
	local trailBreathSpeed = JUICE.TrailBreathSpeed or 2.5
	local trailBreathAmount = JUICE.TrailBreathAmount or 0.12
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		if not JUICE.TrailBreathing then
			return
		end

		local now = tick()
		local _ = 1 + math.sin(now * trailBreathSpeed) * trailBreathAmount

		for k, v29 in pairs(v4) do
			if not v29.active then
				continue
			end

			local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local pollenTrail = humanoidRootPart:FindFirstChild("PollenTrail")

			if not (pollenTrail and pollenTrail.Enabled) then
				continue
			end

			if not pollenTrail:GetAttribute("BaseWidthScale") then
				pollenTrail:SetAttribute("BaseWidthScale", true)
			end

			local baseBrightness = pollenTrail:GetAttribute("BaseBrightness") or pollenTrail.Brightness

			if not pollenTrail:GetAttribute("BaseBrightness") then
				pollenTrail:SetAttribute("BaseBrightness", pollenTrail.Brightness)
			end

			pollenTrail.Brightness = baseBrightness * (math.sin(now * trailBreathSpeed * 1.3) * 0.15 + 0.9)
		end
	end)
end

print("[PollenTrailClient] Beam + Ground mode | Attribute-driven | Direct HRP | Juice FX")