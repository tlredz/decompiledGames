local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local PartyEvent = require(adminAbuse:WaitForChild("PartyEvent"))
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local VariantBattleLeaderboardUI = require(adminAbuse:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("VariantBattleLeaderboardUI"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local milkBattle = EventsConfig.MilkBattle
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local color = Color3.fromRGB(255, 215, 90)
local uDim = UDim2.fromScale(0, 0.13)
local v = PartyEvent.new({
	DisplayName = milkBattle.DisplayName,
	NeedsDuration = milkBattle.NeedsDuration,
	MaxDurationSeconds = milkBattle.MaxDurationSeconds,
	DefaultDurationSeconds = milkBattle.DefaultDurationSeconds,
	RequiresRespawnRefire = false,
	SkipDoorTransition = milkBattle.SkipDoorTransition,
	IsAdminAbuse = milkBattle.IsAdminAbuse,
	Sounds = milkBattle.Sounds
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
	local model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):FindFirstChild(milkBattle.CoinModelName)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function getCollectRemote()
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local milkBattleCollect = remotes and remotes:FindFirstChild("MilkBattleCollect")

	if milkBattleCollect and milkBattleCollect:IsA("RemoteEvent") then
		return milkBattleCollect
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
	local coinPartAttach = model:FindFirstChild("CoinPartAttach", true)

	if not coinPartAttach then
		return
	end

	for _, emitter in coinPartAttach:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit((math.max(1, (math.floor(emitter.Rate)))))
		end
	end
end

local function isLocalCharacterPart(instance)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function resolveTouchParts(folder)
	local collectHitbox = folder:FindFirstChild("CollectHitbox")

	if collectHitbox and collectHitbox:IsA("BasePart") then
		return { collectHitbox }
	end

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
	local milkBattleCollect = remotes and remotes:FindFirstChild("MilkBattleCollect")

	if not (milkBattleCollect and milkBattleCollect:IsA("RemoteEvent")) then
		milkBattleCollect = nil
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

					if milkBattleCollect then
						milkBattleCollect:FireServer(p)
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

	local milkBattleCoinsLocal = workspace:FindFirstChild("MilkBattleCoinsLocal")

	if milkBattleCoinsLocal and milkBattleCoinsLocal:IsA("Folder") then
		self._coinFolder = milkBattleCoinsLocal
		return
	end

	self._coinFolder = Instance.new("Folder")
	self._coinFolder.Name = "MilkBattleCoinsLocal"
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
		Debris:AddItem(_localCoin.model, milkBattle.PickupDestroyDelaySec)
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

function v:_mountLocalCoin(id: string, position: Vector3, instance, flag: boolean)
	self:_ensureCoinFolder()
	local clone = instance:Clone()
	clone.Name = "MilkBattleCoin_" .. id
	local part = Instance.new("Part")
	part.Name = "CollectHitbox"
	part.Size = createVector(1, 1, 1) * milkBattle.CollectHitboxSizeStuds
	part.CFrame = clone:GetPivot()
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = true
	part.CastShadow = false
	part.Parent = clone
	local touchParts = resolveTouchParts(clone)
	local v2 = {}

	for _, touchPart in touchParts do
		v2[touchPart] = true
	end

	for _, part2 in clone:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = v2[part2] == true
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

	if flag then
		playWorldSound(
			milkBattle.SpawnSoundId,
			position,
			milkBattle.SpawnSoundVolume,
			milkBattle.SpawnSoundRollOffMin,
			milkBattle.SpawnSoundRollOffMax
		)
	end

	Debris:AddItem(clone, milkBattle.CoinLifetimeSec + 1)
	maid:Add(clone.Destroying:Connect(function()
		local _localCoins = self._localCoins

		if _localCoins then
			_localCoins[id] = nil
		end
	end))
end

function v:_spawnLocalCoin(p, flag: boolean?)
	local id, position, v2

	if type(p) == "table" and type(p.id) == "string" and typeof(p.position) == "Vector3" then
		id = p.id
		position = p.position
		v2 = true
	else
		v2 = false
	end

	if not v2 or self._phase == "ended" or not (id and position and self._localCoins) then
		return
	end

	local _localCoin = self._localCoins[id]

	if _localCoin and not _localCoin.model.Parent then
		self:_destroyLocalCoin(id, false)
	end

	if not self._localCoins[id] then
		local model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Events"):FindFirstChild(milkBattle.CoinModelName)

		if not (model and model:IsA("Model")) then
			model = nil
		end

		if model then
			self:_mountLocalCoin(id, position, model, flag ~= false)
		end
	end
end

function v:_reconcileActiveCoins(list)
	if type(list) ~= "table" or self._phase == "ended" or not self._localCoins then
		return
	end

	local v2 = {}

	for _, v3 in ipairs(list) do
		local id, v4

		if type(v3) == "table" and type(v3.id) == "string" and typeof(v3.position) == "Vector3" then
			id = v3.id
			local _ = v3.position
			v4 = true
		else
			v4 = false
		end

		if not (v4 and id) then
			continue
		end

		v2[id] = true
		self:_spawnLocalCoin(v3, false)
	end

	local v3 = {}

	for k in self._localCoins do
		if not v2[k] then
			table.insert(v3, k)
		end
	end

	for _, v4 in v3 do
		self:_destroyLocalCoin(v4, false)
	end
end

function v:_tickLocalCoins()
	local _localCoins = self._localCoins

	if not _localCoins then
		return
	end

	local hoverBobAmplitude = milkBattle.HoverBobAmplitude
	local hoverBobSpeed = milkBattle.HoverBobSpeed
	local rotateSpeedRad = milkBattle.RotateSpeedRad

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
	self._board = VariantBattleLeaderboardUI.new({
		title = "MILK BATTLE",
		accentColor = Color3.fromRGB(225, 247, 255),
		secondaryColor = Color3.fromRGB(92, 190, 255),
		scoreLabel = "MILK",
		icon = "rbxassetid://89445276279968"
	})
	local v2 = {}

	local function connectMilkTool(tool)
		if not tool:IsA("Tool") or tool.Name ~= milkBattle.ToolName or v2[tool] then
			return
		end

		v2[tool] = true
		p.janitor:Add(tool.Activated:Connect(function()
			local notifier = getNotifier() -- equivalent call inferred; original call site unknown
			notifier:ShowGeneralNotification("MILK TIME X2 SPEED!", Color3.fromRGB(235, 245, 255))
		end))
	end

	local backpack = Players.LocalPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, child in backpack:GetChildren() do
			connectMilkTool(child)
		end

		p.janitor:Add(backpack.ChildAdded:Connect(connectMilkTool))
	end

	local v3 = SharedSyncedEvent.new(milkBattle.SyncChannelName)
	v3:onChange("Leaderboard", function(leaderboard)
		self._leaderboard = leaderboard
		self:_render()
	end)
	v3:onChange("Phase", function(phase)
		self._phase = phase

		if phase == "ended" then
			self:_clearLocalCoins()
			self:_dismissBoard()
		end
	end)
	v3:onChange("CombatEndsAt", function(combatEndsAt)
		self._combatEndsAt = combatEndsAt
	end)
	v3:onChange("ActiveCoins", function(p2)
		self:_reconcileActiveCoins(p2)
	end)
	v3:onFire("Notify", function(p2)
		if type(p2) == "table" and type(p2.text) == "string" then
			local notifier = getNotifier() -- equivalent call inferred; original call site unknown
			notifier:ShowGeneralNotification(p2.text, p2.color or color)
		end
	end)
	v3:onFire("ItemReward", function(data)
		if type(data) == "table" and data.userId == Players.LocalPlayer.UserId and type(data.itemKey) == "string" then
			local rank = tonumber(data.rank)
			local v4

			if rank then
				v4 = string.format("Top %d!", rank)
			end

			local ItemRewardUISystem = require(ReplicatedStorage:WaitForChild("ItemRewardUISystem"))
			ItemRewardUISystem.playForItemKey(data.itemKey, v4, (tonumber(data.tier)))
		end
	end)
	v3:onFire("CoinSpawn", function(p2)
		self:_spawnLocalCoin(p2)
	end)
	v3:onFire("CoinPickup", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			if typeof(p2.position) == "Vector3" then
				playWorldSound(
					milkBattle.PickupSoundId,
					p2.position,
					milkBattle.PickupSoundVolume,
					milkBattle.PickupSoundRollOffMin,
					milkBattle.PickupSoundRollOffMax
				)
			end

			self:_destroyLocalCoin(p2.id, true)
		end
	end)
	v3:onFire("CoinDespawn", function(p2)
		if type(p2) == "table" and type(p2.id) == "string" then
			self:_destroyLocalCoin(p2.id, false)
		end
	end)
	v3:onFire("CoinClear", function()
		self:_clearLocalCoins()
	end)
	self:_applyNotificationLayout()
	self:_render()
	p.janitor:Add(self._board, "Destroy")
	p.janitor:Add(v3, "destroy")
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