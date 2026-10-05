local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local BassieVFXClient = {}
local v = {}
local config2 = nil
local v3 = nil
local v4 = nil

local function getCachedTemplates()
	if v3 then
		return v3, v4
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")

	if parts then
		local vinesAnimated = parts:FindFirstChild("VinesAnimated")

		if vinesAnimated then
			local children = {}
			local children2 = {}

			for _, child in ipairs(vinesAnimated:GetChildren()) do
				if not (child:IsA("Model") or child:IsA("BasePart")) then
					continue
				end

				if string.sub(child.Name, 1, 18) == "HugeSpike_Circular" then
					table.insert(children2, child)
				else
					table.insert(children, child)
				end
			end

			v3 = children
			v4 = children2
			return children, children2
		end
	end

	v3 = {}
	v4 = {}
	return v3, v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRigType(value)
	if string.find(value, "Small_Vines_Thick_Wheels", 1, true) == 1 then
		return "thickWheels"
	end

	if string.find(value, "New_thorn_rig", 1, true) == 1 then
		return "newThorn"
	end

	return "vineForward"
end

local function getEmergeList(rigType, config)
	if rigType == "thickWheels" then
		return config.THICK_WHEELS_EMERGE_ANIMS or {}
	end

	if rigType == "newThorn" then
		local NEW_THORN_EMERGE_ANIMS = config.NEW_THORN_EMERGE_ANIMS or {}

		if #NEW_THORN_EMERGE_ANIMS == 0 then
			NEW_THORN_EMERGE_ANIMS = config.NEW_THORN_LOOP_ANIMS or {}
		end

		return NEW_THORN_EMERGE_ANIMS
	else
		local VINE_EMERGE_ANIMS = config.VINE_EMERGE_ANIMS or {}

		if #VINE_EMERGE_ANIMS == 0 then
			VINE_EMERGE_ANIMS = config.THORN_LOOP_ANIMS or {}
		end

		return VINE_EMERGE_ANIMS
	end
end

local function getIdleList(rigType, config)
	if rigType == "thickWheels" then
		return config.THICK_WHEELS_IDLE_ANIMS or {}
	elseif rigType == "newThorn" then
		return config.NEW_THORN_IDLE_ANIMS or {}
	end

	return config.THORN_IDLE_ANIMS or {}
end

local function getWarningIdleList(rigType, config)
	if rigType == "thickWheels" then
		return config.THICK_WHEELS_WARNING_IDLE_ANIMS or {}
	end

	if rigType == "newThorn" then
		local NEW_THORN_WARNING_IDLE_ANIMS = config.NEW_THORN_WARNING_IDLE_ANIMS or {}

		if #NEW_THORN_WARNING_IDLE_ANIMS == 0 then
			NEW_THORN_WARNING_IDLE_ANIMS = config.NEW_THORN_LOOP_ANIMS or {}
		end

		return NEW_THORN_WARNING_IDLE_ANIMS
	else
		local VINE_WARNING_IDLE_ANIMS = config.VINE_WARNING_IDLE_ANIMS or {}

		if #VINE_WARNING_IDLE_ANIMS == 0 then
			VINE_WARNING_IDLE_ANIMS = config.THORN_LOOP_ANIMS or {}
		end

		return VINE_WARNING_IDLE_ANIMS
	end
end

