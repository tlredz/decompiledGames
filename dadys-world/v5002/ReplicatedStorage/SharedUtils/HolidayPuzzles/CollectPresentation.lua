local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectPresentation = {}
local v = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOut(p: number)
	return 1 - (1 - p) * (1 - p)
end

local function easeIn(p: number)
	return p * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anchorOf(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") and instance.PrimaryPart then
		return instance.PrimaryPart
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

function CollectPresentation.findTemplate(p)
	local child = ReplicatedStorage:FindFirstChild(p.TokenFolder)
	local instance = child and child:FindFirstChild(p.TokenTemplate)

	if instance and (instance:IsA("BasePart") or instance:IsA("Model")) then
		return instance, "ReplicatedStorage." .. p.TokenFolder .. "." .. p.TokenTemplate
	end

	return nil, nil
end

local v2 = {}

function CollectPresentation.ensureTemplate(data)
	local template, v3 = CollectPresentation.findTemplate(data)

	if template or not data.MeshId or RunService:IsClient() then
		return template, v3
	end

	local v4 = "ReplicatedStorage." .. data.TokenFolder .. "." .. data.TokenTemplate

	if v2[data.TokenTemplate] then
		local child = ReplicatedStorage:WaitForChild(data.TokenFolder, 15)
		local child2 = child and child:WaitForChild(data.TokenTemplate, 15)
		return child2, child2 and v4 or nil
	else
		v2[data.TokenTemplate] = true
		local AssetService = game:GetService("AssetService")
		local success, result = pcall(function()
			return AssetService:CreateMeshPartAsync(data.MeshId)
		end)

		if not (success and result) and typeof(Content) == "table" and Content.fromUri then
			success, result = pcall(function()
				return AssetService:CreateMeshPartAsync(Content.fromUri(data.MeshId))
			end)
		end

		if success and result then
			result.Name = data.TokenTemplate

			if data.TextureId then
				result.TextureID = data.TextureId
			end

			result.Anchored = true
			result.CanCollide = false
			local parent = ReplicatedStorage:FindFirstChild(data.TokenFolder)

			if not parent then
				parent = Instance.new("Folder")
				parent.Name = data.TokenFolder
				parent.Parent = ReplicatedStorage
			end

			result.Parent = parent
			return result, v4 .. " (built from " .. data.MeshId .. ")"
		else
			v2[data.TokenTemplate] = nil
			warn(("[CollectPresentation] could not build %s from %s: %s"):format(
				tostring(data.TokenTemplate),
				tostring(data.MeshId),
				(tostring(result))
			))
			return nil, nil
		end
	end
end

function CollectPresentation.duration(data)
	return data.EmergeTime + data.ToHeadTime + data.SpinTime + data.FlyInTime
end

function CollectPresentation.cloneMesh(instance, p: number)
	local clone = instance:Clone()

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		end
	end

	local v3 = {}

	if clone:IsA("BasePart") then
		table.insert(v3, clone)
	end

	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(v3, part)
		end
	end

	for _, v4 in ipairs(v3) do
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanQuery = false
		v4.CanTouch = false
	end

	local fn

	if clone:IsA("Model") then
		local extentsSize = clone:GetExtentsSize()
		local v4 = p / math.max(extentsSize.X, extentsSize.Y, extentsSize.Z, 0.01)
		local v5 = clone:GetScale() * v4
		clone:ScaleTo(v5)

		fn = function(p2: number)
			clone:ScaleTo((math.max(v5 * p2, 0.01)))
		end
	else
		local size = clone.Size * (p / math.max(clone.Size.X, clone.Size.Y, clone.Size.Z, 0.01))
		clone.Size = size

		fn = function(p2: number)
			clone.Size = size * p2
		end
	end

	return clone, fn
end

local function makeGlow(data, parent)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = data.TokenColor
	pointLight.Parent = parent
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = data.SparkleTexture or "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(data.TokenColor)
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new(0.35, 0)
	particleEmitter.Lifetime = NumberRange.new(0.4, 0.7)
	particleEmitter.Speed = NumberRange.new(0.5, 1.5)
	particleEmitter.Parent = parent

	local function lerp(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end

	return function(p: number)
		local v3 = pointLight
		local glowBrightness = data.GlowBrightness
		v3.Brightness = glowBrightness + (data.SpinGlowBrightness - glowBrightness) * p
		local v4 = pointLight
		local glowRange = data.GlowRange
		v4.Range = glowRange + (data.SpinGlowRange - glowRange) * p
		local v5 = particleEmitter
		local sparkleRate = data.SparkleRate
		v5.Rate = sparkleRate + (data.SpinSparkleRate - sparkleRate) * p
	end
end

local function sfxBus()
	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local audio = modules and modules:FindFirstChild("Audio")
	local soundGroupManager = audio and audio:FindFirstChild("SoundGroupManager")

	if not soundGroupManager then
		return nil
	end

	local success, result = pcall(function()
		local module = require(soundGroupManager)
		return module.GetGroup("SFX")
	end)

	if success then
		return result
	end

	return nil
end

local function playSound(p: string?, volume: number?)
	local audio = ReplicatedStorage:FindFirstChild("SharedUtils") and ReplicatedStorage.SharedUtils:FindFirstChild("Audio")

	if audio and p then
		task.spawn(function()
			pcall(function()
				local module = require(audio)
				module:Play(p, {
					Volume = volume,
					SoundGroup = sfxBus()
				})
			end)
		end)
	end
end

local function makeToken(data)
	local template = CollectPresentation.findTemplate(data)
	local v3, fn

	if template then
		v3, fn = CollectPresentation.cloneMesh(template, data.TokenSize)
	else
		if not v[data.TokenTemplate] then
			v[data.TokenTemplate] = true
			warn(("[CollectPresentation] %s not found in ReplicatedStorage.%s — collectibles fly as a plain orb"):format(
				tostring(data.TokenTemplate),
				(tostring(data.TokenFolder))
			))
		end

		v3 = Instance.new("Part")
		v3.Shape = Enum.PartType.Ball
		v3.Material = Enum.Material.Neon
		v3.Color = data.TokenColor
		v3.Anchored = true
		v3.CanCollide = false
		v3.CanQuery = false
		v3.CanTouch = false
		local size = createVector(1, 1, 1) * data.TokenSize
		v3.Size = size

		fn = function(p: number)
			v3.Size = size * p
		end
	end

	v3.Name = "HalloweenCollectToken"
	local parent = anchorOf(v3) -- equivalent call inferred; original call site unknown
	local fn2 = not parent and function(_: number) end or makeGlow(data, parent)
	fn2(0)
	return v3, fn, fn2
end

local function makeCaption(p, p2, list)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "HalloweenCollectCaption"
	billboardGui.Adornee = p2
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, p.HeadHeight + p.CaptionOffset, 0)
	billboardGui.Size = UDim2.fromOffset(460, #list * 36)
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextSize = 28
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Text = table.concat(list, "\n")
	textLabel.Parent = billboardGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 2
	uIStroke.Parent = textLabel
	billboardGui.Parent = p2

	local function setOpacity(p3: number)
		textLabel.TextTransparency = 1 - p3
		uIStroke.Transparency = 1 - p3
	end

	textLabel.TextTransparency = 1
	uIStroke.Transparency = 1
	return billboardGui, setOpacity
end

local function burst(data, parent)
	local attachment = Instance.new("Attachment")
	attachment.Name = "HalloweenCollectBurst"
	attachment.Parent = parent
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = data.SparkleTexture or "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(data.TokenColor)
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new(0.6, 0)
	particleEmitter.Lifetime = NumberRange.new(0.5, 0.9)
	particleEmitter.Speed = NumberRange.new(6, 10)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Rate = 0
	particleEmitter.Parent = attachment
	particleEmitter:Emit(data.BurstCount)
	Debris:AddItem(attachment, 2)
	playSound(data.Sound, data.SoundVolume)
end

function CollectPresentation.play(data, primaryPart, list)
	if RunService:IsServer() then
		warn("[CollectPresentation] play is client-only")
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local position = nil

	if typeof(primaryPart) == "Vector3" then
		position = primaryPart
	elseif typeof(primaryPart) == "Instance" then
		if not primaryPart:IsA("BasePart") then
			if primaryPart:IsA("Model") and primaryPart.PrimaryPart then
				primaryPart = primaryPart.PrimaryPart
			else
				primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		position = primaryPart and primaryPart.Position
	end

	local v3 = position or humanoidRootPart.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function headPosition()
		local stickerOverride = humanoidRootPart:FindFirstChild("StickerOverride")

		if stickerOverride and stickerOverride:IsA("Attachment") then
			return stickerOverride.WorldPosition
		end

		return humanoidRootPart.Position + Vector3.new(0, data.HeadHeight, 0)
	end

	local token, v4, v5 = makeToken(data)
	token:PivotTo(CFrame.new(v3))
	token.Parent = workspace
	playSound(data.FlowSound)
	local v6 = v3 + Vector3.new(0, data.RiseHeight, 0)
	local v7 = data.EmergeTime + data.ToHeadTime
	local v8 = v7 + data.SpinTime
	local v9 = v8 + data.FlyInTime
	local lastTime = os.clock()
	local v10 = false
	local v11, v12

	if list and #list > 0 then
		v11, v12 = makeCaption(data, humanoidRootPart, list)
	else
		v12 = nil
		v11 = nil
	end

	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v13 = os.clock() - lastTime

		if v9 <= v13 or not humanoidRootPart.Parent then
			heartbeatConnection:Disconnect()
			v10 = true
		else
			local v14 = headPosition() -- equivalent call inferred; original call site unknown
			local v15, v16, v17

			if v13 < data.EmergeTime then
				local v19 = easeOut(v13 / data.EmergeTime)
				v15 = v3:Lerp(v6, v19)
				v16 = v19 * 0.8 + 0.2
				v17 = 0
			elseif v13 < v7 then
				v15 = v6:Lerp(v14, easeOut((v13 - data.EmergeTime) / data.ToHeadTime))
				v16 = 1
				v17 = 0
			elseif v13 < v8 then
				v15 = v14 + Vector3.new(0, math.sin(v13 * 6) * 0.15, 0)
				v17 = easeOut((v13 - v7) / data.SpinTime)
				v16 = 1
			else
				local v18 = (v13 - v8) / data.FlyInTime
				local v19 = v18 * v18
				v15 = v14:Lerp(humanoidRootPart.Position, v19)
				v16 = 1 - v19 * 0.8
				v17 = 1
			end

			v4(v16)
			v5(v17)

			if v12 and v7 <= v13 then
				v12((math.min((v13 - v7) / 0.25, 1)))
			end

			token:PivotTo(CFrame.new(v15) * CFrame.Angles(0, math.rad(v13 * data.SpinSpeed % 360), 0))
		end
	end)

	while not v10 do
		task.wait()
	end

	token:Destroy()

	if humanoidRootPart.Parent then
		burst(data, humanoidRootPart)
	end

	if v11 then
		task.spawn(function()
			v12(1)
			task.wait(data.CaptionHoldTime)
			local lastTime2 = os.clock()

			while v11.Parent and os.clock() - lastTime2 < 0.25 do
				v12(1 - (os.clock() - lastTime2) / 0.25)
				task.wait()
			end

			v11:Destroy()
		end)
	end
end

local function backOut(p: number)
	local v3 = p - 1
	return v3 ^ 3 * 2.70158 + 1 + v3 ^ 2 * 1.70158
end

local function localRoot()
	local localPlayer = Players.LocalPlayer
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
	local v3 = inGamePlayers and inGamePlayers:FindFirstChild(localPlayer.Name) or localPlayer.Character
	local humanoidRootPart = v3 and (v3:FindFirstChild("HumanoidRootPart") or v3.PrimaryPart)

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function clearTags(folder)
	local CollectionService = game:GetService("CollectionService")
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, part in ipairs(descendants) do
		for _, tag in ipairs(CollectionService:GetTags(part)) do
			CollectionService:RemoveTag(part, tag)
		end

		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0
		end
	end
end

local function addTrail(data, primaryPart)
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 0.3, 0)
	attachment.Parent = primaryPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -0.3, 0)
	attachment2.Parent = primaryPart
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(Color3.new(1, 1, 1), data.TokenColor)
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.Lifetime = 0.2
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Enabled = false
	trail.Parent = primaryPart
	return trail
