local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoulvesterGuardFx = {}
local color = Color3.fromRGB(129, 215, 180)
local color2 = Color3.fromRGB(255, 240, 200)
local color3 = Color3.fromRGB(255, 120, 80)
local color4 = Color3.fromRGB(180, 210, 255)
local v = {
	Mark = {
		Pulse = {
			from = 2,
			to = 8,
			life = 0.6
		},
		Flash = 0.3,
		Tether = {
			width = 0.35,
			life = 0.35
		},
		Glyph = {
			size = 4,
			life = 0.7
		},
		Volume = 0.6
	},
	Blink = {
		GhostFade = 0.4,
		GhostTransparency = 0.45,
		StripStep = 0.14,
		StripHold = 1.2,
		StageStep = 0.12,
		StageTransparency = 0.12,
		StageTick = 0.35,
		DeparturePulse = {
			from = 8,
			to = 1,
			life = 0.3
		},
		ArrivalPulse = {
			from = 2,
			to = 14,
			life = 0.4
		},
		Flash = 0.35,
		Glyph = {
			size = 5,
			life = 0.5
		},
		Shake = {
			magnitude = 3,
			roughness = 7,
			fadeIn = 0.04,
			fadeOut = 0.4
		},
		FovPunch = 10,
		FovTime = 0.3,
		AllyShake = {
			magnitude = 1.2,
			roughness = 5,
			fadeIn = 0.05,
			fadeOut = 0.3
		},
		Volume = 0.9
	},
	Block = {
		Glyph = {
			size = 9,
			life = 0.6
		},
		Shockwave = {
			from = 3,
			to = 24,
			life = 0.55
		},
		Shards = {
			count = 10,
			size = 0.7,
			distance = 12,
			life = 0.5
		},
		CasterPulse = {
			from = 2,
			to = 8,
			life = 0.5
		},
		Flash = 0.4,
		Callout = {
			life = 1.1,
			rise = 3
		},
		Screen = {
			transparency = 0.35,
			inTime = 0.05,
			outTime = 0.45
		},
		Shake = {
			magnitude = 5,
			roughness = 9,
			fadeIn = 0.03,
			fadeOut = 0.55
		},
		FovPunch = -6,
		FovTime = 0.35,
		ObserverRadius = 50,
		ObserverShake = {
			magnitude = 2,
			roughness = 6,
			fadeIn = 0.05,
			fadeOut = 0.35
		},
		Volume = 1
	},
	HighlightFlash = {
		fill = 0.88,
		hold = 0.3
	},
	ImpactFrame = {
		flashTime = 0.07,
		sparkLength = 11,
		sparkWidth = 0.9,
		sparkLife = 0.22
	},
	Stun = {
		Callout = {
			life = 1,
			rise = 1.5
		}
	},
	Poof = {
		emit = 20,
		life = 3
	},
	ArrivalPoof = {
		emit = 6,
		life = 1.2,
		maxLifetime = 0.6,
		opacity = 0.4
	},
	Petals = {
		count = 34,
		size = 0.7,
		rise = 8,
		spread = 3.5,
		life = 1.25,
		color = Color3.fromRGB(220, 60, 110)
	},
	ApexPetals = {
		count = 17,
		size = 0.6,
		rise = 6,
		spread = 2.5,
		life = 1,
		color = Color3.fromRGB(235, 90, 140)
	}
}
local v2 = {
	Sheath = "rbxassetid://104775450784771",
	Block = "rbxassetid://88576097467297",
	SwordAfter = "rbxassetid://76802210464357",
	PreTeleport = "rbxassetid://124333766522872",
	Teleport = "rbxassetid://82117212099427",
	Arrive = "rbxassetid://125698689731252",
	Tick = "Sounds.UI.Ping"
}
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local CameraShaker = require(ReplicatedStorage.Modules.External.CameraShaker)
local SoulvesterGuardCinematic = require(script.Parent.SoulvesterGuardCinematic)

