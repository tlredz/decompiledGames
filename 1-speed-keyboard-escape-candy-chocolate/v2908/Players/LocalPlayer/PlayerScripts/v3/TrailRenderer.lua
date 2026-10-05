local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local v = {}

local function applyTrailFromConfig(trail, trailData)
	trail.Color = trailData.Color
	trail.Lifetime = trailData.Lifetime or 0.5
	trail.FaceCamera = trailData.FaceCamera == nil or trailData.FaceCamera
	trail.WidthScale = trailData.WidthScale or NumberSequence.new(1, 0)
	trail.Transparency = trailData.Transparency or NumberSequence.new(0)
	trail.LightInfluence = 0
	trail.LightEmission = 0.3

	if trailData.Texture then
		trail.Texture = trailData.Texture
	end

	if trailData.TextureLength then
		trail.TextureLength = trailData.TextureLength
	end

	if trailData.TextureMode then
		trail.TextureMode = trailData.TextureMode
	end

	if trailData.MaxLength then
		trail.MaxLength = trailData.MaxLength
	end

	if trailData.MinLength then
		trail.MinLength = trailData.MinLength
	end
end

local function createTrail(folder, equippedTrail, maid)
	local IMAGE_ID = "rbxassetid://12598279413"
	maid:Cleanup()

	for _, trail in ipairs(folder:GetDescendants()) do
		if not (trail:IsA("Trail") or trail.Name:find("TrailAtt") or trail.Name:find("TrailFX")) then
			continue
		end

		trail:Destroy()
	end

	local trailData = PlayerUpgradesCatalog.GetTrailData(equippedTrail)

	if equippedTrail == "None" or not trailData then
		return
	end

	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart", 5)
	local humanoid = folder:WaitForChild("Humanoid", 5)

	if not (humanoidRootPart and humanoid) then
		return
	end

	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "TrailAtt0"
	attachment.Position = createVector(0, 1.5, 0)
	local attachment2 = Instance.new("Attachment", humanoidRootPart)
	attachment2.Name = "TrailAtt1"
	attachment2.Position = createVector(0, -1.5, 0)
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	applyTrailFromConfig(trail, trailData)
	trail.Parent = folder

	if equippedTrail == "EasterTrail" then
		trail.TextureMode = Enum.TextureMode.Wrap
		trail.LightEmission = 0.1
		local attachment3 = Instance.new("Attachment", humanoidRootPart)
		attachment3.Name = "TrailFX_DropAtt"
		attachment3.Position = createVector(0, -1, 0)
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "TrailFX_Drops"
		particleEmitter.Texture = "rbxassetid://102982173039667"
		particleEmitter.Rate = 120
		particleEmitter.Lifetime = NumberRange.new(0.5, 1.2)
		particleEmitter.Speed = NumberRange.new(2, 6)
		particleEmitter.SpreadAngle = Vector2.new(55, 55)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-200, 200)
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 130, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 10))
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(0.6, 0.35),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.75, 0.1),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.LightEmission = 0
		particleEmitter.Acceleration = createVector(0, -20, 0)
		particleEmitter.LockedToPart = false
		particleEmitter.Enabled = false
		particleEmitter.Parent = attachment3
		local attachment4 = Instance.new("Attachment", humanoidRootPart)
		attachment4.Name = "TrailFX_SplashAtt"
		attachment4.Position = createVector(0, -1.5, 0)
		local particleEmitter2 = Instance.new("ParticleEmitter")
		particleEmitter2.Name = "TrailFX_Splash"
		particleEmitter2.Texture = "rbxassetid://102982173039667"
		particleEmitter2.Rate = 25
		particleEmitter2.Lifetime = NumberRange.new(0.6, 1)
		particleEmitter2.Speed = NumberRange.new(4, 9)
		particleEmitter2.SpreadAngle = Vector2.new(70, 70)
		particleEmitter2.Rotation = NumberRange.new(0, 360)
		particleEmitter2.RotSpeed = NumberRange.new(-90, 90)
		particleEmitter2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 160, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 70, 20))
		})
		particleEmitter2.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.1),
			NumberSequenceKeypoint.new(0.5, 0.7),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.8, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter2.LightEmission = 0
		particleEmitter2.Acceleration = createVector(0, -25, 0)
		particleEmitter2.LockedToPart = false
		particleEmitter2.Enabled = false
		particleEmitter2.Parent = attachment4
		maid:Add((humanoid.Running:Connect(function(p: number)
			local enabled = p > 1

			if particleEmitter and particleEmitter.Parent then
				particleEmitter.Enabled = enabled
			end

			if particleEmitter2 and particleEmitter2.Parent then
				particleEmitter2.Enabled = enabled
			end
		end)))
	elseif equippedTrail == "EasterGoldenTrail" then
		trail.TextureMode = Enum.TextureMode.Wrap
		trail.LightEmission = 0.1
		local trail2 = Instance.new("Trail")
		trail2.Name = "TrailFX_Overlay"
		trail2.Attachment0 = attachment
		trail2.Attachment1 = attachment2
		trail2.Lifetime = 0.5
		trail2.Texture = "rbxassetid://12251459424"
		trail2.TextureMode = Enum.TextureMode.Stretch
		trail2.Color = ColorSequence.new(Color3.fromRGB(255, 140, 0))
		trail2.FaceCamera = true
		trail2.Transparency = NumberSequence.new(0)
		trail2.WidthScale = NumberSequence.new(1, 0)
		trail2.LightInfluence = 0
		trail2.LightEmission = 1
		trail2.Parent = folder
		local trail3 = Instance.new("Trail")
		trail3.Name = "TrailFX_Glow"
		trail3.Attachment0 = attachment
		trail3.Attachment1 = attachment2
		trail3.Lifetime = 0.25
		trail3.Texture = IMAGE_ID
		trail3.TextureMode = Enum.TextureMode.Stretch
		trail3.Color = ColorSequence.new(Color3.fromRGB(255, 180, 50))
		trail3.FaceCamera = true
		trail3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail3.WidthScale = NumberSequence.new(1, 0)
		trail3.LightInfluence = 0
		trail3.LightEmission = 1
		trail3.Parent = folder
		local attachment3 = Instance.new("Attachment", humanoidRootPart)
		attachment3.Name = "TrailFX_StarAtt"
		attachment3.Position = createVector(0, -1, 0)
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "TrailFX_Stars"
		particleEmitter.Texture = "rbxassetid://10598374841"
		particleEmitter.Rate = 120
		particleEmitter.Lifetime = NumberRange.new(0.6, 1.2)
		particleEmitter.Speed = NumberRange.new(2, 6)
		particleEmitter.SpreadAngle = Vector2.new(80, 80)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-180, 180)
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 100, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 0))
		})
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2),
			NumberSequenceKeypoint.new(0.5, 1.4),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.85, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.LightEmission = 1
		particleEmitter.Acceleration = createVector(0, 4, 0)
		particleEmitter.LockedToPart = false
		particleEmitter.Enabled = false
		particleEmitter.Parent = attachment3
		local attachment4 = Instance.new("Attachment", humanoidRootPart)
		attachment4.Name = "TrailFX_SparkAtt"
		attachment4.Position = createVector(0, -0.5, 0)
		local particleEmitter2 = Instance.new("ParticleEmitter")
		particleEmitter2.Name = "TrailFX_Sparks"
		particleEmitter2.Texture = IMAGE_ID
		particleEmitter2.Rate = 180
		particleEmitter2.Lifetime = NumberRange.new(0.3, 0.6)
		particleEmitter2.Speed = NumberRange.new(3, 8)
		particleEmitter2.SpreadAngle = Vector2.new(60, 60)
		particleEmitter2.Rotation = NumberRange.new(0, 360)
		particleEmitter2.RotSpeed = NumberRange.new(-360, 360)
		particleEmitter2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(251, 255, 234)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 200, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(144, 108, 0))
		})
		particleEmitter2.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.4, 0.7),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter2.LightEmission = 1
		particleEmitter2.Acceleration = createVector(0, 8, 0)
		particleEmitter2.LockedToPart = false
		particleEmitter2.Enabled = false
		particleEmitter2.Parent = attachment4
		maid:Add((humanoid.Running:Connect(function(p: number)
			local enabled = p > 1

			if particleEmitter and particleEmitter.Parent then
				particleEmitter.Enabled = enabled
			end

			if particleEmitter2 and particleEmitter2.Parent then
				particleEmitter2.Enabled = enabled
			end
		end)))
	elseif equippedTrail == "GalaxyTrail" then
		local trail2 = Instance.new("Trail")
		trail2.Name = "TrailFX_Overlay"
		trail2.Attachment0 = attachment
		trail2.Attachment1 = attachment2
		trail2.Lifetime = 0.45
		trail2.Texture = "rbxassetid://12251459424"
		trail2.TextureMode = Enum.TextureMode.Stretch
		trail2.Color = ColorSequence.new(Color3.fromRGB(200, 160, 255))
		trail2.FaceCamera = true
		trail2.Transparency = NumberSequence.new(0)
		trail2.WidthScale = NumberSequence.new(1, 0)
		trail2.LightInfluence = 0
		trail2.LightEmission = 1
		trail2.Parent = folder
		local attachment3 = Instance.new("Attachment", humanoidRootPart)
		attachment3.Name = "TrailFX_PartAtt"
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "TrailFX_Particles"
		particleEmitter.Texture = IMAGE_ID
		particleEmitter.Rate = 250
		particleEmitter.Lifetime = NumberRange.new(0.6, 1.2)
		particleEmitter.Speed = NumberRange.new(0)
		particleEmitter.LockedToPart = false
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 100, 255))
		})
		particleEmitter.Size = NumberSequence.new(1.2, 0)
		particleEmitter.Transparency = NumberSequence.new(0, 1)
		particleEmitter.LightEmission = 1
		particleEmitter.Enabled = false
		particleEmitter.Parent = attachment3
		maid:Add((humanoid.Running:Connect(function(p: number)
			if particleEmitter and particleEmitter.Parent then
				particleEmitter.Enabled = p > 1
			end
		end)))
	end
