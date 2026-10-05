local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local QuickZone = require(ReplicatedStorage.Utilities.QuickZone)
local v = { "Door1", "Door2", "Door3" }
local v2 = {}
local localPlayer = nil
local playerGui = nil
local v3 = nil
local v4 = nil

local function isLocalPlayerAlive()
	local character = localPlayer and localPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			return true
		end
	end

	return false
end

local function considerVisual(list, instance)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		table.insert(list, {
			instance = instance,
			transparency = instance.Transparency
		})
	elseif instance:IsA("LayerCollector") then
		table.insert(list, {
			instance = instance,
			enabled = instance.Enabled
		})
	elseif instance:IsA("GuiObject") then
		table.insert(list, {
			instance = instance,
			visible = instance.Visible
		})
	end
end

local function captureVisuals(folder)
	local v5 = {}
	considerVisual(v5, folder)

	for _, descendant in folder:GetDescendants() do
		considerVisual(v5, descendant)
	end

	return v5
end

local function setVisualsHidden(items, flag: boolean, value: number?)
	local v5 = value or 0

	for _, item in items do
		local instance = item.instance

		if item.transparency == nil then
			if item.enabled == nil then
				if item.visible ~= nil then
					instance.Visible = not flag
				end
			else
				instance.Enabled = not flag
			end
		else
			instance.Transparency = flag and 1 or v5
		end
	end
end

local function captureTsunamiParts(folder)
	local result = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(result, {
				part = part,
				transparency = part.Transparency,
				canTouch = part.CanTouch,
				canQuery = part.CanQuery
			})
		end
	end

	return result
end

local function isLocalCharacterPart(instance)
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	return character ~= nil and instance:IsDescendantOf(character)
end

local function killLocalPlayer()
	local character = localPlayer and localPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end
end

local function bindTsunamiKills(p)
	p.tsunamiKillJanitor:Cleanup()

	for _, tsunamiPart in p.tsunamiParts do
		p.tsunamiKillJanitor:Add(tsunamiPart.part.Touched:Connect(function(otherPart)
			local character

			if localPlayer then
				character = localPlayer.Character
			end

			local character2 = character ~= nil and otherPart:IsDescendantOf(character) and localPlayer and localPlayer.Character

			if character2 then
				local humanoid = character2:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
				end
			end
		end))
	end
end

local function activateTsunamiBody(p)
	for _, tsunamiPart in p.tsunamiParts do
		tsunamiPart.part.Transparency = 0
		tsunamiPart.part.CanTouch = true
		tsunamiPart.part.CanQuery = true
	end

	bindTsunamiKills(p)
	local tsunamiSound = p.tsunamiSound

	if tsunamiSound then
		tsunamiSound:Play()
	end
end

local function restoreTsunamiBody(data)
	data.tsunamiKillJanitor:Cleanup()

	for _, tsunamiPart in data.tsunamiParts do
		tsunamiPart.part.Transparency = tsunamiPart.transparency
		tsunamiPart.part.CanTouch = tsunamiPart.canTouch
		tsunamiPart.part.CanQuery = tsunamiPart.canQuery
	end

	local tsunamiSound = data.tsunamiSound

	if tsunamiSound then
		tsunamiSound:Stop()
	end
end

local function restoreVisuals(items)
	for _, item in items do
		local instance = item.instance

		if item.transparency == nil then
			if item.enabled == nil then
				if item.visible ~= nil then
					instance.Visible = item.visible
				end
			else
				instance.Enabled = item.enabled
			end
		else
			instance.Transparency = item.transparency
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCountdown(p)
	local countdownGui = p.countdownGui

	if countdownGui then
		countdownGui:Destroy()
	end

	p.countdownGui = nil
	p.countdownLabel = nil
end

local function showCountdown(p)
	destroyCountdown(p) -- equivalent call inferred; original call site unknown

	if playerGui then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "Stage13TrapCountdownGui"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.36)
		textLabel.Size = UDim2.fromScale(0.7, 0.16)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.Text = string.format("Tsunami incoming in %.1fs", 2)
		textLabel.TextColor3 = Color3.fromRGB(255, 170, 35)
		textLabel.TextScaled = true
		textLabel.Parent = screenGui
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.new(0, 0, 0)
		uIStroke.Thickness = 4
		uIStroke.Parent = textLabel
		screenGui.Parent = playerGui
		p.countdownGui = screenGui
		p.countdownLabel = textLabel
	end
end

local function setModelSoundsPlaying(folder, flag: boolean)
	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		if flag then
			sound:Play()
		else
			sound:Stop()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blinkDoorArrows(door, p: number)
	local v5 = math.floor(p / 0.15) % 2 == 0
	setVisualsHidden(door.leftVisuals, not v5, 0.5)
	setVisualsHidden(door.rightVisuals, v5, 0.5)
end

