local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local localPlayer = Players.LocalPlayer
local v = {}

local function setAuraEnabled(folder, enabled)
	for _, folder2 in folder:GetDescendants() do
		if folder2.Name ~= "AuraFX_Att" then
			continue
		end

		for _, emitter in folder2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = enabled
			end
		end
	end
end

local function attachEmitter(upperTorso, auraData)
	local attachment = Instance.new("Attachment")
	attachment.Name = "AuraFX_Att"
	attachment.Position = createVector(0, 0, 0)
	attachment.Parent = upperTorso

	if auraData.instance then
		local clone = auraData.instance:Clone()
		clone.Name = "AuraFX_Emitter"
		clone.Parent = attachment
	else
		local particles = auraData.particles
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "AuraFX_Emitter"
		particleEmitter.Texture = particles.texture
		particleEmitter.Rate = particles.rate
		particleEmitter.Lifetime = particles.lifetime
		particleEmitter.Speed = particles.speed
		particleEmitter.SpreadAngle = particles.spreadAngle
		particleEmitter.Color = particles.color
		particleEmitter.Size = particles.size
		particleEmitter.Transparency = particles.transparency
		particleEmitter.LightEmission = particles.lightEmission
		particleEmitter.LightInfluence = 0
		particleEmitter.LockedToPart = true
		particleEmitter.Enabled = true

		if particles.acceleration then
			particleEmitter.Acceleration = particles.acceleration
		end

		if particles.rotation then
			particleEmitter.Rotation = particles.rotation
		end

		if particles.rotSpeed then
			particleEmitter.RotSpeed = particles.rotSpeed
		end

		particleEmitter.Parent = attachment
	end
end

local function createAura(folder, equippedAura)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name:find("AuraFX") then
			descendant:Destroy()
		end
	end

	if equippedAura == "None" or not equippedAura then
		return
	end

	local auraData = PlayerUpgradesCatalog.GetAuraData(equippedAura)

	if not (auraData and (auraData.instance or auraData.particles)) then
		return
	end

	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart", 5)

	if not humanoidRootPart then
		return
	end

	local upperTorso = folder:FindFirstChild("UpperTorso") or folder:FindFirstChild("Torso") or humanoidRootPart

	if not upperTorso then
		return
	end

	attachEmitter(upperTorso, auraData)

	if localPlayer:GetAttribute("AuraHidden") then
		setAuraEnabled(folder, false)
	end
end

local function onCharacterAdded(object, character)
	object:Cleanup()
	local equippedAuraChangedConnection = character:GetAttributeChangedSignal("EquippedAura"):Connect(function()
		createAura(character, character:GetAttribute("EquippedAura"))
	end)
	local equippedAura = character:GetAttribute("EquippedAura")

	if equippedAura then
		createAura(character, equippedAura)
	else
		task.delay(1.5, function()
			if not character.Parent then
				return
			end

			local equippedAura2 = character:GetAttribute("EquippedAura")

			if equippedAura2 then
				createAura(character, equippedAura2)
			end
		end)
	end

	object:Add(equippedAuraChangedConnection)
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

localPlayer:GetAttributeChangedSignal("AuraHidden"):Connect(function()
	local character = localPlayer.Character

	if not character then
		return
	end

	setAuraEnabled(character, not localPlayer:GetAttribute("AuraHidden"))
end)
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