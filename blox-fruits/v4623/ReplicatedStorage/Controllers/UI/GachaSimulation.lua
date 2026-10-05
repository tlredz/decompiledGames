local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Net = require(game.ReplicatedStorage.Modules.Net)
local GachaSimulation = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation)
require(game.ReplicatedStorage.Modules.Gacha.SimulationSession)
local boxNames = {}
local v2 = nil
local v3 = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getGuiRoot()
	if RunService:IsRunning() and RunService:IsClient() then
		return (Players.LocalPlayer:WaitForChild("PlayerGui"))
	end

	return game:GetService("CoreGui")
end

local function remote()
	local v4 = v2

	if v4 ~= nil then
		return v4
	end

	local remoteFunction = Net:RemoteFunction("GachaNetworkRF")
	v2 = remoteFunction
	return remoteFunction
end

local function invoke(p)
	local v4 = v2

	if v4 == nil then
		v4 = Net:RemoteFunction("GachaNetworkRF")
		v2 = v4
	end

	local v5 = v4:InvokeServer(p)

	if typeof(v5) == "table" and v5.Disabled == true then
		error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
	end

	return v5
end

local remote2 = {
	solveChances = function(config, flag2: boolean)
		local v6 = v2

		if v6 == nil then
			v6 = Net:RemoteFunction("GachaNetworkRF")
			v2 = v6
		end

		local v7 = v6:InvokeServer({
			Context = "SolveChances",
			Config = config,
			ApplyPity = flag2
		})

		if typeof(v7) == "table" and v7.Disabled == true then
			error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
		end

		if v7 == nil then
			error("the server would not solve this box; simulation is disabled on a live build")
		end

		local chances = {}

		for k, chance in v7.Chances do
			local v8 = tonumber(k)
			assert(type(v8) == "number", (`couldn't convert str "{k}" to number`))
			chances[v8] = chance
		end

		return chances, v7.SoftPityKey, v7.HardPityKey
	end,
	start = function(config)
		local v6 = v2

		if v6 == nil then
			v6 = Net:RemoteFunction("GachaNetworkRF")
			v2 = v6
		end

		local v7 = v6:InvokeServer({
			Context = "StartSimulation",
			Config = config
		})

		if typeof(v7) == "table" and v7.Disabled == true then
			error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
		end

		if typeof(v7) ~= "table" or typeof(v7.JobId) ~= "string" then
			return v7
		end

		if flag then
			pcall(invoke, {
				Context = "CancelSimulation",
				JobId = v7.JobId
			})
			return v7
		else
			v3[v7.JobId] = true
		end

		return v7
	end,
	poll = function(jobId: string, cursor)
		local v6 = v2

		if v6 == nil then
			v6 = Net:RemoteFunction("GachaNetworkRF")
			v2 = v6
		end

		local v7 = v6:InvokeServer({
			Context = "PollSimulation",
			JobId = jobId,
			Cursor = cursor
		})

		if typeof(v7) == "table" and v7.Disabled == true then
			error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
		end

		if typeof(v7) ~= "table" or v7.Status ~= "Running" then
			v3[jobId] = nil
		end

		return v7
	end,
	cancel = function(jobId: string)
		v3[jobId] = nil
		local v6 = v2

		if v6 == nil then
			v6 = Net:RemoteFunction("GachaNetworkRF")
			v2 = v6
		end

		local v7 = v6:InvokeServer({
			Context = "CancelSimulation",
			JobId = jobId
		})

		if typeof(v7) == "table" and v7.Disabled == true then
			error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
		end
	end
}

local function loadBoxNamesAsync()
	local success, result = pcall(function()
		local v6 = v2

		if v6 == nil then
			v6 = Net:RemoteFunction("GachaNetworkRF")
			v2 = v6
		end

		local v7 = v6:InvokeServer({
			Context = "ListSimulationBoxes"
		})

		if typeof(v7) == "table" and v7.Disabled == true then
			error("gacha simulation is switched off on this build; it only runs where CORE_BRANCH is not live")
		end

		return v7
	end)

	if not success or typeof(result) ~= "table" then
		return
	end

	boxNames = result
end

local class = {}
class.__index = class

function class:Open()
	if self.IsOpen then
		return
	end

	self.IsOpen = true
	self._OnOpen:Fire()
end

function class:Close()
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

return ServiceLocker(function()
	local object = setmetatable({
		_Connections = {},
		IsInitialized = true,
		IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_Callbacks = {}
	}, class)
	local init = Osiris.Init
	local guiRoot = getGuiRoot() -- equivalent call inferred; original call site unknown
	init(guiRoot, nil, true)
	task.spawn(loadBoxNamesAsync)
	local connection = Osiris:Connect(function()
		if not object.IsOpen then
			return
		end

		GachaSimulation({
			Arguments = {
				BoxNames = boxNames
			},
			Remote = remote2
		})
	end)
	table.insert(object._Callbacks, connection)
	local localPlayer = Players.LocalPlayer

	local function syncFromAttribute()
		if localPlayer:GetAttribute("IsGachaSimOpen") == true then
			object:Open()
		else
			object:Close()
		end
	end

	table.insert(
		object._Connections,
		localPlayer:GetAttributeChangedSignal("IsGachaSimOpen"):Connect(syncFromAttribute)
	)

	if localPlayer:GetAttribute("IsGachaSimOpen") == true then
		object:Open()
		return object
	end

	object:Close()
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	for _, _Callback in list._Callbacks do
		local v5 = _Callback
		local success, result = pcall(function()
			v5()
		end)

		if not success then
			warn("Error while cleaning up GachaSimulationController: " .. tostring(result))
		end
	end

	flag = true
	local clone = table.clone(v3)
	table.clear(v3)

	for k in clone do
		pcall(invoke, {
			Context = "CancelSimulation",
			JobId = k
		})
	end

	setmetatable(list, nil)
	table.clear(list)
end)