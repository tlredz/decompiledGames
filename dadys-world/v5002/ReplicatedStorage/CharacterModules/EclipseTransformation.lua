local createVector = vector.create
local EclipseTransformation = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local EclipseTransformCore = require(ReplicatedStorage.CharacterModules.EclipseTransformCore)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local color = Color3.fromRGB(150, 180, 220)
local _ = {
	Enabled = true,
	RevealDuration = 4,
	MaxTargets = 12,
	Volume = 0.8,
	Broadcast = true
}
local v = { "rbxassetid://120144830183055", "rbxassetid://75260646139440" }
local v2 = nil

local function resolveHowlSound()
	local manifest = v2 == nil and Audio:GetManifest()

	if manifest then
		for _, v4 in ipairs(("Sounds.Toon.Eclipse.Howl"):gsub("^Sounds%.", ""):split(".")) do
			if typeof(manifest) == "table" then
				manifest = manifest[v4] or nil
			else
				manifest = nil
			end

			if manifest == nil then
				break
			end
		end

		v2 = manifest ~= nil

		if not v2 then
			warn(string.format(
				"[EclipseTransformation] %s is not in the Sounds package yet; playing the raw howl ids until it is",
				"Sounds.Toon.Eclipse.Howl"
			))
		end
	end

	if v2 then
		return "Sounds.Toon.Eclipse.Howl"
	end

	return v[math.random(1, #v)]
end

local color2 = Color3.fromRGB(150, 180, 220)

local function collectFloorTwisteds(p)
	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	local currentRoomModel = currentRoom and currentRoom:FindFirstChildOfClass("Model")
	local monsters = currentRoomModel and currentRoomModel:FindFirstChild("Monsters")

	if not monsters then
		return {}
	end

	local v3 = {}

	for _, model in ipairs(monsters:GetChildren()) do
		if not model:IsA("Model") or not (#model:GetChildren() > 0) or string.find(model.Name, "Rodger") then
			continue
		end

		table.insert(v3, {
			model = model,
			distance = (model:GetPivot().Position - p).Magnitude
		})
	end

	table.sort(v3, function(a, b)
		return a.distance < b.distance
	end)
	local models = {}

	for i = 1, math.min(#v3, 12) do
		models[i] = v3[i].model
	end

	return models
end

local function revealTwisteds(position)
	local v3 = collectFloorTwisteds(position)

	for _, v4 in ipairs(v3) do
		local eclipseMoonSense = v4:FindFirstChild("EclipseMoonSense")

		if eclipseMoonSense then
			eclipseMoonSense:Destroy()
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "EclipseMoonSense"
		highlight.FillColor = color2
		highlight.FillTransparency = 0.85
		highlight.OutlineColor = color2
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = v4
		highlight.Parent = v4
		TweenService:Create(highlight, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
		Debris:AddItem(highlight, 4)
	end

	return #v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function broadcastHowlMessage()
	local events = ReplicatedStorage:FindFirstChild("Events")
	local textEvent = events and events:FindFirstChild("TextEvent")

	if not textEvent then
		return
	end

	textEvent:FireAllClients("Eclipse howls at the moon... the Twisteds are revealed!")
end

local function moonHowl(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	local animations = instance:FindFirstChild("Animations")
	local howl = animations and animations:FindFirstChild("Howl")
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if howl and howl:IsA("Animation") and animator then
		local track = animator:LoadAnimation(howl)
		track.Priority = Enum.AnimationPriority.Action2
		track:Play()
	end

	Audio:Play(resolveHowlSound(), {
		Name = "EclipseMoonHowl",
		Volume = 0.8,
		Parent = humanoidRootPart
	})
	local v3 = revealTwisteds(humanoidRootPart.Position)
	broadcastHowlMessage() -- equivalent call inferred; original call site unknown
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	print(string.format(
		"[EclipseTransformation] Moon Howl by %s revealed %d Twisted(s)",
		playerFromCharacter and playerFromCharacter.Name or instance.Name,
		v3
	))
end

local v3 = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function newData()
	local record = EclipseTransformCore.newRecord()
	record.originalTextures = {}
	record.modifierIds = {}
	return record
end

local function isAlive(instance)
	if not (instance and instance.Parent) then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function makeFlag(parent, name, duration)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = name
	boolValue.Parent = parent
	return {
		flag = boolValue,
		failsafe = task.delay(duration, function()
			if boolValue.Parent then
				boolValue:Destroy()
			end
		end)
	}
end

local function releaseFlags(p)
	for _, v4 in ipairs({ "noTarget", "noDandy", "noDecode" }) do
		local v5 = p[v4]

		if not v5 then
			continue
		end

		task.cancel(v5.failsafe)

		if v5.flag.Parent then
			v5.flag:Destroy()
		end

		p[v4] = nil
	end

	if p.transformingFailsafe then
		task.cancel(p.transformingFailsafe)
		p.transformingFailsafe = nil
	end
end

local function stopLeftovers(state)
	if state.transitionTrack then
		pcall(function()
			state.transitionTrack:Stop()
		end)
		state.transitionTrack = nil
	end

	if state.landingConnection then
		state.landingConnection:Disconnect()
		state.landingConnection = nil
	end

	if state.glowTween then
		state.glowTween:Cancel()
		state.glowTween = nil
	end

	releaseFlags(state)
end

local function restoreOwnership(instance, humanoidRootPart)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not (playerFromCharacter and humanoidRootPart and instance.Parent) then
		return
	end

	if instance:FindFirstChild("Grabbed") or instance:GetAttribute("Grabbed") then
		return
	end

	pcall(function()
		if humanoidRootPart:CanSetNetworkOwnership() then
			humanoidRootPart:SetNetworkOwner(playerFromCharacter)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseHold(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart then
		humanoidRootPart.Anchored = false
	end

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
	end

	restoreOwnership(instance, humanoidRootPart)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function glowLight(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	return toonLight and toonLight:FindFirstChild("PointLight")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restGlow(p)
	p.Enabled = false
	p.Range = 25
end

local function revertStats(instance, p)
	if not EclipseTransformCore.take(p, "stats") then
		return
	end

	local modifierIds = p.modifierIds

	if modifierIds.stamina then
		StatModifierManager.RemoveModifier(instance, "StaminaModifier", modifierIds.stamina)
	end

	if modifierIds.speed then
		StatModifierManager.RemoveSpeedModifiers(instance, modifierIds.speed)
	end

	if modifierIds.currentStaminaMultiplier then
		local stats = instance:FindFirstChild("Stats")
		local currentStamina = stats and stats:FindFirstChild("CurrentStamina")

		if currentStamina then
			currentStamina.Value /= modifierIds.currentStaminaMultiplier
		end
	end

	p.modifierIds = {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function revertScale(instance, p)
	if EclipseTransformCore.take(p, "scale") then
		instance:ScaleTo(instance:GetScale() / 1.2)
	end
end

local fn

local function playTransformationAnimation(instance, childName, p)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local animations = instance:FindFirstChild("Animations")

	if not animations then
		return nil
	end

	local animation = animations:FindFirstChild(childName)
	local track = animation and animation:IsA("Animation") and animator:LoadAnimation(animation)

	if not track then
		warn(string.format(
			"[EclipseTransformation][DBG] %s: no '%s' Animation under Animations folder - no transition track will play",
			instance.Name,
			childName
		))
		return nil
	end

	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = p or false
	track:Play()
	print(string.format(
		"[EclipseTransformation][DBG] %s: %s track loaded | length=%.2f looped=%s playing=%s",
		instance.Name,
		childName,
		track.Length,
		tostring(track.Looped),
		(tostring(track.IsPlaying))
	))
	return track
end

local function spawnTransformationParticles(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")

	if not parts then
		return
	end

	local eclipseTransformFX = parts:FindFirstChild("EclipseTransformFX")

	if not eclipseTransformFX then
		return
	end

	local clone = eclipseTransformFX:Clone()
	clone:PivotTo(humanoidRootPart.CFrame)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
	weldConstraint.Parent = clone
	clone.Parent = workspace
	local playAnimation = clone:FindFirstChild("PlayAnimation", true)

	if playAnimation and playAnimation:IsA("Script") then
		playAnimation.Disabled = false
	end

	Debris:AddItem(clone, 3)
end

local function playTransformationSound(instance)
	if ("rbxassetid://TRANSFORMATION_SOUND_ID"):find("TRANSFORMATION") then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://TRANSFORMATION_SOUND_ID"
	sound.Volume = 0.7
	sound.Parent = humanoidRootPart
	sound:Play()
	Debris:AddItem(sound, 5)
end

local function swapTextures(instance, p, state)
	local config = instance:FindFirstChild("Config")

	if not config then
		return
	end

	local normalTexture = config:FindFirstChild("NormalTexture")
	local blinkTexture = config:FindFirstChild("BlinkTexture")
	local hurtTexture = config:FindFirstChild("HurtTexture")
	local transformNormalTexture = config:FindFirstChild("TransformNormalTexture")
	local transformBlinkTexture = config:FindFirstChild("TransformBlinkTexture")
	local transformHurtTexture = config:FindFirstChild("TransformHurtTexture")

	if p then
		if normalTexture then
			state.originalTextures.Normal = normalTexture.Texture
		end

		if blinkTexture then
			state.originalTextures.Blink = blinkTexture.Texture
		end

		if hurtTexture then
			state.originalTextures.Hurt = hurtTexture.Texture
		end

		local head = instance:FindFirstChild("Head")

		if head then
			state.originalTextures.HeadTextureID = head.TextureID
		end

		local blinkingParts = instance:FindFirstChild("BlinkingParts")

		if blinkingParts then
			state.originalTextures.BlinkingParts = {}

			for _, objectValue in pairs(blinkingParts:GetChildren()) do
				if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
					continue
				end

				local value = objectValue.Value

				if value:IsA("MeshPart") then
					state.originalTextures.BlinkingParts[value] = value.TextureID
				end

				local meshPart = value:FindFirstChildWhichIsA("MeshPart")

				if meshPart then
					state.originalTextures.BlinkingParts[meshPart] = meshPart.TextureID
				end
			end
		end

		if transformNormalTexture and transformBlinkTexture and transformHurtTexture then
			if normalTexture then
				normalTexture.Texture = transformNormalTexture.Texture
			end

			if blinkTexture then
				blinkTexture.Texture = transformBlinkTexture.Texture
			end

			if hurtTexture then
				hurtTexture.Texture = transformHurtTexture.Texture
			end

			if head and transformNormalTexture then
				head.TextureID = transformNormalTexture.Texture
			end

			if blinkingParts and transformNormalTexture then
				for _, objectValue in pairs(blinkingParts:GetChildren()) do
					if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
						continue
					end

					local value = objectValue.Value

					if value:IsA("MeshPart") then
						value.TextureID = transformNormalTexture.Texture
					end

					local meshPart = value:FindFirstChildWhichIsA("MeshPart")

					if meshPart then
						meshPart.TextureID = transformNormalTexture.Texture
					end
				end
			end
		end
	else
		if normalTexture and state.originalTextures.Normal then
			normalTexture.Texture = state.originalTextures.Normal
		end

		if blinkTexture and state.originalTextures.Blink then
			blinkTexture.Texture = state.originalTextures.Blink
		end

		if hurtTexture and state.originalTextures.Hurt then
			hurtTexture.Texture = state.originalTextures.Hurt
		end

		local head = instance:FindFirstChild("Head")

		if head and state.originalTextures.HeadTextureID then
			head.TextureID = state.originalTextures.HeadTextureID
		elseif head and state.originalTextures.Normal then
			head.TextureID = state.originalTextures.Normal
		end

		if state.originalTextures.BlinkingParts then
			for part, blinkingPart in pairs(state.originalTextures.BlinkingParts) do
				if part and part.Parent and part:IsA("MeshPart") then
					part.TextureID = blinkingPart
				end
			end
		end
	end

	local animations = instance:FindFirstChild("Animations")

	if animations then
		local decode = animations:FindFirstChild("Decode")
		local transformDecode = animations:FindFirstChild("TransformDecode")

		if p then
			if decode and decode:IsA("Animation") then
				state.originalDecodeAnimId = decode.AnimationId
			end

			if transformDecode and transformDecode:IsA("Animation") and decode then
				decode.AnimationId = transformDecode.AnimationId
			end
		elseif decode and state.originalDecodeAnimId then
			decode.AnimationId = state.originalDecodeAnimId
		end
	end
end

function EclipseTransformation.ApplyWerewolfForm(instance)
	local v4

	if instance and instance.Parent then
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			v4 = false
		else
			v4 = humanoid.Health > 0
		end
	else
		v4 = false
	end

	if not v4 then
		return false
	end

	local v5 = v3[instance]

	if not v5 then
		v5 = EclipseTransformCore.newRecord()
		v5.originalTextures = {}
		v5.modifierIds = {}
		v3[instance] = v5
	end

	if not EclipseTransformCore.canStart(v5, "on") then
		return false
	end

	local v6 = EclipseTransformCore.begin(v5, "on")
	stopLeftovers(v5)
	instance:SetAttribute("Transforming", true)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		Network:Post(playerFromCharacter, "PlayHaptic", "RumbleLongLow")
	end

	local decoding = instance:FindFirstChild("Decoding")

	if decoding and decoding.Value ~= nil then
		local value = decoding.Value

		if value:FindFirstChild("Stats") then
			local forceStop = value.Stats:FindFirstChild("ForceStop")
			local playerFromCharacter2 = forceStop and Players:GetPlayerFromCharacter(instance)

			if playerFromCharacter2 then
				forceStop:Fire(playerFromCharacter2)
			end
		end

		local lastTime = tick()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		while tick() - lastTime < 1 do
			local value2 = decoding.Value
			local v7 = value2 == nil or value2 and not value2.Parent
			local v8 = humanoidRootPart and not humanoidRootPart.Anchored

			if v7 and v8 then
				if value2 and not value2.Parent then
					decoding.Value = nil
				end

				break
			else
				task.wait(0.05)
			end
		end

		local value2 = decoding.Parent and decoding.Value
		local v7

		if value2 == nil then
			v7 = false
		else
			v7 = value2.Parent ~= nil
		end

		local v8

		if value2 == nil then
			v8 = false
		else
			v8 = value2.Parent == nil
		end

		local anchored = humanoidRootPart and humanoidRootPart.Anchored

		if v7 or v8 or anchored then
			if v7 or v8 then
				decoding.Value = nil
			end

			if humanoidRootPart and humanoidRootPart.Anchored then
				humanoidRootPart.Anchored = false
			end
		end
	end

	if not EclipseTransformCore.owns(v5, v6) then
		return false
	end

	local v7

	if instance and instance.Parent then
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			v7 = false
		else
			v7 = humanoid.Health > 0
		end
	else
		v7 = false
	end

	if not v7 then
		return false
	end

	local stats = instance:FindFirstChild("Stats")
	local humanoid = instance.Humanoid
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	v5.noTarget = makeFlag(instance, "NoTarget", 5)
	v5.noDandy = makeFlag(instance, "NoDandy", 5)
	v5.noDecode = makeFlag(instance, "NoDecode", 5)
	v5.transformingFailsafe = task.delay(5, function()
		if instance:GetAttribute("Transforming") == true then
			instance:SetAttribute("Transforming", nil)
		end
	end)
	local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter2 then
		local ServerStorage = game:GetService("ServerStorage")
		local bindables = ServerStorage:FindFirstChild("Bindables")
		local removeCharacterAntiExploitModule = bindables and bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

		if removeCharacterAntiExploitModule then
			removeCharacterAntiExploitModule:Fire(playerFromCharacter2, true, nil, 10)
		end
	end

	if humanoidRootPart and humanoid then
		humanoidRootPart.Anchored = true
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		humanoidRootPart.CFrame += createVector(0, 2, 0)
	end

	local transitionTrack = playTransformationAnimation(instance, "TransformationOnLooped", true)
	v5.transitionTrack = transitionTrack
	playTransformationSound(instance)
	spawnTransformationParticles(instance)
	local v9 = not (transitionTrack and transitionTrack.Length > 0) and 0.8 or transitionTrack.Length or 0.8

	if EclipseTransformCore.mark(v5, "scale") then
		instance:ScaleTo(instance:GetScale() * 1.2)
	end

	print(string.format("[EclipseTransformation][DBG] %s: transform-on scale=%.3f", instance.Name, instance:GetScale()))
	instance:SetAttribute("Transformed", true)
	local v10 = v9 * 2 + 1
	local v11 = v10 + 1
	print(string.format(
		"[EclipseTransformation][DBG] %s: transform-on timings | loop=%.2fs unanchor@%.2fs complete@%.2fs fallback@%.2fs | state=%s",
		instance.Name,
		v9,
		v10,
		v11,
		v10 + 1.5,
		(tostring(humanoid:GetState()))
	))
	local flag = false
	local stateChangedConnection = nil
	stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Running or p == Enum.HumanoidStateType.GettingUp or p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.FallingDown then
			if flag or not EclipseTransformCore.current(v5, v6) then
				return
			end

			flag = true
			print(string.format(
				"[EclipseTransformation][DBG] %s: landing detected via state %s | track playing=%s",
				instance.Name,
				tostring(p),
				(tostring(transitionTrack and transitionTrack.IsPlaying))
			))

			if transitionTrack then
				transitionTrack:Stop()
			end

			v5.transitionTrack = nil

			if humanoid then
				humanoid.PlatformStand = false
				humanoid.AutoRotate = true
			end

			releaseFlags(v5)

			if stateChangedConnection then
				stateChangedConnection:Disconnect()
			end

			v5.landingConnection = nil
		end
	end)
	v5.landingConnection = stateChangedConnection
	task.delay(v10, function()
		if not EclipseTransformCore.current(v5, v6) then
			return
		end

		if instance.Parent and humanoidRootPart and humanoid then
			humanoidRootPart.Anchored = false
			restoreOwnership(instance, humanoidRootPart)
		end
	end)
	task.delay(v10 + 1.5, function()
		if flag or not EclipseTransformCore.current(v5, v6) then
			return
		end

		flag = true
		print(string.format(
			"[EclipseTransformation][DBG] %s: landing NOT detected - fallback cleanup | state=%s track playing=%s anchored=%s platformStand=%s",
			instance.Name,
			tostring(humanoid and humanoid:GetState()),
			tostring(transitionTrack and transitionTrack.IsPlaying),
			tostring(humanoidRootPart and humanoidRootPart.Anchored),
			(tostring(humanoid and humanoid.PlatformStand))
		))

		if transitionTrack and instance.Parent then
			transitionTrack:Stop()
		end

		v5.transitionTrack = nil

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end

		releaseFlags(v5)

		if stateChangedConnection then
			stateChangedConnection:Disconnect()
		end

		v5.landingConnection = nil
	end)

	if EclipseTransformCore.mark(v5, "textures") then
		swapTextures(instance, true, v5)
	end

	if stats and EclipseTransformCore.mark(v5, "stats") then
		local currentStamina = stats:FindFirstChild("CurrentStamina")
		v5.modifierIds.stamina = StatModifierManager.ApplyModifier(
			instance,
			"StaminaModifier",
			1.6,
			"EclipseWerewolf",
			{
				category = "ability",
				antiCheat = true
			}
		)
		v5.modifierIds.speed = StatModifierManager.ApplySpeedModifiers(instance, 1.2, "EclipseWerewolf", {
			category = "ability",
			antiCheat = true
		})

		if currentStamina then
			currentStamina.Value *= 1.6
			v5.modifierIds.currentStaminaMultiplier = 1.6
		end
	end

	if humanoidRootPart then
		local parent = humanoidRootPart:FindFirstChild("ToonLight")

		if not parent then
			parent = Instance.new("Attachment")
			parent.Name = "ToonLight"
			parent.Parent = humanoidRootPart
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = parent
			pointLight.Enabled = false
			pointLight.Range = 0
			pointLight.Brightness = 1
			pointLight.Color = color
		end

		local pointLight = parent:FindFirstChild("PointLight")

		if pointLight then
			EclipseTransformCore.mark(v5, "glow")
			pointLight.Color = color
			pointLight.Enabled = true
			local tween = TweenService:Create(
				pointLight,
				TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Range = 25
				}
			)
			v5.glowTween = tween
			tween:Play()
		end
	end

	task.delay(v11, function()
		if not EclipseTransformCore.finish(v5, v6, true) then
			return
		end

		print(string.format(
			"[EclipseTransformation][DBG] %s: transform-on COMPLETE | landingDetected=%s track playing=%s anchored=%s platformStand=%s state=%s",
			instance.Name,
			tostring(flag),
			tostring(transitionTrack and transitionTrack.IsPlaying),
			tostring(humanoidRootPart and humanoidRootPart.Anchored),
			tostring(humanoid and humanoid.PlatformStand),
			(tostring(humanoid and humanoid:GetState()))
		))

		if instance.Parent and object[instance] ~= false then
			pcall(moonHowl, instance)
		end

		instance:SetAttribute("Transforming", nil)
		releaseFlags(v5)

		if instance.Parent and humanoidRootPart and humanoid then
			releaseHold(instance) -- equivalent call inferred; original call site unknown
		end

		if v5.landingConnection then
			v5.landingConnection:Disconnect()
			v5.landingConnection = nil
		end

		fn(instance)
	end)
	return true
end

function EclipseTransformation.RemoveWerewolfForm(instance)
	if not (instance and instance:FindFirstChild("Humanoid")) then
		return false
	end

	local v4 = v3[instance]

	if not (v4 and EclipseTransformCore.canStart(v4, "off")) then
		return false
	end

	local v5 = EclipseTransformCore.begin(v4, "off")
	stopLeftovers(v4)
	instance:SetAttribute("Transforming", true)
	local humanoid = instance.Humanoid
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		local ServerStorage = game:GetService("ServerStorage")
		local bindables = ServerStorage:FindFirstChild("Bindables")
		local removeCharacterAntiExploitModule = bindables and bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

		if removeCharacterAntiExploitModule then
			removeCharacterAntiExploitModule:Fire(playerFromCharacter, true, nil, 5)
		end
	end

	if humanoidRootPart and humanoid then
		humanoidRootPart.Anchored = true
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
	end

	instance:SetAttribute("Transformed", false)
	local transitionTrack = playTransformationAnimation(instance, "TransformationOff", false)
	v4.transitionTrack = transitionTrack

	if EclipseTransformCore.take(v4, "textures") then
		swapTextures(instance, false, v4)
	end

	local length = transitionTrack and transitionTrack.Length > 0 and transitionTrack.Length or 0.8
	revertScale(instance, v4) -- equivalent call inferred; original call site unknown
	print(string.format("[EclipseTransformation][DBG] %s: transform-off scale=%.3f", instance.Name, instance:GetScale()))
	local v7 = length + 0.3
	print(string.format(
		"[EclipseTransformation][DBG] %s: transform-off timings | anim=%.2fs release@%.2fs",
		instance.Name,
		length,
		v7
	))
	revertStats(instance, v4)
	local v8 = EclipseTransformCore.take(v4, "glow")

	if v8 then
		v8 = glowLight(instance)
	end

	if v8 then
		local tween = TweenService:Create(v8, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Range = 0
		})
		v4.glowTween = tween
		tween:Play()
		task.delay(0.8, function()
			if not EclipseTransformCore.current(v4, v5) then
				return
			end

			v4.glowTween = nil
			restGlow(v8) -- equivalent call inferred; original call site unknown
		end)
	end

	task.delay(v7, function()
		if not EclipseTransformCore.finish(v4, v5, false) then
			return
		end

		v4.transitionTrack = nil
		instance:SetAttribute("Transforming", nil)
		releaseFlags(v4)

		if instance.Parent and humanoidRootPart and humanoid then
			releaseHold(instance) -- equivalent call inferred; original call site unknown
		end

		fn(instance)
	end)
	return true
end

function EclipseTransformation.IsTransformed(p)
	local v4 = v3[p]
	return v4 ~= nil and v4.transformed
end

function EclipseTransformation.IsTransforming(p)
	local v4 = v3[p]
	return v4 ~= nil and EclipseTransformCore.isBusy(v4)
end

function EclipseTransformation.Cleanup(instance)
	object[instance] = nil
	local v4 = v3[instance]

	if not v4 then
		return
	end

	v3[instance] = nil
	local busy = EclipseTransformCore.isBusy(v4)
	EclipseTransformCore.cancel(v4)
	stopLeftovers(v4)
	instance:SetAttribute("Transformed", false)
	instance:SetAttribute("Transforming", nil)
	local success, result = pcall(function()
		if EclipseTransformCore.take(v4, "textures") then
			swapTextures(instance, false, v4)
		end

		revertScale(instance, v4) -- equivalent call inferred; original call site unknown
		revertStats(instance, v4)
		EclipseTransformCore.take(v4, "glow")
		local v7 = glowLight(instance) -- equivalent call inferred; original call site unknown

		if v7 then
			restGlow(v7) -- equivalent call inferred; original call site unknown
		end

		if busy and instance.Parent then
			releaseHold(instance) -- equivalent call inferred; original call site unknown
		end
	end)

	if not success then
		warn("[EclipseTransformation] Cleanup could not fully revert", instance.Name, result)
	end
end

fn = function(p)
	local v4 = object[p]

	if v4 == nil then
		return
	end

	local step = EclipseTransformCore.nextStep(v3[p] or EclipseTransformCore.newRecord(), v4)

	if step == "on" then
		task.spawn(EclipseTransformation.ApplyWerewolfForm, p)
	elseif step == "off" then
		task.spawn(EclipseTransformation.RemoveWerewolfForm, p)
	end
end

function EclipseTransformation.SetBlackout(p, p2)
	object[p] = p2 == true
	fn(p)
end

return EclipseTransformation