local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Universe = require(script.Parent.Universe)
local HolidayCollectionCore = require(script.Parent.HolidayCollectionCore)
local HolidayCollectionHunting = {
	GATED_PROMPT_TAG = "CollectableGatedPrompt",
	GATED_PROMPT_ATTRIBUTE = "RequiresCollectable",
	PICKUP_FOLDER = "HolidayPickups"
}
local v = nil
local namesByPiece = {}

function HolidayCollectionHunting.Init(p)
	if type(p) ~= "table" then
		warn("[CollectionHunting] Init expects a collection data table — ignoring")
		return
	end

	if v then
		warn(("[CollectionHunting] a collection is already registered (%s) — ignoring %s"):format(
			tostring(v.HolidayKey),
			(tostring(p.HolidayKey))
		))
		return
	end

	v = p

	for _, collectable in ipairs(v.Collectables) do
		for _, piece in ipairs(collectable.Pieces) do
			if namesByPiece[piece] then
				warn(("[CollectionHunting] piece id %q is claimed by both %s and %s — keeping %s"):format(
					piece,
					namesByPiece[piece],
					collectable.Name,
					namesByPiece[piece]
				))
			else
				namesByPiece[piece] = collectable.Name
			end
		end
	end

	for _, v2 in ipairs(HolidayCollectionCore.validateKeepsakes(v.ProgressKeepsakes, v.MaxCollectionProgress)) do
		warn("[CollectionHunting] " .. v2)
	end

	if RunService:IsServer() then
		task.defer(HolidayCollectionHunting._startSpotWatcher)

		if Universe:IsGame() then
			task.defer(HolidayCollectionHunting.PrepareFloorPieceMesh)
		end
	else
		task.defer(function()
			HolidayCollectionHunting._startPickupClient()

			if Universe:IsLobby() then
				HolidayCollectionHunting._startLobbyClient()
			end
		end)
	end
end

function HolidayCollectionHunting.GetCollection()
	return v
end

function HolidayCollectionHunting.GetPieceOwner(p: string?)
	if v and p then
		return namesByPiece[p]
	end

	return nil
end

function HolidayCollectionHunting.GetCollectableEntry(p: string?)
	if not (v and p) then
		return nil
	end

	for _, collectable in ipairs(v.Collectables) do
		if collectable.Name == p then
			return collectable
		end
	end

	return nil
end

function HolidayCollectionHunting.GetAllPieces()
	local result = {}

	if not v then
		return result
	end

	for _, collectable in ipairs(v.Collectables) do
		for _, piece in ipairs(collectable.Pieces) do
			table.insert(result, {
				collectable = collectable.Name,
				id = piece
			})
		end
	end

	return result
end

function HolidayCollectionHunting.GetTotalPieces()
	local total = 0

	if not v then
		return total
	end

	for _, collectable in ipairs(v.Collectables) do
		total += #collectable.Pieces
	end

	return total
end

function HolidayCollectionHunting.ClampProgress(p)
	if v then
		return (math.clamp(math.floor(tonumber(p) or 0), 0, v.MaxCollectionProgress))
	end

	return 0
end

function HolidayCollectionHunting.IsProgressMaxed(p)
	if v then
		return HolidayCollectionHunting.ClampProgress(p) >= v.MaxCollectionProgress
	end

	return false
end

function HolidayCollectionHunting.IsCollectableComplete(p, p2: string?)
	local collectableEntry = HolidayCollectionHunting.GetCollectableEntry(p2)

	if not (collectableEntry and type(p) == "table") then
		return false
	end

	for _, piece in ipairs(collectableEntry.Pieces) do
		if not p[piece] then
			return false
		end
	end

	return true
end

function HolidayCollectionHunting.IsCollectableUnlocked(p, p2: string?)
	local collectableEntry = HolidayCollectionHunting.GetCollectableEntry(p2)

	if not collectableEntry or type(p) ~= "table" then
		return false
	end

	local v2 = p[v.CollectablesKey]
	local isCollectableComplete = HolidayCollectionHunting.IsCollectableComplete
	local v3

	if type(v2) == "table" then
		v3 = v2[collectableEntry.Name] or nil
	end

	local collectableComplete = isCollectableComplete(v3, collectableEntry.Name)
	return HolidayCollectionCore.isCollectableUnlocked(p, collectableEntry.UnlockedBy, collectableComplete)
end

function HolidayCollectionHunting.HasUnlockedCollectable(p, p2: string?)
	if not v then
		return false
	end

	local seasonal = p and p.Data and p.Data.Seasonal
	return type(seasonal) == "table" and HolidayCollectionHunting.IsCollectableUnlocked(seasonal[v.HolidayKey], p2)
end

function HolidayCollectionHunting.GetDefaultCollectables()
	local result = {}

	if not v then
		return result
	end

	for _, collectable in ipairs(v.Collectables) do
		result[collectable.Name] = {}
	end

	return result
end

function HolidayCollectionHunting:NormalizeCollectables()
	if type(self) ~= "table" then
		return HolidayCollectionHunting.GetDefaultCollectables()
	end

	if not v then
		return self
	end

	for _, collectable in ipairs(v.Collectables) do
		local v2 = self[collectable.Name]

		if type(v2) ~= "table" then
			v2 = {}
			self[collectable.Name] = v2
		end

		for k in pairs(v2) do
			if namesByPiece[k] ~= collectable.Name then
				v2[k] = nil
			end
		end
	end

	return self
end

function HolidayCollectionHunting.MeetsTutorialGate(p: number?, p2: string?)
	if not v then
		return false
	end

	local collectableEntry = HolidayCollectionHunting.GetCollectableEntry(p2)
	return HolidayCollectionCore.meetsTutorialGate(
		v.MinTutorialStep,
		p,
		collectableEntry ~= nil and collectableEntry.AllowDuringFTUE == true
	)
end

function HolidayCollectionHunting.GetHolidayPath()
	if v then
		return string.format("Seasonal.%s", v.HolidayKey)
	end

	return nil
end

function HolidayCollectionHunting.GetTutorialStepPath()
	return "TutorialProgress.CurrentStep"
end

function HolidayCollectionHunting.GetProgressPath()
	if v then
		return string.format("Seasonal.%s.%s", v.HolidayKey, v.ProgressKey)
	end

	return nil
end

function HolidayCollectionHunting.GetCollectablesPath()
	if v then
		return string.format("Seasonal.%s.%s", v.HolidayKey, v.CollectablesKey)
	end

	return nil
end

function HolidayCollectionHunting.GetKeepsakesPath()
	if v and v.KeepsakesKey then
		return string.format("Seasonal.%s.%s", v.HolidayKey, v.KeepsakesKey)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getReplicaUpdater()
	local modules = ServerScriptService:FindFirstChild("Modules")
	local replicaUpdater = modules and modules:FindFirstChild("ReplicaUpdater")
	return replicaUpdater and require(replicaUpdater) or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function replicate(p, p2: string?, p3)
	if not (p and p2) then
		return
	end

	local replicaUpdater = getReplicaUpdater() -- equivalent call inferred; original call site unknown

	if replicaUpdater then
		replicaUpdater:UpdateValue(p, p2, p3)
	end
end

local function ensureHolidayData(p, p2)
	if not v or type(p) ~= "table" then
		return nil
	end

	local selected = p[v.HolidayKey]
	local v3 = type(selected) ~= "table"

	if v3 then
		selected = {}
		p[v.HolidayKey] = selected
	end

	selected[v.ProgressKey] = HolidayCollectionHunting.ClampProgress(selected[v.ProgressKey])
	selected[v.CollectablesKey] = HolidayCollectionHunting.NormalizeCollectables(selected[v.CollectablesKey])

	if not v3 then
		return selected
	end

	local holidayPath = HolidayCollectionHunting.GetHolidayPath()

	if not p2 then
		return selected
	end

	if not holidayPath then
		return selected
	end

	local replicaUpdater = getReplicaUpdater() -- equivalent call inferred; original call site unknown

	if replicaUpdater then
		replicaUpdater:UpdateValue(p2, holidayPath, selected)
	end

	return selected
end

function HolidayCollectionHunting.EnsureHolidayData(p, p2)
	if not RunService:IsClient() then
		return (ensureHolidayData(p, p2))
	end

	warn("[CollectionHunting] SECURITY: EnsureHolidayData called from client — BLOCKED")
	return nil
