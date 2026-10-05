local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))

local function playChewSoundLocal(part)
	if part and part:IsA("BasePart") then
		Audio:Play("Sounds.Twisted.Squirm.Chew", {
			Volume = 0.15,
			RollOffMaxDistance = 40,
			RollOffMode = Enum.RollOffMode.LinearSquare,
			Parent = part
		})
	end
end

local v = {}
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v3 = nil
local object2 = setmetatable({}, {
	__mode = "k"
})
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalSquirm()
	local character = localPlayer.Character

	if not character then
		return false
	end

	local config = character:FindFirstChild("Config")

	if not config then
		return false
	end

	local moduleName = config:FindFirstChild("ModuleName")
	return moduleName and moduleName.Value == "Squirm"
end

local function findClosestBookshelf(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local position = humanoidRootPart.Position
	local tagged = CollectionService:GetTagged("BookShelfModel")
	local v5 = 10
	local v6 = nil

	for _, part in ipairs(tagged) do
		if not part:IsDescendantOf(workspace) then
			continue
		end

		local magnitude = 1e999

		if part:IsA("BasePart") then
			magnitude = (position - part.Position).Magnitude
		else
			for _, part2 in ipairs(part:GetDescendants()) do
				if not part2:IsA("BasePart") then
					continue
				end

				local magnitude2 = (position - part2.Position).Magnitude

				if magnitude2 < magnitude then
					magnitude = magnitude2
				end
			end
		end

		if not (magnitude < v5) then
			continue
		end

		v6 = part
		v5 = magnitude
	end

	return v6
end

local function getBookParticlesTemplate()
	local parts = ReplicatedStorage:FindFirstChild("Parts")

	if not parts then
		return nil
	end

	for _, part in ipairs(parts:GetChildren()) do
		if part.Name == "BookParticles" and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function createNibbleParticles(folder)
	local bookParticlesTemplate = getBookParticlesTemplate()

	if not bookParticlesTemplate then
		warn("[SquirmEffects] BookParticles MeshPart not found in ReplicatedStorage.Parts!")
		return nil
	end

	local v5 = {}
	local v6 = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("Texture") or descendant:IsA("Decal")) or not descendant.Parent or not descendant.Parent:IsA("BasePart") or v5[descendant.Parent] then
			continue
		end

		v5[descendant.Parent] = true
		table.insert(v6, descendant.Parent)
	end

	if #v6 == 0 then
		for _, part in ipairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			table.insert(v6, part)
			break
		end
	end

	if #v6 == 0 and folder:IsA("BasePart") then
		table.insert(v6, folder)
	end

	if #v6 == 0 then
		warn("[SquirmEffects] No BasePart found in bookshelf!")
		return nil
	end

	local clones = {}

	for _, parent in ipairs(v6) do
		for _, emitter in ipairs(bookParticlesTemplate:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Enabled = false
			clone.Rate = 0
			clone.Parent = parent
			table.insert(clones, clone)
		end
	end

	return {
		particles = clones
	}
end

local function stopNibbleParticles(character)
	local v5 = v[character]

	if v5 then
		if v5.particles then
			for _, particle in ipairs(v5.particles) do
				if particle then
					particle.Enabled = false
				end
			end
		end

		task.delay(2, function()
			if v5.particles then
				for _, particle in ipairs(v5.particles) do
					if particle and particle.Parent then
						particle:Destroy()
					end
				end
			end
		end)
		v[character] = nil
	end
end

local v5 = {}

local function destroyCharacterNibbleParticles(p)
	local v6 = v2[p]

	if v6 then
		if v6.particles then
			for _, particle in ipairs(v6.particles) do
				if particle and particle.Parent then
					particle.Enabled = false
				end
			end
		end

		local attachment = v6.attachment
		task.delay(2, function()
			if attachment and attachment.Parent then
				attachment:Destroy()
			end
		end)
		v2[p] = nil
	end
end

local function stopCharacterNibbleParticles(instance, p)
	if p then
		if v5[instance] then
			v5[instance][p] = nil
		end

		local flag = false

		for _ in pairs(v5[instance] or {}) do
			flag = true
			break
		end

		if flag then
			return
		end
	end

	v5[instance] = nil
	destroyCharacterNibbleParticles(instance)
end

local function emitBookPageParticles(attachment, p, vector2, value)
	local bookParticlesTemplate = getBookParticlesTemplate()

	if not bookParticlesTemplate then
		warn("[SquirmEffects] BookParticles template not found")
		return
	end

	local children = bookParticlesTemplate:GetChildren()

	for _, emitter in ipairs(children) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Rate = 0
		clone.Enabled = false
		clone.EmissionDirection = p or Enum.NormalId.Top
		clone.SpreadAngle = vector2 or Vector2.new(180, 180)
		clone.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.05, 0.5),
			NumberSequenceKeypoint.new(0.8, 0.35),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.1, 0.1),
			NumberSequenceKeypoint.new(0.7, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		clone.Lifetime = NumberRange.new(1.5, 3)
		clone.Speed = NumberRange.new(3, 7)
		clone.Parent = attachment
		clone:Emit(value or 12)
	end
end

local function createCharacterNibbleParticles(instance, p)
	if p then
		if not v5[instance] then
			v5[instance] = {}
		end

		v5[instance][p] = true
	end

	if v2[instance] then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("[SquirmEffects] No HumanoidRootPart for character page-fly particles")
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "SquirmPageFlyAttachment"
	attachment.Position = createVector(0, 0.5, 0)
	attachment.Parent = humanoidRootPart
	emitBookPageParticles(attachment, Enum.NormalId.Top, Vector2.new(180, 180), 12)
	v2[instance] = {
		attachment = attachment
	}
end

local function createBuffParticles(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if object2[instance] then
		object2[instance]:Destroy()
		object2[instance] = nil
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")

	if not parts then
		warn("[SquirmEffects] ReplicatedStorage.Parts not found for buff particles")
		return
	end

	local buffParticles = parts:FindFirstChild("BuffParticles")

	if not buffParticles then
		warn("[SquirmEffects] ReplicatedStorage.Parts.BuffParticles not found")
		return
	end

	local decodeSpeed = buffParticles:FindFirstChild("DecodeSpeed")

	if not decodeSpeed then
		warn("[SquirmEffects] ReplicatedStorage.Parts.BuffParticles.DecodeSpeed not found")
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "SquirmBuffAttachment"
	attachment.Parent = humanoidRootPart
	local buffParticle = decodeSpeed:FindFirstChild("BuffParticle")

	if buffParticle then
		local clone = buffParticle:Clone()
		clone.Parent = attachment
		clone.Enabled = true
	end

	local glow = decodeSpeed:FindFirstChild("Glow")

	if glow then
		local clone = glow:Clone()
		clone.Parent = attachment
		clone.Enabled = true
	end

	object2[instance] = attachment
end

local function clearBuffParticles(instance)
	local v6 = instance and object2[instance]

	if v6 then
		object2[instance] = nil

		for _, emitter in ipairs(v6:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.delay(2, function()
			if v6 and v6.Parent then
				v6:Destroy()
			end
		end)
	end
end

local function startProximityParticles(instance)
	-- equivalent call inferred; original call site unknown
	if not isLocalSquirm() then
		return
	end

	local closestBookshelf = findClosestBookshelf(instance)

	if not closestBookshelf then
		return
	end

	if v3 then
		local particles = v3.particles or {}

		for _, particle in ipairs(particles) do
			if particle and particle.Parent then
				particle.Enabled = false
			end
		end

		task.delay(2, function()
			for _, particle in ipairs(particles) do
				if particle and particle.Parent then
					particle:Destroy()
				end
			end
		end)
	end

	local nibbleParticles = createNibbleParticles(closestBookshelf)

	if nibbleParticles then
		nibbleParticles.bookshelf = closestBookshelf
		v3 = nibbleParticles
	end
end

local function stopProximityParticles()
	if v3 then
		local particles = v3.particles or {}

		for _, particle in ipairs(particles) do
			if particle and particle.Parent then
				particle.Enabled = false
			end
		end

		task.delay(2, function()
			for _, particle in ipairs(particles) do
				if particle and particle.Parent then
					particle:Destroy()
				end
			end
		end)
		v3 = nil
	end
end

local function playProximityMunchAnimation(instance)
	-- equivalent call inferred; original call site unknown
	if not isLocalSquirm() or v4 then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("[SquirmEffects] No Humanoid found for proximity munch animation")
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn("[SquirmEffects] No Animator found for proximity munch animation")
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://80370936256063"
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not (success and result) then
		warn("[SquirmEffects] Failed to load proximity munch animation:", result)
		return
	end

	v4 = result
	v4.Priority = Enum.AnimationPriority.Action
	v4.Looped = true
	v4:Play(0.3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopProximityMunchAnimation()
	if v4 then
		v4:Stop(0.3)
		v4 = nil
	end
end

local function setupAttributeListener(instance)
	if not instance or object[instance] then
		return
	end

	object[instance] = true
	instance:GetAttributeChangedSignal("NearBookshelf"):Connect(function()
		if instance ~= localPlayer.Character then
			return
		end

		if instance:GetAttribute("NearBookshelf") then
			startProximityParticles(instance)
			playProximityMunchAnimation(instance)
		else
			stopProximityParticles()
			stopProximityMunchAnimation() -- equivalent call inferred; original call site unknown
		end
	end)

	if instance == localPlayer.Character and instance:GetAttribute("NearBookshelf") then
		startProximityParticles(instance)
		playProximityMunchAnimation(instance)
	end

	instance:GetAttributeChangedSignal("HoldAbilityActive"):Connect(function()
		if instance ~= localPlayer.Character then
			return
		end

		if instance:GetAttribute("HoldAbilityActive") then
			instance:SetAttribute("DisableQuirks", true)
			return
		end

		instance:SetAttribute("DisableQuirks", nil)
		stopCharacterNibbleParticles(instance, "hold")
	end)
	instance:GetAttributeChangedSignal("SquirmBookEaten"):Connect(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "BookEatBurstAttachment"
		attachment.Position = createVector(0, 0.5, -2)
		attachment.Parent = humanoidRootPart
		emitBookPageParticles(attachment, Enum.NormalId.Front, Vector2.new(120, 120), 9)
		task.delay(4, function()
			if attachment and attachment.Parent then
				attachment:Destroy()
			end
		end)
	end)
	instance:GetAttributeChangedSignal("SquirmBuffActive"):Connect(function()
		if instance:GetAttribute("SquirmBuffActive") then
			createBuffParticles(instance)
		else
			clearBuffParticles(instance)
		end
	end)

	if instance:GetAttribute("SquirmBuffActive") then
		createBuffParticles(instance)
	end
end

local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function connectNibbleHandler(p)
	p.OnClientEvent:Connect(function(character, bookshelf, p2)
		if p2 == "start" and bookshelf then
			stopNibbleParticles(character)
			local nibbleParticles = createNibbleParticles(bookshelf)

			if nibbleParticles then
				nibbleParticles.bookshelf = bookshelf
				v[character] = nibbleParticles

				if not Players:GetPlayerFromCharacter(character) then
					for _, particle in ipairs(nibbleParticles.particles) do
						particle.Enabled = true
						particle.Rate = 5
						particle.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.05, 0.5),
							NumberSequenceKeypoint.new(0.8, 0.35),
							NumberSequenceKeypoint.new(1, 0)
						})
						particle.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.7),
							NumberSequenceKeypoint.new(0.1, 0.1),
							NumberSequenceKeypoint.new(0.7, 0.3),
							NumberSequenceKeypoint.new(1, 1)
						})
						particle.Lifetime = NumberRange.new(1.5, 3)
						particle.Speed = NumberRange.new(2, 5)
					end
				end

				if v6[character] then
					v6[character]:Disconnect()
				end

				v6[character] = character.AncestryChanged:Connect(function(_, parent)
					if not parent then
						stopNibbleParticles(character)

						if v6[character] then
							v6[character]:Disconnect()
							v6[character] = nil
						end
					end
				end)
			end
		elseif p2 == "stop" then
			stopNibbleParticles(character)

			if v6[character] then
				v6[character]:Disconnect()
				v6[character] = nil
			end
		end
	end)
