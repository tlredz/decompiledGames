local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages:WaitForChild("Net"))
local battleRenderer = battleDemo:WaitForChild("BattleRenderer")
local module = require(battleRenderer)
local TemplateLibrary = require(battleRenderer:WaitForChild("TemplateLibrary"))
local CameraShake = require(battleRenderer:WaitForChild("CameraShake"))
local BattlePlaybackController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Battle"):WaitForChild("BattlePlaybackController"))
local HpDisplayFreeze = require(battleDemo:WaitForChild("HpDisplayFreeze"))
local DuelBallBadge = require(battleDemo:WaitForChild("DuelBallBadge"))
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local BattleSettlementEffects = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("BattleSettlementEffects"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local DuelPasserbyHider = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelPasserbyHider"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage2:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
local client = PlayerData.client
local GameModeRegistry = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("GameModeRegistry"))
local ArenaOverride = require(battleDemo:WaitForChild("ArenaOverride"))

local function getCameraVerticalMargin(p)
	if GameModeRegistry.getForTable(p).raceCnId ~= "2v2模式" then
		return 1
	end

	local _2v2 = Config.race.byCnId["2v2模式"]
	local cameraMargin = _2v2 and _2v2.cameraMargin

	if typeof(cameraMargin) == "number" then
		return cameraMargin
	end

	warn((`[DuelMatchClient] Config.race.byCnId["2v2模式"].cameraMargin 无效，回退为 {1}`))
	return 1
end

local v = ReplicatedStorage:WaitForChild("音效素材")
local winner = v:WaitForChild("winner!")
local rdr2losehonorsoundlouder = v:WaitForChild("Rdr2 lose honor sound(louder)")
local defaultRaceAnimation = Config.misc.defaultRaceAnimation

if typeof(defaultRaceAnimation) ~= "string" or defaultRaceAnimation == "" then
	warn("[DuelMatchClient] Config.misc.defaultRaceAnimation 无效，入座默认动作将不可用")
	defaultRaceAnimation = nil
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutQuad(p: number)
	return 1 - (1 - p) * (1 - p)
end

local v2 = ReplicatedStorage:WaitForChild("美术素材")
local v3 = v2:WaitForChild("悬浮UI"):WaitForChild("Rig"):WaitForChild("对局玩家血量")
local v4 = v2:WaitForChild("爆炸特效"):WaitForChild("默认_击杀特效"):WaitForChild("默认_爆炸特效")
local DuelMatchClient = {}
DuelMatchClient.__index = DuelMatchClient

