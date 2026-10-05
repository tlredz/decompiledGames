local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local PartyEvent = require(adminAbuse:WaitForChild("PartyEvent"))
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local CoinBattleLeaderboardUI = require(adminAbuse:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("CoinBattleLeaderboardUI"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local coinBattle = EventsConfig.CoinBattle
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local color = Color3.fromRGB(255, 215, 90)
local uDim = UDim2.fromScale(0, 0.13)
local v = PartyEvent.new({
	DisplayName = coinBattle.DisplayName,
	NeedsDuration = coinBattle.NeedsDuration,
	MaxDurationSeconds = coinBattle.MaxDurationSeconds,
	DefaultDurationSeconds = coinBattle.DefaultDurationSeconds,
	RequiresRespawnRefire = false,
	SkipDoorTransition = coinBattle.SkipDoorTransition,
	IsAdminAbuse = coinBattle.IsAdminAbuse,
	Sounds = coinBattle.Sounds
})

-- equivalent calls inferred from this helper; original call sites unknown
local function fmtClock(p: number)
	local v2 = math.max(0, (math.floor(p)))
	return string.format("%d:%02d", math.floor(v2 / 60), v2 % 60)
end

local function serverNow()
	return workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNotifier()
	return require(ReplicatedStorage:WaitForChild("NotificationSystem"))
end

local function getCoinTemplate()
	local model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):FindFirstChild(coinBattle.CoinModelName)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function getCollectRemote()
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local coinBattleCollect = remotes and remotes:FindFirstChild("CoinBattleCollect")

	if coinBattleCollect and coinBattleCollect:IsA("RemoteEvent") then
		return coinBattleCollect
	end

	return nil
end

local function playWorldSound(soundId: string, position: Vector3?, volume: number, rollOffMinDistance: number, rollOffMaxDistance: number)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = rollOffMinDistance
	sound.RollOffMaxDistance = rollOffMaxDistance
	sound:SetAttribute("IsEventSound", true)

	if position then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(position)
		part.Parent = workspace
		sound.Parent = part
		sound:Play()
		Debris:AddItem(part, 3)
	else
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 3)
	end
end