end

local flag = false
local setupNibbleEventListener

setupNibbleEventListener = function()
	if flag then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		ReplicatedStorage.ChildAdded:Connect(function(child)
			if child.Name == "Events" then
				setupNibbleEventListener()
			end
		end)
		return
	end

	local squirmBookshelfNibble = events:FindFirstChild("SquirmBookshelfNibble")

	if not squirmBookshelfNibble then
		events.ChildAdded:Connect(function(child)
			if child.Name == "SquirmBookshelfNibble" and not flag then
				flag = true
				connectNibbleHandler(child) -- equivalent call inferred; original call site unknown
			end
		end)
		return
	end

	flag = true
	connectNibbleHandler(squirmBookshelfNibble) -- equivalent call inferred; original call site unknown
end

local function emitChewDust(part)
	if not (part and part:IsA("BasePart")) then
		warn("[SquirmEffects] emitChewDust - invalid part:", part)
		return
	end

	local bookParticlesTemplate = getBookParticlesTemplate()
	local v7 = {}

	if bookParticlesTemplate then
		for _, emitter in ipairs(bookParticlesTemplate:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Rate = 0
			clone.Enabled = false
			clone.Parent = part
			clone:Emit(15)
			table.insert(v7, clone)
		end
	end

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 170, 155), Color3.fromRGB(140, 130, 115))
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 2),
		NumberSequenceKeypoint.new(1, 3)
	})
	particleEmitter.LightInfluence = 1
	particleEmitter.Speed = NumberRange.new(3, 7)
	particleEmitter.EmissionDirection = Enum.NormalId.Front
	particleEmitter.SpreadAngle = Vector2.new(50, 50)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter.Lifetime = NumberRange.new(1.5, 3)
	particleEmitter.Acceleration = createVector(0, 2, 0)
	particleEmitter.Drag = 3
	particleEmitter.Parent = part
	particleEmitter:Emit(20)
	table.insert(v7, particleEmitter)
	playChewSoundLocal(part)
	task.delay(5, function()
		for _, v8 in ipairs(v7) do
			if v8 and v8.Parent then
				v8:Destroy()
			end
		end
	end)
