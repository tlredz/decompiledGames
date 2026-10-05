local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)

if PlaceRegistry.getSpecialPlaceKey() ~= nil then
	return
end

local _ = Players.LocalPlayer
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local DiscoPartyConfig = require(ReplicatedStorage.AdminAbuse.Modules.DiscoParty.DiscoPartyConfig)
local specialKeyEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpecialKeyEvent")
local v = 0
local v2 = 0
local keycapRainConfig = DiscoPartyConfig.KeycapRainConfig
local hueJumpMinSec = keycapRainConfig.HueJumpMinSec or 0.12
local hueJumpMaxSec = keycapRainConfig.HueJumpMaxSec or 0.35
local folder = Instance.new("Folder")
folder.Name = "DiscoKeyVisualsLocal"
folder.Parent = workspace
local v3 = {}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyDiscoVisual(value: string?)
	if type(value) ~= "string" then
		return
	end

	local v5 = v3[value]

	if v5 then
		v4[v5] = nil
		v3[value] = nil
		v5:Destroy()
	end
end

local function mountDiscoVisual(part)
	local discoKeyId = part:GetAttribute("DiscoKeyId")

	if type(discoKeyId) ~= "string" or v3[discoKeyId] then
		return
	end

	local clone = part:Clone()

	for _, surfaceAppearance in ipairs(clone:GetDescendants()) do
		if surfaceAppearance:IsA("SurfaceAppearance") then
			surfaceAppearance:Destroy()
		end
	end

	clone.Name = "DiscoKeyVisual"
	clone.Transparency = 0
	clone.Material = Enum.Material.Neon
	clone.Color = Color3.fromHSV(math.random(), 1, 1)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.Parent = folder
	v3[discoKeyId] = clone
	v4[clone] = 0
	part.Destroying:Connect(function()
		destroyDiscoVisual(discoKeyId) -- equivalent call inferred; original call site unknown
	end)
end

local function updateDiscoKeyColors()
	local now = os.clock()

	for k in pairs(v4) do
		if k.Parent then
			local v5 = v4[k]

			if not v5 or v5 <= now then
				k.Color = Color3.fromHSV(math.random(), 1, 1)
				v4[k] = now + hueJumpMinSec + math.random() * (hueJumpMaxSec - hueJumpMinSec)
			end
		else
			v4[k] = nil
		end
	end
end

RunService.Heartbeat:Connect(updateDiscoKeyColors)
task.spawn(function()
	local specialKeys = workspace:WaitForChild("SpecialKeys", 30)

	if not specialKeys then
		return
	end

	for _, part in ipairs(specialKeys:GetChildren()) do
		if part:IsA("MeshPart") and part:GetAttribute("IsDiscoKey") then
			mountDiscoVisual(part)
		end
	end

	specialKeys.ChildAdded:Connect(function(part)
		if part:IsA("MeshPart") and part:GetAttribute("IsDiscoKey") then
			task.defer(mountDiscoVisual, part)
		end
	end)
end)
local ligtning = ReplicatedStorage:FindFirstChild("Ligtning")

local function createLightningHit(position)
	if not ligtning then
		return
	end

	local hitParticles = ligtning:FindFirstChild("HitParticles")

	if hitParticles then
		local clone = hitParticles:Clone()
		clone.Position = position
		clone.Parent = workspace
		Debris:AddItem(clone, 3)
		task.delay(0.3, function()
			if clone and clone.Parent then
				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end
		end)
	end

	local lightningSound = ligtning:FindFirstChild("LightningSound")

	if lightningSound then
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.Position = position
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.Parent = workspace.Terrain
		local clone = lightningSound:Clone()
		clone.Volume = 0.5
		clone.RollOffMode = Enum.RollOffMode.Linear
		clone.RollOffMinDistance = 10
		clone.RollOffMaxDistance = 200
		clone.Parent = part
		clone:Play()
		Debris:AddItem(part, 5)
	end