local function findTemplateByName(s1Templates, templateName)
	for _, v5 in ipairs(s1Templates) do
		if v5.Name == templateName then
			return v5
		end
	end

	local rigType = getRigType(templateName) -- equivalent call inferred; original call site unknown
	local v5 = rigType == "thickWheels" and "Small_Vines_Thick_Wheels" or rigType == "newThorn" and "New_thorn_rig" or "VineForward"

	for _, v6 in ipairs(s1Templates) do
		if string.find(v6.Name, v5, 1, true) == 1 then
			return v6
		end
	end

	if #s1Templates > 0 then
		return s1Templates[1]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findStage2Template(list, value)
	if #list == 0 then
		return nil
	end

	return list[math.clamp(value or 1, 1, #list)]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPartProperties(p)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
end

local function setAllPartProperties(part)
	if part:IsA("BasePart") then
		setPartProperties(part) -- equivalent call inferred; original call site unknown
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		setPartProperties(part2) -- equivalent call inferred; original call site unknown
	end
end

local function disableScripts(folder)
	for _, script in ipairs(folder:GetDescendants()) do
		if script:IsA("Script") or script:IsA("LocalScript") then
			script.Disabled = true
		end
	end
end

local function scaleAndPositionVine(clone, cFrame, config)
	if clone:IsA("Model") then
		local VINE_FILL_CHUNK = config.VINE_FILL_CHUNK
		local VINE_SPAN_CHUNKS = config.VINE_SPAN_CHUNKS or 1
		local vineScale = config.vineScale or 1
		local sizeX = config.sizeX or 4
		local v5 = (config.sizeZ or 8) * math.max(VINE_SPAN_CHUNKS, 1)

		if VINE_FILL_CHUNK then
			local success, result = pcall(function()
				local _, v6 = clone:GetBoundingBox()
				return v6
			end)

			if success and result then
				local v6 = math.max(result.X, 0.1)
				local v7 = math.max(result.Z, 0.1)
				vineScale = math.max(sizeX / v6, v5 / v7) * vineScale
			end
		end

		if vineScale ~= 1 then
			pcall(function()
				clone:ScaleTo(vineScale)
			end)
		end

		if clone.PrimaryPart then
			pcall(function()
				clone:SetPrimaryPartCFrame(cFrame)
			end)
		else
			local basePart = clone:FindFirstChildWhichIsA("BasePart", true)

			if basePart then
				local v6 = cFrame * basePart.CFrame:Inverse()

				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CFrame = v6 * part.CFrame
					end
				end
			end
		end
	elseif clone:IsA("BasePart") then
		clone.CFrame = cFrame
		local VINE_FILL_CHUNK = config.VINE_FILL_CHUNK
		local vineScale = config.vineScale or 1
		local sizeX = config.sizeX or 4
		local sizeZ = config.sizeZ or 8

		if VINE_FILL_CHUNK then
			clone.Size = Vector3.new(sizeX * vineScale, clone.Size.Y, sizeZ * vineScale)
		elseif vineScale ~= 1 then
			clone.Size *= vineScale
		end
	end
end

local function scaleAndPositionStage2Vine(clone, cFrame, config)
	if clone:IsA("Model") then
		local VINE_FILL_CHUNK = config.VINE_FILL_CHUNK
		local vineStage2Scale = config.vineStage2Scale or 1
		local sizeX = config.sizeX or 4
		local sizeZ = config.sizeZ or 8

		if VINE_FILL_CHUNK then
			local success, result = pcall(function()
				local _, v5 = clone:GetBoundingBox()
				return v5
			end)

			if success and result then
				local v5 = math.max(result.X, 0.1)
				local v6 = math.max(result.Z, 0.1)
				vineStage2Scale = math.max(math.min(sizeX / v5, sizeZ / v6), 1) * vineStage2Scale
			end
		end

		if vineStage2Scale ~= 1 then
			pcall(function()
				clone:ScaleTo(vineStage2Scale)
			end)
		end

		if clone.PrimaryPart then
			pcall(function()
				clone:SetPrimaryPartCFrame(cFrame)
			end)
		else
			local basePart = clone:FindFirstChildWhichIsA("BasePart", true)

			if basePart then
				local v5 = cFrame * basePart.CFrame:Inverse()

				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CFrame = v5 * part.CFrame
					end
				end
			end
		end
	elseif clone:IsA("BasePart") then
		clone.CFrame = cFrame
		local vineStage2Scale = config.vineStage2Scale or 1

		if vineStage2Scale ~= 1 then
			clone.Size *= vineStage2Scale
		end
	end
end

local function applyStretchZ(clone, p, VINE_STRETCH_Z)
	if VINE_STRETCH_Z == 0 then
		return
	end

	local v5 = p.LookVector * VINE_STRETCH_Z

	if clone:IsA("Model") then
		if clone.PrimaryPart then
			pcall(function()
				clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame + v5)
			end)
			return
		end

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CFrame += v5
			end
		end
	elseif clone:IsA("BasePart") then
		clone.CFrame += v5
	end
end

local function emitDustFlare(position, p, p2, config)
	if not (config and config.dustEnabled) then
		return
	end

	local part = Instance.new("Part")
	part.Name = "BassieDustFlare"
	setPartProperties(part) -- equivalent call inferred; original call site unknown
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position + Vector3.new(0, config.dustYOffset or -1.5, 0)
	part.Parent = workspace
	local dustSize = config.dustSize or 1.5
	local dustLifeMin = config.dustLifeMin or 0.3
	local dustLifeMax = config.dustLifeMax or 0.8
	local dustSpeedMin = config.dustSpeedMin or 2
	local dustSpeedMax = config.dustSpeedMax or 8
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(p2 or config.dustColor or Color3.fromRGB(180, 150, 100))
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, dustSize),
		NumberSequenceKeypoint.new(0.5, dustSize * 0.6),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.6, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(dustLifeMin, dustLifeMax)
	particleEmitter.Speed = NumberRange.new(dustSpeedMin, dustSpeedMax)
	particleEmitter.SpreadAngle = Vector2.new(60, 60)
	particleEmitter.Rate = 0
	particleEmitter.LightEmission = 0.1
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Parent = part
	particleEmitter:Emit(p)
	task.delay(dustLifeMax + 0.5, function()
		if part and part.Parent then
			part:Destroy()
		end
	end)
end

local function emitTransitionPoof(position, config)
	if not (config and config.poofEnabled) then
		return
	end

	local part = Instance.new("Part")
	part.Name = "BassieTransitionPoof"
	setPartProperties(part) -- equivalent call inferred; original call site unknown
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position + createVector(0, -2, 0)
	part.Parent = workspace
	local color = Color3.fromRGB(200, 200, 200)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(0.3, 4),
		NumberSequenceKeypoint.new(1, 2)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.6, 1.5)
	particleEmitter.Speed = NumberRange.new(1.7999999999999998, 6)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Rate = 0
	particleEmitter.LightEmission = 0.2
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Parent = part
	particleEmitter:Emit(20)
	task.delay(2, function()
		if part and part.Parent then
			part:Destroy()
		end
	end)