local function findTableById(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local firstChild = Workspace:FindFirstChild("双人对战", true)

	if not firstChild then
		return nil
	end

	for _, model in ipairs(firstChild:GetChildren()) do
		if model:IsA("Model") and (model:GetAttribute("DuelTableId") == value or model.Name == value) then
			return model
		end
	end

	return nil
end

local function resolveTable(model, p)
	if typeof(model) == "Instance" and model:IsA("Model") then
		return model
	end

	return (findTableById(p))
end

local function getAnchor(instance)
	local part = instance:FindFirstChild("棋盘锚点") or instance:FindFirstChild("ArenaAnchor")

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function getCameraMarker(instance)
	local part = instance:FindFirstChild("对战视角", true)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function isTeamTable(instance)
	return GameModeRegistry.isTeamMode(GameModeRegistry.getForTable(instance))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getUserId(value)
	if typeof(value) == "number" then
		return value
	end

	if typeof(value) == "table" and typeof(value.userId) == "number" then
		return value.userId
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayersBySlot(p)
	if typeof(p) == "table" then
		return p
	end

	return {}
end

function DuelMatchClient.new(config, duelTableClient)
	local object = setmetatable({}, DuelMatchClient)
	object.config = config
	object.duelTableClient = duelTableClient
	object.boardTemplate = TemplateLibrary.load(ReplicatedStorage, config).boardTemplate
	object.teamConfigsByMode = {}
	object.autoCameraCFrames = {}
	object.arenas = {}
	object.lastPlayersByTable = {}
	object.lastSettlementByTable = {}
	object.boards = {}
	object.matchFinishedTables = {}
	object.billboards = {}
	object.localPlayingTable = nil
	object.duelAudio = DuelAudioController.new()
	object.cameraState = nil
	object.cameraTween = nil
	object.hpLossCamera = nil
	object.cameraShake = CameraShake.new(config)
	object.pendingHpFreeze = {}
	object.lastHpByUserId = {}
	object.ballInfoByUserId = {}
	object._disconnectUnfreeze = HpDisplayFreeze.onUnfreeze(function()
		for k in pairs(object.ballInfoByUserId) do
			object:_applyBallBadge(k)
		end
	end)
	object.settlementSequences = {}
	object.localSeated = false
	object.hideBallBadges = false
	object.localSeatAnimationTrack = nil
	object.localSeatAnimationLoading = false
	object.passerbyHider = DuelPasserbyHider.new()
	object.hiddenOpponentHumanoids = {}
	object._duelLodAccumulator = 0
	Net:Connect("DuelTableReplayStream", function(p)
		object:_onReplay(p)
	end)
	Net:Connect("DuelTableState", function(p)
		object:_onState(p)
	end)
	RunService.RenderStepped:Connect(function(dt: number)
		object:_updateCamera(dt)
	end)
	RunService.Heartbeat:Connect(function(dt: number)
		object:_updateDuelLod(dt)
	end)
	return object
end

function DuelMatchClient:_updateDuelLod(p: number)
	local duelLod = self.config.duelLod
	self._duelLodAccumulator += p

	if self._duelLodAccumulator < duelLod.reevaluateInterval then
		return
	end

	self._duelLodAccumulator = 0
	local localPlayingTable = self.localPlayingTable

	if localPlayingTable then
		for k, arena in self.arenas do
			arena.controller:setRenderInterval(k == localPlayingTable and 1 or duelLod.frozenRenderInterval)
		end
	else
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local position = currentCamera.CFrame.Position
		local v5 = duelLod.farDistanceThreshold * duelLod.farDistanceThreshold

		for _, arena in self.arenas do
			local anchor = arena.anchor

			if not (anchor and anchor.Parent) then
				continue
			end

			local vector = anchor.Position - position
			local v6 = v5 < vector:Dot(vector)
			arena.controller:setRenderInterval(not v6 and 1 or duelLod.farRenderInterval)
		end
	end
end

function DuelMatchClient:_getTableConfig(p2)
	local v5 = GameModeRegistry.getForTable(p2)

	if not GameModeRegistry.isTeamMode(v5) then
		return self.config
	end

	local v6 = self.teamConfigsByMode[v5.id]

	if not v6 then
		v6 = ArenaOverride.resolveConfig(self.config, ArenaOverride.buildArenaData(v5))
		self.teamConfigsByMode[v5.id] = v6
	end

	return v6
end

function DuelMatchClient:_getCameraCFrame(instance)
	local part = instance:FindFirstChild("对战视角", true)

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if part then
		return part.CFrame
	end

	if not GameModeRegistry.isTeamMode(GameModeRegistry.getForTable(instance)) then
		return nil
	end

	local autoCameraCFrame = self.autoCameraCFrames[instance]

	if autoCameraCFrame then
		return autoCameraCFrame
	end

	local part2 = instance:FindFirstChild("棋盘锚点") or instance:FindFirstChild("ArenaAnchor")

	if not (part2 and part2:IsA("BasePart")) then
		part2 = nil
	end

	if not part2 then
		return nil
	end

	local currentCamera = Workspace.CurrentCamera
	local fieldOfView = self.cameraState and self.cameraState.fieldOfView or currentCamera and currentCamera.FieldOfView or 70
	local v5 = self:_getTableConfig(instance).arena.size.X / 2 + 0.3
	local cameraMargin

	if GameModeRegistry.getForTable(instance).raceCnId == "2v2模式" then
		local _2v2 = Config.race.byCnId["2v2模式"]
		cameraMargin = _2v2 and _2v2.cameraMargin

		if typeof(cameraMargin) ~= "number" then
			warn((`[DuelMatchClient] Config.race.byCnId["2v2模式"].cameraMargin 无效，回退为 {1}`))
			cameraMargin = 1
		end
	else
		cameraMargin = 1
	end

	local v6 = (v5 + cameraMargin) / math.tan(math.rad(fieldOfView) / 2)
	local v7 = part2.CFrame * CFrame.new(0, 0, -v6) * CFrame.Angles(0, 3.141592653589793, 0)
	self.autoCameraCFrames[instance] = v7
	return v7
end

function DuelMatchClient:_ensureArena(instance)
	local arena = self.arenas[instance]

	if arena then
		return arena
	end

	local part = instance:FindFirstChild("棋盘锚点") or instance:FindFirstChild("ArenaAnchor")

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if not part then
		warn((`[DuelMatchClient] 桌子缺少棋盘锚点: {instance:GetFullName()}`))
		return nil
	end

	local duelTableId = instance:GetAttribute("DuelTableId")

	if typeof(duelTableId) ~= "string" or duelTableId == "" then
		duelTableId = instance.Name
	end

	local renderer = module.new(self:_getTableConfig(instance), {
		instanceId = "Duel_" .. duelTableId,
		arenaCenter = part.Position,
		arenaCFrame = part.CFrame,
		audioMode = "spatial",
		soundGroup = self.duelAudio:getGroup(instance),
		skipBoard = true,
		onCameraImpact = function(p: number, p2)
			if self.localPlayingTable == instance then
				self.cameraShake:trigger(p, p2)
			end
		end,
		showLaunchArrows = true
	})
	renderer:setForceHighlightAllEnemies(isTeamTable(instance))
	local v6 = {
		renderer = renderer,
		controller = BattlePlaybackController.new(self.config, renderer),
		anchor = part
	}
	v6.controller:setOnFinished(function()
		self:_onRoundSettled(instance)
	end)
	self.arenas[instance] = v6
	return v6
end

function DuelMatchClient:_ensureBoard(parent)
	local board = self.boards[parent]

	if board then
		return board
	end

	local part = parent:FindFirstChild("棋盘锚点") or parent:FindFirstChild("ArenaAnchor")

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if not part then
		warn((`[DuelMatchClient] 桌子缺少棋盘锚点: {parent:GetFullName()}`))
		return nil
	end

	local _getTableConfig = self:_getTableConfig(parent)
	local boardTemplate = self.boardTemplate

	if _getTableConfig ~= self.config then
		boardTemplate = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("棋盘"):WaitForChild(_getTableConfig.arena.boardAssetName)
	end

	local boardModel = TemplateLibrary.buildBoardModel(_getTableConfig, boardTemplate, part.CFrame)

	if not boardModel then
		return nil
	end

	boardModel.Parent = parent
	self.boards[parent] = boardModel
	return boardModel
end

function DuelMatchClient:_destroyBoard(p2)
	local board = self.boards[p2]

	if not board then
		return
	end

	board:Destroy()
	self.boards[p2] = nil
end

function DuelMatchClient:_startPasserbyHider(items)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local userIds = { localPlayer.UserId }

	for _, userId in pairs(items) do
		if typeof(userId) ~= "number" then
			if typeof(userId) == "table" and typeof(userId.userId) == "number" then
				userId = userId.userId
			else
				userId = nil
			end
		end

		if userId and userId ~= localPlayer.UserId then
			table.insert(userIds, userId)
		end
	end

	self.passerbyHider:start(userIds)
end

function DuelMatchClient:_hideOpponentNames(items)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local team = nil

	for _, item in pairs(items) do
		local userId = getUserId(item) -- equivalent call inferred; original call site unknown

		if userId == localPlayer.UserId and typeof(item) == "table" then
			team = item.team
		end
	end

	for _, item in pairs(items) do
		local userId = getUserId(item) -- equivalent call inferred; original call site unknown

		if not (userId and userId ~= localPlayer.UserId and (team == nil or typeof(item) ~= "table" or item.team ~= team)) then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(userId)
		local character = playerByUserId and playerByUserId.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not (humanoid and self.hiddenOpponentHumanoids[humanoid] == nil) then
			continue
		end

		self.hiddenOpponentHumanoids[humanoid] = humanoid.DisplayDistanceType
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

function DuelMatchClient:_restoreOpponentNames()
	for k, hiddenOpponentHumanoid in pairs(self.hiddenOpponentHumanoids) do
		if k.Parent then
			k.DisplayDistanceType = hiddenOpponentHumanoid
		end
	end

	table.clear(self.hiddenOpponentHumanoids)
end

function DuelMatchClient:_isLocalParticipant(items)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	for k, userId in pairs(items) do
		if typeof(userId) ~= "number" then
			if typeof(userId) == "table" and typeof(userId.userId) == "number" then
				userId = userId.userId
			else
				userId = nil
			end
		end

		if userId == localPlayer.UserId then
			return k
		end
	end

	return nil
end

function DuelMatchClient:_onReplay(data)
	if typeof(data) ~= "table" or data.kind ~= "replay" then
		return
	end

	local table2 = data.table
	local tableId = data.tableId

	if typeof(table2) ~= "Instance" or not table2:IsA("Model") then
		table2 = findTableById(tableId)
	end

	if not table2 then
		warn("[DuelMatchClient] 回放找不到对应桌子")
		return
	end

	local _ensureArena = self:_ensureArena(table2)

	if not _ensureArena then
		return
	end

	local playersBySlot = getPlayersBySlot(data.players) -- equivalent call inferred; original call site unknown
	self.lastPlayersByTable[table2] = playersBySlot
	local _isLocalParticipant = self:_isLocalParticipant(playersBySlot)
	local teamPlayers

	if typeof(data.teamPlayers) == "table" then
		teamPlayers = data.teamPlayers
	end

	if teamPlayers then
		local localPlayer = Players.LocalPlayer
		_isLocalParticipant = nil

		for k, teamPlayer in pairs(teamPlayers) do
			for _, userId in pairs(teamPlayer) do
				if not localPlayer then
					continue
				end

				if typeof(userId) ~= "number" then
					if typeof(userId) == "table" and typeof(userId.userId) == "number" then
						userId = userId.userId
					else
						userId = nil
					end
				end

				if userId == localPlayer.UserId then
					_isLocalParticipant = k
				end
			end
		end
	end

	local loserUserIds = typeof(data.loserUserIds) ~= "table" and {} or data.loserUserIds
	local isDraw = data.isDraw == true
	local userIds = {}

	if isDraw then
		for _, userId in pairs(playersBySlot) do
			if typeof(userId) ~= "number" then
				if typeof(userId) == "table" and typeof(userId.userId) == "number" then
					userId = userId.userId
				else
					userId = nil
				end
			end

			if userId then
				table.insert(userIds, userId)
			end
		end
	end

	local lastSettlementByTable = self.lastSettlementByTable
	local v6 = {
		loserUserIds = loserUserIds,
		matchFinished = data.matchFinished == true,
		winnerUserId = 0,
		winnerUserIds = 0,
		teamPlayers = 0,
		isDraw = 0,
		drawUserIds = 0
	}
	local winnerUserId

	if typeof(data.winnerUserId) == "number" then
		winnerUserId = data.winnerUserId
	end

	v6.winnerUserId = winnerUserId
	v6.winnerUserIds = typeof(data.winnerUserIds) ~= "table" and {} or data.winnerUserIds
	v6.teamPlayers = teamPlayers
	v6.isDraw = isDraw
	v6.drawUserIds = userIds
	lastSettlementByTable[table2] = v6

	if #loserUserIds > 0 then
		for _, v8 in ipairs(loserUserIds) do
			if typeof(v8) ~= "number" then
				continue
			end

			self.pendingHpFreeze[v8] = true
			HpDisplayFreeze.freeze(v8)
		end
	elseif isDraw then
		for _, v8 in ipairs(userIds) do
			self.pendingHpFreeze[v8] = true
			HpDisplayFreeze.freeze(v8)
		end
	end

	_ensureArena.renderer:setLocalParticipantSlot(_isLocalParticipant)
	_ensureArena.renderer:setParticipantView(_isLocalParticipant ~= nil, "Playing")
	_ensureArena.controller:loadReplay(data)
end

function DuelMatchClient:_destroyArena(p)
	local settlementSequence = self.settlementSequences[p]

	if settlementSequence then
		self.settlementSequences[p] = nil
		settlementSequence.cancel()
	end

	local arena = self.arenas[p]

	if not arena then
		return
	end

	arena.controller:destroy()
	arena.renderer:destroy()
	self.arenas[p] = nil
	self.lastPlayersByTable[p] = nil
	local v5 = self.lastSettlementByTable[p]

	if v5 then
		for _, loserUserId in ipairs(v5.loserUserIds) do
			if typeof(loserUserId) ~= "number" then
				continue
			end

			self.pendingHpFreeze[loserUserId] = nil
			HpDisplayFreeze.unfreeze(loserUserId)
		end

		if v5.drawUserIds then
			for _, drawUserId in ipairs(v5.drawUserIds) do
				self.pendingHpFreeze[drawUserId] = nil
				HpDisplayFreeze.unfreeze(drawUserId)
			end
		end
	end

	self.lastSettlementByTable[p] = nil
end

function DuelMatchClient:_ensureBillboard(p2: number)
	local billboard = self.billboards[p2]
	local playerByUserId = Players:GetPlayerByUserId(p2)
	local character = playerByUserId and playerByUserId.Character
	local head = character and character:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) or billboard and billboard.Parent == head then
		return billboard
	end

	if billboard then
		billboard:Destroy()
	end

	local clone = v3:Clone()
	clone.Name = "DuelRaceHp"
	clone.Adornee = head
	clone.Parent = head
	self.billboards[p2] = clone
	return clone
