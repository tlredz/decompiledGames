local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local Net = require(game.ReplicatedStorage.Modules.Net)
local QATask = require(game.ReplicatedStorage.Definitions.QATask)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("QA"):tag("UI"):tag("Controller"):traceback():display():build()
local QATasks = require(game.ReplicatedStorage.Osiris.Components.QATasks)
local RANK_ATTRIBUTE = QATask.RANK_ATTRIBUTE
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function getGuiRoot()
	if RunService:IsRunning() and RunService:IsClient() then
		return (localPlayer:WaitForChild("PlayerGui"))
	end

	return game:GetService("CoreGui")
end

local function invoke(p)
	local v2 = Net:RemoteFunction(QATask.REQUEST_REMOTE_NAME):InvokeServer(p)

	if v2.Type == "Denied" then
		error(v2.Error)
	end

	assert(v2.Type == p.Type, (`expected a "{p.Type}" response, received "{v2.Type}"`))
	return v2
end

local function sendChatCommand(p: string)
	local textChannels = TextChatService:FindFirstChild("TextChannels")
	local rBXGeneral

	if textChannels then
		rBXGeneral = textChannels:FindFirstChild("RBXGeneral")
	end

	if rBXGeneral and rBXGeneral:IsA("TextChannel") then
		rBXGeneral:SendAsync(p)
	else
		v.warn((`could not find a chat channel to run "{p}"`))
	end
end

local function onChange(fn)
	local onClientEventConnection = Net:RemoteEvent(QATask.CHANGE_REMOTE_NAME).OnClientEvent:Connect(function(p)
		local v2, v3 = QATask.Types.ChangeEvent(p)

		if v2 then
			fn(p)
		else
			v.warn((`bad change event: {v3}`))
		end
	end)
	return function()
		onClientEventConnection:Disconnect()
	end
end

local driver = {
	LocalUserId = localPlayer.UserId,
	getPermissions = function()
		local v3 = invoke({
			Type = "GetPermissions"
		})
		assert(v3.Type == "GetPermissions")
		return v3.Permissions
	end,
	getRoots = function(filter)
		local v3 = invoke({
			Type = "GetTaskTreeRoots",
			Filter = filter
		})
		assert(v3.Type == "GetTaskTreeRoots")
		return v3.Roots, v3.Progress
	end,
	getTask = function(path, filter)
		local v3 = invoke({
			Type = "GetTask",
			Path = path,
			Filter = filter
		})
		assert(v3.Type == "GetTask")
		return v3.Task, v3.Progress
	end,
	getChildren = function(path, filter)
		local v3 = invoke({
			Type = "GetChildrenTasks",
			Path = path,
			Filter = filter
		})
		assert(v3.Type == "GetChildrenTasks")
		return v3.Tasks, v3.Progress
	end,
	getState = function()
		local v3 = invoke({
			Type = "GetState"
		})
		assert(v3.Type == "GetState")
		return v3.Build, v3.Completions, v3.Assignments
	end,
	getProgress = function(paths, filter)
		local v3 = invoke({
			Type = "GetProgress",
			Paths = paths,
			Filter = filter
		})
		assert(v3.Type == "GetProgress")
		return v3.Progress
	end,
	setCompletion = function(path, isCompleted, filter)
		local v3 = invoke({
			Type = "SetTaskCompletion",
			Path = path,
			IsCompleted = isCompleted,
			Filter = filter
		})
		assert(v3.Type == "SetTaskCompletion")
		return v3.DidChange, v3.Current, v3.Record, v3.Progress
	end,
	createTask = function(draft)
		local v3 = invoke({
			Type = "CreateTask",
			Draft = draft
		})
		assert(v3.Type == "CreateTask")
		return v3.Task, v3.Error
	end,
	updateTask = function(path, draft)
		local v3 = invoke({
			Type = "UpdateTask",
			Path = path,
			Draft = draft
		})
		assert(v3.Type == "UpdateTask")
		return v3.Task, v3.Error
	end,
	deleteTask = function(path)
		local v3 = invoke({
			Type = "DeleteTask",
			Path = path
		})
		assert(v3.Type == "DeleteTask")
		return v3.DidDelete, v3.Error
	end,
	resetAll = function(filter)
		local v3 = invoke({
			Type = "ResetAll",
			Filter = filter
		})
		assert(v3.Type == "ResetAll")
		return v3.Count
	end,
	resetSubtree = function(path, filter)
		local v3 = invoke({
			Type = "ResetSubtree",
			Path = path,
			Filter = filter
		})
		assert(v3.Type == "ResetSubtree")
		return v3.Count
	end,
	resetSha = function(sha, filter)
		local v3 = invoke({
			Type = "ResetSha",
			Sha = sha,
			Filter = filter
		})
		assert(v3.Type == "ResetSha")
		return v3.Count
	end,
	getShaSummary = function(filter)
		local v3 = invoke({
			Type = "GetShaSummary",
			Filter = filter
		})
		assert(v3.Type == "GetShaSummary")
		return v3.Entries
	end,
	assignTask = function(path, userId, filter)
		local v3 = invoke({
			Type = "AssignTask",
			Path = path,
			UserId = userId,
			Filter = filter
		})
		assert(v3.Type == "AssignTask")
		return v3.Count, v3.Error
	end,
	getTesters = function()
		local v3 = invoke({
			Type = "GetTesters"
		})
		assert(v3.Type == "GetTesters")
		return v3.Testers
	end,
	runCommand = sendChatCommand,
	onChange = onChange
}
local class = {}
class.__index = class

