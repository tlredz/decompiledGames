local createVector = vector.create
local Entity = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(script.Parent.Types)
local Config = require(script.Parent.Config)
local Snapshots = require(script.Parent.Snapshots)
local InterpolationMath = require(script.Parent.InterpolationMath)
local ClientClock = require(script.Parent.Parent.Client.ClientClock)
local Holder = require(script.Parent.Holder)
local Signal = require(script.Parent.Signal)
local Events = require(script.Parent.Events)
local ModelHelper = require(script.Parent.ModelHelper)
local Warn = require(script.Parent.Warn)
local velocityAt = InterpolationMath.VelocityAt
local changes = {}
local _clientOwned = Holder._clientOwned
local isServer = RunService:IsServer()
local localPlayer

if isServer then
	localPlayer = nil
else
	localPlayer = Players.LocalPlayer
end

local part = Instance.new("Part")
part.Size = createVector(0.1, 0.1, 0.1)
part.Name = "__CHRONO_CENTER"
part.Anchored = true
part.Transparency = 1
part.CanCollide = false
part.CanTouch = false
part.CanQuery = false

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeDestroy(instance)
	if instance then
		pcall(function()
			instance:Destroy()
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeSetNetworkOwner(object, networkOwner)
	pcall(function()
		object:SetNetworkOwner(networkOwner)
	end)
end

local function GetPart(data)
	local model = data.model

	if not model then
		return nil
	end

	if model:IsA("BasePart") then
		return model
	end

	if not model:IsA("Model") then
		return nil
	end

	local _chronoPrimary = data._chronoPrimary

	if _chronoPrimary then
		local part2 = model:FindFirstChild(_chronoPrimary)

		if part2 and part2:IsA("BasePart") then
			return part2
		else
			Warn.low((`Chrono primary part {_chronoPrimary} not found or not a BasePart in model {model:GetFullName()} for entity id {data.id}. Falling back to default PrimaryPart.`))
		end
	end

	local primaryPart = model.PrimaryPart
	return primaryPart or nil
end

local function GetRootPart(p)
	local primaryPart = Entity.GetPrimaryPart(p)

	if not primaryPart then
		return
	end

	if not (isServer and p._lockedCFReplication) then
		return primaryPart
	end

	local __CHRONO_LOCKER = primaryPart:FindFirstChild("__CHRONO_LOCKER")

	if not __CHRONO_LOCKER then
		return
	end

	local basePart = __CHRONO_LOCKER:FindFirstChildWhichIsA("BasePart")

	if basePart and basePart:IsA("BasePart") then
		return basePart
	end

	return primaryPart
end

local function LockCFReplication(part2)
	if not part2 then
		return
	end

	local cFrame = part2.CFrame
	local __CHRONO_LOCKER = part2:FindFirstChild("__CHRONO_LOCKER")

	if __CHRONO_LOCKER then
		local __CHRONO_WELD = __CHRONO_LOCKER:FindFirstChild("__CHRONO_WELD")

		if __CHRONO_WELD then
			__CHRONO_WELD.Part1 = part2
			part2.CFrame = cFrame
			return __CHRONO_WELD.Part0
		elseif __CHRONO_LOCKER then
			SafeDestroy(true) -- equivalent call inferred; original call site unknown
		end
	end

	local camera = Instance.new("Camera", part2)
	camera.Archivable = false
	camera.Name = "__CHRONO_LOCKER"
	local weld = Instance.new("Weld", camera)
	weld.Name = "__CHRONO_WELD"
	local part3 = Instance.new("Part")
	part3.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
	part3.Name = "__CHRONO_LOCKER_PART"
	part3.Parent = camera
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.Transparency = isServer and 0 or 1
	part3.Color = Color3.new(1, 0, 0)
	part3.Massless = false
	part3.RootPriority = 127
	part3.Size = createVector(0, 0, 0)
	weld.Part0 = part3
	weld.Part1 = part2
	part2.CFrame = cFrame
	return part3
end

local function SetPartCFrame(p, cFrame: CFrame)
	local rootPart = GetRootPart(p)

	if rootPart then
		rootPart.CFrame = cFrame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UnlockCFReplication(instance)
	if not instance then
		return
	end

	local cFrame = instance.CFrame
	local __CHRONO_LOCKER = instance:FindFirstChild("__CHRONO_LOCKER")

	if __CHRONO_LOCKER then
		__CHRONO_LOCKER:Destroy()
		instance.CFrame = cFrame
	end
end

local function SetValue(p, p2: string, p3, flag: boolean?, p4)
	if not flag and p[p2] == p3 then
		return
	end

	p[p2] = p3

	if not isServer then
		return
	end

	if not changes[p] then
		changes[p] = {}
	end

	changes[p][p2] = p4 or p3 or false
end

local function FireEvent(p, p2: string, ...)
	local _events = p._events

	if not _events then
		return
	end

	local _event = _events[p2]

	if _event then
		_event:Fire(p, ...)
	end
end

local function CheckNetworkOwner(state, p)
	state.isContextOwner = state.networkOwner == localPlayer
	local v2 = state.networkOwner == p

	if not v2 then
		state.latestTime = 0
		state.lastClientClock = 0
	end

	if isServer then
		local part2 = GetPart(state)

		if part2 then
			local _lockedCFReplication = state._lockedCFReplication

			if _lockedCFReplication and part2 then
				local cFrame = part2.CFrame
				local __CHRONO_LOCKER = part2:FindFirstChild("__CHRONO_LOCKER")

				if __CHRONO_LOCKER then
					__CHRONO_LOCKER:Destroy()
					part2.CFrame = cFrame
				end
			end

			SafeSetNetworkOwner(part2, state.networkOwner) -- equivalent call inferred; original call site unknown

			if _lockedCFReplication then
				LockCFReplication(part2)
				local rootPart = GetRootPart(state)

				if rootPart then
					SafeSetNetworkOwner(rootPart, state.networkOwner) -- equivalent call inferred; original call site unknown
					rootPart.Anchored = not v2
				end
			end
		end

		if state.isContextOwner and not state.entityConfig.STORE_SNAPSHOTS then
			state.snapshot = nil
		elseif not state.snapshot then
			state.snapshot = Snapshots(InterpolationMath.Hermite)
		end
	elseif state._lockedCFReplication and state.isContextOwner then
		local part2 = GetPart(state)

		if part2 then
			LockCFReplication(part2)
			state._cfLockFailed = nil
		else
			state._cfLockFailed = true
		end

		if state._player and part2 then
			local cFrame = part2.CFrame
			local __CHRONO_LOCKER = part2:FindFirstChild("__CHRONO_LOCKER")

			if __CHRONO_LOCKER then
				__CHRONO_LOCKER:Destroy()
				part2.CFrame = cFrame
			end
		end
	end

	if v2 then
		return
	end

	if state.snapshot then
		state.snapshot:Clear()
	end

	if not isServer then
		if state._clientClock then
			state._clientClock:Destroy()
			state._clientClock = nil
		end

		if state.networkOwner then
			state._clientClock = ClientClock.new(
				state.entityConfig.TICK_RATE,
				`Entity id: {state.id} plr: {state.networkOwner.Name}`,
				nil,
				state.networkOwner
			)
		end
	end

	FireEvent(state, "NetworkOwnerChanged", state.networkOwner, p)
	local v3 = p and _clientOwned[p]

	if v3 then
		v3[state] = nil
		Events._Signals.PlayerOwnedRemoved:Fire(p, state)
	end

	if state.networkOwner then
		local v4 = _clientOwned[state.networkOwner]

		if not v4 then
			return
		end

		v4[state] = true
		Events._Signals.PlayerOwnedAdded:Fire(state.networkOwner, state)
	end
end

function Entity.SyncOwnerShip(p)
	CheckNetworkOwner(p, p.networkOwner)
end

local function CheckModelReplicationMode(state, p)
	local upper = (p or state.modelReplicationMode or state.entityConfig.MODEL_REPLICATION_MODE):upper()

	if upper ~= "NATIVE" and upper ~= "CUSTOM" and upper ~= "NATIVE_WITH_LOCK" then
		Warn.medium((`Invalid model replication mode {upper} for entity id {state.id}, defaulting to NATIVE`))
		upper = "NATIVE"
	end

	state._lockedCFReplication = false

	if upper == "NATIVE_WITH_LOCK" then
		state._lockedCFReplication = true
		upper = "NATIVE"
	end

	return upper
end

local function SetModel(state, modelString, p, flag: boolean?)
	local v2 = state.modelReplicationMode == "CUSTOM"

	if isServer then
		if state.modelReplicationMode == "NATIVE" and state._lockedCFReplication then
			local part2 = GetPart(state)
			state._lockedCFReplication = false
			UnlockCFReplication(part2) -- equivalent call inferred; original call site unknown
		end

		local model = not flag and state.model

		if model then
			SafeDestroy(true) -- equivalent call inferred; original call site unknown
		end

		state.model = nil
	elseif isServer or not v2 then
		if not isServer and state._lockedCFReplication then
			local part2 = GetPart(state)
			state._lockedCFReplication = false
			UnlockCFReplication(part2) -- equivalent call inferred; original call site unknown
		end
	else
		if state.model then
			SafeDestroy(true) -- equivalent call inferred; original call site unknown
		end

		state.model = nil
	end

	local clone

	if type(modelString) == "string" then
		local _GetEntityModel = Config._GetEntityModel(modelString)
		clone = _GetEntityModel and _GetEntityModel:Clone()

		if clone then
			clone.Parent = workspace
		end
	else
		clone = modelString
		modelString = nil
	end

	local _GetBroadPhase = Config._GetBroadPhase(modelString)
	local modelReplicationMode = CheckModelReplicationMode(state, p)
	state.modelString = modelString
	state.model = clone

	if isServer or not state.broadPhase then
		state.broadPhase = _GetBroadPhase
	end

	if clone then
		if modelReplicationMode == "CUSTOM" then
			clone.Parent = Holder.GetEntityStorageInstance()
		end

		local __CHRONO_PRIMARY = clone:GetAttribute("__CHRONO_PRIMARY")

		if __CHRONO_PRIMARY and type(__CHRONO_PRIMARY) == "string" then
			state._chronoPrimary = __CHRONO_PRIMARY
		end
	end

	state.modelReplicationMode = modelReplicationMode
	local part3 = GetPart(state)

	if clone and not part3 then
		(isServer and Warn.high or Warn.low)((`{clone:GetFullName()} must have a PrimaryPart set for things like autoReplication and movement.`))
	elseif clone and not clone.Archivable then
		Warn.low((`{clone:GetFullName()} is not Archivable. It is recommended to set Archivable to true for entity models to prevent potential issues when cloning. Archivable has been set to true automatically.`))
		clone.Archivable = true
	end

	if not part3 then
		return
	end

	local cFrame = part3.CFrame

	if not state.latestCFrame then
		Entity.SetCFrame(state, cFrame or part3.CFrame)
	end

	if state.latestCFrame then
		part3.CFrame = state.latestCFrame
	end

	state.modelReplicationMode = Entity.GetModelReplicationType(state)

	if state.modelReplicationMode == "NATIVE_WITH_LOCK" then
		state._lockedCFReplication = true
		state.modelReplicationMode = "NATIVE"
	end

	if not isServer and not state.isContextOwner and (modelReplicationMode == "CUSTOM" or state._lockedCFReplication) then
		part3.Anchored = true
	end
end

function Entity._new(p: string?, value, p2, cframe: CFrame?)
	local _GetEntityType = Config._GetEntityType(p)

	if not _GetEntityType then
		Warn.medium((`Entity config {p} not found. Using DEFAULT config.`))
		_GetEntityType = Config._GetEntityType("DEFAULT")
	end

	if cframe == nil and typeof(value) == "string" and Config._GetEntityModel(value) == false then
		Warn.medium("Entity's model doesn't exist, initCFrame is required. DEFAULTING to CFrame.new(0, 0, 0)")
		cframe = CFrame.new(0, 0, 0)
	end

	local v2 = {
		id = -1,
		registered = false,
		autoUpdatePosition = _GetEntityType.AUTO_UPDATE_POSITION ~= false,
		isContextOwner = false,
		networkOwner = nil,
		latestCFrame = cframe,
		paused = false,
		entityConfig = _GetEntityType,
		destroyed = false,
		interpolation = not isServer and true
	}

	if localPlayer then
		v2.snapshot = Snapshots(InterpolationMath.Hermite)
	end

	SetModel(v2, value, p2)
	CheckNetworkOwner(v2, nil)
	return v2
end

function Entity.new(p: string?, p2, p3, cframe: CFrame?)
	local _new = Entity._new(p, p2, p3, cframe)
	Holder.RegisterEntity(_new)
	return _new
end

function Entity:SetModel(p, p2, flag: boolean?)
	local model = self.model
	SetModel(self, p, p2, flag)

	if isServer then
		local readyModelFromRep, modelMetaData = ModelHelper.ReadyModelFromRep(self, nil)
		local model2 = self.model
		local v3 = readyModelFromRep or false
		self.model = model2

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].model = v3 or model2 or false
		end

		self._modelMetaData = modelMetaData

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			local v4 = changes[self]

			if not (modelMetaData or modelMetaData) then
				modelMetaData = false
			end

			v4._modelMetaData = modelMetaData
		end

		CheckNetworkOwner(self, self.networkOwner)
	end

	FireEvent(self, "ModelChanged", self.model, model)
