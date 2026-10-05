require(script.Types)
local Iris = {}
local Internal = require(script.Internal)
local internal = Internal(Iris)
Iris.Disabled = false
Iris.Args = {}
Iris.Events = {}

function Iris.Init(playerGui, heartbeat, flag: boolean)
	assert(internal._shutdown == false, "Iris.Init() cannot be called once shutdown.")
	assert(internal._started == false or flag == true, "Iris.Init() can only be called once.")

	if internal._started then
		return Iris
	end

	if playerGui == nil then
		local Players = game:GetService("Players")
		playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	if heartbeat == nil then
		local RunService = game:GetService("RunService")
		heartbeat = RunService.Heartbeat
	end

	internal.parentInstance = playerGui
	internal._started = true
	internal._generateRootInstance()
	internal._generateSelectionImageObject()

	for _, _initFunction in internal._initFunctions do
		_initFunction()
	end

	task.spawn(function()
		if typeof(heartbeat) == "function" then
			while internal._started do
				local v2 = heartbeat()
				internal._cycle(v2)
			end
		elseif heartbeat ~= nil and heartbeat ~= false then
			internal._eventConnection = heartbeat:Connect(function(...)
				internal._cycle(...)
			end)
		end
	end)
	return Iris
end

function Iris.Shutdown()
	internal._started = false
	internal._shutdown = true

	if internal._eventConnection then
		internal._eventConnection:Disconnect()
	end

	internal._eventConnection = nil

	if internal._rootWidget then
		if internal._rootWidget.Instance then
			internal._widgets.Root.Discard(internal._rootWidget)
		end

		internal._rootInstance = nil
	end

	if internal.SelectionImageObject then
		internal.SelectionImageObject:Destroy()
	end

	for _, _connection in internal._connections do
		_connection:Disconnect()
	end
end

function Iris:Connect(callback)
	if internal._started == false then
		warn("Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.")
	end

	local v2 = #internal._connectedFunctions + 1
	internal._connectedFunctions[v2] = callback
	return function()
		internal._connectedFunctions[v2] = nil
	end
end

function Iris:Append()
	local _GetParentWidget = internal._GetParentWidget()
	local parent

	if internal._config.Parent then
		parent = internal._config.Parent
	else
		parent = internal._widgets[_GetParentWidget.type].ChildAdded(_GetParentWidget, {
			type = "userInstance"
		})
	end

	self.Parent = parent
end

function Iris.End()
	if internal._stackIndex == 1 then
		error("Too many calls to Iris.End().", 2)
	end

	internal._IDStack[internal._stackIndex] = nil
	internal._stackIndex -= 1
end

function Iris.ForceRefresh()
	internal._globalRefreshRequested = true
end

function Iris.UpdateGlobalConfig(items)
	for k, item in items do
		internal._rootConfig[k] = item
	end

	Iris.ForceRefresh()
end

function Iris.PushConfig(p)
	local state = Iris.State(-1)

	if state.value == -1 then
		state:set(p)
	elseif internal._deepCompare(state:get(), p) == false then
		state:set(p)
		internal._refreshStack[internal._refreshLevel] = true
		internal._refreshCounter += 1
	end

	internal._refreshLevel += 1
	internal._config = setmetatable(p, {
		__index = internal._config
	})
end

function Iris.PopConfig()
	internal._refreshLevel -= 1

	if internal._refreshStack[internal._refreshLevel] == true then
		internal._refreshCounter -= 1
		internal._refreshStack[internal._refreshLevel] = nil
	end

	internal._config = getmetatable(internal._config).__index
end

Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
internal._globalRefreshRequested = false

function Iris.PushId(value)
	assert(typeof(value) == "string", "The ID argument to Iris.PushId() to be a string.")
	internal._newID = true
	table.insert(internal._pushedIds, value)
end

function Iris.PopId()
	if #internal._pushedIds == 0 then
		return
	end

	table.remove(internal._pushedIds)
end

function Iris.SetNextWidgetID(nextWidgetId)
	internal._nextWidgetId = nextWidgetId
end

function Iris.State(p)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		return internal._states[_getID]
	end

	local v2 = {
		ID = _getID,
		value = p,
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	setmetatable(v2, internal.StateClass)
	internal._states[_getID] = v2
	return v2
end

function Iris.WeakState(p)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		if next(internal._states[_getID].ConnectedWidgets) ~= nil then
			return internal._states[_getID]
		end

		internal._states[_getID] = nil
	end

	local v2 = {
		ID = _getID,
		value = p,
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	setmetatable(v2, internal.StateClass)
	internal._states[_getID] = v2
	return v2
end

function Iris.VariableState(p, callback)
	local _getID = internal._getID(2)
	local _state = internal._states[_getID]

	if _state then
		if p ~= _state.value then
			_state:set(p)
		end

		return _state
	else
		local v2 = {
			ID = _getID,
			value = p,
			lastChangeTick = Iris.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		}
		setmetatable(v2, internal.StateClass)
		internal._states[_getID] = v2
		v2:onChange(callback)
		return v2
	end
end

function Iris:TableState(p2, callback)
	local v2 = self[p2]
	local _getID = internal._getID(2)
	local _state = internal._states[_getID]

	if _state then
		if v2 ~= _state.value then
			_state:set(v2)
		end

		return _state
	else
		local v3 = {
			ID = _getID,
			value = v2,
			lastChangeTick = Iris.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		}
		setmetatable(v3, internal.StateClass)
		internal._states[_getID] = v3
		v3:onChange(function()
			if callback == nil then
				self[p2] = v3.value
			elseif callback(v3.value) then
				self[p2] = v3.value
			end
		end)
		return v3
	end
end

function Iris.ComputedState(object, callback)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		return internal._states[_getID]
	end

	local v2 = {
		ID = _getID,
		value = callback(object.value),
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	setmetatable(v2, internal.StateClass)
	internal._states[_getID] = v2
	object:onChange(function(p)
		v2:set(callback(p))
	end)
	return v2
end

local demoWindow = require(script.demoWindow)
Iris.ShowDemoWindow = demoWindow(Iris)
local widgets = require(script.widgets)
widgets(internal)
local API = require(script.API)
API(Iris)
return Iris