end

local function createSmoke(model, config)
	if not (config and config.smokeEnabled) then
		return
	end

	local primaryPart

	if model:IsA("Model") then
		primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	else
		primaryPart = model
	end

	if not primaryPart then
		return
	end

	local SMOKE_Y_OFFSET = config.SMOKE_Y_OFFSET or -2
	local parent

	if SMOKE_Y_OFFSET == 0 then
		parent = primaryPart
	else
		parent = Instance.new("Part")
		parent.Name = "BassieSmokePart"
		setPartProperties(parent) -- equivalent call inferred; original call site unknown
		parent.Transparency = 1
		parent.Size = createVector(1, 1, 1)
		parent.Position = primaryPart.Position + Vector3.new(0, SMOKE_Y_OFFSET, 0)
		parent.Parent = model:IsA("Model") and model or workspace
	end

	local smoke = Instance.new("Smoke")
	smoke.Color = config.smokeColor or Color3.fromRGB(15, 5, 15)
	smoke.Size = config.smokeSize or 1.5
	smoke.RiseVelocity = config.smokeRiseVelocity or 1.5
	smoke.Opacity = config.smokeOpacity or 0.3
	smoke.Parent = parent
	local pointLight = Instance.new("PointLight")
	pointLight.Color = config.smokeLightColor or Color3.fromRGB(120, 30, 180)
	pointLight.Brightness = config.smokeLightBrightness or 1
	pointLight.Range = config.smokeLightRange or 6
	pointLight.Parent = parent
end

local function playVineEmergeSound(primaryPart, config)
	local vineEmergeSounds = config.vineEmergeSounds

	if not vineEmergeSounds or #vineEmergeSounds == 0 then
		return
	end

	if primaryPart:IsA("Model") then
		primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart", true)
	end

	if not primaryPart then
		return
	end

	Audio:Play("Sounds.Twisted.Bassie.VineEmerge", {
		Volume = config.vineEmergeVol or 0.8,
		RollOffMaxDistance = 80,
		Parent = primaryPart
	})
end

local function playThornSpikeSound(primaryPart, config)
	local thornSpikeSounds = config.thornSpikeSounds

	if not thornSpikeSounds or #thornSpikeSounds == 0 then
		return
	end

	if primaryPart:IsA("Model") then
		primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart", true)
	end

	if not primaryPart then
		return
	end

	Audio:Play("Sounds.Twisted.Bassie.ThornHit", {
		Volume = config.thornSpikeVol or 1,
		RollOffMaxDistance = 80,
		Parent = primaryPart
	})
end

local function loadAndPlayAnimation(animator, animationId, looped, action, value, value2)
	if not animator or not animationId or animationId == "" then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	animation.Parent = animator.Parent
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not (success and result) then
		return nil
	end

	result.Looped = looped
	result.Priority = action or Enum.AnimationPriority.Action
	result:Play(value2 or 0, 1, value or 1)
	return result
end

local function waitForTrackLength(result, value)
	if result.Length > 0 then
		return result.Length
	end

	local total = 0
	local v5 = value or 1

	while result.Length == 0 and total < v5 do
		task.wait(0.05)
		total += 0.05
	end

	return result.Length
end

function BassieVFXClient.HandleConfig(p)
	local config = p.config

	if not config then
		warn("BassieVFXClient: HandleConfig missing config payload")
		return
	end

	config2 = config
	local sharedData = ReplicatedStorage:FindFirstChild("SharedData")
	local holidayEventConfig = sharedData and sharedData:FindFirstChild("HolidayEventConfig")
	local success, result = pcall(require, holidayEventConfig)

	if success and result and result.ENABLED and result.ContentFlag == "Easter" then
		task.spawn(function()
			local ContentProvider = game:GetService("ContentProvider")
			local v5 = {}

			for _, v6 in ipairs({
				"THICK_WHEELS_EMERGE_ANIMS",
				"THICK_WHEELS_IDLE_ANIMS",
				"THICK_WHEELS_WARNING_IDLE_ANIMS",
				"THORN_LOOP_ANIMS",
				"THORN_IDLE_ANIMS",
				"NEW_THORN_LOOP_ANIMS",
				"NEW_THORN_IDLE_ANIMS",
				"NEW_THORN_WARNING_IDLE_ANIMS",
				"NEW_THORN_EMERGE_ANIMS",
				"VINE_EMERGE_ANIMS",
				"VINE_WARNING_IDLE_ANIMS"
			}) do
				local v7 = config[v6]

				if type(v7) ~= "table" then
					continue
				end

				for _, animationId in ipairs(v7) do
					if not (type(animationId) == "string" and animationId ~= "") then
						continue
					end

					local animation = Instance.new("Animation")
					animation.AnimationId = animationId
					table.insert(v5, animation)
				end
			end

			for _, v6 in ipairs({ "FLOWER_EMERGE_ANIM", "THORN_EMERGE_ANIM" }) do
				local animationId = config[v6]

				if not (type(animationId) == "string" and animationId ~= "") then
					continue
				end

				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				table.insert(v5, animation)
			end

			if #v5 > 0 then
				pcall(function()
					ContentProvider:PreloadAsync(v5)
				end)

				for _, v6 in ipairs(v5) do
					v6:Destroy()
				end
			end
		end)
	end

	print("BassieVFXClient: Config cached (one-time at Bassie spawn)")