end

function DuelMatchClient:_setHpText(instance, p: number)
	local label = instance:FindFirstChild("血量爱心")

	if label and label:IsA("TextLabel") then
		local v5 = math.max(0, p)
		label.Text = v5 <= 0 and "💀" or table.concat(table.create(v5, "❤"), " ")
	end
end

function DuelMatchClient:_applyBallBadge(p: number)
	local v5 = self.ballInfoByUserId[p]
	local billboard = self.billboards[p]

	if not (v5 and billboard) then
		return
	end

	local v6 = not self.hideBallBadges and v5.team and DuelBallBadge.SIDE_BY_TEAM[v5.team]

	for _, childName in pairs(DuelBallBadge.SIDE_BY_TEAM) do
		local image = billboard:FindFirstChild(childName)

		if not (image and image:IsA("ImageLabel")) then
			continue
		end

		image.Visible = childName == v6

		if childName == v6 then
			DuelBallBadge.apply(image, v5.roleId, nil)
		end
	end
end

function DuelMatchClient:_readHp(p, p2: number)
	if typeof(p) ~= "table" then
		return 0
	end

	local selected = p[tostring(p2)]

	if typeof(selected) ~= "number" then
		selected = p[p2]
	end

	if typeof(selected) == "number" then
		return selected
	end

	return 0