end

Entity._FireEvent = FireEvent

function Entity:SetConfig(p2: string)
	local _GetEntityType = Config._GetEntityType(p2)

	if not _GetEntityType then
		Warn.medium((`Entity config {p2} not found. Using Default config.`))
		_GetEntityType = Config._GetEntityType("DEFAULT")
	end

	local NAME = _GetEntityType.NAME

	if self.entityConfig == _GetEntityType then
		return
	end

	self.entityConfig = _GetEntityType

	if not isServer then
		return
	end

	if not changes[self] then
		changes[self] = {}
	end

	changes[self].entityConfig = NAME or _GetEntityType or false
end

function Entity:SetBroadPhase(broadPhase: Vector3?)
	if self.broadPhase == broadPhase then
		return
	end

	self.broadPhase = broadPhase

	if not isServer then
		return
	end

	if not changes[self] then
		changes[self] = {}
	end

	changes[self].broadPhase = broadPhase or false
end

function Entity:GetData()
	return self._data
end

function Entity.GetModel(p)
	return p.model
end

function Entity:SetData(p2)
	self._data = p2

	if isServer then
		if not changes[self] then
			changes[self] = {}
		end

		changes[self]._data = p2 or false
	end

	FireEvent(self, "DataChanged", p2)
end

function Entity:_SetTickMode(isHalfTicked: boolean?)
	if self.isHalfTicked == isHalfTicked then
		return
	end

	if self.isContextOwner then
		self.isHalfTicked = isHalfTicked
	elseif self.isHalfTicked ~= isHalfTicked then
		self.isHalfTicked = isHalfTicked

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].isHalfTicked = isHalfTicked or false
		end
	end

	FireEvent(self, "TickChanged", isHalfTicked == nil and "NONE" or isHalfTicked and "HALF" or "NORMAL")