local function stopAllEmitters(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

local function hideCoinModel(folder)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

local function emitPickupBurst(model)
	local primaryPart = model.PrimaryPart
	local coinPartAttach = primaryPart and primaryPart:FindFirstChild("CoinPartAttach")

	if coinPartAttach then
		for _, emitter in coinPartAttach:GetChildren() do
			if not (emitter:IsA("ParticleEmitter") and (emitter.Name == "CoinsPick" or emitter.Name == "ShinePick")) then
				continue
			end

			local rate = emitter.Rate

			if rate > 0 then
				emitter:Emit(rate)
			end
		end
	end
end

local function isLocalCharacterPart(instance)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function resolveTouchParts(folder)
	local coinPart = folder:FindFirstChild("CoinPart", true)

	if coinPart and coinPart:IsA("BasePart") then
		return { coinPart }
	end

	local primaryPart = folder.PrimaryPart

	if primaryPart then
		return { primaryPart }
	end

	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function bindCoinTouch(object, p: string, clone, maid, p2)
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local coinBattleCollect = remotes and remotes:FindFirstChild("CoinBattleCollect")

	if not (coinBattleCollect and coinBattleCollect:IsA("RemoteEvent")) then
		coinBattleCollect = nil
	end

	for _, v2 in resolveTouchParts(clone) do
		maid:Add(v2.Touched:Connect(function(part)
			if not p2.pendingCollect and part:IsA("BasePart") then
				local localPlayer = Players.LocalPlayer
				local character = localPlayer and localPlayer.Character
				local v3

				if character == nil then
					v3 = false
				else
					v3 = part:IsDescendantOf(character)
				end

				if v3 then
					p2.pendingCollect = true

					if coinBattleCollect then
						coinBattleCollect:FireServer(p)
					end

					local v4 = p
					task.delay(0.25, function()
						local _localCoins = object._localCoins
						local v5 = _localCoins and _localCoins[v4]

						if v5 and v5.pendingCollect and v5.model.Parent then
							v5.pendingCollect = false
						end
					end)
				end
			end
		end))
	end
end

local function checkSpawnPayload(p)
	if type(p) == "table" and type(p.id) == "string" and typeof(p.position) == "Vector3" then
		return true, p.id, p.position
	end

	return false, nil, nil
end

function v:_applyNotificationLayout()
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	local generalNotificationGui = playerGui and playerGui:FindFirstChild("GeneralNotificationGui")

	if generalNotificationGui then
		self._notifGui = generalNotificationGui
		self._notifGuiOrder = generalNotificationGui.DisplayOrder
		generalNotificationGui.DisplayOrder = 50
	end

	local mainFrame = generalNotificationGui and generalNotificationGui:FindFirstChild("MainFrame")

	if mainFrame then
		self._notifMainFrame = mainFrame
		self._notifMainFramePos = mainFrame.Position
		local _notifMainFramePos = self._notifMainFramePos
		mainFrame.Position = UDim2.new(
			_notifMainFramePos.X.Scale,
			_notifMainFramePos.X.Offset,
			_notifMainFramePos.Y.Scale + uDim.Y.Scale,
			_notifMainFramePos.Y.Offset + uDim.Y.Offset
		)
	end
end

function v:_restoreNotificationLayout()
	if self._notifMainFrame and self._notifMainFramePos then
		self._notifMainFrame.Position = self._notifMainFramePos
	end

	if self._notifGui and self._notifGuiOrder ~= nil then
		self._notifGui.DisplayOrder = self._notifGuiOrder
	end

	self._notifGui = nil
	self._notifGuiOrder = nil
	self._notifMainFrame = nil
	self._notifMainFramePos = nil
end

function v:_dismissBoard()
	if self._board then
		self._board:Destroy()
		self._board = nil
	end

	self:_restoreNotificationLayout()
end

function v:_render()
	if self._board and type(self._leaderboard) == "table" then
		local localPlayer = Players.LocalPlayer
		self._board:Update(self._leaderboard, localPlayer and localPlayer.UserId)
	end
end

function v:_updateTimer()
	if not self._board then
		return
	end

	if self._phase == "running" and self._combatEndsAt then
		self._board:SetPhaseText("Time left  " .. fmtClock(self._combatEndsAt - workspace:GetServerTimeNow()))
	elseif self._phase == "ended" then
		self._board:SetPhaseText("Results")
	end
end

function v:_ensureCoinFolder()
	if self._coinFolder and self._coinFolder.Parent then
		return
	end

	local coinBattleCoinsLocal = workspace:FindFirstChild("CoinBattleCoinsLocal")

	if coinBattleCoinsLocal then
		coinBattleCoinsLocal:Destroy()
	end

	self._coinFolder = Instance.new("Folder")
	self._coinFolder.Name = "CoinBattleCoinsLocal"
	self._coinFolder.Parent = workspace
end

function v:_destroyLocalCoin(p2: string, flag: boolean)
	local _localCoins = self._localCoins

	if not _localCoins then
		return
	end

	local _localCoin = _localCoins[p2]

	if not _localCoin then
		return
	end

	_localCoins[p2] = nil

	if flag and _localCoin.model.Parent then
		stopAllEmitters(_localCoin.model)
		hideCoinModel(_localCoin.model)
		emitPickupBurst(_localCoin.model)
		Debris:AddItem(_localCoin.model, coinBattle.PickupDestroyDelaySec)
	else
		_localCoin.model:Destroy()
	end

	if _localCoin.janitor then
		_localCoin.janitor:Cleanup()
	end
end

function v:_clearLocalCoins()
	local _localCoins = self._localCoins

	if not _localCoins then
		return
	end

	for k in _localCoins do
		self:_destroyLocalCoin(k, false)
	end

	table.clear(_localCoins)

	if self._coinFolder then
		self._coinFolder:Destroy()
		self._coinFolder = nil
	end
end

function v:_mountLocalCoin(id: string, position: Vector3, instance)
	self:_ensureCoinFolder()
	local clone = instance:Clone()
	clone.Name = "CoinBattleCoin_" .. id
	local touchParts = resolveTouchParts(clone)
	local v2 = {}

	for _, touchPart in touchParts do
		v2[touchPart] = true
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = v2[part] == true
	end

	local cframe = CFrame.new(position)
	clone:PivotTo(cframe)
	clone.Parent = self._coinFolder
	local maid = Janitor.new()
	local v3 = {
		id = id,
		model = clone,
		baseCf = cframe,
		startTime = os.clock(),
		janitor = maid,
		pendingCollect = false
	}
	self._localCoins[id] = v3
	bindCoinTouch(self, id, clone, maid, v3)
	playWorldSound(
		coinBattle.SpawnSoundId,
		position,
		coinBattle.SpawnSoundVolume,
		coinBattle.SpawnSoundRollOffMin,
		coinBattle.SpawnSoundRollOffMax
	)
	Debris:AddItem(clone, coinBattle.CoinLifetimeSec + 1)
	maid:Add(clone.Destroying:Connect(function()
		local _localCoins = self._localCoins

		if _localCoins then
			_localCoins[id] = nil
		end
	end))
end

function v:_spawnLocalCoin(p)
	local id, position, v2

	if type(p) == "table" and type(p.id) == "string" and typeof(p.position) == "Vector3" then
		id = p.id
		position = p.position
		v2 = true
	else
		v2 = false
	end

	if v2 and self._phase == "running" and id and position and not self._localCoins[id] then
		local model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):FindFirstChild(coinBattle.CoinModelName)

		if not (model and model:IsA("Model")) then
			model = nil
		end

		if model then
			self:_mountLocalCoin(id, position, model)
		end
	end