end

function DuelMatchClient:_isLocalPlayerSeatedAt(items)
	local localPlayer = Players.LocalPlayer

	if not localPlayer or typeof(items) ~= "table" then
		return false
	end

	for _, userId in pairs(items) do
		if typeof(userId) ~= "number" then
			if typeof(userId) == "table" and typeof(userId.userId) == "number" then
				userId = userId.userId
			else
				userId = nil
			end
		end

		if userId == localPlayer.UserId then
			return true
		end
	end

	return false
end

function DuelMatchClient:_ensureLocalSeatAnimation()
	if not defaultRaceAnimation or self.localSeatAnimationTrack or self.localSeatAnimationLoading then
		return
	end

	local equipment = client.equipment()

	if typeof(equipment) == "table" and equipment["飞行器"] then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	self.localSeatAnimationLoading = true
	task.spawn(function()
		local animator = humanoid:WaitForChild("Animator")
		self.localSeatAnimationLoading = false

		if not self.localSeated then
			return
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = defaultRaceAnimation
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		self.localSeatAnimationTrack = track
	end)
end

function DuelMatchClient:_stopLocalSeatAnimation()
	local localSeatAnimationTrack = self.localSeatAnimationTrack
	self.localSeatAnimationTrack = nil

	if localSeatAnimationTrack then
		localSeatAnimationTrack:Stop()
	end
end

function DuelMatchClient:_onState(p)
	if typeof(p) ~= "table" or typeof(p.tables) ~= "table" then
		return
	end

	local table2 = nil
	local hideBallBadges = false

	for _, table3 in pairs(p.tables) do
		if not (typeof(table3) == "table" and self:_isLocalPlayerSeatedAt(table3.seats)) then
			continue
		end

		hideBallBadges = true
		table2 = table3.table
		local tableId = table3.tableId

		if typeof(table2) ~= "Instance" or not table2:IsA("Model") then
			table2 = findTableById(tableId)
		end

		if table2 then
			self.duelAudio:getGroup(table2)
		end

		break
	end

	self.duelAudio:setSeatedTable(table2)

	if hideBallBadges then
		hideBallBadges = not (table2 and GameModeRegistry.isTeamMode(GameModeRegistry.getForTable(table2)))
	end

	self.hideBallBadges = hideBallBadges
	local v7 = {}
	local localSeated = false

	for _, table3 in pairs(p.tables) do
		if typeof(table3) ~= "table" then
			continue
		end

		localSeated = self:_isLocalPlayerSeatedAt(table3.seats) and true or localSeated
		local state = table3.state
		local table4 = table3.table
		local tableId = table3.tableId

		if typeof(table4) ~= "Instance" or not table4:IsA("Model") then
			table4 = findTableById(tableId)
		end

		local v9 = state == "Waiting" or state == "Idle"

		if table4 then
			local v10 = not v9

			if v10 then
				if state == "Countdown" then
					v10 = false
				else
					v10 = not self.matchFinishedTables[table4]
				end
			end

			if v9 then
				self:_destroyBoard(table4)
				self.matchFinishedTables[table4] = nil
			elseif v10 then
				self:_ensureBoard(table4)
			end

			if state ~= "Playing" then
				self:_destroyArena(table4)
			end

			local v11 = self:_isLocalParticipant(getPlayersBySlot(table3.players)) ~= nil

			if v11 and not v9 then
				if self.localPlayingTable ~= table4 then
					self.localPlayingTable = table4
					local playersBySlot = getPlayersBySlot(table3.players) -- equivalent call inferred; original call site unknown
					self:_startPasserbyHider(playersBySlot)
					self:_hideOpponentNames(playersBySlot)
				end
			elseif self.localPlayingTable == table4 and (v9 or not v11) then
				self.localPlayingTable = nil
				self.passerbyHider:stop()
				self:_restoreOpponentNames()
				self:_restoreCamera()
			end
		end

		local v10

		if state == "Waiting" or state == "Idle" then
			v10 = false
		else
			v10 = state ~= "Ended"
		end

		if not v10 then
			continue
		end

		local playersBySlot = getPlayersBySlot(table3.players) -- equivalent call inferred; original call site unknown

		for _, v11 in pairs(playersBySlot) do
			local userId = getUserId(v11) -- equivalent call inferred; original call site unknown

			if not userId then
				continue
			end

			v7[userId] = true
			local playersBySlot2 = getPlayersBySlot(v11) -- equivalent call inferred; original call site unknown
			local ballInfoByUserId = self.ballInfoByUserId
			local team

			if typeof(playersBySlot2.team) == "string" then
				team = playersBySlot2.team
			end

			local roleId

			if DuelBallBadge.shouldShowBall(state) and typeof(playersBySlot2.roleId) == "string" then
				roleId = playersBySlot2.roleId
			end

			ballInfoByUserId[userId] = {
				team = team,
				roleId = roleId
			}
			local _ensureBillboard = self:_ensureBillboard(userId)
			self:_applyBallBadge(userId)
			local _readHp = self:_readHp(table3.hp, userId)
			self.lastHpByUserId[userId] = _readHp

			if not _ensureBillboard then
				continue
			end

			_ensureBillboard.Enabled = true

			if not self.pendingHpFreeze[userId] then
				self:_setHpText(_ensureBillboard, _readHp)
			end
		end
	end

	for k, billboard in pairs(self.billboards) do
		if not v7[k] then
			billboard.Enabled = false
		end
	end

	for k in pairs(self.ballInfoByUserId) do
		if not v7[k] then
			self.ballInfoByUserId[k] = nil
		end
	end

	self.localSeated = localSeated

	if localSeated then
		self:_ensureLocalSeatAnimation()
	else
		self:_stopLocalSeatAnimation()
	end
