local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local SummerCoinsRemotes = require(ReplicatedStorage.EventRemotes.SummerCoinsRemotes)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local AutoOpenModalSystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("AutoOpenModalSystem"))
local AutoOpenModalConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("AutoOpenModalConfig"))
local InfoModalUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("InfoModalUISystem"))
local LightningStrike = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("LightningStrike"))
local summerCoins = EventsConfig.SummerCoins
local summerCoinSpawn = SummerCoinsRemotes.SummerCoinSpawn
local summerCoinDespawn = SummerCoinsRemotes.SummerCoinDespawn
local summerCoinCollected = SummerCoinsRemotes.SummerCoinCollected
local summerCoinCollect = SummerCoinsRemotes.SummerCoinCollect
local summerCoinStormAnnounce = SummerCoinsRemotes.SummerCoinStormAnnounce
local localPlayer = Players.LocalPlayer
local model = Instance.new("Model")
model.Name = "SummerCoinsLocal"
model.Parent = workspace
local coinHighlight = summerCoins.CoinHighlight

if coinHighlight then
	local highlight = Instance.new("Highlight")
	local fillColor = coinHighlight.FillColor or { 255, 225, 120 }
	local outlineColor = coinHighlight.OutlineColor or { 255, 190, 40 }
	highlight.Name = "SummerCoinsHighlight"
	highlight.FillColor = Color3.fromRGB(fillColor[1], fillColor[2], fillColor[3])
	highlight.OutlineColor = Color3.fromRGB(outlineColor[1], outlineColor[2], outlineColor[3])
	highlight.FillTransparency = coinHighlight.FillTransparency or 0.6
	highlight.OutlineTransparency = coinHighlight.OutlineTransparency or 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = model
	highlight.Parent = model
end

local v = {}
local cframe = CFrame.Angles(1.5707963267948966, 0, 0)

local function getTemplate()
	local assets = ReplicatedStorage:WaitForChild("Assets")
	local events = assets and assets:WaitForChild("Events")
	local model2 = events and events:WaitForChild(summerCoins.CoinTemplateName)

	if model2 and model2:IsA("Model") then
		return model2
	end

	return nil
end

local function applyVisuals(clone)
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		return
	end

	local coinLight = summerCoins.CoinLight

	if coinLight then
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = coinLight.Brightness or 2
		pointLight.Range = coinLight.Range or 16
		local color = coinLight.Color or { 255, 210, 60 }
		pointLight.Color = Color3.fromRGB(color[1], color[2], color[3])
		pointLight.Parent = primaryPart
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function animateCoin(clone, cframe2: CFrame, maid)
	local total = 0
	maid:Add((RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v2 = math.sin(total * 2) * 0.6
		clone:PivotTo(cframe2 * CFrame.new(0, v2, 0) * CFrame.Angles(0, total * 1.4, 0) * cframe)
	end)))
end