end

local flag2 = false
local setupChewDustListener

setupChewDustListener = function()
	if flag2 then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		ReplicatedStorage.ChildAdded:Connect(function(child)
			if child.Name == "Events" then
				setupChewDustListener()
			end
		end)
		return
	end

	local squirmChewDust = events:FindFirstChild("SquirmChewDust")

	if not squirmChewDust then
		events.ChildAdded:Connect(function(child)
			if child.Name == "SquirmChewDust" and not flag2 then
				flag2 = true
				child.OnClientEvent:Connect(function(parent)
					emitChewDust(parent)
				end)
			end
		end)
		return
	end

	flag2 = true
	squirmChewDust.OnClientEvent:Connect(function(parent)
		emitChewDust(parent)
	end)
end

local v7 = {
	active = false,
	leftIK = nil,
	rightIK = nil,
	config = nil,
	wiggleTween = nil,
	flailConnection = nil,
	originalTextures = {}
}
local v8 = {
	Brusha = {
		{
			meshName = "Brush_Geo",
			bone = "hand.r"
		},
		{
			meshName = "Notebook_Geo",
			bone = "hand.l"
		}
	},
	Astro = {
		{
			meshName = "StarBigGeo",
			attachment = "SquirmGrabRight"
		},
		{
			meshName = "StarSmallGeo",
			attachment = "SquirmGrabLeft"
		}
	},
	Eggson = {
		{
			meshName = "Cane",
			bone = "R_hand"
		}
	}
}
local v9 = {}