end

local function onCharacterAdded(object, character)
	object:Cleanup()
	local v2 = Janitor.new()
	local equippedTrailChangedConnection = character:GetAttributeChangedSignal("EquippedTrail"):Connect(function()
		createTrail(character, character:GetAttribute("EquippedTrail"), v2)
	end)
	local equippedTrail = character:GetAttribute("EquippedTrail")

	if equippedTrail then
		createTrail(character, equippedTrail, v2)
	else
		task.delay(1.5, function()
			if not character.Parent then
				return
			end

			local equippedTrail2 = character:GetAttribute("EquippedTrail")

			if equippedTrail2 then
				createTrail(character, equippedTrail2, v2)
			end
		end)
	end

	object:Add(equippedTrailChangedConnection)
	object:Add(v2, "Cleanup")
end

local function watchPlayer(player)
	local v2 = Janitor.new()
	local v3 = Janitor.new()
	local characterAddedConnection = player.CharacterAdded:Connect(function(character)
		onCharacterAdded(v3, character)
	end)

	if player.Character then
		onCharacterAdded(v3, player.Character)
	end

	v[player] = v2
	v2:Add(characterAddedConnection)
	v2:Add(v3, "Cleanup")
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player]

	if v2 then
		v2:Cleanup()
		v[player] = nil
	end
end)

for _, v2 in ipairs(Players:GetPlayers()) do
	watchPlayer(v2)
end