end

function DuelMatchClient:_onDrawMatchFinished(p, p2)
	local drawUserIds = p2.drawUserIds or {}

	for _, drawUserId in ipairs(drawUserIds) do
		self.pendingHpFreeze[drawUserId] = nil
		HpDisplayFreeze.unfreeze(drawUserId)
		local billboard = self.billboards[drawUserId]

		if billboard then
			self:_setHpText(billboard, 0)
		end
	end

	if p then
		self.matchFinishedTables[p] = true
		self:_destroyBoard(p)
		self:_destroyArena(p)
	end

	if self.duelTableClient then
		self.duelTableClient:showSettlement(p, nil, true)
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer then
		for _, drawUserId in ipairs(drawUserIds) do
			if localPlayer.UserId ~= drawUserId then
				continue
			end

			rdr2losehonorsoundlouder:Play()
			return
		end
	end
end

function DuelMatchClient:_onRoundSettled(p)
	local group = self.duelAudio:getGroup(p)
	local v5 = self.lastSettlementByTable[p]

	if not v5 then
		return
	end

	if v5.isDraw then
		self:_onDrawMatchFinished(p, v5)
	elseif v5.teamPlayers then
		if #v5.loserUserIds > 0 then
			self:_onTeamRoundSettled(p, v5)
		end
	else
		local loserUserId = v5.loserUserIds[1]

		if typeof(loserUserId) ~= "number" then
			return
		end

		local matchFinished = v5.matchFinished
		local winnerUserId = v5.winnerUserId
		local playerByUserId = Players:GetPlayerByUserId(loserUserId)
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local position = humanoidRootPart.Position
			local duelSettlement = self.config.visual.duelSettlement
			local killDeathSettlement = self.config.visual.killDeathSettlement
			local explosionSkinCnId = nil
			local flag = false

			local function onImpact()
				if flag then
					return
				end

				flag = true

				if p then
					self.settlementSequences[p] = nil
				end

				self.pendingHpFreeze[loserUserId] = nil
				HpDisplayFreeze.unfreeze(loserUserId)
				local billboard = self.billboards[loserUserId]

				if billboard then
					self:_setHpText(billboard, self.lastHpByUserId[loserUserId] or 0)
				end

				local skinModel = BattleSettlementEffects.resolveSkinModel(explosionSkinCnId, "爆炸特效", v4)
				local clone = skinModel:Clone()
				DuelAudioController.bindRoot(clone, group)
				clone.Parent = Workspace
				local v6 = p
				local part = v6:FindFirstChild("棋盘锚点") or v6:FindFirstChild("ArenaAnchor")

				if not (part and part:IsA("BasePart")) then
					part = nil
				end

				EffectPlayer.play(
					clone,
					BattleSettlementEffects.alignToArena(skinModel, position, part and part.CFrame)
				)

				if matchFinished and p then
					self.matchFinishedTables[p] = true
					self:_destroyBoard(p)
					self:_destroyArena(p)

					if self.duelTableClient then
						self.duelTableClient:showSettlement(p, winnerUserId and { winnerUserId } or nil)
					end

					local localPlayer = Players.LocalPlayer

					if localPlayer then
						if localPlayer.UserId == winnerUserId then
							winner:Play()
						elseif localPlayer.UserId == loserUserId then
							rdr2losehonorsoundlouder:Play()
						end
					end
				end
			end

			local v6 = p and self.arenas[p]
			local v7 = p and self.lastPlayersByTable[p]
			local v8 = nil

			if v6 and v7 then
				for k, userId in pairs(v7) do
					if typeof(userId) ~= "number" then
						if typeof(userId) == "table" and typeof(userId.userId) == "number" then
							userId = userId.userId
						else
							userId = nil
						end
					end

					if userId ~= loserUserId then
						continue
					end

					v8 = k
					break
				end
			end

			if not (p and v6 and v8) then
				task.delay(self.config.visual.killDeathSettlement.ballKillShakeDuration, onImpact)
				return
			end

			v6.controller:pause()
			local pluckAllBallsForTeam = v6.renderer:pluckAllBallsForTeam(v8)
			local v9 = v8 == "Blue" and "Yellow" or "Blue"
			explosionSkinCnId = v7[v9] and v7[v9].explosionSkinCnId
			local handles = {}
			self.settlementSequences[p] = {
				handles = handles,
				cancel = function()
					for _, v11 in handles do
						if v11 then
							v11.destroy()
						end
					end

					table.clear(handles)
					onImpact()
				end
			}

			local function beginJumpKill()
				task.delay(killDeathSettlement.deathParticleWaitDuration, function()
					if flag then
						return
					end

					local pluckAllBallsForTeam2 = v6.renderer:pluckAllBallsForTeam(v9)
					BattleSettlementEffects.jumpKillWindup(pluckAllBallsForTeam2, v6.anchor.CFrame, function()
						if flag then
							for _, v11 in pluckAllBallsForTeam2 do
								v11:Destroy()
							end
						else
							if #pluckAllBallsForTeam2 == 0 then
								onImpact()
								return
							end

							local _resolveJumpKillBulge, cameraBulge = self:_resolveJumpKillBulge(p, v6.anchor)

							for _, v12 in pluckAllBallsForTeam2 do
								local v13 = v12
								BattleSettlementEffects.flyAndImpact(v12, position, function()
									v13:Destroy()
									onImpact()
								end, {
									duration = duelSettlement.flightDuration,
									arcHeight = duelSettlement.flightArcHeight,
									bulgeVector = _resolveJumpKillBulge,
									cameraBulge = cameraBulge,
									bezierX1 = duelSettlement.flightEaseBezierX1,
									bezierY1 = duelSettlement.flightEaseBezierY1,
									bezierX2 = duelSettlement.flightEaseBezierX2,
									bezierY2 = duelSettlement.flightEaseBezierY2,
									skinCnId = explosionSkinCnId,
									soundGroup = group,
									playImpactEffect = false
								})

								if v12 == pluckAllBallsForTeam2[1] and self.localPlayingTable == p then
									self:_beginCameraFollow(p, position, duelSettlement.flightDuration, matchFinished)
								end
							end
						end
					end, explosionSkinCnId, group)
				end)
			end

			local v11

			if #pluckAllBallsForTeam == 0 then
				v11 = v6.renderer:getLastVanishedBallPosition(v8)
			else
				v11 = nil
			end

			local v12 = BattleSettlementEffects.killShake(pluckAllBallsForTeam, v6.anchor.CFrame, v11, function(p2)
				if flag then
					return
				end

				BattleSettlementEffects.deathEffect(
					pluckAllBallsForTeam,
					p2,
					v11,
					beginJumpKill,
					explosionSkinCnId,
					group,
					v6.anchor.CFrame
				)
			end, explosionSkinCnId, group)

			for _, v13 in v12 do
				table.insert(handles, v13)
			end
		else
			self.pendingHpFreeze[loserUserId] = nil
			HpDisplayFreeze.unfreeze(loserUserId)
		end
	end