local function setupHeldItemClones(folder)
	if not (folder and folder.Parent) or v9[folder] then
		return
	end

	local config = folder:FindFirstChild("Config")

	if not config then
		return
	end

	local moduleName = config:FindFirstChild("ModuleName")

	if not moduleName then
		return
	end

	local v10 = v8[moduleName.Value]

	if not v10 then
		return
	end

	local bonesByName = {}

	for _, bone in ipairs(folder:GetDescendants()) do
		if bone:IsA("Bone") then
			bonesByName[bone.Name] = bone
		end
	end

	local v11 = {
		clones = {},
		originals = {},
		connection = nil
	}

	for _, v12 in ipairs(v10) do
		local part = folder:FindFirstChild(v12.meshName)
		local bone

		if v12.bone then
			bone = bonesByName[v12.bone] or nil
		end

		local v14 = bone or v12.attachment

		if not (part and part:IsA("MeshPart") and v14) then
			continue
		end

		local v15 = part

		for _, part2 in ipairs(part:GetChildren()) do
			if not (part2:IsA("MeshPart") and part2.Transparency < 1) then
				continue
			end

			v15 = part2
			break
		end

		local v17 = {
			mesh = part,
			transparency = part.Transparency,
			children = {}
		}
		part.Transparency = 1

		for _, child in ipairs(part:GetChildren()) do
			if not ((child:IsA("Decal") or child:IsA("MeshPart")) and child.Transparency < 1) then
				continue
			end

			table.insert(v17.children, {
				instance = child,
				transparency = child.Transparency
			})
			child.Transparency = 1
		end

		table.insert(v11.originals, v17)
		local clone = v15:Clone()
		clone.Name = v12.meshName .. "_HeldClone"
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Transparency = 0

		for _, child in ipairs(clone:GetChildren()) do
			if not (child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("WeldConstraint")) then
				continue
			end

			child:Destroy()
		end

		if bone then
			clone.CFrame = bone.TransformedWorldCFrame
		end

		clone.Parent = workspace
		table.insert(v11.clones, {
			clone = clone,
			bone = bone,
			attachmentName = v12.attachment,
			attachment = nil,
			character = folder
		})
	end

	if #v11.clones > 0 then
		v11.connection = RunService.RenderStepped:Connect(function()
			for _, clone in ipairs(v11.clones) do
				if not (clone.clone and clone.clone.Parent) then
					continue
				end

				if clone.bone then
					if clone.bone.Parent then
						clone.clone.CFrame = clone.bone.TransformedWorldCFrame
					else
						clone.clone:Destroy()
					end
				elseif clone.attachmentName then
					local humanoidRootPart = not (clone.attachment and clone.attachment.Parent) and clone.character and clone.character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						clone.attachment = humanoidRootPart:FindFirstChild(clone.attachmentName)
					end

					if clone.attachment and clone.attachment.Parent then
						clone.clone.CFrame = clone.attachment.WorldCFrame
					end
				else
					clone.clone:Destroy()
				end
			end
		end)
	end

	v9[folder] = v11
end

local function cleanupHeldItemClones(p)
	local v10 = v9[p]

	if not v10 then
		return
	end

	if v10.connection then
		v10.connection:Disconnect()
		v10.connection = nil
	end

	for _, clone in ipairs(v10.clones) do
		if clone.clone and clone.clone.Parent then
			clone.clone:Destroy()
		end
	end

	for _, original in ipairs(v10.originals) do
		if not (original.mesh and original.mesh.Parent) then
			continue
		end

		original.mesh.Transparency = original.transparency

		for _, v11 in ipairs(original.children) do
			if v11.instance and v11.instance.Parent then
				v11.instance.Transparency = v11.transparency
			end
		end
	end

	v9[p] = nil
end

local fn

local function fn2(instance, p)
	if not instance then
		return
	end

	local v10 = p or v7
	local config = instance:FindFirstChild("Config")

	if not config then
		warn("[SquirmEffects] No Config folder for hurt face")
		return
	end

	local decal = config:FindFirstChild((instance:GetAttribute("Transformed") == true and "Transform" or "") .. "HurtTexture") or config:FindFirstChild("HurtTexture")

	if not (decal and decal:IsA("Decal")) then
		warn("[SquirmEffects] HurtTexture not found in Config")
		return
	end

	local v11 = {}
	local blinkingParts = instance:FindFirstChild("BlinkingParts")

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
				continue
			end

			table.insert(v11, objectValue.Value)
			local meshPart = objectValue.Value:FindFirstChildWhichIsA("MeshPart")

			if meshPart then
				table.insert(v11, meshPart)
			end
		end
	else
		local head = instance:FindFirstChild("Head")

		if head then
			table.insert(v11, head)
			local head2 = head:FindFirstChild("Head")

			if head2 then
				table.insert(v11, head2)
			end
		end
	end

	v10.originalTextures = {}

	for _, part in ipairs(v11) do
		local surfaceAppearance = part:FindFirstChildWhichIsA("SurfaceAppearance")
		local decal2 = part:FindFirstChildWhichIsA("Decal")

		if surfaceAppearance then
			table.insert(v10.originalTextures, {
				part = part,
				type = "SurfaceAppearance",
				original = surfaceAppearance.TextureId
			})
			surfaceAppearance.TextureId = decal.Texture
		elseif decal2 then
			table.insert(v10.originalTextures, {
				part = part,
				type = "Decal",
				original = decal2.Texture
			})
			decal2.Texture = decal.Texture
		elseif part:IsA("MeshPart") or part:IsA("Part") then
			table.insert(v10.originalTextures, {
				part = part,
				type = "TextureID",
				original = part.TextureID
			})
			part.TextureID = decal.Texture
		end
	end
end

local function fn3(p)
	local v10 = p or v7

	for _, v11 in ipairs(v10.originalTextures or {}) do
		if not (v11.part and v11.part.Parent) then
			continue
		end

		if v11.type == "SurfaceAppearance" then
			local surfaceAppearance = v11.part:FindFirstChildWhichIsA("SurfaceAppearance")

			if surfaceAppearance then
				surfaceAppearance.TextureId = v11.original
			end
		elseif v11.type == "Decal" then
			local decal = v11.part:FindFirstChildWhichIsA("Decal")

			if decal then
				decal.Texture = v11.original
			end
		elseif v11.type == "TextureID" then
			v11.part.TextureID = v11.original
		end
	end

	v10.originalTextures = {}
end

