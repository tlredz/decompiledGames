local Binding = require(script.Parent.Binding)
local Children = require(script.Parent.PropMarkers.Children)
local ElementKind = require(script.Parent.ElementKind)
local SingleEventManager = require(script.Parent.SingleEventManager)
local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)
local Ref = require(script.Parent.PropMarkers.Ref)
local Constant = require(script.Parent.PropMarkers.Constant)
local Type = require(script.Parent.Type)
local internalAssert = require(script.Parent.internalAssert)
local GlobalConfig = require(script.Parent.GlobalConfig)
local v = GlobalConfig.get()

local function identity(...)
	return ...
end

local function applyRef(callback, p)
	if callback == nil then
		return
	end

	if typeof(callback) == "function" then
		callback(p)
	elseif Type.of(callback) == Type.Binding then
		Binding.update(callback, p)
	else
		error(("Invalid ref: Expected type Binding but got %s"):format((typeof(callback))))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRobloxInstanceProperty(hostObject, p, p2)
	if p2 == nil then
		local v2
		v2, p2 = getDefaultInstanceProperty(hostObject.ClassName, p)
	end

	hostObject[p] = p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeBinding(state, p)
	state.bindings[p]()
	state.bindings[p] = nil
end

local function attachBinding(state, p, object)
	local function updateBoundProperty(p2)
		if p2 == Constant.SkipBindingUpdate then
			return
		end

		local v2, v3 = xpcall(function()
			setRobloxInstanceProperty(state.hostObject, p, p2) -- equivalent call inferred; original call site unknown
		end, identity)

		if not v2 then
			local source = state.currentElement.source
			local formatted = ([[
Error updating props:
	%s
In element:
%s
]]):format(v3, source == nil and "<enable element tracebacks>" or source)
			error(formatted, 0)
		end
	end

	if state.bindings == nil then
		state.bindings = {}
	end

	state.bindings[p] = Binding.subscribe(object, updateBoundProperty)
	updateBoundProperty(object:getValue())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function detachAllBindings(data)
	if data.bindings ~= nil then
		for _, binding in pairs(data.bindings) do
			binding()
		end

		data.bindings = nil
	end
end

local function applyProp(state, k, p, p2)
	if p == p2 or (k == Ref or k == Children) then
		return
	end

	local v2 = Type.of(k)

	if v2 == Type.HostEvent or v2 == Type.HostChangeEvent then
		if state.eventManager == nil then
			state.eventManager = SingleEventManager.new(state.hostObject)
		end

		local name = k.name

		if v2 == Type.HostChangeEvent then
			state.eventManager:connectPropertyChange(name, p)
		else
			state.eventManager:connectEvent(name, p)
		end
	else
		local v3 = Type.of(p) == Type.Binding

		if Type.of(p2) == Type.Binding then
			removeBinding(state, k) -- equivalent call inferred; original call site unknown
		end

		if v3 then
			attachBinding(state, k, p)
			return
		end

		local hostObject = state.hostObject

		if p == nil then
			local v4
			v4, p = getDefaultInstanceProperty(hostObject.ClassName, k)
		end

		hostObject[k] = p
	end
end

local function applyProps(state, props)
	for k, item in pairs(props) do
		applyProp(state, k, item, nil)
	end
end

local function updateProps(data, props, props2)
	for k, item in pairs(props2) do
		applyProp(data, k, item, props[k])
	end

	for k, item in pairs(props) do
		if props2[k] == nil then
			applyProp(data, k, nil, item)
		end
	end
end

local RobloxRenderer = {}

function RobloxRenderer.isHostObject(instance)
	return typeof(instance) == "Instance"
end

function RobloxRenderer.mountHostNode(p, state)
	local currentElement = state.currentElement
	local hostParent = state.hostParent
	local hostKey = state.hostKey

	if v.internalTypeChecks then
		internalAssert(
			ElementKind.of(currentElement) == ElementKind.Host,
			"Element at given node is not a host Element"
		)
	end

	if v.typeChecks then
		assert(currentElement.props.Name == nil, "Name can not be specified as a prop to a host component in Roact.")
		assert(
			currentElement.props.Parent == nil,
			"Parent can not be specified as a prop to a host component in Roact."
		)
	end

	local instance = Instance.new(currentElement.component)
	state.hostObject = instance
	local v2, v3 = xpcall(function()
		applyProps(state, currentElement.props)
	end, identity)

	if not v2 then
		local source = currentElement.source
		local formatted = ([[
Error applying props:
	%s
In element:
%s
]]):format(v3, source == nil and "<enable element tracebacks>" or source)
		error(formatted, 0)
	end

	instance.Name = tostring(hostKey)
	local v4 = currentElement.props[Children]

	if v4 ~= nil then
		p.updateVirtualNodeWithChildren(state, state.hostObject, v4)
	end

	instance.Parent = hostParent
	state.hostObject = instance
	applyRef(currentElement.props[Ref], instance)

	if state.eventManager ~= nil then
		state.eventManager:resume()
	end
end

function RobloxRenderer.unmountHostNode(p, data)
	applyRef(data.currentElement.props[Ref], nil)

	for _, v2 in pairs(data.children) do
		p.unmountVirtualNode(v2)
	end

	detachAllBindings(data) -- equivalent call inferred; original call site unknown
	data.hostObject:Destroy()
end

function RobloxRenderer.updateHostNode(p, data, p2)
	local props = data.currentElement.props
	local props2 = p2.props

	if data.eventManager ~= nil then
		data.eventManager:suspend()
	end

	if props[Ref] ~= props2[Ref] then
		applyRef(props[Ref], nil)
		applyRef(props2[Ref], data.hostObject)
	end

	local v2, v3 = xpcall(function()
		updateProps(data, props, props2)
	end, identity)

	if not v2 then
		local source = p2.source
		local formatted = ([[
Error updating props:
	%s
In element:
%s
]]):format(v3, source == nil and "<enable element tracebacks>" or source)
		error(formatted, 0)
	end

	local v4 = p2.props[Children]

	if v4 ~= nil or props[Children] ~= nil then
		p.updateVirtualNodeWithChildren(data, data.hostObject, v4)
	end

	if data.eventManager ~= nil then
		data.eventManager:resume()
	end

	return data
end

return RobloxRenderer