end

function DuelMatchClient:_onTeamRoundSettled(p, data)
	local group = self.duelAudio:getGroup(p)
	local duelSettlement = self.config.visual.duelSettlement
	local killDeathSettlement = self.config.visual.killDeathSettlement
	local teamPlayers = data.teamPlayers
	local loserUserIds = data.loserUserIds
	local winnerUserIds = data.winnerUserIds or {}
	local matchFinished = data.matchFinished
	local v5 = nil

	for k, teamPlayer in pairs(teamPlayers) do
		for _, userId in pairs(teamPlayer) do
			if typeof(userId) ~= "number" then
				if typeof(userId) == "table" and typeof(userId.userId) == "number" then
					userId = userId.userId
				else
					userId = nil
				end
			end

			if userId == loserUserIds[1] then
				v5 = k
			end
		end
	end

	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function revealLoserHp(loserUserId: number?)
		if not loserUserId or v6[loserUserId] then
			return
		end

		v6[loserUserId] = true
		self.pendingHpFreeze[loserUserId] = nil
		HpDisplayFreeze.unfreeze(loserUserId)
		local billboard = self.billboards[loserUserId]

		if billboard then
			self:_setHpText(billboard, self.lastHpByUserId[loserUserId] or 0)
		end
	end

	local flag = false

	local function finish()
		if flag then
			return
		end

		flag = true
		self.settlementSequences[p] = nil

		for _, loserUserId in ipairs(loserUserIds) do
			if not loserUserId or v6[loserUserId] then
				continue
			end

			v6[loserUserId] = true
			self.pendingHpFreeze[loserUserId] = nil
			HpDisplayFreeze.unfreeze(loserUserId)
			local billboard = self.billboards[loserUserId]

			if billboard then
				self:_setHpText(billboard, self.lastHpByUserId[loserUserId] or 0)
			end
		end

		if matchFinished then
			self.matchFinishedTables[p] = true
			self:_destroyBoard(p)
			self:_destroyArena(p)

			if self.duelTableClient then
				self.duelTableClient:showSettlement(p, winnerUserIds)
			end

			local localPlayer = Players.LocalPlayer

			if localPlayer then
				if table.find(winnerUserIds, localPlayer.UserId) then
					winner:Play()
				elseif table.find(loserUserIds, localPlayer.UserId) then
					rdr2losehonorsoundlouder:Play()
				end
			end
		end
	end

	local arena = self.arenas[p]

	if not (arena and v5) then
		task.delay(killDeathSettlement.ballKillShakeDuration, finish)
		return
	end

	local v7 = v5 == "Blue" and "Yellow" or "Blue"
	local v8 = teamPlayers[v7] or {}
	local v9 = teamPlayers[v5] or {}
	local explosionSkinCnId = v8[1] and v8[1].explosionSkinCnId
	arena.controller:pause()
	local pluckAllBallsForTeam = arena.renderer:pluckAllBallsForTeam(v5)
	local handles = {}
	self.settlementSequences[p] = {
		handles = handles,
		cancel = function()
			for _, v11 in handles do
				if v11 then
					v11.destroy()
				end
			end

			table.clear(handles)
			finish()
		end
	}

	local function beginJumpKills()
		task.delay(killDeathSettlement.deathParticleWaitDuration, function()
			if flag then
				return
			end

			local v11 = {}
			local v12 = {}

			for k, v13 in pairs(v8) do
				local v14

				if k == 1 then
					v14 = v7
				else
					v14 = string.format("%s#%d", v7, k)
				end

				local pluckAllBallsForOwner = arena.renderer:pluckAllBallsForOwner(v14)

				for _, model in pluckAllBallsForOwner do
					local v16 = {
						model = model,
						skinCnId = v13.explosionSkinCnId,
						loserUserId = 0
					}
					local userId = v9[k]

					if typeof(userId) ~= "number" then
						if typeof(userId) == "table" and typeof(userId.userId) == "number" then
							userId = userId.userId
						else
							userId = nil
						end
					end

					v16.loserUserId = userId
					table.insert(v11, v16)
					v12[k] = true
				end
			end

			for _, v13 in arena.renderer:pluckAllBallsForTeam(v7) do
				v13:Destroy()
			end

			for k, userId in pairs(v9) do
				if v12[k] then
					continue
				end

				if typeof(userId) ~= "number" then
					if typeof(userId) == "table" and typeof(userId.userId) == "number" then
						userId = userId.userId
					else
						userId = nil
					end
				end

				if not userId or v6[userId] then
					continue
				end

				v6[userId] = true
				self.pendingHpFreeze[userId] = nil
				HpDisplayFreeze.unfreeze(userId)
				local billboard = self.billboards[userId]

				if billboard then
					self:_setHpText(billboard, self.lastHpByUserId[userId] or 0)
				end
			end

			if #v11 == 0 then
				finish()
				return
			end

			local count = #v11

			-- equivalent calls inferred from this helper; original call sites unknown
			local function landed()
				count -= 1

				if count <= 0 then
					finish()
				end
			end

			local _resolveJumpKillBulge, cameraBulge = self:_resolveJumpKillBulge(p, arena.anchor)
			local v14 = false

			for _, v15 in v11 do
				local v16 = v15
				BattleSettlementEffects.jumpKillWindup({ v15.model }, arena.anchor.CFrame, function()
					local playerByUserId = v16.loserUserId and Players:GetPlayerByUserId(v16.loserUserId)
					local character = playerByUserId and playerByUserId.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if flag or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						v16.model:Destroy()
						revealLoserHp(v16.loserUserId) -- equivalent call inferred; original call site unknown
						landed() -- equivalent call inferred; original call site unknown
					else
						local position = humanoidRootPart.Position
						BattleSettlementEffects.flyAndImpact(v16.model, position, function()
							v16.model:Destroy()
							revealLoserHp(v16.loserUserId) -- equivalent call inferred; original call site unknown
							local skinModel = BattleSettlementEffects.resolveSkinModel(v16.skinCnId, "爆炸特效", v4)
							local clone = skinModel:Clone()
							DuelAudioController.bindRoot(clone, group)
							clone.Parent = Workspace
							EffectPlayer.play(
								clone,
								BattleSettlementEffects.alignToArena(skinModel, position, arena.anchor.CFrame)
							)
							landed() -- equivalent call inferred; original call site unknown
						end, {
							duration = duelSettlement.flightDuration,
							arcHeight = duelSettlement.flightArcHeight,
							bulgeVector = _resolveJumpKillBulge,
							cameraBulge = cameraBulge,
							bezierX1 = duelSettlement.flightEaseBezierX1,
							bezierY1 = duelSettlement.flightEaseBezierY1,
							bezierX2 = duelSettlement.flightEaseBezierX2,
							bezierY2 = duelSettlement.flightEaseBezierY2,
							skinCnId = v16.skinCnId,
							soundGroup = group,
							playImpactEffect = false
						})

						if not v14 and self.localPlayingTable == p then
							v14 = true
							self:_beginCameraFollow(p, position, duelSettlement.flightDuration, matchFinished)
						end
					end
				end, v15.skinCnId, group)
			end
		end)
	end

	local v11

	if #pluckAllBallsForTeam == 0 then
		v11 = arena.renderer:getLastVanishedBallPosition(v5)
	else
		v11 = nil
	end

	local v12 = BattleSettlementEffects.killShake(pluckAllBallsForTeam, arena.anchor.CFrame, v11, function(p2)
		if flag then
			return
		end

		BattleSettlementEffects.deathEffect(
			pluckAllBallsForTeam,
			p2,
			v11,
			beginJumpKills,
			explosionSkinCnId,
			group,
			arena.anchor.CFrame
		)
	end, explosionSkinCnId, group)

	for _, v13 in v12 do
		table.insert(handles, v13)
	end