end

function CollectPresentation.snapDuration(data)
	return data.SnapWindupTime + data.SnapHopTime + data.SnapDiveTime
end

function CollectPresentation.snap(data, position)
	if RunService:IsServer() then
		warn("[CollectPresentation] snap is client-only")
		return false
	end

	local parent = localRoot()

	if not parent then
		return false
	end

	local pivot, v4, v5

	if typeof(position) == "Instance" and position:IsA("PVInstance") then
		pivot = position:GetPivot()
		local extentsSize

		if position:IsA("Model") then
			extentsSize = position:GetExtentsSize()
		else
			extentsSize = position.Size
		end

		v4, v5 = CollectPresentation.cloneMesh(position, (math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)))
		clearTags(v4)
	else
		if typeof(position) ~= "Vector3" then
			position = parent.Position
		end

		pivot = CFrame.new(position)
		local v6
		v4, v5, v6 = makeToken(data)
		v6(1)
	end

	v4.Name = "HalloweenCollectToken"
	v4:PivotTo(pivot)
	v4.Parent = workspace
	local primaryPart = v4

	if not primaryPart:IsA("BasePart") then
		if primaryPart:IsA("Model") and primaryPart.PrimaryPart then
			primaryPart = primaryPart.PrimaryPart
		else
			primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart", true)
		end
	end

	local v6 = primaryPart and addTrail(data, primaryPart)
	local snapWindupTime = data.SnapWindupTime
	local v7 = snapWindupTime + data.SnapHopTime
	local v8 = v7 + data.SnapDiveTime
	local position2 = pivot.Position
	local v9 = position2 + Vector3.new(0, data.SnapHopHeight, 0)
	local snapSpinSpeed = math.rad(data.SnapSpinSpeed)
	local lastTime = os.clock()
	local v10 = false
	local v11 = 1
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v12 = os.clock() - lastTime

		if v8 <= v12 or not parent.Parent then
			heartbeatConnection:Disconnect()
			v10 = true
		else
			local v13, v14

			if v12 < snapWindupTime then
				v13 = position2
				v14 = 1 - math.sin(3.141592653589793 * v12 / snapWindupTime) * 0.2
			elseif v12 < v7 then
				local v16 = easeOut((v12 - snapWindupTime) / data.SnapHopTime)
				v13 = position2:Lerp(v9, v16)
				v14 = 1 + (data.SnapHopScale - 1) * v16
			else
				if v6 then
					v6.Enabled = true
				end

				local v15 = (v12 - v7) / data.SnapDiveTime
				local v16 = v15 * v15
				local v17 = parent.Position + createVector(0, 0.5, 0)
				local v18 = v9:Lerp(v17, 0.5) + createVector(0, 1.5, 0)
				v13 = v9:Lerp(v18, v16):Lerp(v18:Lerp(v17, v16), v16)
				v14 = data.SnapHopScale + (data.SnapArriveScale - data.SnapHopScale) * v16
			end

			if math.abs(v14 - v11) > 0.001 then
				v5(v14)
				v11 = v14
			end

			local v15 = snapSpinSpeed * v12 * v12 / (2 * v8)
			v4:PivotTo(CFrame.new(v13) * CFrame.Angles(0, v15, 0) * pivot.Rotation)
		end
	end)

	while not v10 do
		task.wait()
	end

	v4:Destroy()

	if not parent.Parent then
		return false
	end

	burst(data, parent)
	return true
