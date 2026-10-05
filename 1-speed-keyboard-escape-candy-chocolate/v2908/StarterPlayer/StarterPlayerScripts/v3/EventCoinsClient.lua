local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local EventCoinsRemotes = require(ReplicatedStorage.EventRemotes.EventCoinsRemotes)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local AutoOpenModalSystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("AutoOpenModalSystem"))
local InfoModalUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("InfoModalUISystem"))
local LightningStrike = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("LightningStrike"))
local eventCoins = EventsConfig.EventCoins
local eventCoinSpawn = EventCoinsRemotes.EventCoinSpawn
local eventCoinDespawn = EventCoinsRemotes.EventCoinDespawn
local eventCoinCollected = EventCoinsRemotes.EventCoinCollected
local eventCoinCollect = EventCoinsRemotes.EventCoinCollect
local eventCoinStormAnnounce = EventCoinsRemotes.EventCoinStormAnnounce
local localPlayer = Players.LocalPlayer
local model = Instance.new("Model")
model.Name = "EventCoinsLocal"
model.Parent = workspace
local highlight = Instance.new("Highlight")
highlight.Name = "EventCoinsHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Enabled = false
highlight.Adornee = model
highlight.Parent = model
local v = nil

local function applyGroupHighlight(event: string, p)
	if v == event then
		return
	end

	v = event
	local coinHighlight = p.CoinHighlight

	if coinHighlight then
		local fillColor = coinHighlight.FillColor or { 255, 225, 120 }
		local outlineColor = coinHighlight.OutlineColor or { 255, 190, 40 }
		highlight.FillColor = Color3.fromRGB(fillColor[1], fillColor[2], fillColor[3])
		highlight.OutlineColor = Color3.fromRGB(outlineColor[1], outlineColor[2], outlineColor[3])
		highlight.FillTransparency = coinHighlight.FillTransparency or 0.6
		highlight.OutlineTransparency = coinHighlight.OutlineTransparency or 0
	end

	highlight.Enabled = coinHighlight ~= nil
end

local v2 = {}

local function toRotation(list)
	return CFrame.Angles(math.rad(list[1]), math.rad(list[2]), (math.rad(list[3])))
end

local function getTemplate(p)
	local events = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events")
	local model2 = events:FindFirstChild(p.CoinTemplateName)

	if model2 and model2:IsA("Model") then
		return model2, toRotation(p.CoinRotation)
	end

	local model3 = events:FindFirstChild(eventCoins.FallbackTemplate.Name)

	if model3 and model3:IsA("Model") then
		return model3, toRotation(eventCoins.FallbackTemplate.Rotation)
	end

	return nil, nil
end