local function playWorldSound(soundId: string?, position: Vector3?, volume: number, rollOffMinDistance: number, rollOffMaxDistance: number)
	if not soundId then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = rollOffMinDistance
	sound.RollOffMaxDistance = rollOffMaxDistance

	if position then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(position)
		part.Parent = model
		sound.Parent = part
		sound:Play()
		Debris:AddItem(part, 3)
	else
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSpawnSound(position: Vector3)
	playWorldSound(
		summerCoins.SpawnSoundId,
		position,
		summerCoins.SpawnSoundVolume or 1.5,
		summerCoins.SpawnSoundRollOffMin or 40,
		summerCoins.SpawnSoundRollOffMax or 900
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playCollectSound(position: Vector3?)
	playWorldSound(
		summerCoins.CollectSoundId,
		position,
		summerCoins.CollectSoundVolume or 0.85,
		summerCoins.CollectSoundRollOffMin or 12,
		summerCoins.CollectSoundRollOffMax or 220
	)
end

local function isLocalCharacterPart(instance)
	local character = localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCoin(value: string, flag: boolean)
	local v2 = v[value]

	if not v2 then
		return
	end

	v[value] = nil
	v2.janitor:Cleanup()

	if not v2.model then
		return
	end

	if not flag then
		v2.model:Destroy()
		return
	end

	playCollectSound(v2.model:GetPivot().Position) -- equivalent call inferred; original call site unknown

	for _, descendant in v2.model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanTouch = false
			descendant.Transparency = 1
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = false
		end
	end

	task.delay(0.15, function()
		if v2.model.Parent then
			v2.model:Destroy()
		end
	end)
end

local function onTouched(id: string, part)
	local v2 = v[id]

	if not v2 or v2.pendingCollect then
		return
	end

	if part:IsA("BasePart") then
		local character = localPlayer.Character
		local v3

		if character == nil then
			v3 = false
		else
			v3 = part:IsDescendantOf(character)
		end

		if v3 then
			v2.pendingCollect = true
			summerCoinCollect:fire(id)
			task.delay(0.25, function()
				local v4 = v[id]

				if v4 and v4.pendingCollect and v4.model.Parent then
					v4.pendingCollect = false
				end
			end)
		end
	end
end

local function mountCoin(data)
	if v[data.id] then
		return
	end

	local assets = ReplicatedStorage:WaitForChild("Assets")
	local events = assets and assets:WaitForChild("Events")
	local model2 = events and events:WaitForChild(summerCoins.CoinTemplateName)

	if not (model2 and model2:IsA("Model")) then
		model2 = nil
	end

	if not model2 then
		warn("[SummerCoinsClient] Template introuvable : ReplicatedStorage.Assets.Events." .. summerCoins.CoinTemplateName)
		return
	end

	local clone = model2:Clone()
	clone.Name = "SummerCoin"
	clone:SetAttribute("CoinId", data.id)
	local primaryPart = clone.PrimaryPart

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false

		if not primaryPart then
			primaryPart = part
		end
	end

	if primaryPart then
		primaryPart.CanTouch = true

		if not clone.PrimaryPart then
			clone.PrimaryPart = primaryPart
		end
	end

	local cframe2 = CFrame.new(data.position)
	clone:PivotTo(cframe2 * cframe)
	applyVisuals(clone)
	clone.Parent = model
	playSpawnSound(data.position) -- equivalent call inferred; original call site unknown
	local maid = Janitor.new()
	v[data.id] = {
		model = clone,
		pendingCollect = false,
		janitor = maid
	}

	if primaryPart then
		maid:Add(primaryPart.Touched:Connect(function(otherPart)
			onTouched(data.id, otherPart)
		end))
	end

	animateCoin(clone, cframe2, maid) -- equivalent call inferred; original call site unknown
end

local function spawnLocalCoin(data)
	if type(data) ~= "table" or type(data.id) ~= "string" or typeof(data.position) ~= "Vector3" then
		warn("[SummerCoinsClient] spawn payload invalide:", data)
		return
	end

	if v[data.id] then
		return
	end

	if not data.lightning then
		mountCoin(data)
		return
	end

	v[data.id] = {
		model = nil,
		pendingCollect = true,
		janitor = Janitor.new(),
		pendingLightning = true
	}
	LightningStrike.strike(data.position, {
		onImpact = function()
			local v2 = v[data.id]

			if v2 and v2.pendingLightning then
				v2.janitor:Cleanup()
				v[data.id] = nil
				mountCoin(data)
			end
		end
	})
end

summerCoinSpawn:connect(spawnLocalCoin)
summerCoinDespawn:connect(function(value)
	if type(value) == "string" then
		destroyCoin(value, false) -- equivalent call inferred; original call site unknown
	end
end)
summerCoinCollected:connect(function(value, _)
	if type(value) ~= "string" then
		return
	end

	destroyCoin(value, true)
	local summerCoinFound = AutoOpenModalConfig.Ids.SummerCoinFound

	if not AutoOpenModalSystem.IsSeen(summerCoinFound) then
		AutoOpenModalSystem.MarkSeen(summerCoinFound)
		local firstCollect = summerCoins.InfoModal.FirstCollect
		InfoModalUISystem:Open(firstCollect.Title, firstCollect.Description)
	end
end)
summerCoinStormAnnounce:connect(function(p)
	if type(p) ~= "table" or type(p.text) ~= "string" then
		return
	end

	local color = p.color or { 255, 200, 60 }
	NotificationSystem:ShowMessage(p.text, Color3.fromRGB(color[1], color[2], color[3]))
end)