end

function DuelMatchClient:_resolveJumpKillBulge(p, instance)
	local duelSettlement = self.config.visual.duelSettlement
	local lookVector = instance.CFrame.LookVector
	local flightCameraBulge = duelSettlement.flightCameraBulge
	local _getCameraCFrame = self:_getCameraCFrame(p)

	if not _getCameraCFrame then
		return lookVector.Unit, flightCameraBulge
	end

	local v5 = _getCameraCFrame.Position - instance.Position

	if lookVector:Dot(v5) < 0 then
		lookVector = -lookVector
	end

	flightCameraBulge = math.min(flightCameraBulge, math.abs((lookVector:Dot(v5))) * 0.6)
	return lookVector.Unit, flightCameraBulge
end

function DuelMatchClient:_beginCameraFollow(tableModel, vector: Vector3, flightDuration: number, flag: boolean)
	local currentCamera = Workspace.CurrentCamera
	local _getCameraCFrame = self:_getCameraCFrame(tableModel)

	if not (currentCamera and _getCameraCFrame) then
		return
	end

	local duelSettlement = self.config.visual.duelSettlement
	local cameraFocusMixFactor = duelSettlement.cameraFocusMixFactor
	local focusCFrame

	if flag then
		focusCFrame = _getCameraCFrame:Lerp(CFrame.lookAt(_getCameraCFrame.Position, vector), cameraFocusMixFactor)
	else
		local vector2 = vector - _getCameraCFrame.Position
		local v6 = _getCameraCFrame.RightVector * vector2:Dot(_getCameraCFrame.RightVector)
		focusCFrame = _getCameraCFrame:Lerp(
			CFrame.new(_getCameraCFrame.Position + v6) * _getCameraCFrame.Rotation,
			cameraFocusMixFactor
		)
	end

	self.hpLossCamera = {
		tableModel = tableModel,
		startTime = os.clock(),
		startFov = currentCamera.FieldOfView,
		targetFov = currentCamera.FieldOfView * duelSettlement.cameraFocusFovScale,
		flightDuration = flightDuration,
		holdDuration = duelSettlement.cameraHoldDuration,
		returnDuration = duelSettlement.cameraReturnDuration,
		focusCFrame = focusCFrame
	}