local function fn4()
	if v7.flailConnection or not v7.active or not (v7.leftIK and v7.rightIK) then
		return
	end

	local total = 0
	local v10 = 0
	local v11 = "left"
	local config = v7.config
	local intensity = config.intensity or 3.5
	local duration = config.duration or 0.18
	local position = v7.leftIK.targetAttachment.Position
	local position2 = v7.rightIK.targetAttachment.Position
	local v12 = v7
	local RunService2 = game:GetService("RunService")
	v12.flailConnection = RunService2.Heartbeat:Connect(function(dt)
		if not v7.active then
			fn()
			return
		end

		total += dt

		if total - v10 >= 0.15 then
			v10 = total
			local leftIK = v11 == "left" and v7.leftIK or v7.rightIK
			local rightIK = v11 == "left" and v7.rightIK or v7.leftIK
			v11 = v11 == "left" and "right" or "left"
			local vector2 = Vector3.new(leftIK.sideDir * intensity, intensity * 0.8, 0)
			local vector3 = Vector3.new(rightIK.sideDir * intensity, -intensity * 0.5, 0)

			if v11 == "right" then
				position = vector2
				position2 = vector3
			else
				position2 = vector2
				position = vector3
			end
		end

		local v13 = math.min(1, dt / math.max(duration, 0.01))
		v7.leftIK.ikControl.Weight = v7.leftIK.ikControl.Weight + (1 - v7.leftIK.ikControl.Weight) * v13
		v7.leftIK.targetAttachment.Position = v7.leftIK.targetAttachment.Position:Lerp(position, v13)
		v7.rightIK.ikControl.Weight = v7.rightIK.ikControl.Weight + (1 - v7.rightIK.ikControl.Weight) * v13
		v7.rightIK.targetAttachment.Position = v7.rightIK.targetAttachment.Position:Lerp(position2, v13)
	end)
end

fn = function()
	if v7.flailConnection then
		v7.flailConnection:Disconnect()
		v7.flailConnection = nil
	end
end

local function overrideIsRigIdle(instance, p)
	if not p then
		return false
	end

	local animations = instance and instance:FindFirstChild("Animations")
	local idle = animations and animations:FindFirstChild("Idle")
	return idle ~= nil and idle:IsA("Animation") and idle.AnimationId == p
end

local function setupArmWiggle(p)
	if v7.active then
		return
	end

	local character = localPlayer.Character

	if not character then
		warn("[SquirmEffects] No character for arm wiggle")
		return
	end

	character:SetAttribute("DisableQuirks", true)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		warn("[SquirmEffects] Missing rootPart or humanoid for arm wiggle")
		return
	end

	local count = 0

	for _, iKControl in ipairs(humanoid:GetChildren()) do
		if not iKControl:IsA("IKControl") then
			continue
		end

		if not (iKControl.Name:match("Arm") or iKControl.Name:match("Wiggle") or iKControl.Name:match("Icey")) then
			continue
		end

		iKControl:Destroy()
		count += 1
	end

	local _ = count > 0
	v7.config = p or {
		duration = 0.15,
		intensity = 1.5
	}
	local animationId = nil
	local v11 = nil
	local v12 = nil
	local v13 = nil
	local config = character:FindFirstChild("Config")

	if config then
		local moduleName = config:FindFirstChild("ModuleName")

		if moduleName then
			local sharedData = ReplicatedStorage:FindFirstChild("SharedData")

			if sharedData then
				local iKOverrideAnimations = sharedData:FindFirstChild("IKOverrideAnimations")

				if iKOverrideAnimations then
					local success, result = pcall(require, iKOverrideAnimations)

					if success and result and result[moduleName.Value] then
						local v14 = result[moduleName.Value]

						if type(v14) == "table" then
							animationId = v14[1]
							v11 = v14[2]
							v12 = v14[3]
							v13 = v14[4]
						else
							animationId = v14
						end
					end
				end
			end
		end
	end

	local v14 = nil
	local v15 = nil

	if v11 and v12 then
		for _, bone in ipairs(character:GetDescendants()) do
			if not bone:IsA("Bone") then
				continue
			end

			if not v14 and bone.Name == v11 then
				v14 = bone
			end

			if v15 or bone.Name ~= v12 then
				continue
			end

			v15 = bone
		end
	end

	if not (v14 and v15) then
		for _, bone in ipairs(character:GetDescendants()) do
			if not bone:IsA("Bone") then
				continue
			end

			local name = bone.Name:lower()

			if (v14 or name ~= "lefthand" and name ~= "left_hand" and name ~= "l_hand" and name ~= "hand.l" and name ~= "l_hand_jnt" and name ~= "handbone_l" and name ~= "hand_l") and (v14 or not (name:find("left") and name:find("hand"))) and (v14 or not name:match("l_hand")) then
				if not v14 and name:find("hand") and name:match("[_%.]l$") then
					v14 = bone
				end
			else
				v14 = bone
			end

			if v15 or name ~= "righthand" and name ~= "right_hand" and name ~= "r_hand" and name ~= "hand.r" and name ~= "r_hand_jnt" and name ~= "handbone_r" and name ~= "hand_r" then
				if v15 or not (name:find("right") and name:find("hand")) then
					if v15 or not name:match("r_hand") then
						if not v15 and name:find("hand") and name:match("[_%.]r$") then
							v15 = bone
						end
					else
						v15 = bone
					end
				else
					v15 = bone
				end
			else
				v15 = bone
			end
		end
	end

	if v14 and v15 then
		local v16 = v13 or 2

		local function getChainRoot(bone)
			if not (bone and bone:IsA("Bone")) then
				return nil
			end

			local v17 = bone

			for _ = 1, v16 do
				local parent = v17.Parent

				if parent and parent:IsA("Bone") then
					v17 = parent
				else
					if v17 == bone or not v17 then
						return nil
					end

					return v17
				end
			end

			return v17
		end

		local chainRoot = getChainRoot(v14)
		local chainRoot2 = getChainRoot(v15)

		if chainRoot and chainRoot2 then
			local function createArmIK(chainRoot3, endEffector, p2)
				local sideDir = p2 == "Left" and -1 or 1
				local attachment = Instance.new("Attachment")
				attachment.Name = "SquirmWiggleTarget_" .. p2
				attachment.Parent = humanoidRootPart
				attachment.Position = Vector3.new(sideDir * 3, 0.5, 0)
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "SquirmWigglePole_" .. p2
				attachment2.Parent = humanoidRootPart
				attachment2.Position = Vector3.new(sideDir * 1.5, 1.5, -1)
				local iKControl = Instance.new("IKControl")
				iKControl.Name = "SquirmWiggleIK_" .. p2
				iKControl.Type = Enum.IKControlType.Position
				iKControl.ChainRoot = chainRoot3
				iKControl.EndEffector = endEffector
				iKControl.Target = attachment
				iKControl.Pole = attachment2
				iKControl.Weight = 0
				iKControl.SmoothTime = 0.2
				iKControl.Parent = humanoid
				return {
					ikControl = iKControl,
					targetAttachment = attachment,
					poleAttachment = attachment2,
					sideDir = sideDir
				}
			end

			v7.leftIK = createArmIK(chainRoot, v14, "Left")
			v7.rightIK = createArmIK(chainRoot2, v15, "Right")
			v7.active = true
			v7.startTime = tick()
			local animator = humanoid:FindFirstChildOfClass("Animator")

			if animator then
				local v17

				if animationId then
					local animations = character and character:FindFirstChild("Animations")
					local idle = animations and animations:FindFirstChild("Idle")

					if idle == nil then
						v17 = false
					else
						v17 = idle:IsA("Animation") and idle.AnimationId == animationId
					end
				else
					v17 = false
				end

				if not v17 then
					if animationId then
						local animation = Instance.new("Animation")
						animation.AnimationId = animationId
						local success, result = pcall(function()
							return animator:LoadAnimation(animation)
						end)

						if success and result then
							result.Priority = Enum.AnimationPriority.Action4
							result.Looped = true
							result:Play(0.2)
							v7.decodeTrack = result
						end
					else
						local animations = character:FindFirstChild("Animations")

						if animations then
							local decode = animations:FindFirstChild("Decode")

							if decode and decode:IsA("Animation") then
								local success, result = pcall(function()
									return animator:LoadAnimation(decode)
								end)

								if success and result then
									result.Priority = Enum.AnimationPriority.Action4
									result.Looped = true
									result:Play(0.2)
									v7.decodeTrack = result
								end
							end
						end
					end
				end
			end

			fn2(character)

			if p.flailEnabled then
				fn4()
			end

			return
		end
	end

	fn2(character)
	v7.active = true