end

function Entity:ClearMount()
	if not isServer then
		error("ClearMount can only be called on the server")
	end

	if not self.mountParentId then
		return
	end

	if self.mountParentId ~= nil then
		self.mountParentId = nil

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].mountParentId = false
		end
	end

	if self.mountOffset ~= nil then
		self.mountOffset = nil

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].mountOffset = false
		end
	end

	Events._Signals.EntityMountChanged:Fire(self, nil)
end

function Entity:SetMount(p, mountOffset: CFrame?)
	if not isServer then
		error("SetMount can only be called on the server")
	end

	if p == nil then
		return Entity.ClearMount(self)
	end

	if self == p then
		Warn.medium("An entity cannot mount itself")
		return
	end

	if not p.id then
		Warn.high("Parent entity must be registered before mounting")
		return
	end

	local id = p.id

	if self.mountParentId ~= id then
		self.mountParentId = id

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].mountParentId = id or false
		end
	end

	if self.mountOffset ~= mountOffset then
		self.mountOffset = mountOffset

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self].mountOffset = mountOffset or false
		end
	end

	Events._Signals.EntityMountChanged:Fire(self, p.id)
end

Entity["设置网络主控玩家"] = function(state, networkOwner)
	if networkOwner ~= state.networkOwner then
		local networkOwner2 = state.networkOwner

		if state.networkOwner ~= networkOwner then
			state.networkOwner = networkOwner

			if isServer then
				if not changes[state] then
					changes[state] = {}
				end

				changes[state].networkOwner = networkOwner or false
			end
		end

		CheckNetworkOwner(state, networkOwner2)
		Entity.Clear(state)
	end

	state.lastCheckedCFrame = nil
	local v2 = not isServer and state.modelReplicationMode == "CUSTOM" and Entity.GetPrimaryPart(state)

	if v2 then
		v2.Anchored = not state.isContextOwner
	end