end

local function syncKeepsakes(holidayData, p, flag: boolean?)
	local progressKeepsakes = v.ProgressKeepsakes

	if not (v.KeepsakesKey and progressKeepsakes and #progressKeepsakes > 0) then
		return
	end

	local v2 = holidayData[v.KeepsakesKey]
	local v3 = type(v2) ~= "table" and {} or v2

	if not HolidayCollectionCore.syncKeepsakes(v3, progressKeepsakes, holidayData[v.ProgressKey], os.time(), flag) then
		return
	end

	holidayData[v.KeepsakesKey] = v3
	local keepsakesPath = HolidayCollectionHunting.GetKeepsakesPath()

	if p then
		if not keepsakesPath then
			return
		end

		local replicaUpdater = getReplicaUpdater() -- equivalent call inferred; original call site unknown

		if replicaUpdater then
			replicaUpdater:UpdateValue(p, keepsakesPath, v3)
		end
	end
end

function HolidayCollectionHunting.AddCollectionProgress(p, p2: number?, p3)
	local holidayData = ensureHolidayData(p, p3)

	if not holidayData then
		return nil
	end

	local v2 = math.floor(tonumber(p2) or 0)

	if v2 <= 0 then
		return nil
	end

	local v3 = holidayData[v.ProgressKey]
	local clampProgress = HolidayCollectionHunting.ClampProgress(v3 + v2)

	if clampProgress == v3 then
		syncKeepsakes(holidayData, p3)
		return nil
	end

	holidayData[v.ProgressKey] = clampProgress
	replicate(p3, HolidayCollectionHunting.GetProgressPath(), clampProgress) -- equivalent call inferred; original call site unknown
	syncKeepsakes(holidayData, p3)
	return clampProgress
end

function HolidayCollectionHunting.SetCollectionProgress(p, p2: number, p3)
	local holidayData = ensureHolidayData(p, p3)

	if not holidayData then
		return nil
	end

	holidayData[v.ProgressKey] = HolidayCollectionHunting.ClampProgress(p2)
	replicate(p3, HolidayCollectionHunting.GetProgressPath(), holidayData[v.ProgressKey]) -- equivalent call inferred; original call site unknown
	syncKeepsakes(holidayData, p3, true)
	return holidayData[v.ProgressKey]
end

function HolidayCollectionHunting.HasKeepsake(p, p2: string)
	if not v then
		return false
	end

	local seasonal = p and p.Data and p.Data.Seasonal
	local v2

	if type(seasonal) == "table" then
		v2 = seasonal[v.HolidayKey]
	else
		v2 = false
	end

	if type(v2) ~= "table" then
		return false
	end

	local v3 = v.KeepsakesKey and v2[v.KeepsakesKey]
	local clampProgress = HolidayCollectionHunting.ClampProgress(v2[v.ProgressKey])

	for _, v4 in ipairs(v.ProgressKeepsakes or {}) do
		if v4.Id == p2 then
			return HolidayCollectionCore.isKeepsakeEarned(v3, v4, clampProgress)
		end
	end

	return type(v3) == "table" and v3[p2] ~= nil
end

function HolidayCollectionHunting.SetFoundPieces(p, p2, p3)
	local holidayData = ensureHolidayData(p, p3)

	if not holidayData then
		return nil
	end

	holidayData[v.CollectablesKey] = HolidayCollectionHunting.NormalizeCollectables(p2)
	replicate(p3, HolidayCollectionHunting.GetCollectablesPath(), holidayData[v.CollectablesKey]) -- equivalent call inferred; original call site unknown
	return holidayData[v.CollectablesKey]
end

local function grantInProfile(p, p2, p3: string, p4: string)
	if not (p and p.Data and p.Data.Seasonal) then
		return false, false, 0
	end

	local tutorialProgress = p.Data.TutorialProgress

	if not HolidayCollectionHunting.MeetsTutorialGate(tutorialProgress and tutorialProgress.CurrentStep, p3) then
		return true, false, 0
	end

	local holidayData = ensureHolidayData(p.Data.Seasonal, p2)

	if not holidayData then
		return false, false, 0
	end

	local v2 = holidayData[v.CollectablesKey]
	local v3

	if v2[p3][p4] then
		v3 = false
	else
		v2[p3][p4] = os.time()
		v3 = true
		replicate(p2, HolidayCollectionHunting.GetCollectablesPath(), v2) -- equivalent call inferred; original call site unknown
	end

	local count = 0

	for _, piece in ipairs(HolidayCollectionHunting.GetCollectableEntry(p3).Pieces) do
		if v2[p3][piece] then
			count += 1
		end
	end

	return false, v3, count
end

local function resolvePieceOwner(p: string)
	local v2 = namesByPiece[p]

	if not v2 then
		warn(("[CollectionHunting] unknown piece id %q — check the spot marker against the roster"):format((tostring(p))))
	end

	return v2
end

function HolidayCollectionHunting.AwardSpecialPiece(player, p: string)
	if RunService:IsClient() then
		warn("[CollectionHunting] SECURITY: AwardSpecialPiece called from client — BLOCKED")
		return false, "CLIENT_CALL"
	end

	if not v then
		return false, "NO_COLLECTION"
	end

	if not (player and player:IsA("Player")) then
		return false, "BAD_PLAYER"
	end

	local v2 = namesByPiece[p]

	if not v2 then
		warn(("[CollectionHunting] unknown piece id %q — check the spot marker against the roster"):format((tostring(p))))
	end

	if not v2 then
		return false, "UNKNOWN_PIECE"
	end

	local editData = ReplicatedStorage:FindFirstChild("editData")

	if not editData then
		warn("[CollectionHunting] editData BindableFunction not found — cannot award piece")
		return false, "NO_EDITDATA"
	end

	local v3 = false
	local v4 = 0
	local v5 = false
	local success, result = pcall(function()
		editData:Invoke(player, function(p2)
			v5, v3, v4 = grantInProfile(p2, player, v2, p)
		end)
	end)

	if not success then
		warn(("[CollectionHunting] failed to award %q to %s: %s"):format(tostring(p), player.Name, (tostring(result))))
		return false, "EDIT_FAILED"
	end

	if v5 then
		return false, "TUTORIAL_GATE"
	end

	return v3, v2, v4, #HolidayCollectionHunting.GetCollectableEntry(v2).Pieces
end

function HolidayCollectionHunting.GrantSpecialPieceInProfile(p, p2, p3: string)
	if RunService:IsClient() then
		warn("[CollectionHunting] SECURITY: GrantSpecialPieceInProfile called from client — BLOCKED")
		return false, "CLIENT_CALL"
	end

	if not v then
		return false, "NO_COLLECTION"
	end

	local v2 = namesByPiece[p3]

	if not v2 then
		warn(("[CollectionHunting] unknown piece id %q — check the spot marker against the roster"):format((tostring(p3))))
	end

	if not v2 then
		return false, "UNKNOWN_PIECE"
	end

	local v3, v4, v5 = grantInProfile(p, p2, v2, p3)

	if v3 then
		return false, "TUTORIAL_GATE"
	end

	return v4, v2, v5, #HolidayCollectionHunting.GetCollectableEntry(v2).Pieces
end

local function canCollect(player)
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		local child = inGamePlayers:FindFirstChild(player.Name)

		if not child then
			return false
		end

		local humanoid = child:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	else
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(player, p: string?)
	if not p then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local textEvent = events and events:FindFirstChild("TextEvent")

	if textEvent then
		textEvent:FireClient(player, p)
	end
end

local function countTowardRunResults(p)
	local info = workspace:FindFirstChild("Info")
	local playerStats = info and info:FindFirstChild("PlayerStats")
	local child = playerStats and playerStats:FindFirstChild(p.Name)
	local holidayCollectibleItem = child and child:FindFirstChild("HolidayCollectibleItem")

	if not holidayCollectibleItem then
		return
	end

	holidayCollectibleItem.Value += 1
	print(("[CollectionHunting] %s run event-item tally: %d"):format(p.Name, holidayCollectibleItem.Value))
end

local function resolvePrompt(instance)
	local proximityPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt", true)

	if proximityPrompt then
		return proximityPrompt
	end

	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		return nil
	end

	local proximityPrompt2 = Instance.new("ProximityPrompt")
	proximityPrompt2.RequiresLineOfSight = false
	proximityPrompt2.MaxActivationDistance = 10
	proximityPrompt2.Parent = primaryPart
	return proximityPrompt2
end

local function preparePickup(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
	end
end

local function setupPickup(clone, spotPieceTag: string, spotPromptObjectText: string?, fn)
	CollectionService:AddTag(clone, spotPieceTag)
	local v2 = clone:FindFirstChildWhichIsA("ProximityPrompt", true)

	if not v2 then
		local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

		if primaryPart then
			v2 = Instance.new("ProximityPrompt")
			v2.RequiresLineOfSight = false
			v2.MaxActivationDistance = 10
			v2.Parent = primaryPart
		else
			v2 = nil
		end
	end

	if not v2 then
		warn("[CollectionHunting] spawned pickup has no BasePart to host a prompt — it cannot be collected")
		return
	end

	v2.ActionText = v.PromptActionText
	v2.ObjectText = spotPromptObjectText
	local v3 = {}
	v2.Triggered:Connect(function(player)
		if v3[player] or not canCollect(player) then
			return
		end

		v3[player] = true
		local success, result = pcall(fn, player)

		if success then
			notify(player, result) -- equivalent call inferred; original call site unknown
		else
			v3[player] = nil
			warn("[CollectionHunting] pickup handler errored: " .. tostring(result))
		end
	end)
end

local v2 = {}
local v3 = false

local function liveRootOf(player)
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")
	local character

	if inGamePlayers then
		character = inGamePlayers:FindFirstChild(player.Name)
	else
		character = player.Character
	end

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not (humanoid and humanoid.Health > 0) then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function awardProximity(p, player)
	local success, result = pcall(p.onCollected, player)

	if not success then
		warn("[CollectionHunting] pickup handler errored: " .. tostring(result))
		return
	end

	notify(player, result) -- equivalent call inferred; original call site unknown
end

local function runProximityLoop()
	local v4 = (v.PieceCollectRadius or 7) + 2

	while next(v2) do
		task.wait(0.1)
		local players = Players:GetPlayers()

		for k, v5 in pairs(v2) do
			if not k:IsDescendantOf(workspace) then
				continue
			end

			for _, player in ipairs(players) do
				if v5.claimed[player] then
					continue
				end

				local v6 = liveRootOf(player)

				if not (v6 and (v6.Position - v5.origin).Magnitude <= v4) then
					continue
				end

				v5.claimed[player] = true
				task.spawn(awardProximity, v5, player)
			end
		end
	end

	v3 = false
end

local function setupProximityPickup(instance, pieceTag: string, onCollected)
	CollectionService:AddTag(instance, pieceTag)
	v2[instance] = {
		origin = instance:GetPivot().Position,
		claimed = {},
		onCollected = onCollected
	}
	instance.Destroying:Once(function()
		v2[instance] = nil
	end)

	if not v3 then
		v3 = true
		task.spawn(runProximityLoop)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function collectPresentationModule()
	local holidayPuzzles = script.Parent:FindFirstChild("HolidayPuzzles")
	local collectPresentation = holidayPuzzles and holidayPuzzles:FindFirstChild("CollectPresentation")
	return collectPresentation and require(collectPresentation) or nil
end

local function findFloorPieceTemplate()
	local piecePresentation = v.PiecePresentation
	local v4

	if piecePresentation then
		v4 = collectPresentationModule()
	else
		v4 = piecePresentation
	end

	if v4 then
		local template, v5 = v4.ensureTemplate(piecePresentation)

		if template then
			return template, v5, true
		end
	end

	local parts = ServerStorage:FindFirstChild("Parts")
	local child = parts and parts:FindFirstChild(v.PieceModelName)

	if child then
		return child, "ServerStorage.Parts." .. v.PieceModelName, false
	end

	return nil, nil, false
end

local function instantiateFloorPiece(child, flag: boolean)
	if not flag then
		return (child:Clone())
	end

	local mesh = (collectPresentationModule()).cloneMesh(child, v.PieceMeshSize or 2.5)
	local model = Instance.new("Model")
	model.Name = v.PieceModelName
	mesh.Parent = model

	if not mesh:IsA("BasePart") then
		mesh = mesh.PrimaryPart or mesh:FindFirstChildWhichIsA("BasePart", true)
	end

	model.PrimaryPart = mesh
	return model
end

function HolidayCollectionHunting.PrepareFloorPieceMesh()
	if not v or RunService:IsClient() then
		return
	end

	local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

	if not HolidayEventConfig.ENABLED then
		return
	end

	local piecePresentation = v.PiecePresentation
	local v4

	if piecePresentation then
		v4 = collectPresentationModule()
	else
		v4 = piecePresentation
	end

	local v5, parts

	if v4 then
		local v6
		v6, v5 = v4.ensureTemplate(piecePresentation)

		if not v6 then
			parts = ServerStorage:FindFirstChild("Parts")

			if parts and parts:FindFirstChild(v.PieceModelName) then
				v5 = "ServerStorage.Parts." .. v.PieceModelName
			else
				v5 = nil
			end
		end
	else
		parts = ServerStorage:FindFirstChild("Parts")

		if parts and parts:FindFirstChild(v.PieceModelName) then
			v5 = "ServerStorage.Parts." .. v.PieceModelName
		end
	end

	print("[CollectionHunting] decor pickups use " .. tostring(v5))
end

function HolidayCollectionHunting.GetFloorPieceSource()
	if not v then
		return nil, nil
	end

	local piecePresentation = v.PiecePresentation
	local v4

	if piecePresentation then
		v4 = collectPresentationModule()
	else
		v4 = piecePresentation
	end

	local child, v5, parts

	if v4 then
		child, v5 = v4.ensureTemplate(piecePresentation)

		if not child then
			parts = ServerStorage:FindFirstChild("Parts")
			child = parts and parts:FindFirstChild(v.PieceModelName)

			if child then
				v5 = "ServerStorage.Parts." .. v.PieceModelName
			else
				v5 = nil
				child = nil
			end
		end
	else
		parts = ServerStorage:FindFirstChild("Parts")
		child = parts and parts:FindFirstChild(v.PieceModelName)

		if child then
			v5 = "ServerStorage.Parts." .. v.PieceModelName
		else
			child = nil
		end
	end

	return v5, child
end

local function presentCollect(player, p, vector: Vector3, pickupMessage: string?, p2: number)
	local piecePresentation = v.PiecePresentation
	local v4

	if piecePresentation then
		v4 = collectPresentationModule()
	else
		v4 = piecePresentation
	end

	local network = script.Parent:FindFirstChild("Network")

	if v4 and network then
		local module = require(network)
		module:Post(player, "HalloweenCollectPresentation", vector, p2, p)
		task.delay(v4.snapDuration(piecePresentation), notify, player, pickupMessage)
	else
		notify(player, pickupMessage) -- equivalent call inferred; original call site unknown
	end
end

local function spawnPieces(p: number, p2: string)
	local piecePresentation = v.PiecePresentation
	local v4

	if piecePresentation then
		v4 = collectPresentationModule()
	else
		v4 = piecePresentation
	end

	local child, v5, v6, parts

	if v4 then
		child, v5 = v4.ensureTemplate(piecePresentation)

		if child then
			v6 = true
		else
			parts = ServerStorage:FindFirstChild("Parts")
			child = parts and parts:FindFirstChild(v.PieceModelName)

			if child then
				v5 = "ServerStorage.Parts." .. v.PieceModelName
				v6 = false
			else
				child = nil
				v6 = false
				v5 = nil
			end
		end
	else
		parts = ServerStorage:FindFirstChild("Parts")
		child = parts and parts:FindFirstChild(v.PieceModelName)

		if child then
			v5 = "ServerStorage.Parts." .. v.PieceModelName
			v6 = false
		else
			child = nil
			v6 = false
		end
	end

	if not child then
		warn(("[CollectionHunting] no floor pickup model: neither the collectible mesh nor ServerStorage.Parts.%s exists — no pieces on %s"):format(
			tostring(v.PieceModelName),
			p2
		))
		return 0
	end

	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	local currentRoomModel = currentRoom and currentRoom:FindFirstChildOfClass("Model")

	if not currentRoomModel then
		warn("[CollectionHunting] no room in workspace.CurrentRoom — no pieces on " .. p2)
		return 0
	end

	local IchorPuddleSpawner = require(ReplicatedStorage.Modules.Zones:WaitForChild("IchorPuddleSpawner"))
	local spawnPositions = IchorPuddleSpawner.GetSpawnPositions()

	if #spawnPositions == 0 then
		warn("[CollectionHunting] no ichor trigger zones on " .. p2 .. " — no pieces")
		return 0
	end

	if #spawnPositions < p then
		warn(("[CollectionHunting] %s wanted %d pieces but only %d spawn points exist"):format(p2, p, #spawnPositions))
	end

	local parent = currentRoomModel:FindFirstChild(HolidayCollectionHunting.PICKUP_FOLDER)

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = HolidayCollectionHunting.PICKUP_FOLDER
		parent.Parent = currentRoomModel
	end

	local count = 0

	for i = 1, math.min(p, #spawnPositions) do
		local v8 = instantiateFloorPiece(child, v6)
		preparePickup(v8)
		v8:PivotTo(CFrame.new(spawnPositions[i].floorPosition + Vector3.new(0, v.PieceHeightOffset, 0)) * CFrame.Angles(
			0,
			math.rad((math.random(0, 360))),
			0
		))
		local position = v8:GetPivot().Position
		setupProximityPickup(v8, v.PieceTag, function(p3)
			local editData = ReplicatedStorage:FindFirstChild("editData")

			if not editData then
				error("editData BindableFunction not found", 0)
			end

			local v11 = nil
			local v12 = nil
			editData:Invoke(p3, function(p4)
				if not (p4 and p4.Data and p4.Data.Seasonal) then
					return
				end

				v11 = HolidayCollectionHunting.AddCollectionProgress(p4.Data.Seasonal, 1, p3)
				local v13 = p4.Data.Seasonal[v.HolidayKey]
				v12 = type(v13) == "table" and v13[v.ProgressKey] or nil
			end)

			if not v11 then
				print(("[CollectionHunting] %s took a decor piece but nothing was added: %s"):format(
					p3.Name,
					v12 and ("count already at the cap (%d / %d)"):format(v12, v.MaxCollectionProgress) or "profile not loaded"
				))
				return nil
			end

			print(("[CollectionHunting] %s collected a decor piece: %d / %d"):format(
				p3.Name,
				v11,
				v.MaxCollectionProgress
			))
			countTowardRunResults(p3)
			presentCollect(p3, v8, position, v.PickupMessage, v11)
			return nil
		end)
		v8.Parent = parent
		count += 1
	end

	print(("[CollectionHunting] spawned %d common piece(s) on %s from %s"):format(count, p2, (tostring(v5))))
	return count
end

function HolidayCollectionHunting.SpawnForFloor(p: number)
	if not v then
		return 0
	end

	local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

	if not HolidayEventConfig.ENABLED then
		return 0
	end

	local pieceCountForFloor = HolidayCollectionHunting.PieceCountForFloor(p)

	if pieceCountForFloor <= 0 then
		return 0
	end

	return (spawnPieces(pieceCountForFloor, "floor " .. tostring(p)))
end

function HolidayCollectionHunting.PieceCountForFloor(p: number)
	if not v then
		return 0
	end

	local count = 0

	for _, v4 in ipairs(v.FloorPieceCounts or {}) do
		if p < v4.fromFloor then
			break
		else
			count = v4.count
		end
	end

	return count
end

function HolidayCollectionHunting.SpawnPiecesNow(p: number)
	if RunService:IsClient() then
		warn("[CollectionHunting] SECURITY: SpawnPiecesNow called from client — BLOCKED")
		return 0
	end

	if not v then
		return 0
	end

	local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

	if not HolidayEventConfig.ENABLED then
		return 0
	end

	local v4 = math.clamp(math.floor(tonumber(p) or 0), 0, 20)

	if v4 == 0 then
		return 0
	end

	return (spawnPieces(v4, "the current floor (QA)"))
end

function HolidayCollectionHunting._startSpotWatcher()
	if not v then
		return
	end

	local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

	if not HolidayEventConfig.ENABLED then
		return
	end

	local parts = ServerStorage:FindFirstChild("Parts")
	local child = parts and parts:FindFirstChild(v.SpotPieceModelName)

	if child then
		local function equip(part)
			local attribute = part:GetAttribute(v.PieceIdAttribute)

			if type(attribute) ~= "string" or attribute == "" then
				warn(("[CollectionHunting] spot marker %s has no %s attribute — nothing to award"):format(
					part:GetFullName(),
					v.PieceIdAttribute
				))
				return
			end

			if not namesByPiece[attribute] then
				warn(("[CollectionHunting] spot marker %s awards unknown piece id %q"):format(
					part:GetFullName(),
					attribute
				))
				return
			end

			if HolidayCollectionHunting.GetCollectableEntry(namesByPiece[attribute]).QuestAwarded then
				warn(("[CollectionHunting] spot marker %s names quest piece %q — ignored, the quest awards it; remove the %s tag"):format(
					part:GetFullName(),
					attribute,
					v.SpotTag
				))
				return
			end

			if part:FindFirstChild(v.SpotPieceModelName) then
				return
			end

			local clone = child:Clone()
			clone.Name = v.SpotPieceModelName
			preparePickup(clone)
			clone:PivotTo(part.CFrame)
			clone:SetAttribute(v.PieceIdAttribute, attribute)
			setupPickup(clone, v.SpotPieceTag, v.SpotPromptObjectText, function(p)
				local awardSpecialPiece, _, v4, v5 = HolidayCollectionHunting.AwardSpecialPiece(p, attribute)

				if not awardSpecialPiece then
					return nil
				end

				countTowardRunResults(p)
				return v.SpotPickupMessage:format(v4, v5)
			end)
			clone.Parent = part
		end

		local function serveSpot(part)
			if not part:IsA("BasePart") then
				warn(("[CollectionHunting] spot marker %s is a %s, expected a BasePart"):format(
					part:GetFullName(),
					part.ClassName
				))
				return
			end

			if part:IsDescendantOf(workspace) then
				equip(part)
				return
			end

			local ancestryChangedConnection = nil
			ancestryChangedConnection = part.AncestryChanged:Connect(function()
				if part:IsDescendantOf(workspace) then
					ancestryChangedConnection:Disconnect()
					equip(part)
				end
			end)
		end

		for _, v4 in ipairs(CollectionService:GetTagged(v.SpotTag)) do
			serveSpot(v4)
		end

		CollectionService:GetInstanceAddedSignal(v.SpotTag):Connect(serveSpot)
	else
		local count = #CollectionService:GetTagged(v.SpotTag)

		if count > 0 then
			warn(("[CollectionHunting] %d %s marker(s) but %q not found under ServerStorage.Parts — spot pieces disabled here"):format(
				count,
				v.SpotTag,
				(tostring(v.SpotPieceModelName))
			))
		end
	end
end

function HolidayCollectionHunting._startPickupClient()
	if not v then
		return
	end

	local function captionFor(progress)
		if type(progress) ~= "number" or not v.PickupCountCaption then
			return nil
		end

		local v4 = { v.PickupCountCaption:format(progress, v.MaxCollectionProgress) }
		local piecesToNextKeepsake = HolidayCollectionCore.piecesToNextKeepsake(v.ProgressKeepsakes, progress)

		if piecesToNextKeepsake and v.PickupKeepsakeCaption then
			table.insert(v4, v.PickupKeepsakeCaption:format(piecesToNextKeepsake))
		end

		return v4
	end

	local fn

	if v.PiecePresentation then
		task.spawn(function()
			local Network = require(script.Parent:WaitForChild("Network"))
			Network:AddAction("HalloweenCollectPresentation", function(p, p2, p3)
				if typeof(p) ~= "Vector3" or not fn then
					return
				end

				fn(p, p2, p3)
			end)
		end)
	end

	local localPlayer = Players.LocalPlayer
	local v4 = {}
	local v5 = {}
	local v6 = 0
	local v7 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function remember(instance)
		if v7[instance] == nil and instance.Parent ~= nil then
			v7[instance] = instance.Parent
			instance.Destroying:Once(function()
				v7[instance] = nil
				v5[instance] = nil
			end)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setVisible(p, flag: boolean)
		if flag then
			local parent = v7[p]

			if parent and p.Parent ~= parent then
				pcall(function()
					p.Parent = parent
				end)
			end
		elseif p.Parent ~= nil then
			pcall(function()
				p.Parent = nil
			end)
		end
	end

	local function findTaggedPickup(parent)
		while parent and parent ~= workspace do
			if CollectionService:HasTag(parent, v.PieceTag) or CollectionService:HasTag(parent, v.SpotPieceTag) then
				return parent
			else
				parent = parent.Parent
			end
		end

		return nil
	end

	local function isProgressMaxed()
		return localPlayer:GetAttribute(v.ProgressMaxedAttribute) == true
	end

	local function shouldShow(instance)
		if CollectionService:HasTag(instance, v.SpotPieceTag) then
			local attribute = instance:GetAttribute(v.PieceIdAttribute)
			local v8

			if type(attribute) == "string" then
				v8 = namesByPiece[attribute] or nil
			end

			if not HolidayCollectionHunting.MeetsTutorialGate(v6, v8) then
				return false
			end

			return type(attribute) ~= "string" or not v4[attribute]
		else
			return not v5[instance] and localPlayer:GetAttribute(v.ProgressMaxedAttribute) ~= true
		end
	end

	local pieceIdle = v.PieceIdle
	local v8 = {}

	local function dressIdle(model)
		local primaryPart = model:IsA("Model") and model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)

		if not primaryPart or primaryPart:FindFirstChild("HalloweenPickupSparkle") then
			return
		end

		local piecePresentation = v.PiecePresentation
		local tokenColor = piecePresentation and piecePresentation.TokenColor or Color3.fromRGB(255, 137, 2)
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "HalloweenPickupSparkle"
		particleEmitter.Texture = piecePresentation and piecePresentation.SparkleTexture or "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Color = ColorSequence.new(tokenColor)
		particleEmitter.LightEmission = 1
		particleEmitter.Size = NumberSequence.new(0.4, 0)
		particleEmitter.Lifetime = NumberRange.new(0.6, 1)
		particleEmitter.Speed = NumberRange.new(0.5, 1.5)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Rate = pieceIdle.SparkleRate or 8
		particleEmitter.Parent = primaryPart
		local pointLight = Instance.new("PointLight")
		pointLight.Name = "HalloweenPickupGlow"
		pointLight.Color = tokenColor
		pointLight.Range = pieceIdle.LightRange or 10
		pointLight.Brightness = pieceIdle.LightBrightness or 1.2
		pointLight.Parent = primaryPart
	end

	local function startIdle(pVInstance)
		if not pieceIdle or v8[pVInstance] or not (pVInstance:IsA("PVInstance") and CollectionService:HasTag(
			pVInstance,
			v.PieceTag
		)) then
			return
		end

		v8[pVInstance] = {
			base = pVInstance:GetPivot(),
			phase = math.random() * 3.141592653589793 * 2
		}
		dressIdle(pVInstance)
		pVInstance.Destroying:Once(function()
			v8[pVInstance] = nil
		end)
	end

	if pieceIdle then
		local spinSpeed = math.rad(pieceIdle.SpinSpeed or 90)
		local v9 = 6.283185307179586 / (pieceIdle.BobPeriod or 2)
		local bobHeight = pieceIdle.BobHeight or 0.35
		RunService.Heartbeat:Connect(function()
			if next(v8) == nil then
				return
			end

			local now = os.clock()

			for k, v10 in pairs(v8) do
				if not k.Parent then
					continue
				end

				local v11 = math.sin(now * v9 + v10.phase) * bobHeight
				k:PivotTo(v10.base * CFrame.new(0, v11, 0) * CFrame.Angles(0, now * spinSpeed + v10.phase, 0))
			end
		end)
	end

	local pieceCollectRadius = v.PieceCollectRadius or 7
	local v9 = {}
	local object = setmetatable({}, {
		__mode = "k"
	})

	local function tryCaption(state)
		if state.captioned or not (state.landed and state.progress) then
			return
		end

		state.captioned = true
		local presentationModule = collectPresentationModule() -- equivalent call inferred; original call site unknown

		if presentationModule then
			presentationModule.showCaption(v.PiecePresentation, (captionFor(state.progress)))
		end
	end

	local function beginSnap(instance, vector: Vector3?)
		local v10 = {
			landed = false,
			captioned = false,
			progress = nil
		}

		if instance then
			object[instance] = v10
			remember(instance) -- equivalent call inferred; original call site unknown
			v5[instance] = true
		end

		local presentationModule = collectPresentationModule() -- equivalent call inferred; original call site unknown

		if presentationModule and v.PiecePresentation then
			task.spawn(function()
				local success, result = pcall(presentationModule.snap, v.PiecePresentation, instance or vector)

				if not success then
					warn("[CollectionHunting] collect animation failed: " .. tostring(result))
				end

				v10.landed = true
				local v12 = v10

				if not v12.captioned and v12.landed then
					if not v12.progress then
						return
					end

					v12.captioned = true
					local presentationModule2 = collectPresentationModule() -- equivalent call inferred; original call site unknown

					if presentationModule2 then
						presentationModule2.showCaption(v.PiecePresentation, (captionFor(v12.progress)))
					end
				end
			end)
		else
			v10.landed = true
		end

		if instance and instance.Parent ~= nil then
			pcall(function()
				instance.Parent = nil
			end)
		end

		return v10
	end

	fn = function(vector: Vector3, progress, instance)
		if typeof(instance) ~= "Instance" then
			instance = nil
		end

		local v10 = instance and object[instance] or beginSnap(instance, vector)

		if type(progress) ~= "number" then
			progress = nil
		end

		v10.progress = progress

		if not v10.captioned and v10.landed then
			if not v10.progress then
				return
			end

			v10.captioned = true
			local presentationModule = collectPresentationModule() -- equivalent call inferred; original call site unknown

			if presentationModule then
				presentationModule.showCaption(v.PiecePresentation, (captionFor(v10.progress)))
			end
		end
	end

	RunService.Heartbeat:Connect(function()
		if next(v9) == nil then
			return
		end

		local v10 = liveRootOf(localPlayer)

		if not v10 then
			return
		end

		for k in pairs(v9) do
			if not k.Parent or object[k] or not ((k:GetPivot().Position - v10.Position).Magnitude <= pieceCollectRadius) then
				continue
			end

			beginSnap(k, nil)
		end
	end)

	local function trackCommon(pVInstance)
		if v9[pVInstance] or not (pVInstance:IsA("PVInstance") and CollectionService:HasTag(pVInstance, v.PieceTag)) then
			return
		end

		v9[pVInstance] = true
		pVInstance.Destroying:Once(function()
			v9[pVInstance] = nil
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply(instance)
		remember(instance) -- equivalent call inferred; original call site unknown
		setVisible(instance, shouldShow(instance))
		startIdle(instance)
		trackCommon(instance)
	end

	local function sweep()
		for _, tag in ipairs({ v.PieceTag, v.SpotPieceTag }) do
			for _, v10 in ipairs(CollectionService:GetTagged(tag)) do
				apply(v10) -- equivalent call inferred; original call site unknown
			end
		end

		for k in pairs(v7) do
			setVisible(k, shouldShow(k))
		end
	end

	ProximityPromptService.PromptTriggered:Connect(function(player, p)
		if p ~= localPlayer then
			return
		end

		local taggedPickup = findTaggedPickup(player)

		if not taggedPickup then
			return
		end

		remember(taggedPickup) -- equivalent call inferred; original call site unknown

		if not CollectionService:HasTag(taggedPickup, v.SpotPieceTag) then
			v5[taggedPickup] = true
		end

		setVisible(taggedPickup, false) -- equivalent call inferred; original call site unknown
		local attribute = taggedPickup:GetAttribute(v.PieceIdAttribute)
		local firstPieceCutscene = v.FirstPieceCutscene

		if firstPieceCutscene and attribute == firstPieceCutscene.PieceId and not v4[attribute] then
			task.spawn(HolidayCollectionHunting._playFirstPieceCutscene, attribute)
		end
	end)

	for _, v10 in ipairs({ v.PieceTag, v.SpotPieceTag }) do
		CollectionService:GetInstanceAddedSignal(v10):Connect(apply)
	end

	localPlayer:GetAttributeChangedSignal(v.ProgressMaxedAttribute):Connect(sweep)
	local v10 = nil

	local function hasUnlocked(value)
		return type(value) == "string" and HolidayCollectionHunting.IsCollectableUnlocked(v10, value)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyGate(proximityPrompt)
		if not proximityPrompt:IsA("ProximityPrompt") then
			return
		end

		local attribute = proximityPrompt:GetAttribute(HolidayCollectionHunting.GATED_PROMPT_ATTRIBUTE)
		local enabled

		if type(attribute) == "string" then
			enabled = HolidayCollectionHunting.IsCollectableUnlocked(v10, attribute)
		else
			enabled = false
		end

		if proximityPrompt.Enabled ~= enabled then
			proximityPrompt.Enabled = enabled
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyGates()
		for _, v11 in ipairs(CollectionService:GetTagged(HolidayCollectionHunting.GATED_PROMPT_TAG)) do
			applyGate(v11) -- equivalent call inferred; original call site unknown
		end
	end

	local function watchGate(proximityPrompt)
		if not proximityPrompt:IsA("ProximityPrompt") then
			return
		end

		applyGate(proximityPrompt) -- equivalent call inferred; original call site unknown
		proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
			applyGate(proximityPrompt) -- equivalent call inferred; original call site unknown
		end)
	end

	for _, v11 in ipairs(CollectionService:GetTagged(HolidayCollectionHunting.GATED_PROMPT_TAG)) do
		watchGate(v11)
	end

	CollectionService:GetInstanceAddedSignal(HolidayCollectionHunting.GATED_PROMPT_TAG):Connect(watchGate)
	local _getDataController = HolidayCollectionHunting._getDataController()

	if not _getDataController then
		return
	end

	_getDataController:onReplicaReady(function(object2)
		local holidayPath = HolidayCollectionHunting.GetHolidayPath()
		local progressPath = HolidayCollectionHunting.GetProgressPath()
		local collectablesPath = HolidayCollectionHunting.GetCollectablesPath()
		local tutorialStepPath = HolidayCollectionHunting.GetTutorialStepPath()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyProgress(data)
			localPlayer:SetAttribute(v.ProgressMaxedAttribute, HolidayCollectionHunting.IsProgressMaxed(data))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshGates()
			v10 = _getDataController:getDataFromPath(holidayPath)
			applyGates() -- equivalent call inferred; original call site unknown
		end

		local function applyFound(items)
			refreshGates() -- equivalent call inferred; original call site unknown
			table.clear(v4)

			if type(items) == "table" then
				for _, item in pairs(items) do
					if type(item) ~= "table" then
						continue
					end

					for k in pairs(item) do
						v4[k] = true
					end
				end
			end

			sweep()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyTutorial(p)
			v6 = tonumber(p) or 0
			sweep()
		end

		applyProgress(_getDataController:getDataFromPath(progressPath)) -- equivalent call inferred; original call site unknown
		applyTutorial(_getDataController:getDataFromPath(tutorialStepPath)) -- equivalent call inferred; original call site unknown
		applyFound(_getDataController:getDataFromPath(collectablesPath))
		object2:ListenToChange(progressPath, applyProgress)
		object2:ListenToChange(collectablesPath, applyFound)
		object2:ListenToChange(tutorialStepPath, applyTutorial)

		for _, collectable in ipairs(v.Collectables) do
			if collectable.UnlockedBy then
				object2:ListenToChange(holidayPath .. "." .. collectable.UnlockedBy.StateKey, refreshGates)
			end
		end
	end)
end

local v4 = nil

function HolidayCollectionHunting._playFirstPieceCutscene(p: string)
	local firstPieceCutscene = v and v.FirstPieceCutscene

	if not (firstPieceCutscene and v4) then
		return false
	end

	local CameraController = require(script.Parent.CameraController)
	local PlayerMovementController = require(script.Parent.PlayerMovementController)
	local MenuManager = require(script.Parent.MenuManager)

	if CameraController:IsActive() or PlayerMovementController:IsLocked() then
		return false
	end

	local child = workspace:FindFirstChild(v.DecorFolder)
	local child2 = child and child:FindFirstChild(firstPieceCutscene.CameraFolder)
	local part = child2 and child2:FindFirstChild(firstPieceCutscene.DandyCamName)
	local part2 = child2 and child2:FindFirstChild(firstPieceCutscene.LockboxCamName)

	if not (part and part:IsA("BasePart") and part2 and part2:IsA("BasePart")) then
		warn(("[CollectionHunting] cutscene needs %s.%s.{%s,%s} as BaseParts — skipping"):format(
			v.DecorFolder,
			firstPieceCutscene.CameraFolder,
			firstPieceCutscene.DandyCamName,
			firstPieceCutscene.LockboxCamName
		))
		return false
	end

	local v5, v6 = v4.begin(p)

	if not v5 then
		warn(("[CollectionHunting] %s has no slot on the shrine — cutscene plays without the fly-in"):format(p))
	end

	PlayerMovementController:Lock("Halloween26_FirstPieceCutscene")
	local success, result = pcall(function()
		CameraController:TweenTo(part2.CFrame, firstPieceCutscene.ToLockboxTime)
		task.wait(firstPieceCutscene.ToLockboxTime + firstPieceCutscene.SettleTime)

		if v6 then
			local currentCamera = workspace.CurrentCamera
			local v7 = currentCamera and currentCamera.CFrame * CFrame.new(0, 0, -firstPieceCutscene.FlyDistance) or v5
			local cFrameValue = Instance.new("CFrameValue")
			cFrameValue.Value = CFrame.new(v7.Position) * v5.Rotation
			cFrameValue.Changed:Connect(function(cframe)
				v6:PivotTo(cframe)
			end)
			v6:PivotTo(cFrameValue.Value)
			v6.Parent = workspace
			TweenService:Create(
				cFrameValue,
				TweenInfo.new(firstPieceCutscene.FlyTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					Value = v5
				}
			):Play()
			task.wait(firstPieceCutscene.FlyTime)
			cFrameValue:Destroy()
			v6:Destroy()
			v6 = nil
		end

		v4.finish(p, firstPieceCutscene.RevealTime)
		task.wait(firstPieceCutscene.RevealTime)
		v4.preview(p, firstPieceCutscene.PreviewTransparency, firstPieceCutscene.PreviewTime)
		task.wait(firstPieceCutscene.HoldTime)
		CameraController:TweenTo(part.CFrame, firstPieceCutscene.ToDandyTime)
		task.wait(firstPieceCutscene.ToDandyTime)
		local instance = MenuManager:GetInstance(firstPieceCutscene.DialogShopName)

		if not instance then
			warn(("[CollectionHunting] no %q shop instance — cutscene ran without dialogue"):format((tostring(firstPieceCutscene.DialogShopName))))
			return
		end

		for _, line in ipairs(firstPieceCutscene.Lines) do
			local v7 = line
			pcall(function()
				instance:Speak(v7.text, {
					duration = v7.duration
				})
			end)
			task.wait(line.duration)
		end
	end)

	if v6 then
		v6:Destroy()
	end

	CameraController:Reset()
	PlayerMovementController:Unlock("Halloween26_FirstPieceCutscene")
	v4.release(p)

	if success then
		return true
	end

	warn("[CollectionHunting] first-piece cutscene failed: " .. tostring(result))
	return false
end

function HolidayCollectionHunting._getDataController()
	local modules = ReplicatedStorage:WaitForChild("Modules", 30)

	if not modules then
		warn("[CollectionHunting] ReplicatedStorage.Modules never replicated")
		return nil
	end

	ReplicatedStorage:WaitForChild("Bindables", 30)
	local myDataController = modules:FindFirstChild("MyDataController")

	if not myDataController then
		local clientUI = modules:FindFirstChild("ClientUI")
		myDataController = clientUI and clientUI:FindFirstChild("MyDataController")
	end

	if not myDataController then
		warn("[CollectionHunting] no MyDataController in this place")
		return nil
	end

	local success, result = pcall(require, myDataController)

	if success then
		return result
	end

	warn("[CollectionHunting] failed to require MyDataController: " .. tostring(result))
	return nil
end

function HolidayCollectionHunting._startLobbyClient()
	local child = workspace:WaitForChild(v.DecorFolder, 30)

	if not child then
		return
	end

	local child2 = child:FindFirstChild(v.CollectablesFolder)
	local child3 = child:FindFirstChild(v.ProgressFolder)
	local transparenciesByInstance = {}
	local v5 = {}
	local enabledsByInstance = {}
	local tweens = {}
	local v6 = {
		"ParticleEmitter",
		"Fire",
		"Smoke",
		"Sparkles",
		"Beam",
		"Trail",
		"Light",
		"LayerCollector",
		"Highlight"
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isEffect(instance)
		for _, className in ipairs(v6) do
			if instance:IsA(className) then
				return true
			end
		end

		return false
	end

	local tweenInfo = TweenInfo.new(v.GhostFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function fadeTo(instance, transparency: number, duration: number?)
		local v7 = tweens[instance]

		if v7 then
			v7:Cancel()
		end

		local tweenInfo2 = duration and TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or tweenInfo
		local tween = TweenService:Create(instance, tweenInfo2, {
			Transparency = transparency
		})
		tweens[instance] = tween
		tween:Play()
	end

	local function claimPiece(folder)
		local instances = {}
		local instances2 = {}
		local v7 = nil
		local v8 = nil

		local function consider(instance)
			-- equivalent call inferred; original call site unknown
			if isEffect(instance) then
				table.insert(instances2, instance)
				enabledsByInstance[instance] = instance.Enabled
			else
				if not (instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture")) then
					return
				end

				table.insert(instances, instance)
				transparenciesByInstance[instance] = instance.Transparency

				if instance:IsA("BasePart") then
					v5[instance] = {
						CanCollide = instance.CanCollide,
						CanQuery = instance.CanQuery
					}
					local cFrame = instance.CFrame
					local halfSize = instance.Size / 2
					local vector = Vector3.new(
						math.abs(cFrame.XVector.X) * halfSize.X + math.abs(cFrame.YVector.X) * halfSize.Y + math.abs(cFrame.ZVector.X) * halfSize.Z,
						math.abs(cFrame.XVector.Y) * halfSize.X + math.abs(cFrame.YVector.Y) * halfSize.Y + math.abs(cFrame.ZVector.Y) * halfSize.Z,
						math.abs(cFrame.XVector.Z) * halfSize.X + math.abs(cFrame.YVector.Z) * halfSize.Y + math.abs(cFrame.ZVector.Z) * halfSize.Z
					)
					local v10

					if v7 then
						v10 = v7:Min(cFrame.Position - vector)
					else
						v10 = cFrame.Position - vector
					end

					v7 = v10
					local v11

					if v8 then
						v11 = v8:Max(cFrame.Position + vector)
					else
						v11 = cFrame.Position + vector
					end

					v8 = v11
				end
			end
		end

		consider(folder)

		for _, descendant in ipairs(folder:GetDescendants()) do
			consider(descendant)
		end

		return {
			instances = instances,
			effects = instances2,
			anchor = v7 and (v7 + v8) / 2
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setPresent(slot, earned: boolean)
		for _, instance in ipairs(slot.instances) do
			local v7 = v5[instance]

			if not v7 then
				continue
			end

			instance.CanCollide = earned and v7.CanCollide
			instance.CanQuery = earned and v7.CanQuery
		end

		for _, effect in ipairs(slot.effects) do
			effect.Enabled = earned and enabledsByInstance[effect]
		end
	end

	local function mapSlots(child4, data)
		local result

		if data.Stages then
			result = {}

			for i, stage in ipairs(data.Stages) do
				result[stage] = i
			end
		else
			result = nil
		end

		local result2 = {}
		local fullNames = {}
		local walk

		walk = function(instance)
			for _, child5 in ipairs(instance:GetChildren()) do
				local v7

				if result then
					v7 = result[child5.Name] ~= nil
				else
					v7 = namesByPiece[child5.Name] == data.Name
				end

				if v7 then
					result2[child5.Name] = claimPiece(child5)
				else
					if child5:IsA("BasePart") or child5:IsA("Decal") or child5:IsA("Texture") then
						table.insert(fullNames, child5:GetFullName())
					end

					walk(child5)
				end
			end
		end

		walk(child4)

		for _, v7 in ipairs(data.Stages or data.Pieces) do
			if not result2[v7] then
				warn(("[CollectionHunting] %s: %s %q has no matching part — it can be earned but will never appear"):format(
					data.Name,
					result and "stage" or "roster piece",
					v7
				))
			end
		end

		if #fullNames > 0 then
			warn(("[CollectionHunting] %s: %d part(s) sit under no slot and show for every player, e.g. %s"):format(
				data.Name,
				#fullNames,
				table.concat(fullNames, ", ", 1, (math.min(#fullNames, 3)))
			))
		end

		return result2, result
	end

	local v7 = {}
	local v8 = {}
	local v9 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterPosition()
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		return humanoidRootPart and humanoidRootPart.Position or nil
	end

	local function updateGhost(state, vector: Vector3?)
		local near

		if vector == nil or state.anchor == nil then
			near = false
		else
			near = (vector - state.anchor).Magnitude <= v.GhostRevealDistance
		end

		if near == state.near then
			return
		end

		state.near = near
		local ghostNearTransparency = near and v.GhostNearTransparency or v.GhostFarTransparency

		for _, instance in ipairs(state.instances) do
			local v11 = tweens[instance]

			if v11 then
				v11:Cancel()
			end

			local tween = TweenService:Create(instance, tweenInfo, {
				Transparency = ghostNearTransparency
			})
			tweens[instance] = tween
			tween:Play()
		end
	end

	local v10 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isFound(model, p: string)
		local attribute = model:GetAttribute(v.FoundAttribute .. p)
		return attribute == nil or attribute == true
	end

	local function heldCount(p)
		local count = 0

		for _, piece in ipairs(p.entry.Pieces) do
			if isFound(p.model, piece) then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isEarned(p, k: string)
		local v11 = p.stageIndex and p.stageIndex[k]

		if v11 then
			return v11 <= heldCount(p)
		end

		return isFound(p.model, k)
	end

	local function renderCollectable(p)
		for k, slot in pairs(p.slots) do
			if v10[slot] then
				continue
			end

			local earned = isEarned(p, k) -- equivalent call inferred; original call site unknown
			setPresent(slot, earned)

			if earned then
				v9[slot] = nil
				slot.near = nil

				for _, instance in ipairs(slot.instances) do
					local transparency = transparenciesByInstance[instance]
					local v12 = tweens[instance]

					if v12 then
						v12:Cancel()
					end

					local tween = TweenService:Create(instance, tweenInfo, {
						Transparency = transparency
					})
					tweens[instance] = tween
					tween:Play()
				end
			else
				v9[slot] = true
				slot.near = nil
				updateGhost(slot, characterPosition())
			end
		end
	end

	local function registerCollectable(collectable)
		local child4 = child2 and child2:FindFirstChild(collectable.Name)

		if not child4 then
			warn(("[CollectionHunting] no model named %q under %s"):format(collectable.Name, v.CollectablesFolder))
			return
		end

		local slots, stageIndex = mapSlots(child4, collectable)
		local v13 = {
			model = child4,
			entry = collectable,
			slots = slots,
			stageIndex = stageIndex
		}
		v7[collectable.Name] = v13

		for _, piece in ipairs(collectable.Pieces) do
			local v14 = v.FoundAttribute .. piece
			child4:GetAttributeChangedSignal(v14):Connect(function()
				renderCollectable(v13)
			end)
			child4:SetAttribute(v14, false)
		end

		child4:SetAttribute(v.CompleteAttribute, false)
		renderCollectable(v13)
	end

	if child2 then
		for _, collectable in ipairs(v.Collectables) do
			registerCollectable(collectable)
		end

		local function makeFlyingToken()
			local token = v.FirstPieceCutscene and v.FirstPieceCutscene.Token
			local v11

			if token then
				v11 = collectPresentationModule()
			else
				v11 = token
			end

			local v12 = v11 and v11.findTemplate(token)

			if not v12 then
				return nil
			end

			local mesh = v11.cloneMesh(v12, token.TokenSize)
			mesh.Name = "HalloweenCutscenePiece"
			return mesh
		end

		local v11 = {}

		local function resolveSlot(name: string)
			local registered = v7[namesByPiece[name] or ""]

			if not registered then
				return nil
			end

			if registered.stageIndex then
				name = registered.entry.Stages[heldCount(registered)]
			end

			local piece = name and registered.slots[name]

			if piece then
				return {
					registered = registered,
					name = name,
					piece = piece
				}
			end

			return nil
		end

		v4 = {
			begin = function(p)
				local slot = resolveSlot(p)
				local piece = slot and slot.piece

				if not (piece and piece.anchor) then
					return nil, nil
				end

				v11[p] = slot
				v10[piece] = true
				v9[piece] = nil
				piece.near = nil

				for _, instance in ipairs(piece.instances) do
					if not v5[instance] then
						continue
					end

					instance.CanCollide = false
					instance.CanQuery = false
				end

				for _, effect in ipairs(piece.effects) do
					effect.Enabled = false
				end

				for _, instance in ipairs(piece.instances) do
					local v12 = tweens[instance]

					if v12 then
						v12:Cancel()
					end

					local tweenInfo2 = TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or tweenInfo
					local tween = TweenService:Create(instance, tweenInfo2, {
						Transparency = 1
					})
					tweens[instance] = tween
					tween:Play()
				end

				local cframe = CFrame.new(piece.anchor)
				local token = v.FirstPieceCutscene and v.FirstPieceCutscene.Token
				local v12

				if token then
					v12 = collectPresentationModule()
				else
					v12 = token
				end

				local v13 = v12 and v12.findTemplate(token)

				if not v13 then
					return cframe, nil
				end

				local mesh = v12.cloneMesh(v13, token.TokenSize)
				mesh.Name = "HalloweenCutscenePiece"
				return cframe, mesh
			end,
			finish = function(p, p2)
				local v12 = v11[p]

				if not v12 then
					return
				end

				local piece = v12.piece
				setPresent(piece, true) -- equivalent call inferred; original call site unknown

				for _, instance in ipairs(piece.instances) do
					fadeTo(instance, transparenciesByInstance[instance], p2)
				end

				piece.near = nil
				v9[piece] = nil
			end,
			preview = function(p, transparency, duration)
				local v12 = v11[p]

				if not v12 then
					return
				end

				local registered = v12.registered
				local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true)
				local slots = {}

				for k, slot in pairs(registered.slots) do
					if slot == v12.piece then
						continue
					end

					-- equivalent call inferred; original call site unknown
					if isEarned(registered, k) then
						continue
					end

					v9[slot] = nil
					table.insert(slots, slot)

					for _, instance in ipairs(slot.instances) do
						local v13 = tweens[instance]

						if v13 then
							v13:Cancel()
						end

						local tween = TweenService:Create(instance, tweenInfo2, {
							Transparency = transparency
						})
						tweens[instance] = tween
						tween:Play()
					end
				end

				if #slots == 0 then
					return
				end

				task.wait(duration * 2)

				for _, v13 in ipairs(slots) do
					v9[v13] = true
					v13.near = nil
					updateGhost(v13, characterPosition())
				end
			end,
			release = function(p)
				local v12 = v11[p]
				v11[p] = nil

				if not v12 then
					return
				end

				v10[v12.piece] = nil
				renderCollectable(v12.registered)
			end
		}
		task.spawn(function()
			while true do
				task.wait(v.GhostPollInterval)
				local v12 = characterPosition() -- equivalent call inferred; original call site unknown

				for k in pairs(v9) do
					updateGhost(k, v12)
				end
			end
		end)
	else
		warn(("[CollectionHunting] %s has no %s folder"):format(v.DecorFolder, v.CollectablesFolder))
	end

	local v11 = {}
	local v12 = {}
	local v13 = nil

	local function addProgressObject(child4)
		local v14 = tonumber(child4.Name:match("^Object(%d+)$"))

		if not v14 or v12[child4] then
			return false
		end

		v12[child4] = v14
		table.insert(v11, child4)
		table.sort(v11, function(a, b)
			return v12[a] < v12[b]
		end)
		return true
	end

	local function renderProgress()
		if not child3 then
			return
		end

		local attribute = child3:GetAttribute(v.PercentageAttribute)
		local v14 = attribute == nil and 100 or tonumber(attribute) or 0
		local revealedCount = HolidayCollectionCore.revealedCount(v14, #v11)

		for i, v15 in ipairs(v11) do
			local parent = i <= revealedCount and child3 or nil

			if v15.Parent ~= parent then
				v15.Parent = parent
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyProgressPercentage()
		if child3 and v13 then
			child3:SetAttribute(v.PercentageAttribute, HolidayCollectionCore.progressPercentage(v13, #v11))
		end
	end

	local function checkKeepsakes()
		for _, v14 in ipairs(v.ProgressKeepsakes or {}) do
			local child4 = child3:FindFirstChild(v14.Object)
			local index = child4 and table.find(v11, child4)

			if child4 then
				if index == HolidayCollectionCore.thresholdOf(v14) then
					if v14.Model and not child4:FindFirstChild(v14.Model, true) then
						warn(("[CollectionHunting] keepsake %s: %s has no %s — the record no longer matches the prop"):format(
							v14.Id,
							v14.Object,
							v14.Model
						))
					end
				else
					warn(("[CollectionHunting] keepsake %s: %s is revealed at %s pieces, not %s — the folder has a gap or a stray name"):format(
						v14.Id,
						v14.Object,
						tostring(index),
						(tostring(HolidayCollectionCore.thresholdOf(v14)))
					))
				end
			else
				warn(("[CollectionHunting] keepsake %s: no %s in %s"):format(
					v14.Id,
					tostring(v14.Object),
					v.ProgressFolder
				))
			end
		end
	end

	if child3 then
		for _, child4 in ipairs(child3:GetChildren()) do
			addProgressObject(child4)
		end

		if #v11 ~= v.MaxCollectionProgress then
			warn(("[CollectionHunting] %s holds %d objects but MaxCollectionProgress is %d — %s"):format(
				v.ProgressFolder,
				#v11,
				v.MaxCollectionProgress,
				#v11 < v.MaxCollectionProgress and "the last pieces will reveal nothing" or "the last objects can never be revealed"
			))
		end

		checkKeepsakes()
		child3.ChildAdded:Connect(function(child4)
			if addProgressObject(child4) then
				applyProgressPercentage() -- equivalent call inferred; original call site unknown
				renderProgress()
			end
		end)
		child3:GetAttributeChangedSignal(v.PercentageAttribute):Connect(renderProgress)
		child3:SetAttribute(v.PercentageAttribute, 0)
		renderProgress()
	else
		warn(("[CollectionHunting] %s has no %s folder"):format(v.DecorFolder, v.ProgressFolder))
	end

	local function applyFound(p)
		v8 = type(p) == "table" and p or {}

		for _, collectable in ipairs(v.Collectables) do
			local v14 = v7[collectable.Name]

			if not v14 then
				continue
			end

			local v15 = type(v8[collectable.Name]) ~= "table" and {} or v8[collectable.Name] or {}

			for _, piece in ipairs(collectable.Pieces) do
				v14.model:SetAttribute(v.FoundAttribute .. piece, v15[piece] ~= nil)
			end

			v14.model:SetAttribute(
				v.CompleteAttribute,
				HolidayCollectionHunting.IsCollectableComplete(v15, collectable.Name)
			)
		end
	end

	local _getDataController = HolidayCollectionHunting._getDataController()

	if not _getDataController then
		return
	end

	_getDataController:onReplicaReady(function(object)
		local progressPath = HolidayCollectionHunting.GetProgressPath()
		local collectablesPath = HolidayCollectionHunting.GetCollectablesPath()

		local function applyProgress(p)
			v13 = HolidayCollectionHunting.ClampProgress(p)

			if child3 then
				if not v13 then
					return
				end

				child3:SetAttribute(v.PercentageAttribute, HolidayCollectionCore.progressPercentage(v13, #v11))
			end
		end

		local data = _getDataController:getDataFromPath(progressPath)
		v13 = HolidayCollectionHunting.ClampProgress(data)
		applyProgressPercentage() -- equivalent call inferred; original call site unknown
		applyFound(_getDataController:getDataFromPath(collectablesPath))
		object:ListenToChange(progressPath, applyProgress)
		object:ListenToChange(collectablesPath, applyFound)
	end, function()
		warn("[CollectionHunting] replica unavailable — falling back to the fully decorated view")

		if child3 then
			child3:SetAttribute(v.PercentageAttribute, nil)
			renderProgress()
		end

		for _, v14 in pairs(v7) do
			for _, piece in ipairs(v14.entry.Pieces) do
				v14.model:SetAttribute(v.FoundAttribute .. piece, nil)
			end

			renderCollectable(v14)
		end
	end)
end

return HolidayCollectionHunting