end

local function cleanupArmWiggle()
	if not v7.active then
		return
	end

	fn()

	if v7.wiggleTween then
		v7.wiggleTween:Cancel()
		v7.wiggleTween = nil
	end

	if v7.decodeTrack then
		v7.decodeTrack:Stop(0.2)
		v7.decodeTrack = nil
	end

	fn3()
	local character = localPlayer.Character

	if character then
		character:SetAttribute("DisableQuirks", nil)
	end

	if v7.leftIK then
		if v7.leftIK.ikControl then
			v7.leftIK.ikControl:Destroy()
		end

		if v7.leftIK.targetAttachment then
			v7.leftIK.targetAttachment:Destroy()
		end

		if v7.leftIK.poleAttachment then
			v7.leftIK.poleAttachment:Destroy()
		end

		v7.leftIK = nil
	end

	if v7.rightIK then
		if v7.rightIK.ikControl then
			v7.rightIK.ikControl:Destroy()
		end

		if v7.rightIK.targetAttachment then
			v7.rightIK.targetAttachment:Destroy()
		end

		if v7.rightIK.poleAttachment then
			v7.rightIK.poleAttachment:Destroy()
		end

		v7.rightIK = nil
	end

	v7.active = false
	v7.config = nil
end

function _G.SquirmArmWiggleTrigger(p)
	if not (v7.active and (v7.leftIK and v7.rightIK)) then
		return
	end

	local config = v7.config
	local duration = config.duration or 0.18
	local intensity = config.intensity or 3.5
	local leftIK = p == "left" and v7.leftIK or v7.rightIK
	local rightIK = p == "left" and v7.rightIK or v7.leftIK
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local vector2 = Vector3.new(leftIK.sideDir * intensity, intensity * 0.8, 0)
	local vector3 = Vector3.new(rightIK.sideDir * intensity, -intensity * 0.5, 0)
	TweenService:Create(leftIK.ikControl, tweenInfo, {
		Weight = 1
	}):Play()
	TweenService:Create(leftIK.targetAttachment, tweenInfo, {
		Position = vector2
	}):Play()
	TweenService:Create(rightIK.ikControl, tweenInfo, {
		Weight = 1
	}):Play()
	local tween = TweenService:Create(rightIK.targetAttachment, tweenInfo, {
		Position = vector3
	})
	tween:Play()
	v7.wiggleTween = tween
end

local v10 = {}