end

function Entity:SetNetworkOwner(p)
	if isServer and p ~= self.networkOwner then
		Entity["设置网络主控玩家"](self, p)
		local isHalfTicked = self.isHalfTicked
		self.isHalfTicked = isHalfTicked

		if not isServer then
			return
		end

		if not changes[self] then
			changes[self] = {}
		end

		changes[self].isHalfTicked = isHalfTicked or false
	elseif not isServer then
		error("SetNetworkOwner can only be called on the server")
	end
end

function Entity:Clear()
	local snapshot = self.snapshot
	self.latestTime = nil
	self.lastClientClock = nil

	if snapshot then
		snapshot:Clear()
	end
end

function Entity:PauseReplication()
	if self.paused == true then
		return
	end

	self.paused = true

	if not isServer then
		return
	end

	if not changes[self] then
		changes[self] = {}
	end

	changes[self].paused = true
end

function Entity:ResumeReplication()
	if self.paused == false then
		return
	end

	self.paused = false

	if not isServer then
		return
	end

	if not changes[self] then
		changes[self] = {}
	end

	changes[self].paused = false
end

function Entity:Push(latestTime: number, latestCFrame: CFrame, vector2: Vector3?)
	local snapshot = self.snapshot
	local v2 = not self.latestTime or self.latestTime < latestTime

	if v2 then
		self.latestTime = latestTime
		self.latestCFrame = latestCFrame
	end

	if snapshot then
		local latest = snapshot:GetLatest()

		if not isServer and v2 and latest and latestTime - latest.t < 5 and not self.isContextOwner and math.abs(Entity.GetTargetRenderTime(self) - latest.t) > 5 then
			snapshot:Clear()
			Warn.low("Clearing Snapshot due to large time difference")
		end

		local TICK_RATE = self.entityConfig.TICK_RATE

		if self.isHalfTicked then
			TICK_RATE *= 2
		end

		snapshot:PushWithCheck(
			latestTime,
			latestCFrame,
			vector2 or velocityAt(snapshot:GetLatest(), latestTime, latestCFrame, TICK_RATE),
			TICK_RATE
		)
	end

	FireEvent(self, "PushedSnapShot", latestTime, latestCFrame, v2)
	return v2