end

function BassieVFXClient.HandleAttackStart(p)
	local attackId = p.attackId

	if not attackId then
		warn("BassieVFXClient: HandleAttackStart missing attackId")
		return
	end

	if not config2 then
		warn("BassieVFXClient: HandleAttackStart — no cached config yet, attack", attackId, "will be ignored")
		return
	end

	local cachedTemplates, s2Templates = getCachedTemplates()

	if #cachedTemplates == 0 then
		warn("BassieVFXClient: No stage 1 templates found")
		return
	end

	if #s2Templates == 0 then
		local cachedTemplates2 = {}
		local cachedTemplates3 = {}

		for _, cachedTemplate in ipairs(cachedTemplates) do
			if string.find(cachedTemplate.Name, "HugeSpike_Circular", 1, true) == 1 then
				table.insert(cachedTemplates3, cachedTemplate)
			else
				table.insert(cachedTemplates2, cachedTemplate)
			end
		end

		if #cachedTemplates2 > 0 then
			v3 = cachedTemplates2
			cachedTemplates = cachedTemplates2
		end

		if #cachedTemplates3 > 0 then
			v4 = cachedTemplates3
			s2Templates = cachedTemplates3
		end
	end

	v[attackId] = {
		config = config2,
		vines = {},
		mirrors = {},
		emergeClones = {},
		mirrorEmergeClones = {},
		animControllers = {},
		idleTracks = {},
		emergeTracks = {},
		animIndices = {},
		rigTypes = {},
		vineCFrames = {},
		mirrorAnimControllers = {},
		mirrorIdleTracks = {},
		s2Templates = s2Templates,
		s1Templates = cachedTemplates,
		startTime = os.clock()
	}
	task.delay(30, function()
		if v[attackId] then
			warn("BassieVFXClient: Attack", attackId, "timed out — forcing cleanup")
			BassieVFXClient.HandleCleanup({
				attackId = attackId,
				sinkTime = 0.4,
				sinkDistance = 8
			})
		end
	end)
	print("BassieVFXClient: Attack started", attackId)
end