local function cleanupObserverWiggle(p)
	local v11 = v10[p]

	if not v11 then
		return
	end

	if v11.flailConnection then
		v11.flailConnection:Disconnect()
		v11.flailConnection = nil
	end

	if v11.decodeTrack then
		v11.decodeTrack:Stop(0.2)
		v11.decodeTrack = nil
	end

	fn3(v11)

	if v11.leftIK then
		if v11.leftIK.ikControl then
			v11.leftIK.ikControl:Destroy()
		end

		if v11.leftIK.targetAttachment then
			v11.leftIK.targetAttachment:Destroy()
		end

		if v11.leftIK.poleAttachment then
			v11.leftIK.poleAttachment:Destroy()
		end
	end

	if v11.rightIK then
		if v11.rightIK.ikControl then
			v11.rightIK.ikControl:Destroy()
		end

		if v11.rightIK.targetAttachment then
			v11.rightIK.targetAttachment:Destroy()
		end

		if v11.rightIK.poleAttachment then
			v11.rightIK.poleAttachment:Destroy()
		end
	end

	v10[p] = nil
end

local function setupObserverWiggle(folder, p)
	if not (folder and folder.Parent and folder ~= localPlayer.Character) then
		return
	end

	cleanupObserverWiggle(folder)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		warn("[SquirmEffects] Observer wiggle: missing rootPart or humanoid for", folder.Name)
		return
	end

	local v11 = {
		active = true,
		leftIK = nil,
		rightIK = nil,
		flailConnection = nil,
		decodeTrack = nil,
		originalTextures = {}
	}
	v10[folder] = v11
	fn2(folder, v11)
	local animationId = nil
	local v13 = nil
	local v14 = nil
	local v15 = nil
	local config = folder:FindFirstChild("Config")

	if config then
		local moduleName = config:FindFirstChild("ModuleName")

		if moduleName then
			local sharedData = ReplicatedStorage:FindFirstChild("SharedData")

			if sharedData then
				local iKOverrideAnimations = sharedData:FindFirstChild("IKOverrideAnimations")

				if iKOverrideAnimations then
					local success, result = pcall(require, iKOverrideAnimations)

					if success and result and result[moduleName.Value] then
						local v16 = result[moduleName.Value]

						if type(v16) == "table" then
							animationId = v16[1]
							v13 = v16[2]
							v14 = v16[3]
							v15 = v16[4]
						else
							animationId = v16
						end
					end
				end
			end
		end
	end

	local v16 = nil
	local v17 = nil

	if v13 and v14 then
		for _, bone in ipairs(folder:GetDescendants()) do
			if not bone:IsA("Bone") then
				continue
			end

			if not v16 and bone.Name == v13 then
				v16 = bone
			end

			if v17 or bone.Name ~= v14 then
				continue
			end

			v17 = bone
		end
	end

	if not (v16 and v17) then
		for _, bone in ipairs(folder:GetDescendants()) do
			if not bone:IsA("Bone") then
				continue
			end

			local name = bone.Name:lower()

			if (v16 or name ~= "lefthand" and name ~= "left_hand" and name ~= "l_hand" and name ~= "hand.l" and name ~= "l_hand_jnt" and name ~= "handbone_l" and name ~= "hand_l") and (v16 or not (name:find("left") and name:find("hand"))) and (v16 or not name:match("l_hand")) then
				if not v16 and name:find("hand") and name:match("[_%.]l$") then
					v16 = bone
				end
			else
				v16 = bone
			end

			if v17 or name ~= "righthand" and name ~= "right_hand" and name ~= "r_hand" and name ~= "hand.r" and name ~= "r_hand_jnt" and name ~= "handbone_r" and name ~= "hand_r" then
				if v17 or not (name:find("right") and name:find("hand")) then
					if v17 or not name:match("r_hand") then
						if not v17 and name:find("hand") and name:match("[_%.]r$") then
							v17 = bone
						end
					else
						v17 = bone
					end
				else
					v17 = bone
				end
			else
				v17 = bone
			end
		end
	end

	if not (v16 and v17) then
		return
	end

	local v18 = v15 or 2

	local function getChainRoot(bone)
		if not (bone and bone:IsA("Bone")) then
			return nil
		end

		local v19 = bone

		for _ = 1, v18 do
			local parent = v19.Parent

			if parent and parent:IsA("Bone") then
				v19 = parent
			else
				if v19 == bone or not v19 then
					return nil
				end

				return v19
			end
		end

		return v19
	end

	local chainRoot = getChainRoot(v16)
	local chainRoot2 = getChainRoot(v17)

	if not (chainRoot and chainRoot2) then
		return
	end

	local function createArmIK(chainRoot3, endEffector, p2)
		local sideDir = p2 == "Left" and -1 or 1
		local attachment = Instance.new("Attachment")
		attachment.Name = "SquirmObserverTarget_" .. p2
		attachment.Parent = humanoidRootPart
		attachment.Position = Vector3.new(sideDir * 3, 0.5, 0)
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "SquirmObserverPole_" .. p2
		attachment2.Parent = humanoidRootPart
		attachment2.Position = Vector3.new(sideDir * 1.5, 1.5, -1)
		local iKControl = Instance.new("IKControl")
		iKControl.Name = "SquirmObserverIK_" .. p2
		iKControl.Type = Enum.IKControlType.Position
		iKControl.ChainRoot = chainRoot3
		iKControl.EndEffector = endEffector
		iKControl.Target = attachment
		iKControl.Pole = attachment2
		iKControl.Weight = 0
		iKControl.SmoothTime = 0.2
		iKControl.Parent = humanoid
		return {
			ikControl = iKControl,
			targetAttachment = attachment,
			poleAttachment = attachment2,
			sideDir = sideDir
		}
	end

	v11.leftIK = createArmIK(chainRoot, v16, "Left")
	v11.rightIK = createArmIK(chainRoot2, v17, "Right")
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if animator then
		local v19

		if animationId then
			local animations = folder and folder:FindFirstChild("Animations")
			local idle = animations and animations:FindFirstChild("Idle")

			if idle == nil then
				v19 = false
			else
				v19 = idle:IsA("Animation") and idle.AnimationId == animationId
			end
		else
			v19 = false
		end

		if not v19 then
			if animationId then
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				local success, result = pcall(function()
					return animator:LoadAnimation(animation)
				end)

				if success and result then
					result.Priority = Enum.AnimationPriority.Action4
					result.Looped = true
					result:Play(0.2)
					v11.decodeTrack = result
				end
			else
				local animations = folder:FindFirstChild("Animations")

				if animations then
					local decode = animations:FindFirstChild("Decode")

					if decode and decode:IsA("Animation") then
						local success, result = pcall(function()
							return animator:LoadAnimation(decode)
						end)

						if success and result then
							result.Priority = Enum.AnimationPriority.Action4
							result.Looped = true
							result:Play(0.2)
							v11.decodeTrack = result
						end
					end
				end
			end
		end
	end

	local total = 0
	local v19 = 0
	local v20 = "left"
	local v21 = not p and 1.5 or p.intensity or 1.5
	local duration = p and p.duration or 0.15
	local vector2 = Vector3.new(v11.leftIK.sideDir * 3, 0.5, 0)
	local vector3 = Vector3.new(v11.rightIK.sideDir * 3, 0.5, 0)
	local RunService2 = game:GetService("RunService")
	v11.flailConnection = RunService2.Heartbeat:Connect(function(dt)
		if not (v11.active and folder and folder.Parent) then
			cleanupObserverWiggle(folder)
			return
		end

		total += dt

		if total - v19 >= 0.15 then
			v19 = total
			local leftIK = v20 == "left" and v11.leftIK or v11.rightIK
			local rightIK = v20 == "left" and v11.rightIK or v11.leftIK
			v20 = v20 == "left" and "right" or "left"
			local vector4 = Vector3.new(leftIK.sideDir * v21, v21 * 0.8, 0)
			local vector5 = Vector3.new(rightIK.sideDir * v21, -v21 * 0.5, 0)

			if v20 == "right" then
				vector2 = vector4
				vector3 = vector5
			else
				vector3 = vector4
				vector2 = vector5
			end
		end

		local v22 = math.min(1, dt / math.max(duration, 0.01))
		v11.leftIK.ikControl.Weight = v11.leftIK.ikControl.Weight + (1 - v11.leftIK.ikControl.Weight) * v22
		v11.leftIK.targetAttachment.Position = v11.leftIK.targetAttachment.Position:Lerp(vector2, v22)
		v11.rightIK.ikControl.Weight = v11.rightIK.ikControl.Weight + (1 - v11.rightIK.ikControl.Weight) * v22
		v11.rightIK.targetAttachment.Position = v11.rightIK.targetAttachment.Position:Lerp(vector3, v22)
	end)
