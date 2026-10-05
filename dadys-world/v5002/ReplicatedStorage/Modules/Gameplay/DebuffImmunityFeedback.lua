local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local RibeccaEmpowered = require(script.Parent.RibeccaEmpowered)
local color = Color3.fromRGB(140, 240, 150)
local color2 = Color3.fromRGB(190, 110, 255)
local color3 = Color3.fromRGB(225, 190, 255)
local color4 = Color3.fromRGB(60, 20, 90)
local vector2 = Vector2.new(1.3, 0.65)
local vector3 = Vector2.new(0.92, 1.12)
local v = { "IMMUNE" }
local v2 = nil

local function linesFor(p)
	if v2 ~= nil then
		return v2 and v2(p) or v
	end

	local success, result = pcall(function()
		local ServerStorage = game:GetService("ServerStorage")
		return require(ServerStorage.Modules.Data.ImmunityPopLines)
	end)
	local v3

	if success and type(result) == "function" and result then
		v3 = result
	else
		v3 = false
	end

	v2 = v3

	if not v2 then
		warn("[DebuffImmunityFeedback] ImmunityPopLines unavailable, using the default line:", result)
	end

	return v2 and v2(p) or v
end

local v3 = nil

local function pickLine(p)
	local v4 = linesFor(p)
	local v5 = math.random(1, #v4)

	if #v4 > 1 and v5 == v3 then
		v5 = v5 % #v4 + 1
	end

	v3 = v5
	return v4[v5]
end

local color5 = Color3.fromRGB(255, 240, 255)
local v4 = { "Burst", "Graphic" }
local v5 = {
	Burst = 1.6
}

local function debugLog(...) end

local v6 = {}
local v7 = {}

local function manifestNode(value)
	local v8 = v7[value]

	if v8 ~= nil then
		return v8 or nil
	end

	local manifest = Audio:GetManifest()

	if not manifest then
		return nil
	end

	for _, v10 in ipairs(value:gsub("^Sounds%.", ""):split(".")) do
		if typeof(manifest) == "table" then
			manifest = manifest[v10]

			if manifest == nil then
				break
			end
		else
			manifest = nil
			break
		end
	end

	v7[value] = manifest or false

	if not manifest then
		debugLog("no manifest entry at", value)
	end

	return manifest
end

local function isInManifest(p)
	return manifestNode(p) ~= nil
end

local function findReplicatedSound(value)
	local sound = ReplicatedStorage

	for _, childName in ipairs(value:split(".")) do
		sound = sound:FindFirstChild(childName)

		if not sound then
			return nil
		end
	end

	return sound:IsA("Sound") and sound or nil
end

local function soundLength(p)
	local v8 = manifestNode(p)

	if typeof(v8) == "table" and type(v8.duration) == "number" and v8.duration > 0 then
		return v8.duration
	end

	local replicatedSound = findReplicatedSound(p)

	if replicatedSound and replicatedSound.TimeLength > 0 then
		return replicatedSound.TimeLength
	end

	return 3
end

local function spawnTemplateVFX(humanoidRootPart)
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local ribeccaShrugFX = parts and parts:FindFirstChild("RibeccaShrugFX")

	if not ribeccaShrugFX then
		return false
	end

	local clone = ribeccaShrugFX:Clone()
	clone:PivotTo(humanoidRootPart.CFrame)

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.Massless = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")

	if primaryPart then
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = primaryPart
		weldConstraint.Parent = clone
	end

	clone.Parent = workspace
	local playAnimation = clone:FindFirstChild("PlayAnimation", true)

	if playAnimation and playAnimation:IsA("Script") then
		playAnimation.Disabled = false
	end

	Debris:AddItem(clone, 3)
	return true
end

local function spawnFallbackBurst(humanoidRootPart)
	local attachment = Instance.new("Attachment")
	attachment.Name = "ShrugBurst"
	attachment.Parent = humanoidRootPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color2),
		ColorSequenceKeypoint.new(0.5, color),
		ColorSequenceKeypoint.new(1, color2)
	})
	particleEmitter.LightEmission = 0.6
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.42, 0.6)
	particleEmitter.Speed = NumberRange.new(6, 10)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Acceleration = createVector(0, -8, 0)
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Parent = attachment
	particleEmitter:Emit(18)
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Color = ColorSequence.new(color5, color2)
	particleEmitter2.LightEmission = 1
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.2, 0.25),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.24, 0.36)
	particleEmitter2.Speed = NumberRange.new(2, 4)
	particleEmitter2.SpreadAngle = Vector2.new(180, 180)
	particleEmitter2.RotSpeed = NumberRange.new(-360, 360)
	particleEmitter2.Rate = 0
	particleEmitter2.Enabled = false
	particleEmitter2.Parent = attachment
	particleEmitter2:Emit(6)
	Debris:AddItem(attachment, 1.1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ribeccaTemplate(instance, childName)
	if instance:GetAttribute("ToonName") ~= "Ribecca" then
		return nil
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local ribecca = parts and parts:FindFirstChild("Ribecca")
	return ribecca and ribecca:FindFirstChild(childName)
end

local function spawnEmpoweredParticles(instance, humanoidRootPart)
	local attachment = ribeccaTemplate(instance, "Empowered_Particles") -- equivalent call inferred; original call site unknown

	if not attachment then
		return false
	end

	if not attachment:IsA("Attachment") then
		warn(
			"[DebuffImmunityFeedback]",
			"Empowered_Particles",
			"is a",
			attachment.ClassName,
			"- expected an Attachment"
		)
		return false
	end

	local clone = attachment:Clone()
	clone.Position = createVector(0, -2, 0)
	local emitters = {}

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		table.insert(emitters, emitter)
	end

	clone.Parent = humanoidRootPart

	for _, v8 in ipairs(emitters) do
		v8:Emit(20)
	end

	Debris:AddItem(clone, 3)
	debugLog("empowered particles on", instance.Name, "- emitters:", #emitters)
	return true
end

local function buildPopBillboard(instance)
	local v8 = ribeccaTemplate(instance, "Empowered_Billboard") -- equivalent call inferred; original call site unknown

	if v8 then
		local clone = v8:Clone()
		local textLabel = clone:FindFirstChildWhichIsA("TextLabel", true)

		if textLabel then
			return clone, textLabel, true
		end

		warn("[DebuffImmunityFeedback]", "Empowered_Billboard", "has no TextLabel - using the code-built pop")
		clone:Destroy()
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.fromScale(4.5, 1)
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 80
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	local v9 = linesFor(instance)
	local v10 = math.random(1, #v9)

	if #v9 > 1 and v10 == v3 then
		v10 = v10 % #v9 + 1
	end

	v3 = v10
	textLabel.Text = v9[v10]
	textLabel.TextColor3 = color3
	textLabel.Parent = billboardGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = color4
	uIStroke.Thickness = 5
	uIStroke.Parent = textLabel
	return billboardGui, textLabel, false
end

local function flashImages(popBillboard)
	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, childName in ipairs(v4) do
		local image = popBillboard:FindFirstChild(childName, true)

		if not (image and image:IsA("ImageLabel")) then
			continue
		end

		image.Rotation = math.random(0, 359)
		local v8 = image:FindFirstChildOfClass("UIScale")

		if not v8 then
			v8 = Instance.new("UIScale")
			v8.Parent = image
		end

		local scale = v5[childName] or v8.Scale
		v8.Scale = 0
		TweenService:Create(v8, tweenInfo, {
			Scale = scale
		}):Play()
		local parent = image
		task.delay(0.18, function()
			if not parent.Parent then
				return
			end

			TweenService:Create(parent, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
		end)
	end
end

local function spawnPopText(instance, humanoidRootPart)
	local v8 = (math.random() * 2 - 1) * 0.8
	local rotation = (math.random() * 2 - 1) * 9
	local v10 = math.random(0, 1) == 0 and -1 or 1
	local part = Instance.new("Part")
	part.Name = "ImmunePop"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = humanoidRootPart.CFrame * CFrame.new(v8, 3.5, 0)
	part.Parent = workspace
	local popBillboard, parent, v12 = buildPopBillboard(instance)
	popBillboard.Parent = part
	parent.AnchorPoint = Vector2.new(0.5, 0.5)
	parent.Position = UDim2.fromScale(0.5 - v10 * 0.3, 0.5)
	parent.Size = UDim2.fromScale(vector2.X, vector2.Y)
	parent.Rotation = rotation - v10 * 22
	local uIStroke = parent:FindFirstChildOfClass("UIStroke")
	local v13 = parent:FindFirstChildOfClass("UIScale")

	if not v13 then
		v13 = Instance.new("UIScale")
		v13.Parent = parent
	end

	v13.Scale = 0
	flashImages(popBillboard)
	local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(v13, tweenInfo, {
		Scale = 1.35
	}):Play()
	TweenService:Create(parent, tweenInfo, {
		Position = UDim2.fromScale(0.5 + v10 * 0.05, 0.5),
		Size = UDim2.fromScale(vector3.X, vector3.Y),
		Rotation = rotation + v10 * 10
	}):Play()

	if not v12 then
		TweenService:Create(parent, tweenInfo, {
			TextColor3 = color
		}):Play()
	end

	task.delay(0.18, function()
		if not parent.Parent then
			return
		end

		local tweenInfo2 = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(v13, tweenInfo2, {
			Scale = 1
		}):Play()
		TweenService:Create(parent, tweenInfo2, {
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Rotation = rotation
		}):Play()

		if not v12 then
			TweenService:Create(uIStroke, tweenInfo2, {
				Thickness = 3
			}):Play()
		end
	end)
	TweenService:Create(part, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = part.CFrame + createVector(0, 2.5, 0)
	}):Play()
	task.delay(0.4, function()
		if not parent.Parent then
			return
		end

		local tweenInfo3 = TweenInfo.new(0.7999999999999999, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(parent, tweenInfo3, {
			TextTransparency = 1,
			Position = UDim2.fromScale(0.5 + v10 * 0.25, 0.5),
			Rotation = rotation + v10 * 14
		}):Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo3, {
				Transparency = 1
			}):Play()
		end
	end)
	return part
end

local function playSound(instance, parent, result)
	if instance:GetAttribute("ToonName") == "Ribecca" then
		if not result then
			return nil
		end

		local v8 = Audio:Play("rbxassetid://123543560714826", {
			Volume = 0.25,
			Parent = parent
		})

		if v8 then
			return v8.TimeLength > 0 and v8.TimeLength or 3
		end

		return nil
	else
		if not (manifestNode("Sounds.Effects.RibeccaShrug") ~= nil and Audio:Play("Sounds.Effects.RibeccaShrug", {
			Name = "RibeccaShrug",
			Volume = 0.6,
			Parent = parent
		})) then
			return nil
		end

		local v8 = manifestNode("Sounds.Effects.RibeccaShrug")

		if typeof(v8) == "table" and type(v8.duration) == "number" and v8.duration > 0 then
			return v8.duration
		end

		local replicatedSound = findReplicatedSound("Sounds.Effects.RibeccaShrug")

		if replicatedSound and replicatedSound.TimeLength > 0 then
			return replicatedSound.TimeLength
		end

		return 3
	end
end

return {
	Notify = function(instance, value)
		if not RunService:IsServer() or (typeof(instance) ~= "Instance" or not instance.Parent) or instance:GetAttribute("DebuffImmune") ~= true then
			return
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local now = os.clock()
		local v8 = v6[instance]

		if v8 and now - v8 < 1.5 then
			debugLog("cooldown swallow", instance.Name, value)
			return
		end

		v6[instance] = now

		if not v8 then
			instance.AncestryChanged:Once(function()
				if not instance.Parent then
					v6[instance] = nil
				end
			end)
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
		debugLog(string.format(
			"%s shrugged off %s",
			playerFromCharacter and playerFromCharacter.Name or instance.Name,
			(tostring(value or "debuff"))
		))
		local success, result = pcall(RibeccaEmpowered.TryGrant, instance, value)

		if not success then
			warn("[DebuffImmunityFeedback] RibeccaEmpowered.TryGrant failed:", result)
			result = false
		end

		local success2, result2 = pcall(function()
			if not spawnTemplateVFX(humanoidRootPart) then
				-- equivalent call inferred; original call site unknown
				if not ribeccaTemplate(instance, "Empowered_Particles") then
					spawnFallbackBurst(humanoidRootPart)
				end
			end

			if result then
				spawnEmpoweredParticles(instance, humanoidRootPart)
			end

			local parent = spawnPopText(instance, humanoidRootPart)
			local v10 = 1.2
			local v11 = playSound(instance, parent, result)

			if v11 then
				v10 = math.max(v10, v11)
			end

			Debris:AddItem(parent, v10 + 0.2)
		end)

		if not success2 then
			warn("[DebuffImmunityFeedback] pop feedback failed:", result2)
		end
	end
}