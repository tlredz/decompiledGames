require(script.Types)
local Iris = {}
local Internal = require(script.Internal)
local internal = Internal(Iris)
Iris.Disabled = false
Iris.Args = {}
Iris.Events = {}

function Iris.HasInit()
	return internal._started
end

function Iris.Init(playerGui, heartbeat)
	if playerGui == nil then
		local Players = game:GetService("Players")
		playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	if heartbeat == nil then
		local RunService = game:GetService("RunService")
		heartbeat = RunService.Heartbeat
	end

	internal.parentInstance = playerGui
	assert(internal._started == false, "Iris.Init can only be called once.")
	internal._started = true
	internal._generateRootInstance()
	internal._generateSelectionImageObject()
	task.spawn(function()
		if typeof(heartbeat) == "function" then
			while true do
				heartbeat()
				internal._cycle()
			end
		elseif heartbeat ~= nil then
			heartbeat:Connect(function()
				internal._cycle()
			end)
		end
	end)
	return Iris
end

function Iris:Connect(callback)
	if internal._started == false then
		warn("Iris:Connect() was called before calling Iris.Init(), the connected function will never run")
	end

	table.insert(internal._connectedFunctions, callback)
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
		error("Callback has too many calls to Iris.End()", 2)
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
		internal._localRefreshActive = true
		state:set(p)
	end

	internal._config = setmetatable(p, {
		__index = internal._config
	})
end

function Iris.PopConfig()
	internal._localRefreshActive = false
	internal._config = getmetatable(internal._config).__index
end

Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
internal._globalRefreshRequested = false

function Iris.PushId(value)
	assert(typeof(value) == "string", "Iris expected Iris.PushId id to PushId to be a string.")
	internal._pushedId = tostring(value)
end

function Iris.PopId()
	internal._pushedId = nil
end

function Iris.SetNextWidgetID(nextWidgetId)
	internal._nextWidgetId = nextWidgetId
end

function Iris.State(p)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		return internal._states[_getID]
	end

	internal._states[_getID] = {
		value = p,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	setmetatable(internal._states[_getID], internal.StateClass)
	return internal._states[_getID]
end

function Iris.WeakState(p)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		if #internal._states[_getID].ConnectedWidgets ~= 0 then
			return internal._states[_getID]
		end

		internal._states[_getID] = nil
	end

	internal._states[_getID] = {
		value = p,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	setmetatable(internal._states[_getID], internal.StateClass)
	return internal._states[_getID]
end

function Iris.ComputedState(object, callback)
	local _getID = internal._getID(2)

	if internal._states[_getID] then
		return internal._states[_getID]
	end

	internal._states[_getID] = {
		value = callback(object.value),
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}
	object:onChange(function(p)
		internal._states[_getID]:set(callback(p))
	end)
	setmetatable(internal._states[_getID], internal.StateClass)
	return internal._states[_getID]
end

local demoWindow = require(script.demoWindow)
Iris.ShowDemoWindow = demoWindow(Iris)
print(warn(debug.traceback()))
local widgets = require(script.widgets)
widgets(internal)
local API = require(script.API)
API(Iris)
return Iris