function BassieVFXClient.HandleChunk(data)
	local attackId = data.attackId
	local chunkIndex = data.chunkIndex

	if not (attackId and chunkIndex) then
		return
	end

	local v5 = v[attackId]

	if not v5 then
		return
	end

	local config = v5.config
	local vineCFrame = data.vineCFrame
	local templateName = data.templateName

	if not (vineCFrame and templateName) then
		return
	end

	local templateByName = findTemplateByName(v5.s1Templates, templateName)

	if not templateByName then
		return
	end

	task.spawn(function()
		if not v[attackId] then
			return
		end

		local VINE_EMERGE_SPEED = config.VINE_EMERGE_SPEED or 2
		local VINE_EMERGE_BLEND_TIME = config.VINE_EMERGE_BLEND_TIME or 0.05
		local VINE_MIRROR = config.VINE_MIRROR or false
		local VINE_STRETCH_Z = config.VINE_STRETCH_Z or 0
		local rigType = getRigType(templateName) -- equivalent call inferred; original call site unknown
		v5.rigTypes[chunkIndex] = rigType
		v5.vineCFrames[chunkIndex] = vineCFrame
		local emergeList = getEmergeList(rigType, config)
		local idleList = getIdleList(rigType, config)
		local v7 = not (#emergeList > 0) and 0 or math.random(1, #emergeList) or 0
		v5.animIndices[chunkIndex] = v7
		local clone = templateByName:Clone()
		scaleAndPositionVine(clone, vineCFrame, config)
		setAllPartProperties(clone)
		disableScripts(clone)

		if VINE_STRETCH_Z ~= 0 then
			applyStretchZ(clone, vineCFrame, VINE_STRETCH_Z)
		end

		local animationController = clone:FindFirstChildWhichIsA("AnimationController") or clone:FindFirstChildWhichIsA(
			"AnimationController",
			true
		)
		v5.animControllers[chunkIndex] = animationController
		local v8

		if idleList and #idleList > 0 then
			v8 = idleList[math.min(v7 > 0 and v7 or 1, #idleList)] or nil
		end

		local v9 = animationController and v8 and loadAndPlayAnimation(
			animationController,
			v8,
			true,
			Enum.AnimationPriority.Action,
			1,
			0
		)

		if v9 then
			v5.idleTracks[chunkIndex] = v9
		end

		local transparencies = {}

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			transparencies[part] = part.Transparency
			part.Transparency = 1
		end

		if clone:IsA("BasePart") then
			transparencies[clone] = clone.Transparency
			clone.Transparency = 1
		end

		clone.Parent = workspace
		v5.vines[chunkIndex] = clone

		if v7 > 0 and animationController then
			local clone2 = templateByName:Clone()
			local success, result = pcall(function()
				local _, v10 = clone:GetBoundingBox()
				return v10
			end)
			local success2, result2 = pcall(function()
				local _, v10 = clone2:GetBoundingBox()
				return v10
			end)

			if success and success2 and result and result2 then
				local v10 = math.max(result.X / math.max(result2.X, 0.1), result.Z / math.max(result2.Z, 0.1))

				if math.abs(v10 - 1) > 0.05 then
					pcall(function()
						clone2:ScaleTo(v10)
					end)
				end
			end

			if clone.PrimaryPart and clone2:IsA("Model") then
				pcall(function()
					clone2:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame)
				end)
			else
				scaleAndPositionVine(clone2, vineCFrame, config)

				if VINE_STRETCH_Z ~= 0 then
					applyStretchZ(clone2, vineCFrame, VINE_STRETCH_Z)
				end
			end

			setAllPartProperties(clone2)
			disableScripts(clone2)
			local transparencies2 = {}

			for _, part in ipairs(clone2:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				transparencies2[part] = part.Transparency
				part.Transparency = 1
			end

			if clone2:IsA("BasePart") then
				transparencies2[clone2] = clone2.Transparency
				clone2.Transparency = 1
			end

			clone2.Parent = workspace
			v5.emergeClones[chunkIndex] = clone2
			local animationController2 = clone2:FindFirstChildWhichIsA("AnimationController") or clone2:FindFirstChildWhichIsA(
				"AnimationController",
				true
			)

			if animationController2 then
				local v10 = loadAndPlayAnimation(
					animationController2,
					emergeList[v7],
					false,
					Enum.AnimationPriority.Action,
					VINE_EMERGE_SPEED,
					0
				)

				if v10 then
					for k, transparency in pairs(transparencies2) do
						if k and k.Parent then
							k.Transparency = transparency
						end
					end

					v5.emergeTracks[chunkIndex] = v10
					local lastTime = os.clock()
					local length = v10.Length
					local v11 = (length == 0 and 0.5 or length) / VINE_EMERGE_SPEED
					local v12 = math.max(math.max(v11 - VINE_EMERGE_BLEND_TIME, 0) - (os.clock() - lastTime), 0)
					task.delay(v12, function()
						if not v[attackId] then
							return
						end

						if clone2 and clone2.Parent then
							for _, part in ipairs(clone2:GetDescendants()) do
								if part:IsA("BasePart") then
									TweenService:Create(part, TweenInfo.new(VINE_EMERGE_BLEND_TIME), {
										Transparency = 1
									}):Play()
								end
							end

							if clone2:IsA("BasePart") then
								TweenService:Create(clone2, TweenInfo.new(VINE_EMERGE_BLEND_TIME), {
									Transparency = 1
								}):Play()
							end
						end

						for k, transparency in pairs(transparencies) do
							if k and k.Parent then
								TweenService:Create(k, TweenInfo.new(VINE_EMERGE_BLEND_TIME), {
									Transparency = transparency
								}):Play()
							end
						end
					end)
					task.delay(math.max(v11 + 0.2 - (os.clock() - lastTime), 0.1), function()
						if clone2 and clone2.Parent then
							clone2:Destroy()
						end

						if v[attackId] then
							v[attackId].emergeClones[chunkIndex] = nil
						end
					end)
				else
					for k, transparency in pairs(transparencies) do
						if k and k.Parent then
							k.Transparency = transparency
						end
					end

					if clone2 and clone2.Parent then
						clone2:Destroy()
					end

					v5.emergeClones[chunkIndex] = nil
				end
			else
				for k, transparency in pairs(transparencies) do
					if k and k.Parent then
						k.Transparency = transparency
					end
				end

				if clone2 and clone2.Parent then
					clone2:Destroy()
				end

				v5.emergeClones[chunkIndex] = nil
			end
		else
			local FLOWER_EMERGE_ANIM = config.FLOWER_EMERGE_ANIM or ""
			local v10 = (FLOWER_EMERGE_ANIM ~= "" and animationController and true or false) and loadAndPlayAnimation(
				animationController,
				FLOWER_EMERGE_ANIM,
				false,
				Enum.AnimationPriority.Action,
				1,
				0
			)

			if v10 then
				v5.emergeTracks[chunkIndex] = v10
			end

			for k, transparency in pairs(transparencies) do
				if k and k.Parent then
					k.Transparency = transparency
				end
			end
		end

		playVineEmergeSound(clone, config)
		createSmoke(clone, config)

		if config.dustEnabled then
			emitDustFlare(vineCFrame.Position, config.dustCount or 8, nil, config)
		end

		if VINE_MIRROR then
			local cFrame = vineCFrame * CFrame.Angles(0, 3.141592653589793, 0)
			local clone2 = templateByName:Clone()
			scaleAndPositionVine(clone2, cFrame, config)
			setAllPartProperties(clone2)
			disableScripts(clone2)

			if VINE_STRETCH_Z ~= 0 then
				applyStretchZ(clone2, cFrame, VINE_STRETCH_Z)
			end

			local animationController2 = clone2:FindFirstChildWhichIsA("AnimationController") or clone2:FindFirstChildWhichIsA(
				"AnimationController",
				true
			)
			v5.mirrorAnimControllers[chunkIndex] = animationController2
			local v11

			if idleList and #idleList > 0 then
				v11 = idleList[math.min(v7 > 0 and v7 or 1, #idleList)] or nil
			end

			local v12 = animationController2 and v11 and loadAndPlayAnimation(
				animationController2,
				v11,
				true,
				Enum.AnimationPriority.Action,
				1,
				0
			)

			if v12 then
				v5.mirrorIdleTracks[chunkIndex] = v12
			end

			local transparencies2 = {}

			for _, part in ipairs(clone2:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				transparencies2[part] = part.Transparency
				part.Transparency = 1
			end

			if clone2:IsA("BasePart") then
				transparencies2[clone2] = clone2.Transparency
				clone2.Transparency = 1
			end

			clone2.Parent = workspace
			v5.mirrors[chunkIndex] = clone2

			if v7 > 0 and animationController2 then
				local clone3 = templateByName:Clone()
				local success, result = pcall(function()
					local _, v13 = clone2:GetBoundingBox()
					return v13
				end)
				local success2, result2 = pcall(function()
					local _, v13 = clone3:GetBoundingBox()
					return v13
				end)

				if success and success2 and result and result2 then
					local v13 = math.max(result.X / math.max(result2.X, 0.1), result.Z / math.max(result2.Z, 0.1))

					if math.abs(v13 - 1) > 0.05 then
						pcall(function()
							clone3:ScaleTo(v13)
						end)
					end
				end

				if clone2.PrimaryPart and clone3:IsA("Model") then
					pcall(function()
						clone3:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame)
					end)
				else
					scaleAndPositionVine(clone3, cFrame, config)

					if VINE_STRETCH_Z ~= 0 then
						applyStretchZ(clone3, cFrame, VINE_STRETCH_Z)
					end
				end

				setAllPartProperties(clone3)
				disableScripts(clone3)
				clone3.Parent = workspace
				v5.mirrorEmergeClones[chunkIndex] = clone3
				local animationController3 = clone3:FindFirstChildWhichIsA("AnimationController") or clone3:FindFirstChildWhichIsA(
					"AnimationController",
					true
				)

				if animationController3 then
					local v13 = loadAndPlayAnimation(
						animationController3,
						emergeList[v7],
						false,
						Enum.AnimationPriority.Action,
						VINE_EMERGE_SPEED,
						0
					)

					if v13 then
						local lastTime = os.clock()
						local length = v13.Length
						local v14 = (length == 0 and 0.5 or length) / VINE_EMERGE_SPEED
						local v15 = math.max(math.max(v14 - VINE_EMERGE_BLEND_TIME, 0) - (os.clock() - lastTime), 0)
						task.delay(v15, function()
							if not v[attackId] then
								return
							end

							if clone3 and clone3.Parent then
								for _, part in ipairs(clone3:GetDescendants()) do
									if part:IsA("BasePart") then
										TweenService:Create(part, TweenInfo.new(VINE_EMERGE_BLEND_TIME), {
											Transparency = 1
										}):Play()
									end
								end
							end

							for k, transparency in pairs(transparencies2) do
								if k and k.Parent then
									TweenService:Create(k, TweenInfo.new(VINE_EMERGE_BLEND_TIME), {
										Transparency = transparency
									}):Play()
								end
							end
						end)
						task.delay(math.max(v14 + 0.2 - (os.clock() - lastTime), 0.1), function()
							if clone3 and clone3.Parent then
								clone3:Destroy()
							end

							if v[attackId] then
								v[attackId].mirrorEmergeClones[chunkIndex] = nil
							end
						end)
					else
						for k, transparency in pairs(transparencies2) do
							if k and k.Parent then
								k.Transparency = transparency
							end
						end

						if clone3 and clone3.Parent then
							clone3:Destroy()
						end

						v5.mirrorEmergeClones[chunkIndex] = nil
					end
				else
					for k, transparency in pairs(transparencies2) do
						if k and k.Parent then
							k.Transparency = transparency
						end
					end

					if clone3 and clone3.Parent then
						clone3:Destroy()
					end

					v5.mirrorEmergeClones[chunkIndex] = nil
				end
			else
				for k, transparency in pairs(transparencies2) do
					if k and k.Parent then
						k.Transparency = transparency
					end
				end
			end

			createSmoke(clone2, config)
		end
	end)
end

function BassieVFXClient.HandleWarning(p)
	local attackId = p.attackId

	if not attackId then
		return
	end

	local v5 = v[attackId]

	if not v5 then
		warn("BassieVFXClient: HandleWarning - no active attack for", attackId)
		return
	end

	local config = v5.config

	for k, vine in pairs(v5.vines) do
		if not (vine and vine.Parent) then
			continue
		end

		local rigType = v5.rigTypes[k]

		if not rigType then
			continue
		end

		local warningIdleList = getWarningIdleList(rigType, config)

		if #warningIdleList == 0 then
			continue
		end

		local animController = v5.animControllers[k]

		if not animController then
			continue
		end

		local idleTrack = v5.idleTracks[k]

		if idleTrack then
			local v6 = idleTrack
			pcall(function()
				v6:Stop(0.2)
			end)
		end

		local animationId = warningIdleList[math.min(v5.animIndices[k] or 1, #warningIdleList)]

		if not animationId then
			continue
		end

		local v7 = loadAndPlayAnimation(animController, animationId, true, Enum.AnimationPriority.Action, 1, 0.2)

		if v7 then
			v5.idleTracks[k] = v7
		end
	end

	for k, mirror in pairs(v5.mirrors) do
		if not (mirror and mirror.Parent) then
			continue
		end

		local rigType = v5.rigTypes[k]

		if not rigType then
			continue
		end

		local warningIdleList = getWarningIdleList(rigType, config)

		if #warningIdleList == 0 then
			continue
		end

		local mirrorAnimController = v5.mirrorAnimControllers[k]

		if not mirrorAnimController then
			continue
		end

		local mirrorIdleTrack = v5.mirrorIdleTracks[k]

		if mirrorIdleTrack then
			local v6 = mirrorIdleTrack
			pcall(function()
				v6:Stop(0.2)
			end)
		end

		local animationId = warningIdleList[math.min(v5.animIndices[k] or 1, #warningIdleList)]

		if not animationId then
			continue
		end

		local v7 = loadAndPlayAnimation(mirrorAnimController, animationId, true, Enum.AnimationPriority.Action, 1, 0.2)

		if v7 then
			v5.mirrorIdleTracks[k] = v7
		end
	end

	print("BassieVFXClient: Warning swap for attack", attackId)
end

function BassieVFXClient.HandleStage2(data)
	local attackId = data.attackId
	local chunkCount = data.chunkCount
	local stage2ChunkDelay = data.stage2ChunkDelay or 0.11
	local stage2TemplateIndex = data.stage2TemplateIndex

	if not (attackId and chunkCount) then
		return
	end

	local v5 = v[attackId]

	if not v5 then
		return
	end

	local config = v5.config
	local s2Templates = v5.s2Templates

	for i = 1, chunkCount do
		local v6 = i
		task.delay((i - 1) * stage2ChunkDelay, function()
			if not v[attackId] then
				return
			end

			local vineCFrame = v5.vineCFrames[v6]

			if not vineCFrame then
				return
			end

			if s2Templates and #s2Templates ~= 0 then
				local stage2Template = findStage2Template(s2Templates, stage2TemplateIndex) -- equivalent call inferred; original call site unknown

				if not stage2Template then
					return
				end

				task.spawn(function()
					local clone = stage2Template:Clone()
					scaleAndPositionStage2Vine(clone, vineCFrame, config)
					local transparencies = {}

					if clone:IsA("BasePart") then
						transparencies[clone] = clone.Transparency
						clone.Transparency = 1
					end

					for i2, part in ipairs(clone:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						transparencies[part] = part.Transparency
						part.Transparency = 1
					end

					setAllPartProperties(clone)
					disableScripts(clone)
					clone.Parent = workspace
					playThornSpikeSound(clone, config)
					local TRANSITION_POOF_DELAY = config.TRANSITION_POOF_DELAY or 0.5
					task.delay(TRANSITION_POOF_DELAY, function()
						emitTransitionPoof(vineCFrame.Position, config)
					end)

					if config.dustEnabled and config.dustStage2 then
						emitDustFlare(vineCFrame.Position, config.dustCountS2 or 15, Color3.fromRGB(15, 5, 15), config)
					end

					local animationController = clone:FindFirstChildWhichIsA("AnimationController")

					if animationController then
						local animation = clone:FindFirstChildWhichIsA("Animation", true)
						local THORN_EMERGE_ANIM = config.THORN_EMERGE_ANIM or ""
						local v9 = nil

						if animation then
							v9 = animation
						elseif THORN_EMERGE_ANIM ~= "" then
							v9 = Instance.new("Animation")
							v9.AnimationId = THORN_EMERGE_ANIM
							v9.Parent = clone
						end

						if v9 then
							local success, result = pcall(function()
								return animationController:LoadAnimation(v9)
							end)

							if success and result then
								result.Looped = false
								result.Priority = Enum.AnimationPriority.Action
								local v10 = waitForTrackLength(result, 1)
								local v11 = v10 == 0 and 0.5 or v10

								for k, transparency in pairs(transparencies) do
									if k and k.Parent then
										k.Transparency = transparency
									end
								end

								result:Play(0, 1, 1)
								local v12 = math.max(v11, 0.5)
								task.delay(v12 * 0.95, function()
									if clone and clone.Parent then
										pcall(function()
											result:Stop(0)

											for i2, part in ipairs(clone:GetDescendants()) do
												if part:IsA("BasePart") then
													part.Transparency = 1
												end
											end

											if clone:IsA("BasePart") then
												clone.Transparency = 1
											end
										end)
									end
								end)
								task.delay(v12 + 0.2, function()
									if clone and clone.Parent then
										clone:Destroy()
									end
								end)
							else
								for k, transparency in pairs(transparencies) do
									if k and k.Parent then
										k.Transparency = transparency
									end
								end
							end
						else
							for k, transparency in pairs(transparencies) do
								if k and k.Parent then
									k.Transparency = transparency
								end
							end
						end
					else
						for k, transparency in pairs(transparencies) do
							if k and k.Parent then
								k.Transparency = transparency
							end
						end
					end

					local VINE_S1_LINGER = config.VINE_S1_LINGER or 0.6
					local vine = v5.vines[v6]
					local mirror = v5.mirrors[v6]
					v5.vines[v6] = nil
					v5.mirrors[v6] = nil
					task.delay(VINE_S1_LINGER, function()
						if vine and vine.Parent then
							vine:Destroy()
						end

						if mirror and mirror.Parent then
							mirror:Destroy()
						end
					end)
				end)
			else
				local VINE_S1_LINGER = config.VINE_S1_LINGER or 0.6
				local vine = v5.vines[v6]
				local mirror = v5.mirrors[v6]
				task.delay(VINE_S1_LINGER, function()
					if vine and vine.Parent then
						vine:Destroy()
					end

					if mirror and mirror.Parent then
						mirror:Destroy()
					end
				end)
				v5.vines[v6] = nil
				v5.mirrors[v6] = nil
			end
		end)
	end
end

function BassieVFXClient.HandleCleanup(data)
	local attackId = data.attackId
	local sinkTime = data.sinkTime or 0.4
	local sinkDistance = data.sinkDistance or 8

	if not attackId then
		return
	end

	local v5 = v[attackId]

	if not v5 then
		return
	end

	if v5.emergeClones then
		for _, emergeClone in pairs(v5.emergeClones) do
			if emergeClone and emergeClone.Parent then
				emergeClone:Destroy()
			end
		end
	end

	if v5.mirrorEmergeClones then
		for _, mirrorEmergeClone in pairs(v5.mirrorEmergeClones) do
			if mirrorEmergeClone and mirrorEmergeClone.Parent then
				mirrorEmergeClone:Destroy()
			end
		end
	end

	local v6 = {}

	for _, vine in pairs(v5.vines) do
		if vine and vine.Parent then
			table.insert(v6, vine)
		end
	end

	for _, mirror in pairs(v5.mirrors) do
		if mirror and mirror.Parent then
			table.insert(v6, mirror)
		end
	end

	for _, v7 in ipairs(v6) do
		local v8 = v7
		pcall(function()
			local animationController = v8:FindFirstChildWhichIsA("AnimationController")

			if animationController then
				for i, v9 in ipairs(animationController:GetPlayingAnimationTracks()) do
					v9:Stop(0)
				end
			end
		end)
	end

	for _, v7 in ipairs(v6) do
		local instance = v7
		pcall(function()
			if instance:IsA("Model") then
				for i, part in ipairs(instance:GetDescendants()) do
					if part:IsA("BasePart") then
						TweenService:Create(
							part,
							TweenInfo.new(sinkTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								CFrame = part.CFrame * CFrame.new(0, -sinkDistance, 0),
								Transparency = 1
							}
						):Play()
					end
				end
			elseif instance:IsA("BasePart") then
				TweenService:Create(instance, TweenInfo.new(sinkTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					CFrame = instance.CFrame * CFrame.new(0, -sinkDistance, 0),
					Transparency = 1
				}):Play()
			end
		end)
	end

	task.delay(sinkTime + 0.1, function()
		for _, v7 in ipairs(v6) do
			if v7 and v7.Parent then
				v7:Destroy()
			end
		end
	end)
	v[attackId] = nil
	print("BassieVFXClient: Cleanup complete for attack", attackId)
end

function BassieVFXClient.HandleEvent(p)
	if not p or type(p) ~= "table" then
		return
	end

	local action = p.action

	if action == "config" then
		BassieVFXClient.HandleConfig(p)
	elseif action == "attack_start" then
		BassieVFXClient.HandleAttackStart(p)
	elseif action == "chunk" then
		BassieVFXClient.HandleChunk(p)
	elseif action == "warning" then
		BassieVFXClient.HandleWarning(p)
	elseif action == "stage2" then
		BassieVFXClient.HandleStage2(p)
	elseif action == "cleanup" then
		BassieVFXClient.HandleCleanup(p)
	else
		warn("BassieVFXClient: Unknown action:", (tostring(action)))
	end
end

return BassieVFXClient