local function applyDoorChoice(state)
	local chosenSide = math.random(1, 2) == 1 and "Left" or "Right"
	state.chosenSide = chosenSide

	if chosenSide == "Left" then
		setVisualsHidden(state.leftVisuals, false)
		setVisualsHidden(state.rightVisuals, true)
	else
		setVisualsHidden(state.rightVisuals, false)
		setVisualsHidden(state.leftVisuals, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLavaRise(p, now: number)
	p.lavaRaised = true
	p.lavaRiseStart = now

	for _, sound in p.lava:GetDescendants() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginTsunami(state, now: number)
	state.tsunamiPhase = "Countdown"
	state.countdownEndsAt = now + 2
	state.tsunamiStartsAt = state.countdownEndsAt
	state.tsunamiDebounceEndsAt = now + 5
	activateTsunamiBody(state)
	showCountdown(state)
end

local function observePart(p, callback)
	local zone = QuickZone.Zone.fromPart(p)
	local observer = QuickZone.Observer.new({
		groups = { v3 },
		zones = { zone }
	})
	observer:onLocalPlayerEnter(callback)
	return zone, observer
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetTsunami(state)
	destroyCountdown(state) -- equivalent call inferred; original call site unknown
	state.tsunamiPhase = "Idle"
	state.countdownEndsAt = 0
	state.tsunamiStartsAt = 0
	restoreTsunamiBody(state)
	state.bigTsunami:PivotTo(state.spawnCFrame)
end

local function resetDoors(state)
	state.lavaRiseStart = 0
	state.lavaRaised = false
	state.lava:PivotTo(state.lavaHome)

	for _, sound in state.lava:GetDescendants() do
		if sound:IsA("Sound") then
			sound:Stop()
		end
	end

	for _, door in state.doors do
		door.chosenSide = nil
		door.debounceEndsAt = 0
		restoreVisuals(door.leftVisuals)
		restoreVisuals(door.rightVisuals)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetTrap(state)
	state.tsunamiDebounceEndsAt = 0
	resetTsunami(state) -- equivalent call inferred; original call site unknown
	resetDoors(state)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryBeginTsunami(state)
	local now = os.clock()
	local character = localPlayer and localPlayer.Character
	local v5

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		v5 = humanoid and humanoid.Health > 0 and true or false
	else
		v5 = false
	end

	if v5 and state.tsunamiDebounceEndsAt <= now then
		resetTsunami(state) -- equivalent call inferred; original call site unknown
		beginTsunami(state, now) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryChooseDoor(_, p)
	local now = os.clock()
	local character = localPlayer and localPlayer.Character
	local v5

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		v5 = humanoid and humanoid.Health > 0 and true or false
	else
		v5 = false
	end

	if v5 and p.debounceEndsAt <= now then
		applyDoorChoice(p)
		p.debounceEndsAt = now + 5
	end
end

local function updateTsunamiMotion(state, now: number)
	if state.tsunamiPhase == "Countdown" then
		local v5 = state.countdownEndsAt - now

		if v5 > 0 then
			local countdownLabel = state.countdownLabel

			if countdownLabel then
				countdownLabel.Text = string.format("Tsunami incoming in %.1fs", v5)
			end
		else
			destroyCountdown(state) -- equivalent call inferred; original call site unknown
			state.tsunamiPhase = "Moving"
		end
	elseif state.tsunamiPhase == "Moving" then
		local v5 = math.clamp((now - state.tsunamiStartsAt) / state.travelTime, 0, 1)
		state.bigTsunami:PivotTo(state.spawnCFrame:Lerp(state.endCFrame, v5))

		if v5 >= 1 then
			resetTsunami(state) -- equivalent call inferred; original call site unknown
		end
	end
end

local function updateLavaMotion(state, now: number)
	if state.lavaRaised then
		local v5 = now - state.lavaRiseStart

		if v5 < 0.5 then
			state.lava:PivotTo(state.lavaHome)
		elseif v5 >= 5.5 then
			state.lavaRaised = false
			state.lavaRiseStart = 0
			state.lava:PivotTo(state.lavaHome)

			for _, sound in state.lava:GetDescendants() do
				if sound:IsA("Sound") then
					sound:Stop()
				end
			end
		else
			local v6 = math.clamp((v5 - 0.5) / 0.35, 0, 1)
			state.lava:PivotTo(state.lavaHome:Lerp(state.lavaRaisedPivot, v6))
		end
	end
end

local function updateDoorArrows(p, now: number)
	for _, door in p.doors do
		if not (door.chosenSide == nil or door.debounceEndsAt <= now) then
			continue
		end

		door.chosenSide = nil
		blinkDoorArrows(door, now) -- equivalent call inferred; original call site unknown
	end
end

local function applyTrapSetup(model)
	local tsunami = model.Tsunami
	local tsunamiSpawn = tsunami.TsunamiSpawn
	local tsunamiEnd = tsunami.TsunamiEnd
	local speed = tsunami:GetAttribute("Speed") or 70
	local magnitude = (tsunamiEnd.Position - tsunamiSpawn.Position).Magnitude
	local bigTsunami = tsunami.BigTsunami
	local primaryPart = bigTsunami.PrimaryPart
	local rotation = primaryPart.CFrame.Rotation
	local spawnCFrame = CFrame.new(tsunamiSpawn.Position) * rotation
	local endCFrame = CFrame.new(tsunamiEnd.Position) * rotation
	local sound = primaryPart:FindFirstChildOfClass("Sound")
	local lava = model.Lava
	local pivot = lava:GetPivot()
	local doors = {}
	local v8 = {}
	local tsunamiKillJanitor = Janitor.new()
	bigTsunami:PivotTo(spawnCFrame)
	local v10 = {
		model = model,
		janitor = nil,
		bigTsunami = bigTsunami,
		spawnCFrame = spawnCFrame,
		endCFrame = endCFrame,
		travelTime = math.max(magnitude / speed, 0.01),
		tsunamiParts = captureTsunamiParts(bigTsunami),
		tsunamiSound = sound,
		tsunamiKillJanitor = tsunamiKillJanitor,
		lava = lava,
		lavaHome = pivot,
		lavaRaisedPivot = pivot + createVector(0, 30, 0),
		doors = doors,
		tsunamiPhase = "Idle",
		countdownEndsAt = 0,
		tsunamiStartsAt = 0,
		tsunamiDebounceEndsAt = 0,
		lavaRiseStart = 0,
		lavaRaised = false,
		countdownGui = nil,
		countdownLabel = nil
	}
	v2[model] = v10

	local function addObservedPart(p, callback)
		local v11, v12 = observePart(p, callback)
		table.insert(v8, v11)
		table.insert(v8, v12)
	end

	local v11, v12 = observePart(model.EntryZone, function()
		tryBeginTsunami(v10) -- equivalent call inferred; original call site unknown
	end)
	table.insert(v8, v11)
	table.insert(v8, v12)

	for _, v13 in v do
		local v14 = model[v13]
		local v15 = {
			leftVisuals = captureVisuals(v14.LeftArrow),
			rightVisuals = captureVisuals(v14.RightArrow),
			chosenSide = nil,
			debounceEndsAt = 0
		}
		table.insert(doors, v15)
		local v17, v18 = observePart(v14.DetectZone, function()
			tryChooseDoor(nil, v15) -- equivalent call inferred; original call site unknown
		end)
		table.insert(v8, v17)
		table.insert(v8, v18)
		local v19 = v15
		local v20, v21 = observePart(v14.TransparentWallLeft, function()
			local character = localPlayer and localPlayer.Character
			local v22

			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				v22 = humanoid and humanoid.Health > 0 and true or false
			else
				v22 = false
			end

			if v22 and v19.chosenSide == "Right" and not v10.lavaRaised then
				startLavaRise(v10, os.clock()) -- equivalent call inferred; original call site unknown
			end
		end)
		table.insert(v8, v20)
		table.insert(v8, v21)
		local v22 = v15
		local v23, v24 = observePart(v14.TransparentWallRight, function()
			local character = localPlayer and localPlayer.Character
			local v25

			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				v25 = humanoid and humanoid.Health > 0 and true or false
			else
				v25 = false
			end

			if v25 and v22.chosenSide == "Left" and not v10.lavaRaised then
				startLavaRise(v10, os.clock()) -- equivalent call inferred; original call site unknown
			end
		end)
		table.insert(v8, v23)
		table.insert(v8, v24)
	end

	local janitor = Janitor.new()

	for _, v14 in v8 do
		janitor:Add(v14, "destroy")
	end

	janitor:Add(tsunamiKillJanitor, "Destroy")
	v10.janitor = janitor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupTrap(model)
	if model:IsA("Model") and v2[model] == nil then
		applyTrapSetup(model)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownTrap(k)
	local v5 = v2[k]

	if v5 then
		destroyCountdown(v5) -- equivalent call inferred; original call site unknown
		v5.janitor:Destroy()
		v2[k] = nil
	end
end

local function resetActiveTraps()
	for _, v5 in v2 do
		resetTrap(v5) -- equivalent call inferred; original call site unknown
	end
end

local function renderTraps()
	local now = os.clock()

	for k, v5 in v2 do
		if k.Parent then
			updateTsunamiMotion(v5, now)
			updateLavaMotion(v5, now)
			updateDoorArrows(v5, now)
		else
			teardownTrap(k) -- equivalent call inferred; original call site unknown
		end
	end
end

local function startClient()
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
	v3 = QuickZone.Group.localPlayer()

	for _, v5 in CollectionService:GetTagged("Stage13Trap") do
		setupTrap(v5) -- equivalent call inferred; original call site unknown
	end

	local connection = CollectionService:GetInstanceAddedSignal("Stage13Trap"):Connect(setupTrap)
	local connection2 = CollectionService:GetInstanceRemovedSignal("Stage13Trap"):Connect(teardownTrap)
	local characterAddedConnection = localPlayer.CharacterAdded:Connect(resetActiveTraps)
	v4 = Janitor.new()
	v4:Add(connection)
	v4:Add(connection2)
	v4:Add(characterAddedConnection)
	v4:Add(v3, "destroy")
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClient()
		end
	end,
	OnRender = function()
		if RunService:IsClient() then
			renderTraps()
		end
	end
})
return {}