end

local setupArmWiggleListener

setupArmWiggleListener = function()
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		ReplicatedStorage.ChildAdded:Connect(function(child)
			if child.Name == "Events" then
				setupArmWiggleListener()
			end
		end)
		return
	end

	local twistedSquirmGrab = events:FindFirstChild("TwistedSquirmGrab")

	if twistedSquirmGrab then
		twistedSquirmGrab.OnClientEvent:Connect(function(p, data)
			if p == "GrabStart" then
				if localPlayer.Character then
					setupHeldItemClones(localPlayer.Character)
				end

				if data and data.armWiggle then
					setupArmWiggle({
						duration = data.armWiggleDuration or 0.15,
						intensity = data.armWiggleIntensity or 1.5,
						flailEnabled = data.armWiggleFlail or false
					})
				end
			elseif p == "GrabEnd" or p == "Escaped" or p == "Timeout" then
				cleanupArmWiggle()

				if localPlayer.Character then
					cleanupHeldItemClones(localPlayer.Character)
				end
			elseif p == "ObserverGrabStart" then
				if data and data.character then
					setupHeldItemClones(data.character)
				end

				if data and data.armWiggle and data.character then
					setupObserverWiggle(data.character, {
						duration = data.armWiggleDuration or 0.15,
						intensity = data.armWiggleIntensity or 1.5
					})
				end
			elseif p == "ObserverGrabEnd" and data and data.character then
				cleanupObserverWiggle(data.character)
				cleanupHeldItemClones(data.character)
			end
		end)
	else
		events.ChildAdded:Connect(function(child)
			if child.Name == "TwistedSquirmGrab" then
				setupArmWiggleListener()
			end
		end)
	end
end

local function initialize()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function trySetupTagged(instance)
		if instance:GetAttribute("ToonName") == "Squirm" then
			setupAttributeListener(instance)
		end
	end

	for _, v11 in ipairs(CollectionService:GetTagged("Character")) do
		trySetupTagged(v11) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("Character"):Connect(trySetupTagged)
	localPlayer.CharacterAdded:Connect(function()
		stopProximityParticles()
		stopProximityMunchAnimation() -- equivalent call inferred; original call site unknown
		cleanupArmWiggle()
		local v11 = {}

		for k in pairs(v9) do
			table.insert(v11, k)
		end

		for _, v12 in ipairs(v11) do
			cleanupHeldItemClones(v12)
		end
	end)
	setupNibbleEventListener()
	setupChewDustListener()
	setupArmWiggleListener()
end

initialize()