end

function Entity:GetAt(p2: number)
	local snapshot = self.snapshot

	if snapshot then
		return snapshot:GetAt(p2)
	end

	return self.latestCFrame
end

function Entity:GetTargetRenderTime()
	local _clientClock = self._clientClock

	if not _clientClock then
		local CLIENT_CLOCK = self.entityConfig.CLIENT_CLOCK

		if not CLIENT_CLOCK then
			return -1
		end

		_clientClock = self.isHalfTicked and CLIENT_CLOCK.HALF or CLIENT_CLOCK.NORMAL
	end

	if _clientClock then
		return _clientClock:GetTargetRenderTime()
	end

	return -1
end

function Entity:SetAutoUpdatePos(autoUpdatePos: boolean)
	if self.autoUpdatePos == autoUpdatePos then
		return
	end

	self.autoUpdatePos = autoUpdatePos

	if not isServer then
		return
	end

	if not changes[self] then
		changes[self] = {}
	end

	changes[self].autoUpdatePos = autoUpdatePos or false
end

function Entity.GetCFrame(p)
	local part2 = GetPart(p)
	return p.latestCFrame or part2 and part2.CFrame
end

function Entity:SetCFrame(cframe: CFrame)
	local lockedTime = (self.latestTime or 0) + 0.00002

	if Config.FLAGS.SET_CFRAME_FIX then
		if isServer or self.networkOwner then
			self._teleport = os.clock()
		end

		if not (isServer or self.isContextOwner) then
			Entity.Clear(self)
		end
	end

	if self.snapshot and Config.FLAGS.FIX_TELEPORT_JITTER then
		self.snapshot.lockedTime = lockedTime
	end

	Entity.Push(self, lockedTime, cframe)
	self.latestCFrame = cframe

	if isServer then
		if not changes[self] then
			changes[self] = {}
		end

		changes[self].latestCFrame = cframe or false
	end

	local v3 = (self.isContextOwner or not isServer) and GetRootPart(self)

	if v3 then
		v3.CFrame = cframe
	end