end

local function playDiscoSpawnSound(position: Vector3)
	local spawnSoundId = keycapRainConfig.SpawnSoundId

	if type(spawnSoundId) ~= "string" or spawnSoundId == "" then
		return
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Parent = folder
	local sound = Instance.new("Sound")
	sound.SoundId = spawnSoundId
	sound.Volume = keycapRainConfig.SpawnSoundVolume or 1.2
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = keycapRainConfig.SpawnSoundRollOffMin or 20
	sound.RollOffMaxDistance = keycapRainConfig.SpawnSoundRollOffMax or 250
	sound.Parent = part
	sound:Play()
	Debris:AddItem(part, 3)
end

local function createDiscoPop(position)
	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = folder
	local color = Color3.fromHSV(math.random(), 1, 1)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.25, 0.45)
	particleEmitter.Speed = NumberRange.new(8, 18)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.Rate = 0
	particleEmitter.LightEmission = 1
	particleEmitter.Parent = part
	particleEmitter:Emit(18)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 7
	pointLight.Range = 22
	pointLight.Parent = part
	TweenService:Create(pointLight, TweenInfo.new(0.35), {
		Brightness = 0,
		Range = 0
	}):Play()
	playDiscoSpawnSound(position)
	Debris:AddItem(part, 1)
end

local function createCollectEffect(position, isSecret)
	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = workspace.Terrain
	local particleEmitter = Instance.new("ParticleEmitter")

	if isSecret then
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
	else
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 0))
		})
	end

	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.8, 1.5)
	particleEmitter.Speed = NumberRange.new(10, 25)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.Rate = 0
	particleEmitter.LightEmission = isSecret and 0 or 1
	particleEmitter.Parent = part
	particleEmitter:Emit(30)
	local pointLight = Instance.new("PointLight")
	local color

	if isSecret then
		color = Color3.fromRGB(50, 50, 50)
	else
		color = Color3.fromRGB(255, 255, 100)
	end

	pointLight.Color = color
	pointLight.Brightness = isSecret and 2 or 6
	pointLight.Range = isSecret and 20 or 30
	pointLight.Parent = part
	task.delay(0.2, function()
		TweenService:Create(pointLight, TweenInfo.new(0.5), {
			Brightness = 0,
			Range = 0
		}):Play()
	end)
	Debris:AddItem(part, 2)
end

specialKeyEvent.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local action = data.action
	local position = data.position

	if position and typeof(position) ~= "Vector3" then
		return
	end

	local now = tick()

	if action == "spawn" then
		if data.isDisco and type(data.discoId) == "string" then
			local specialKeys = workspace:FindFirstChild("SpecialKeys")

			if specialKeys then
				for _, part in ipairs(specialKeys:GetChildren()) do
					if not (part:IsA("MeshPart") and part:GetAttribute("DiscoKeyId") == data.discoId) then
						continue
					end

					mountDiscoVisual(part)
					break
				end
			end

			if position then
				createDiscoPop(position)
			end
		elseif position and now - v >= 0.5 then
			v = now
			createLightningHit(position)
		end
	elseif action == "collect" then
		if data.isDisco then
			local discoId = data.discoId
			local v5 = type(discoId) == "string" and v3[discoId]

			if v5 then
				v4[v5] = nil
				v3[discoId] = nil
				v5:Destroy()
			end
		end

		if position and now - v2 >= 0.3 then
			v2 = now
			createCollectEffect(position, data.isSecret)
		end
	elseif action == "notification" and data.text and data.color then
		local color = data.color
		NotificationSystem:ShowGeneralNotification(
			data.text,
			Color3.fromRGB(color[1], color[2], color[3]),
			data.duration
		)
		SoundManager:Play("SPECIAL_KEY_NOTIF")
	elseif action == "despawn" and data.isDisco then
		destroyDiscoVisual(data.discoId) -- equivalent call inferred; original call site unknown
	end
end)