end

function CollectPresentation.showCaption(p, list)
	if RunService:IsServer() or not list or #list == 0 then
		return
	end

	local v3 = localRoot()

	if not v3 then
		return
	end

	local caption, setOpacity = makeCaption(p, v3, list)
	local textLabel = caption:FindFirstChildOfClass("TextLabel")
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 0.4
	uIScale.Parent = textLabel
	local studsOffsetWorldSpace = caption.StudsOffsetWorldSpace
	local v5 = 0.25 + p.CaptionHoldTime + 0.25
	task.spawn(function()
		local lastTime = os.clock()

		while caption.Parent do
			local v6 = os.clock() - lastTime

			if v5 <= v6 then
				break
			end

			local v7 = math.min(v6 / 0.25, 1)
			local v8 = uIScale
			local v9 = v7 - 1
			v8.Scale = (v9 ^ 3 * 2.70158 + 1 + v9 ^ 2 * 1.70158) * 0.6 + 0.4
			local parent = caption
			local v12 = v6 / v5
			parent.StudsOffsetWorldSpace = studsOffsetWorldSpace + Vector3.new(0, easeOut(v12) * 0.6, 0)
			local v13 = v6 - 0.25 - p.CaptionHoldTime

			if v13 > 0 then
				v7 = 1 - v13 / 0.25
			end

			setOpacity(v7)
			RunService.Heartbeat:Wait()
		end

		caption:Destroy()
	end)
end

return CollectPresentation