function class:GetRank()
	local attribute = localPlayer:GetAttribute(RANK_ATTRIBUTE)

	if attribute == "QAAdmin" or attribute == "QATester" then
		return attribute
	end

	return nil
end

function class:Open()
	if self._IsOpen then
		v.trace("already open")
		return
	end

	if self:GetRank() == nil then
		v.trace("no QA rank, refusing to open")
		return
	end

	self._IsOpen = true
	self._OnOpen:Fire()
end

function class:IsOpen()
	return self._IsOpen
end

function class:Close()
	if not self._IsOpen then
		v.trace("already closed")
		return
	end

	self._IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_Callbacks = {},
		_IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new()
	}, class)
	local init = Osiris.Init
	local guiRoot = getGuiRoot() -- equivalent call inferred; original call site unknown
	init(guiRoot, nil, true)
	local state = Osiris.State(false)
	local v3 = {}
	local v4 = nil
	local flag = false
	local v5 = onChange(function(p)
		if p.Type == "OpenMenu" then
			object:Open()
		else
			table.insert(v3, p)
		end
	end)
	table.insert(object._Callbacks, v5)
	local connection = Osiris:Connect(function()
		if object:GetRank() == nil then
			if flag then
				flag = false
				v4 = nil
			end

			if object._IsOpen then
				object:Close()
			end
		else
			if not flag then
				flag = true

				if v4 then
					QATasks.Loader.refreshAll(v4, driver)
				end
			end

			if state:get() ~= object._IsOpen then
				state:set(object._IsOpen)
			end

			local component = QATasks.Component({
				Driver = driver,
				Arguments = {
					Title = "QA Tasks"
				},
				States = {
					isOpen = state
				}
			})
			v4 = component

			if #v3 > 0 then
				for _, v6 in v3 do
					QATasks.Loader.applyChange(component, driver, v6)
				end

				table.clear(v3)
			end

			if not state:get() and object._IsOpen then
				object:Close()
			end
		end
	end)
	table.insert(object._Callbacks, connection)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("QATasks", function()
			return object:Open()
		end, function()
			return object:Close()
		end, function()
			return object:IsOpen()
		end)
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	for _, callback in list._Callbacks do
		local success, result = pcall(callback)

		if not success then
			v.warn((`cleanup failed: {result}`))
		end
	end

	setmetatable(list, nil)
	table.clear(list)
end)