end

function DuelMatchClient:_restoreCamera()
	local cameraState = self.cameraState
	self.cameraState = nil
	self.cameraTween = nil
	self.hpLossCamera = nil
	self.cameraShake:reset()
	table.clear(self.autoCameraCFrames)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if cameraState then
		currentCamera.CameraType = cameraState.cameraType
		currentCamera.FieldOfView = cameraState.fieldOfView

		if cameraState.cameraSubject then
			currentCamera.CameraSubject = cameraState.cameraSubject
		end
	else
		currentCamera.CameraType = Enum.CameraType.Custom
	end
end

function DuelMatchClient:_updateCamera(p: number)
	local localPlayingTable = self.localPlayingTable

	if not localPlayingTable then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if not self.cameraState then
		self.cameraState = {
			cameraType = currentCamera.CameraType,
			cameraSubject = currentCamera.CameraSubject,
			fieldOfView = currentCamera.FieldOfView
		}
	end

	local _getCameraCFrame = self:_getCameraCFrame(localPlayingTable)

	if not _getCameraCFrame then
		warn((`[DuelMatchClient] 桌子缺少对战视角: {localPlayingTable:GetFullName()}`))
		return
	end

	if not self.cameraTween or self.cameraTween.tableModel ~= localPlayingTable then
		self.cameraTween = {
			tableModel = localPlayingTable,
			startCFrame = currentCamera.CFrame,
			startTime = os.clock()
		}
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	local cameraTween = self.cameraTween
	local v5 = math.clamp((os.clock() - cameraTween.startTime) / 0.5, 0, 1)
	local focusCFrame = cameraTween.startCFrame:Lerp(_getCameraCFrame, easeOutQuad(v5))
	local hpLossCamera = self.hpLossCamera

	if hpLossCamera and (typeof(hpLossCamera.startTime) ~= "number" or typeof(hpLossCamera.flightDuration) ~= "number" or typeof(hpLossCamera.holdDuration) ~= "number" or typeof(hpLossCamera.returnDuration) ~= "number" or typeof(hpLossCamera.startFov) ~= "number" or typeof(hpLossCamera.targetFov) ~= "number" or typeof(hpLossCamera.focusCFrame) ~= "CFrame") then
		self.hpLossCamera = nil
		hpLossCamera = nil
	end

	if hpLossCamera and hpLossCamera.tableModel == localPlayingTable then
		local v6 = os.clock() - hpLossCamera.startTime
		local flightDuration = hpLossCamera.flightDuration
		local v7 = flightDuration + hpLossCamera.holdDuration

		if v7 + hpLossCamera.returnDuration <= v6 then
			currentCamera.FieldOfView = hpLossCamera.startFov
			self.hpLossCamera = nil
		elseif v7 <= v6 then
			local v9 = easeOutQuad(math.clamp((v6 - v7) / hpLossCamera.returnDuration, 0, 1))
			focusCFrame = hpLossCamera.focusCFrame:Lerp(_getCameraCFrame, v9)
			currentCamera.FieldOfView = hpLossCamera.targetFov + (hpLossCamera.startFov - hpLossCamera.targetFov) * v9
		elseif flightDuration <= v6 then
			focusCFrame = hpLossCamera.focusCFrame
			currentCamera.FieldOfView = hpLossCamera.targetFov
		else
			local v9 = easeOutQuad(math.clamp(v6 / flightDuration, 0, 1))
			focusCFrame = _getCameraCFrame:Lerp(hpLossCamera.focusCFrame, v9)
			local v10 = math.clamp(v6 / flightDuration, 0, 1)
			currentCamera.FieldOfView = hpLossCamera.startFov + (hpLossCamera.targetFov - hpLossCamera.startFov) * v10
		end
	end

	currentCamera.CFrame = focusCFrame
	currentCamera.CFrame *= CFrame.new(self.cameraShake:getOffset(p))
	currentCamera.Focus = focusCFrame
end

function DuelMatchClient:destroy()
	self:_restoreCamera()
	self:_stopLocalSeatAnimation()
	self.passerbyHider:stop()
	self:_restoreOpponentNames()

	for _, arena in pairs(self.arenas) do
		arena.controller:destroy()
		arena.renderer:destroy()
	end

	table.clear(self.arenas)

	for _, board in pairs(self.boards) do
		board:Destroy()
	end

	table.clear(self.boards)
	table.clear(self.matchFinishedTables)

	for _, settlementSequence in pairs(self.settlementSequences) do
		settlementSequence.cancel()
	end

	table.clear(self.settlementSequences)

	for _, billboard in pairs(self.billboards) do
		billboard:Destroy()
	end

	table.clear(self.billboards)
	table.clear(self.ballInfoByUserId)
	self._disconnectUnfreeze()
	self.duelAudio:destroy()
end

return DuelMatchClient