end

function v:_tickLocalCoins()
	local _localCoins = self._localCoins

	if not _localCoins then
		return
	end

	local hoverBobAmplitude = coinBattle.HoverBobAmplitude
	local hoverBobSpeed = coinBattle.HoverBobSpeed
	local rotateSpeedRad = coinBattle.RotateSpeedRad

	for _, _localCoin in _localCoins do
		local model = _localCoin.model

		if not model.Parent then
			continue
		end

		local v2 = os.clock() - _localCoin.startTime
		local v3 = math.sin(v2 * hoverBobSpeed) * hoverBobAmplitude
		local cframe = CFrame.Angles(0, v2 * rotateSpeedRad, 0)
		model:PivotTo(_localCoin.baseCf * CFrame.new(0, v3, 0) * cframe)
	end
end

function v:OnStart(p, _, _, _)
	self._localCoins = {}
	self._board = CoinBattleLeaderboardUI.new({
		title = "COIN BATTLE"
	})
	local v2 = SharedSyncedEvent.new(coinBattle.SyncChannelName)
	v2:onChange("Leaderboard", function(leaderboard)
		self._leaderboard = leaderboard
		self:_render()
	end)
	v2:onChange("Phase", function(phase)
		self._phase = phase

		if phase == "ended" then
			self:_clearLocalCoins()
			self:_dismissBoard()
		end
	end)
	v2:onChange("CombatEndsAt", function(combatEndsAt)
		self._combatEndsAt = combatEndsAt
	end)
	v2:onFire("Notify", function(p2)
		if type(p2) == "table" and type(p2.text) == "string" then
			local notifier = getNotifier() -- equivalent call inferred; original call site unknown
			notifier:ShowGeneralNotification(p2.text, p2.color or color)
		end
	end)
	v2:onFire("ItemReward", function(data)
		if type(data) == "table" and data.userId == Players.LocalPlayer.UserId and type(data.itemKey) == "string" then
			local rank = tonumber(data.rank)
			local v3

			if rank then
				v3 = string.format("Top %d!", rank)
			end

			local ItemRewardUISystem = require(ReplicatedStorage:WaitForChild("ItemRewardUISystem"))
			ItemRewardUISystem.playForItemKey(data.itemKey, v3)
		end
	end)
	v2:onFire("CoinSpawn", function(p2)
		self:_spawnLocalCoin(p2)
	end)
	v2:onFire("CoinPickup", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			if typeof(p2.position) == "Vector3" then
				playWorldSound(
					coinBattle.PickupSoundId,
					p2.position,
					coinBattle.PickupSoundVolume,
					coinBattle.PickupSoundRollOffMin,
					coinBattle.PickupSoundRollOffMax
				)
			end

			self:_destroyLocalCoin(p2.id, true)
		end
	end)
	v2:onFire("CoinDespawn", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			self:_destroyLocalCoin(p2.id, false)
		end
	end)
	v2:onFire("CoinClear", function()
		self:_clearLocalCoins()
	end)
	self:_applyNotificationLayout()
	self:_render()
	p.janitor:Add(self._board, "Destroy")
	p.janitor:Add(v2, "destroy")
	p.janitor:Add(function()
		self:_clearLocalCoins()
		self._localCoins = nil
	end)
	p.janitor:Add(function()
		self:_restoreNotificationLayout()
	end)
end

function v:OnRender(_, _, _, _, _)
	self:_updateTimer()

	if self._localCoins then
		self:_tickLocalCoins()
	end
end

function v:OnStop(_)
	self:_dismissBoard()
	self._leaderboard = nil
	self._phase = nil
	self._combatEndsAt = nil
end

function v:Fire(...)
	PartyEvent.Fire(self, ...)
	local _activeSession = self._activeSession

	if not _activeSession then
		return
	end

	if _activeSession.connection then
		_activeSession.connection:Disconnect()
	end

	_activeSession.connection = _activeSession.janitor:Add(RunService.RenderStepped:Connect(function()
		if self._activeSession ~= _activeSession then
			return
		end

		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return
		end

		if self.OnRender then
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local currentCamera = workspace.CurrentCamera
			self:OnRender(_activeSession, os.clock(), character, humanoidRootPart, currentCamera)
		end
	end))
end

return v