-- equivalent calls inferred from this helper; original call sites unknown
local function rootOf(instance)
	return instance and instance:FindFirstChild("HumanoidRootPart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localCharacter()
	return Players.LocalPlayer and Players.LocalPlayer.Character
end

local function labPrint(...)
	local localPlayer = Players.LocalPlayer

	if localPlayer and (localPlayer:GetAttribute("SoulvesterLabArmed") == true or localPlayer:GetAttribute("AccessTier") == "Dev") then
		print("[SoulvesterLab/client]", ...)
	end
end

local function fxPart(name, shape, color5, size, cFrame, value)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape
	part.Material = Enum.Material.Neon
	part.Color = color5
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = value or 0.3
	part.Size = size
	part.CFrame = cFrame
	part.Parent = workspace
	return part
end

local function tweenOut(part, duration, p, p2)
	Debris:AddItem(part, duration + 0.1)
	p.Transparency = 1
	TweenService:Create(part, TweenInfo.new(duration, p2 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

local function groundCFrame(instance)
	local v3 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if not v3 then
		return nil
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local v4 = v3.Size.Y / 2 + (humanoid and humanoid.HipHeight or 2) - 0.1
	return v3.CFrame * CFrame.new(0, -v4, 0)
end

local function pulse(p, color5, data)
	local v3 = groundCFrame(p)

	if not v3 then
		return
	end

	local cylinder = Enum.PartType.Cylinder
	local vector2 = Vector3.new(0.2, data.from, data.from)
	local cFrame = v3 * CFrame.Angles(0, 0, 1.5707963267948966)
	local part = Instance.new("Part")
	part.Name = "GuardPulse"
	part.Shape = cylinder
	part.Material = Enum.Material.Neon
	part.Color = color5
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 0.3
	part.Size = vector2
	part.CFrame = cFrame
	part.Parent = workspace
	tweenOut(part, data.life, {
		Size = Vector3.new(0.2, data.to, data.to)
	})
end

local v3 = false

local function poof(position, p)
	local v4 = p or v.Poof
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local smokeParticle = parts and parts:FindFirstChild("SmokeParticle")

	if not smokeParticle then
		return
	end

	local success, result = pcall(smokeParticle.Clone, smokeParticle)

	if not (success and result) then
		return
	end

	result.CFrame = CFrame.new(position)
	result.Anchored = true
	result.CanCollide = false
	result.CanQuery = false
	result.CanTouch = false
	result.Parent = workspace

	for _, emitter in ipairs(result:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if v4.color then
			emitter.Color = ColorSequence.new(v4.color)
		end

		if not v3 then
			v3 = true
			labPrint(string.format(
				"smoke rig: %s lifetime %.2f-%.2f s",
				emitter.Name,
				emitter.Lifetime.Min,
				emitter.Lifetime.Max
			))
		end

		if v4.maxLifetime then
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(
				math.min(lifetime.Min, v4.maxLifetime),
				(math.min(lifetime.Max, v4.maxLifetime))
			)
		end

		if v4.opacity then
			local numberSequenceKeypoints = {}

			for _, keypoint in ipairs(emitter.Transparency.Keypoints) do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(
						keypoint.Time,
						1 - (1 - keypoint.Value) * v4.opacity,
						keypoint.Envelope * v4.opacity
					)
				)
			end

			emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
		end

		emitter:Emit(v4.emit)
	end

	Debris:AddItem(result, v4.life)
end

local function shards(instance, color5, shards2)
	local v4 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if not v4 then
		return
	end

	local position = v4.Position

	for i = 1, shards2.count do
		local v5 = i / shards2.count * 3.141592653589793 * 2 + math.random() * 0.4
		local v6 = 0.2 + math.random() * 0.8
		local unit = Vector3.new(math.cos(v5), v6, (math.sin(v5))).Unit
		local block = Enum.PartType.Block
		local vector2 = Vector3.new(shards2.size * 0.4, shards2.size * 0.4, shards2.size * 2)
		local cframe = CFrame.lookAt(position, position + unit)
		local part = Instance.new("Part")
		part.Name = "GuardShard"
		part.Shape = block
		part.Material = Enum.Material.Neon
		part.Color = color5
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 0.1
		part.Size = vector2
		part.CFrame = cframe
		part.Parent = workspace
		local cframe2 = CFrame.lookAt(position + unit * shards2.distance, position + unit * (shards2.distance + 1))
		tweenOut(part, shards2.life, {
			CFrame = cframe2,
			Size = Vector3.new(0.05, 0.05, shards2.size * 0.5)
		})
	end
end

local function streak(position, position2, color5, width, life)
	local v4 = position2 - position
	local magnitude = v4.Magnitude

	if magnitude < 1 then
		return
	end

	local block = Enum.PartType.Block
	local vector2 = Vector3.new(width, width, magnitude)
	local cframe = CFrame.lookAt(position + v4 / 2, position2)
	local part = Instance.new("Part")
	part.Name = "GuardStreak"
	part.Shape = block
	part.Material = Enum.Material.Neon
	part.Color = color5
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 0.15
	part.Size = vector2
	part.CFrame = cframe
	part.Parent = workspace
	tweenOut(part, life, {
		Size = Vector3.new(0.05, 0.05, magnitude)
	})
end

local function ghost(instance, cframe, color5, blink, value, p)
	if not (instance and instance.PrimaryPart) then
		return nil
	end

	local archivable = instance.Archivable
	instance.Archivable = true
	local success, result = pcall(function()
		return instance:Clone()
	end)
	instance.Archivable = archivable

	if not (success and result) then
		return
	end

	result.Name = "GuardAfterimage"
	local descendants = {}

	for _, descendant in ipairs(result:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false

			if p then
				descendant.LocalTransparencyModifier = 0

				if descendant.Transparency < 1 then
					descendant.Transparency = math.max(descendant.Transparency, blink.StageTransparency)
				end
			else
				descendant.Material = Enum.Material.ForceField
				descendant.Color = color5
				descendant.Transparency = descendant.Transparency >= 1 and 1 or blink.GhostTransparency
			end

			table.insert(descendants, descendant)
		elseif (descendant:IsA("Decal") or descendant:IsA("Texture")) and not p then
			descendant.Transparency = 1
		elseif descendant:IsA("LuaSourceContainer") or descendant:IsA("Humanoid") or descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Highlight") or descendant:IsA("BillboardGui") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") then
			descendant:Destroy()
		end
	end

	result:PivotTo(cframe)
	result.Parent = workspace
	Debris:AddItem(result, (value or 0) + blink.GhostFade + 0.1)
	task.delay(value or 0, function()
		local tweenInfo = TweenInfo.new(blink.GhostFade, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v4 in ipairs(descendants) do
			if v4.Parent and v4.Transparency < 1 then
				TweenService:Create(v4, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end
	end)
	return result
end

local v4 = 0

function SoulvesterGuardFx.RevealDelay()
	return (math.max(v4 - os.clock(), 0))
end

local function setLocalHidden(folder, p)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = p and 1 or 0
		end
	end
end

local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function uniqueId(p)
	count += 1
	return p .. "#" .. count
end

local function flash(instance, color5, flash2, p)
	if not (instance and instance.Parent) then
		return
	end

	local highlightFlash = v.HighlightFlash
	local v5 = uniqueId(p) -- equivalent call inferred; original call site unknown
	HighlightController:PlayHighlight(instance, "Target", {
		FillColor = color5,
		FillTransparency = highlightFlash.fill,
		OutlineColor = color5,
		OutlineTransparency = 0,
		Decay = flash2,
		OpaqueDuration = flash2 * highlightFlash.hold,
		Priority = HighlightController.Priority.LOCAL_ABILITY
	}, v5)
	task.delay(flash2, function()
		HighlightController:ClearHighlight(v5)
	end)
end

local function shieldGlyph(instance, imageColor, glyph)
	local v5 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if not v5 then
		return
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "GuardGlyph"
	billboardGui.Adornee = v5
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.fromScale(0, 0)
	billboardGui.StudsOffset = createVector(0, 1, 0)
	billboardGui.LightInfluence = 0
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://121908174722814"
	imageLabel.ImageColor3 = imageColor
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = billboardGui
	billboardGui.Parent = v5
	Debris:AddItem(billboardGui, glyph.life + 0.1)
	TweenService:Create(
		billboardGui,
		TweenInfo.new(glyph.life * 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(glyph.size, glyph.size)
		}
	):Play()
	task.delay(glyph.life * 0.45, function()
		if billboardGui.Parent then
			TweenService:Create(
				imageLabel,
				TweenInfo.new(glyph.life * 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					ImageTransparency = 1
				}
			):Play()
			TweenService:Create(
				billboardGui,
				TweenInfo.new(glyph.life * 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = UDim2.fromScale(glyph.size * 1.4, glyph.size * 1.4)
				}
			):Play()
		end
	end)
end

local function callout(instance, text, color5, callout2)
	local v5 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if not v5 then
		return
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "GuardCallout"
	billboardGui.Adornee = v5
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.fromScale(10, 2.2)
	billboardGui.StudsOffset = createVector(0, 4.5, 0)
	billboardGui.LightInfluence = 0
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	local scale = callout2.scale or 1
	billboardGui.Size = UDim2.fromScale(10 * scale, 2.2 * scale)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(0, 0)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Rotation = (math.random() - 0.5) * 7
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), color5)
	uIGradient.Parent = textLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 3
	uIStroke.Color = Color3.fromRGB(20, 20, 30)
	uIStroke.Parent = textLabel
	textLabel.Parent = billboardGui
	billboardGui.Parent = v5
	Debris:AddItem(billboardGui, callout2.life + 0.1)
	TweenService:Create(textLabel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1)
	}):Play()
	TweenService:Create(billboardGui, TweenInfo.new(callout2.life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = Vector3.new(0, 4.5 + callout2.rise, 0)
	}):Play()
	task.delay(callout2.life * 0.55, function()
		if billboardGui.Parent then
			local tweenInfo = TweenInfo.new(callout2.life * 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end)
end

local screenGui = nil
local v5 = nil

local function ensureScreen()
	if screenGui and screenGui.Parent then
		return
	end

	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoulvesterGuardFlash"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = -4
	v5 = {}

	local function edge(size, position, rotation)
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = size
		frame.Position = position
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = rotation
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Parent = frame
		frame.Parent = screenGui
		table.insert(v5, frame)
	end

	edge(UDim2.new(1, 0, 0.22, 0), UDim2.new(0, 0, 0, 0), 90)
	edge(UDim2.new(1, 0, 0.22, 0), UDim2.new(0, 0, 0.78, 0), -90)
	edge(UDim2.new(0.22, 0, 1, 0), UDim2.new(0, 0, 0, 0), 0)
	edge(UDim2.new(0.22, 0, 1, 0), UDim2.new(0.78, 0, 0, 0), 180)
	screenGui.Parent = playerGui
end

local function screenFlash(color5, screen)
	ensureScreen()

	if not v5 then
		return
	end

	for _, v6 in ipairs(v5) do
		v6.BackgroundColor3 = color5
		v6.BackgroundTransparency = 1
		local tween = TweenService:Create(
			v6,
			TweenInfo.new(screen.inTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				BackgroundTransparency = screen.transparency
			}
		)
		tween:Play()
		local v7 = v6
		tween.Completed:Connect(function()
			TweenService:Create(v7, TweenInfo.new(screen.outTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function petals(p, data)
	local v6 = groundCFrame(p)

	if not v6 then
		return
	end

	task.spawn(function()
		for i = 1, data.count do
			if i % 12 == 0 then
				task.wait()

				if not p.Parent then
					break
				end
			end

			local v7 = i / data.count * 3.141592653589793 * 2 + math.random() * 0.5
			local v8 = 0.8 + math.random() * data.spread
			local cFrame = v6 * CFrame.new(math.cos(v7) * v8, 0.2, math.sin(v7) * v8) * CFrame.Angles(
				math.random() * 3.141592653589793,
				math.random() * 3.141592653589793,
				0
			)
			local cylinder = Enum.PartType.Cylinder
			local color5 = data.color
			local vector2 = Vector3.new(0.05, data.size, data.size * 0.7)
			local part = Instance.new("Part")
			part.Name = "GuardPetal"
			part.Shape = cylinder
			part.Material = Enum.Material.Neon
			part.Color = color5
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Transparency = 0.1
			part.Size = vector2
			part.CFrame = cFrame
			part.Parent = workspace
			part.Material = Enum.Material.SmoothPlastic
			local cFrame2 = (cFrame + Vector3.new(
				(math.random() - 0.5) * 1.5,
				data.rise * (0.7 + math.random() * 0.5),
				(math.random() - 0.5) * 1.5
			)) * CFrame.Angles(math.random() * 3.141592653589793 * 2, math.random() * 3.141592653589793 * 2, 0)
			tweenOut(part, data.life * (0.8 + math.random() * 0.4), {
				CFrame = cFrame2
			}, Enum.EasingStyle.Sine)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sound(p, parent, volume)
	local v6 = v2[p]

	if v6 and parent then
		pcall(function()
			local v7 = Audio:Play(v6, {
				Parent = parent,
				Volume = volume or 1
			})

			if v7 then
				SoundGroupManager.AssignSFXSound(v7)
			end
		end)
	end
end

local v6 = nil

local function shake(data, value)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or SoulvesterGuardCinematic.isActive() then
		return
	end

	if not v6 then
		v6 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
			currentCamera.CFrame *= p
		end)
	end

	v6:Start()
	v6:ShakeOnce(data.magnitude * (value or 1), data.roughness, data.fadeIn, data.fadeOut)
end

local function impactSpark(position)
	local impactFrame = v.ImpactFrame

	for i = 1, 2 do
		local block = Enum.PartType.Block
		local color5 = Color3.new(1, 1, 1)
		local vector2 = Vector3.new(
			impactFrame.sparkWidth,
			impactFrame.sparkLength * 0.25,
			impactFrame.sparkWidth * 0.25
		)
		local cFrame = CFrame.new(position) * CFrame.Angles(0, 0, (i - 1) * 1.5707963267948966 + 0.7853981633974483)
		local part = Instance.new("Part")
		part.Name = "GuardSpark"
		part.Shape = block
		part.Material = Enum.Material.Neon
		part.Color = color5
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 0
		part.Size = vector2
		part.CFrame = cFrame
		part.Parent = workspace
		tweenOut(part, impactFrame.sparkLife, {
			Size = Vector3.new(0.05, impactFrame.sparkLength, 0.05)
		}, Enum.EasingStyle.Quart)
	end
end

local function impactFlash()
	local impactFrame = v.ImpactFrame
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = "SoulvesterImpactFrame"
	screenGui2.ResetOnSpawn = false
	screenGui2.IgnoreGuiInset = true
	screenGui2.DisplayOrder = 6
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Parent = screenGui2
	screenGui2.Parent = playerGui
	Debris:AddItem(screenGui2, impactFrame.flashTime + 0.05)
	TweenService:Create(frame, TweenInfo.new(impactFrame.flashTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopShake()
	if v6 then
		v6:Stop()
	end
end

local count2 = 0
local fieldOfView = nil
local v7 = nil

local function fovPunch(fovPunch2, fovTime)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or fovPunch2 == 0 or SoulvesterGuardCinematic.isActive() then
		return
	end

	count2 += 1
	local v8 = count2

	if not fieldOfView then
		fieldOfView = currentCamera.FieldOfView
	end

	local fieldOfView2 = fieldOfView
	currentCamera.FieldOfView = fieldOfView2 + fovPunch2
	v7 = TweenService:Create(currentCamera, TweenInfo.new(fovTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fieldOfView2
	})
	v7:Play()
	v7.Completed:Connect(function()
		if v8 == count2 then
			currentCamera.FieldOfView = fieldOfView2
			fieldOfView = nil
			v7 = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function settleFov()
	local currentCamera = workspace.CurrentCamera
	count2 += 1

	if v7 then
		v7:Cancel()
		v7 = nil
	end

	if currentCamera and fieldOfView then
		currentCamera.FieldOfView = fieldOfView
	end

	fieldOfView = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function distanceToLocal(instance)
	local v8 = localCharacter() -- equivalent call inferred; original call site unknown
	local v9 = rootOf(v8) -- equivalent call inferred; original call site unknown
	local v10 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if v9 and v10 then
		return (v9.Position - v10.Position).Magnitude
	end

	return 1e999
end

local function renderMark(instance, instance2)
	local mark = v.Mark
	pulse(instance, color, mark.Pulse)
	flash(instance, color, mark.Flash, "SoulvesterMark_" .. instance.Name)
	shieldGlyph(instance, color4, mark.Glyph)
	local v8 = rootOf(instance2) -- equivalent call inferred; original call site unknown
	local v9 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if v8 and v9 and instance2 ~= instance then
		streak(v8.Position, v9.Position, color, mark.Tether.width, mark.Tether.life)
		local ball = Enum.PartType.Ball
		local cframe = CFrame.new(v8.Position)
		local part = Instance.new("Part")
		part.Name = "GuardMarkOrb"
		part.Shape = ball
		part.Material = Enum.Material.Neon
		part.Color = color
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 0.1
		part.Size = createVector(0.7, 0.7, 0.7)
		part.CFrame = cframe
		part.Parent = workspace
		Debris:AddItem(part, 0.4)
		TweenService:Create(part, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = CFrame.new(v9.Position),
			Size = createVector(0.25, 0.25, 0.25),
			Transparency = 0.6
		}):Play()
	end

	if localCharacter() ~= instance2 then
		local humanoidRootPart = instance2 and instance2:FindFirstChild("HumanoidRootPart") or v9
		local volume = mark.Volume
		local sheath = v2.Sheath

		if sheath then
			if not humanoidRootPart then
				return
			end

			pcall(function()
				local v10 = Audio:Play(sheath, {
					Parent = humanoidRootPart,
					Volume = volume or 1
				})

				if v10 then
					SoundGroupManager.AssignSFXSound(v10)
				end
			end)
		end
	end
end

local function renderBlock(p, instance, p2, p3)
	local block = v.Block
	local v8 = p == "Redirect"
	local v9 = type(p3) ~= "table" and 1 or tonumber(p3.chain) or 1
	local v10

	if v8 then
		v10 = color3
	else
		v10 = color2
	end

	local v11 = rootOf(instance) -- equivalent call inferred; original call site unknown

	if v11 then
		impactSpark(v11.Position + createVector(0, 1.2, 0))
		local v12 = localCharacter() -- equivalent call inferred; original call site unknown

		if v12 == instance or v12 == p2 then
			impactFlash()
		end
	end

	shieldGlyph(instance, v10, block.Glyph)
	shards(instance, v10, block.Shards)
	pulse(instance, color, block.Shockwave)
	flash(instance, color, block.Flash, "SoulvesterBlock_" .. instance.Name)
	local callout2 = block.Callout
	local color5

	if v9 >= 2 then
		callout2 = setmetatable({
			scale = math.min(1 + (v9 - 1) * 0.14, 1.5)
		}, {
			__index = block.Callout
		})

		if v9 >= 3 then
			color5 = Color3.fromRGB(255, 210, 110)
		else
			color5 = v10
		end
	else
		color5 = v10
	end

	callout(instance, v9 >= 2 and string.format("BLOCKED! x%d", v9) or "BLOCKED!", color5, callout2)

	if p2 and p2 ~= instance then
		pulse(p2, v10, block.CasterPulse)
		local v13

		if v8 then
			v13 = color3
		else
			v13 = color
		end

		flash(p2, v13, block.Flash, "SoulvesterBlock_" .. p2.Name)

		if v8 then
			callout(p2, "TOOK THE HIT", color3, block.Callout)
		end
	end

	local parent = rootOf(instance) -- equivalent call inferred; original call site unknown
	sound("Block", parent, block.Volume) -- equivalent call inferred; original call site unknown
	task.delay(0.25, function()
		if instance.Parent then
			local parent2 = rootOf(instance) -- equivalent call inferred; original call site unknown
			local v15 = block.Volume * 0.9
			local swordAfter = v2.SwordAfter

			if swordAfter then
				if not parent2 then
					return
				end

				pcall(function()
					local v16 = Audio:Play(swordAfter, {
						Parent = parent2,
						Volume = v15 or 1
					})

					if v16 then
						SoundGroupManager.AssignSFXSound(v16)
					end
				end)
			end
		end
	end)
	local v13 = localCharacter() -- equivalent call inferred; original call site unknown

	if v13 == instance or v13 == p2 then
		if v8 then
			if v13 == p2 then
				v10 = color3
			end

			screenFlash(v10, block.Screen)
		end

		shake(block.Shake)
		fovPunch(block.FovPunch, block.FovTime)
	else
		local v14 = distanceToLocal(instance) -- equivalent call inferred; original call site unknown

		if v14 < block.ObserverRadius then
			shake(block.ObserverShake, 1 - v14 / block.ObserverRadius)
		end
	end
end

local function renderBlink(instance, instance2, value)
	local blink = v.Blink
	local parent = rootOf(instance2) -- equivalent call inferred; original call site unknown

	if not parent then
		return
	end

	local from

	if typeof(value) == "CFrame" and value then
		from = value
	elseif type(value) == "table" then
		from = value.from or nil
	else
		from = nil
	end

	local v9 = type(value) ~= "table" and 1 or tonumber(value.afterimages) or 1
	local v10 = type(value) ~= "table" and "Strip" or value.replay or "Strip"

	if from then
		local cylinder = Enum.PartType.Cylinder
		local vector2 = Vector3.new(0.2, blink.DeparturePulse.from, blink.DeparturePulse.from)
		local cFrame = from * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		local part = Instance.new("Part")
		part.Name = "GuardPulse"
		part.Shape = cylinder
		part.Material = Enum.Material.Neon
		part.Color = color
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 0.3
		part.Size = vector2
		part.CFrame = cFrame
		part.Parent = workspace
		tweenOut(part, blink.DeparturePulse.life, {
			Size = Vector3.new(0.2, blink.DeparturePulse.to, blink.DeparturePulse.to)
		})
		poof(from.Position)
		local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart") or parent
		sound("PreTeleport", humanoidRootPart, blink.Volume) -- equivalent call inferred; original call site unknown
	end

	task.wait(0.05)

	if not (instance2.Parent and parent.Parent) then
		return
	end

	if from then
		local to

		if type(value) == "table" then
			to = value.to
		else
			to = false
		end

		if typeof(to) ~= "CFrame" then
			to = parent.CFrame
		end

		if instance2 == localCharacter() then
			labPrint(string.format(
				"blink: moved %.1f studs (replay=%s, afterimages=%d)",
				(to.Position - from.Position).Magnitude,
				tostring(v10),
				v9
			))
		end

		sound("Teleport", parent, blink.Volume) -- equivalent call inferred; original call site unknown
		local v11 = math.floor(v9)

		if v10 == "Stages" and v11 >= 1 then
			v4 = os.clock() + v11 * blink.StageStep
			setLocalHidden(instance2, true)
			local v12 = ghost(instance2, from, color, blink, 60, true)

			for i = 1, v11 do
				local v13 = from:Lerp(to, (i - 1) / v11)
				task.delay((i - 1) * blink.StageStep, function()
					if instance2.Parent then
						if v12 and v12.Parent then
							v12:PivotTo(v13)
						end

						local cylinder = Enum.PartType.Cylinder
						local cFrame = v13 * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
						local part = Instance.new("Part")
						part.Name = "GuardPulse"
						part.Shape = cylinder
						part.Material = Enum.Material.Neon
						part.Color = color
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.CastShadow = false
						part.Transparency = 0.3
						part.Size = createVector(0.2, 3, 3)
						part.CFrame = cFrame
						part.Parent = workspace
						tweenOut(part, 0.25, {
							Size = createVector(0.2, 1, 1)
						})
						local parent2 = rootOf(instance2) -- equivalent call inferred; original call site unknown
						local stageTick = blink.StageTick
						local tick = v2.Tick

						if tick then
							if not parent2 then
								return
							end

							pcall(function()
								local v18 = Audio:Play(tick, {
									Parent = parent2,
									Volume = stageTick or 1
								})

								if v18 then
									SoundGroupManager.AssignSFXSound(v18)
								end
							end)
						end
					else
						if v12 then
							v12:Destroy()
							v12 = nil
						end

						setLocalHidden(instance2, false)
					end
				end)
			end

			task.delay(v11 * blink.StageStep, function()
				if v12 then
					v12:Destroy()
					v12 = nil
				end

				setLocalHidden(instance2, false)

				if instance2.Parent then
					local parent2 = rootOf(instance2) -- equivalent call inferred; original call site unknown
					sound("Arrive", parent2, blink.Volume) -- equivalent call inferred; original call site unknown
					local v15 = groundCFrame(instance2)

					if v15 then
						poof(v15.Position, v.ArrivalPoof)
					end

					pulse(instance2, color, blink.ArrivalPulse)
					shieldGlyph(instance2, color4, blink.Glyph)
					flash(instance2, color, blink.Flash, "SoulvesterBlink_" .. instance2.Name)
				end
			end)
		elseif v10 == "Strip" and v11 >= 1 then
			local stripHold = blink.StripHold

			for i = 1, v11 do
				local v12 = (i - 1) / v11
				local v13 = (i - 1) * blink.StripStep
				task.delay(v13, function()
					if instance2.Parent then
						ghost(instance2, from:Lerp(to, v12), color, blink, (math.max(stripHold - v13, 0.1)))
					end
				end)
			end
		end
	end

	if v10 ~= "Stages" or not (v9 >= 1) then
		local v11 = groundCFrame(instance2)

		if v11 then
			poof(v11.Position, v.ArrivalPoof)
		end

		pulse(instance2, color, blink.ArrivalPulse)
		shieldGlyph(instance2, color4, blink.Glyph)
		flash(instance2, color, blink.Flash, "SoulvesterBlink_" .. instance2.Name)
	end

	local v11 = localCharacter() -- equivalent call inferred; original call site unknown

	if v11 == instance2 then
		shake(blink.Shake)

		if not SoulvesterGuardCinematic.isActive() then
			fovPunch(blink.FovPunch, blink.FovTime)
		end
	elseif v11 == instance then
		shake(blink.AllyShake)
	end
end

local function renderHeroShot(p, p2, p3)
	local v8 = type(p3) == "table" and p3 or {}
	local v9 = {
		camera = v8.camera ~= false,
		pose = v8.pose ~= false,
		lighting = v8.lighting ~= false,
		particles = v8.particles ~= false,
		banner = v8.banner ~= false,
		subtitle = v8.subtitle,
		void = v8.void == true,
		animation = v8.animation,
		tuning = v8.tuning,
		at = v8.at
	}

	if v9.particles then
		local petals2 = type(v8.tuning) == "table" and tonumber(v8.tuning.Petals) or v.Petals.count

		if petals2 > 0 then
			local object = setmetatable({
				count = petals2
			}, {
				__index = v.Petals
			})
			local object2 = setmetatable({
				count = math.floor(petals2 * 0.5 + 0.5)
			}, {
				__index = v.ApexPetals
			})
			petals(p2, object) -- equivalent call inferred; original call site unknown
			local duration = v8.duration or 1
			task.delay(math.max(duration - 0.34, 0.2) * 0.5 + 0.12, function()
				if p2.Parent then
					petals(p2, object2) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local camera

	if p2 == localCharacter() then
		camera = v9.camera
	else
		camera = false
	end

	if camera then
		settleFov() -- equivalent call inferred; original call site unknown
		stopShake() -- equivalent call inferred; original call site unknown
		SoulvesterGuardCinematic.claim()
	end

	task.wait(0.05)

	if p2.Parent and p.Parent then
		v9.revealDelay = SoulvesterGuardFx.RevealDelay()
		SoulvesterGuardCinematic.play(p, p2, v8.attacker, v8.duration or 1, v9)
	elseif camera then
		SoulvesterGuardCinematic.unclaim()
	end
end

local color5 = Color3.fromRGB(255, 70, 70)

local function renderPierced(p, p2)
	local block = v.Block
	shieldGlyph(p, Color3.fromRGB(90, 50, 60), block.Glyph)
	callout(p, "GUARD PIERCED!", color5, block.Callout)
	local v8 = localCharacter() -- equivalent call inferred; original call site unknown

	if v8 == p or v8 == p2 then
		screenFlash(color5, block.Screen)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderStun(p, value)
	local stun = v.Stun
	local v8 = typeof(value) == "number" and value or 1.5
	task.spawn(function()
		task.wait(0.5)
		local v9 = os.clock() + math.max(v8 - 0.4, 0.5)

		while SoulvesterGuardCinematic.isActive() and os.clock() < v9 do
			task.wait(0.1)
		end

		if p.Parent then
			callout(p, "STUNNED", color2, stun.Callout)
		end
	end)
end

function SoulvesterGuardFx.RenderObject(list)
	local v8 = list[1]
	local v9 = list[2]
	local v10 = list[3]
	local v11 = list[4]

	if not (v9 and v9.Parent) then
		return
	end

	local lastTime = os.clock()
	local localPlayer = Players.LocalPlayer

	if localPlayer and localPlayer:GetAttribute("SoulvesterLabArmed") == true then
		task.defer(function()
			local v12 = (os.clock() - lastTime) * 1000

			if v12 > 4 then
				warn(string.format("[GuardSpike] fx %s took %.1f ms in its frame", tostring(v8), v12))
			end
		end)
	end

	if v8 == "Mark" then
		renderMark(v9, v10)
	elseif v8 == "Blink" then
		renderBlink(v9, v10, v11)
	elseif v8 == "Nullify" or v8 == "Redirect" then
		renderBlock(v8, v9, v10, v11)

		if v10 and v10 == localCharacter() then
			task.delay(0.3, function()
				labPrint("block: " .. tostring(v10:GetAttribute("SoulvesterLastBlock")))
			end)
		end
	elseif v8 == "Stun" then
		renderStun(v9, v11) -- equivalent call inferred; original call site unknown
	elseif v8 == "Pierced" then
		renderPierced(v9, v10)
	elseif v8 == "HeroShot" then
		renderHeroShot(v9, v10, v11)
	end
end

return SoulvesterGuardFx