end

function Entity.GetPrimaryPart(p)
	if p.model then
		return (GetPart(p))
	end

	return nil
end

function Entity:LockNativeServerCFrameReplication()
	if not isServer then
		error("LockNativeServerCFrameReplication can only be called on the server")
		return
	end

	if self.modelReplicationMode ~= "NATIVE" then
		error("LockNativeServerCFrameReplication can only be called on NATIVE model replication mode entities")
	end

	if self._lockedCFReplication then
		return
	end

	if self._lockedCFReplication ~= true then
		self._lockedCFReplication = true

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self]._lockedCFReplication = true
		end
	end

	CheckNetworkOwner(self, self.networkOwner)
	FireEvent(self, "LockChanged", true)
end

function Entity:UnlockNativeServerCFrameReplication()
	if not isServer then
		error("LockNativeServerCFrameReplication can only be called on the server")
		return
	end

	if self.modelReplicationMode ~= "NATIVE" then
		error("LockNativeServerCFrameReplication can only be called on NATIVE model replication mode entities")
	end

	if not self._lockedCFReplication then
		return
	end

	if self._lockedCFReplication ~= false then
		self._lockedCFReplication = false

		if isServer then
			if not changes[self] then
				changes[self] = {}
			end

			changes[self]._lockedCFReplication = false
		end
	end

	UnlockCFReplication(GetPart(self)) -- equivalent call inferred; original call site unknown
	CheckNetworkOwner(self, self.networkOwner)
	FireEvent(self, "LockChanged", false)
end

function Entity:GetModelReplicationType()
	if (self.modelReplicationMode or self.entityConfig.MODEL_REPLICATION_MODE) == "CUSTOM" then
		return "CUSTOM"
	end

	if self._lockedCFReplication then
		return "NATIVE_WITH_LOCK"
	end

	return "NATIVE"
end

function Entity:Destroy()
	self.destroyed = true
	FireEvent(self, "Destroying")
	Holder.UnregisterEntity(self)

	if self._clientClock then
		self._clientClock:Destroy()
	end

	if isServer then
		if self.model then
			SafeDestroy(true) -- equivalent call inferred; original call site unknown
		end
	else
		local modelReplicationMode = self.modelReplicationMode
		local part2 = GetPart(self)

		if modelReplicationMode == "CUSTOM" then
			if self.model then
				SafeDestroy(true) -- equivalent call inferred; original call site unknown
			end
		elseif part2 then
			if self._lockedCFReplication and part2 then
				local cFrame = part2.CFrame
				local __CHRONO_LOCKER = part2:FindFirstChild("__CHRONO_LOCKER")

				if __CHRONO_LOCKER then
					__CHRONO_LOCKER:Destroy()
					part2.CFrame = cFrame
				end
			end

			part2.CFrame = CFrame.new(0, 1000000, 0)
		end
	end

	for _, v2 in self._events or {} do
		v2:DisconnectAll()
	end

	self.model = nil
end

function Entity:GetEvent(p2: string)
	if not self._events then
		self._events = {}
	end

	local _events = self._events

	if not _events[p2] then
		_events[p2] = Signal.new()
	end

	return _events[p2].Event
end

Players.PlayerAdded:Connect(function(player)
	_clientOwned[player] = {}
end)

if Players.LocalPlayer then
	_clientOwned[Players.LocalPlayer] = {}
end

Players.PlayerRemoving:Connect(function(player)
	_clientOwned[player] = nil
end)
Events._Signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"].Event:Connect(SetValue)
Entity._Changes = changes
Entity._GetPart = GetPart
Entity._SetPartCFrame = SetPartCFrame
Entity._GetRootPart = GetRootPart
Entity._LockPartPhysicsReplication = LockCFReplication
Entity._UnlockPartPhysicsReplication = UnlockCFReplication
return Entity