local function applyVisuals(clone, p)
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		return
	end

	local coinLight = p.CoinLight

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
local function animateCoin(clone, cframe: CFrame, cframe2: CFrame, maid)
	local total = 0
	maid:Add((RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v3 = math.sin(total * 2) * 0.6
		clone:PivotTo(cframe * CFrame.new(0, v3, 0) * CFrame.Angles(0, total * 1.4, 0) * cframe2)
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
		eventCoins.SpawnSoundId,
		position,
		eventCoins.SpawnSoundVolume or 1.5,
		eventCoins.SpawnSoundRollOffMin or 40,
		eventCoins.SpawnSoundRollOffMax or 900
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playCollectSound(position: Vector3?)
	playWorldSound(
		eventCoins.CollectSoundId,
		position,
		eventCoins.CollectSoundVolume or 0.85,
		eventCoins.CollectSoundRollOffMin or 12,
		eventCoins.CollectSoundRollOffMax or 220
	)
end

local function isLocalCharacterPart(instance)
	local character = localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCoin(value: string, flag: boolean)
	local v3 = v2[value]

	if not v3 then
		return
	end

	v2[value] = nil
	v3.janitor:Cleanup()

	if not v3.model then
		return
	end

	if not flag then
		v3.model:Destroy()
		return
	end

	playCollectSound(v3.model:GetPivot().Position) -- equivalent call inferred; original call site unknown

	for _, descendant in v3.model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanTouch = false
			descendant.Transparency = 1
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = false
		end
	end

	task.delay(0.15, function()
		if v3.model.Parent then
			v3.model:Destroy()
		end
	end)
end

local function onTouched(id: string, part)
	local v3 = v2[id]

	if not v3 or v3.pendingCollect then
		return
	end

	if part:IsA("BasePart") then
		local character = localPlayer.Character
		local v4

		if character == nil then
			v4 = false
		else
			v4 = part:IsDescendantOf(character)
		end

		if v4 then
			v3.pendingCollect = true
			eventCoinCollect:fire(id)
			task.delay(0.25, function()
				local v5 = v2[id]

				if v5 and v5.pendingCollect and v5.model.Parent then
					v5.pendingCollect = false
				end
			end)
		end
	end
end

local function mountCoin(data, entry)
	if v2[data.id] then
		return
	end

	local template, v3 = getTemplate(entry)

	if not template then
		warn("[EventCoinsClient] Template introuvable : ReplicatedStorage.Assets.Events." .. entry.CoinTemplateName .. " (fallback " .. eventCoins.FallbackTemplate.Name .. ")")
		return
	end

	local clone = template:Clone()
	clone.Name = "EventCoin"
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

	local cframe = data.cframe
	clone:PivotTo(cframe * v3)
	applyVisuals(clone, entry)
	applyGroupHighlight(data.event, entry)
	clone.Parent = model
	playSpawnSound(cframe.Position) -- equivalent call inferred; original call site unknown
	local maid = Janitor.new()
	v2[data.id] = {
		model = clone,
		entry = entry,
		pendingCollect = false,
		janitor = maid
	}

	if primaryPart then
		maid:Add(primaryPart.Touched:Connect(function(otherPart)
			onTouched(data.id, otherPart)
		end))
	end

	animateCoin(clone, cframe, v3, maid) -- equivalent call inferred; original call site unknown
end

local function spawnLocalCoin(data)
	if type(data) ~= "table" or type(data.id) ~= "string" or typeof(data.cframe) ~= "CFrame" then
		warn("[EventCoinsClient] spawn payload invalide:", data)
		return
	end

	local v3

	if type(data.event) == "string" then
		v3 = eventCoins.Events[data.event]
	else
		v3 = false
	end

	if not v3 then
		warn("[EventCoinsClient] no EventCoins entry for event:", data.event)
		return
	end

	if v2[data.id] then
		return
	end

	if not data.lightning then
		mountCoin(data, v3)
		return
	end

	v2[data.id] = {
		model = nil,
		pendingCollect = true,
		janitor = Janitor.new(),
		pendingLightning = true
	}
	LightningStrike.strike(data.cframe.Position, {
		onImpact = function()
			local v4 = v2[data.id]

			if v4 and v4.pendingLightning then
				v4.janitor:Cleanup()
				v2[data.id] = nil
				mountCoin(data, v3)
			end
		end
	})
end

eventCoinSpawn:connect(spawnLocalCoin)
eventCoinDespawn:connect(function(value)
	if type(value) == "string" then
		destroyCoin(value, false) -- equivalent call inferred; original call site unknown
	end
end)
eventCoinCollected:connect(function(value, _)
	if type(value) ~= "string" then
		return
	end

	local v3 = v2[value]
	local entry = v3 and v3.entry
	destroyCoin(value, true)

	if entry then
		local firstCollectSeenId = entry.FirstCollectSeenId

		if not AutoOpenModalSystem.IsSeen(firstCollectSeenId) then
			AutoOpenModalSystem.MarkSeen(firstCollectSeenId)
			local firstCollect = entry.InfoModal.FirstCollect
			InfoModalUISystem:Open(firstCollect.Title, firstCollect.Description)
		end
	end
end)
eventCoinStormAnnounce:connect(function(p)
	if type(p) ~= "table" or type(p.text) ~= "string" then
		return
	end

	local color = p.color or { 255, 200, 60 }
	NotificationSystem:ShowMessage(p.text, Color3.fromRGB(color[1], color[2], color[3]))
end)