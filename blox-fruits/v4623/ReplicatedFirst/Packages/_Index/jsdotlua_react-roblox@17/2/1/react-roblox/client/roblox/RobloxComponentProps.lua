local __DEV__ = _G.__DEV__
local CollectionService = game:GetService("CollectionService")
local luaupolyfill = require(script.Parent.Parent.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local inspect = luaupolyfill.util.inspect
local shared = require(script.Parent.Parent.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local react = require(script.Parent.Parent.Parent.Parent:WaitForChild("react"))
local shared2 = require(script.Parent.Parent.Parent.Parent:WaitForChild("shared"))
local reactSymbols = shared2.ReactSymbols
local SingleEventManager = require(script.Parent:WaitForChild("SingleEventManager"))
local shared3 = require(script.Parent.Parent.Parent.Parent:WaitForChild("shared"))
local type = shared3.Type
local getDefaultInstanceProperty = require(script.Parent:WaitForChild("getDefaultInstanceProperty"))
require(script.Parent.Parent:WaitForChild("ReactRobloxHostTypes.roblox"))
local react2 = require(script.Parent.Parent.Parent.Parent:WaitForChild("react"))
local tag = react2.Tag
local instanceToEventManager = {}
local instanceToBindings = {}

local function identity(...)
	return ...
end

local function setRobloxInstanceProperty(instance, p, p2)
	if p2 == nil then
		local success, _ = pcall(instance.ResetPropertyToDefault, instance, p)

		if success then
			return
		end

		local v3
		v3, p2 = getDefaultInstanceProperty(instance.ClassName, p)
	end

	instance[p] = p2
end

local function removeBinding(p, p2)
	local v3 = instanceToBindings[p]

	if v3 ~= nil then
		v3[p2]()
		v3[p2] = nil
	end
end

local function attachBinding(instance, p, object2)
	local function updateBoundProperty(p2)
		local v3, v4 = xpcall(setRobloxInstanceProperty, identity, instance, p, p2)

		if not v3 then
			local _source = object2._source or "<enable DEV mode for stack>"
			local v5 = string.format([[
Error updating binding or ref assigned to key %s of '%s' (%s).

Updated value:
  %s

Error:
  %s

%s
]], p, instance.Name, instance.ClassName, tostring(p2), v4, _source)
			console.error(v5)
			error(v5, 0)
		end
	end

	if instanceToBindings[instance] == nil then
		instanceToBindings[instance] = {}
	end

	instanceToBindings[instance][p] = react.__subscribeToBinding(object2, updateBoundProperty)
	updateBoundProperty(object2:getValue())
end

local function applyTags(instance, value: string?, value2: string?)
	if __DEV__ and value2 ~= nil and typeof(value2) ~= "string" then
		console.error([[
Type provided for ReactRoblox.Tag is invalid - tags should be specified as a single string, with individual tags delimited by spaces. Instead received:
%s]], inspect(value2))
		return
	end

	local v3 = {}

	for k in string.gmatch(value or "", "%S+") do
		v3[k] = true
	end

	local v4 = {}

	for k in string.gmatch(value2 or "", "%S+") do
		v4[k] = true
	end

	for tag2, _ in v3 do
		if not v4[tag2] then
			CollectionService:RemoveTag(instance, tag2)
		end
	end

	for tag2, _ in v4 do
		if not v3[tag2] then
			CollectionService:AddTag(instance, tag2)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeAllTags(folder)
	for _, tag2 in CollectionService:GetTags(folder) do
		CollectionService:RemoveTag(folder, tag2)
	end
end

local function applyProp(instance, p, p2, p3)
	local v3 = type.of(p)

	if v3 == type.HostEvent or v3 == type.HostChangeEvent then
		local v4 = instanceToEventManager[instance]

		if v4 == nil then
			v4 = SingleEventManager.new(instance)
			instanceToEventManager[instance] = v4
		end

		local name = p.name

		if v3 == type.HostChangeEvent then
			v4:connectPropertyChange(name, p2)
		else
			v4:connectEvent(name, p2)
		end
	else
		local v4

		if typeof(p2) == "table" then
			v4 = p2["$$typeof"] == reactSymbols.REACT_BINDING_TYPE
		else
			v4 = false
		end

		local v5

		if p3 == nil or typeof(p3) ~= "table" then
			v5 = false
		else
			v5 = p3["$$typeof"] == reactSymbols.REACT_BINDING_TYPE
		end

		if v5 then
			local v6 = instanceToBindings[instance]

			if v6 ~= nil then
				v6[p]()
				v6[p] = nil
			end
		end

		if v4 then
			attachBinding(instance, p, p2)
			return
		end

		if p == tag then
			applyTags(instance, p3, p2)
			return
		end

		if p2 == nil then
			local success, _ = pcall(instance.ResetPropertyToDefault, instance, p)

			if success then
				return
			end

			local v6
			v6, p2 = getDefaultInstanceProperty(instance.ClassName, p)
		end

		instance[p] = p2
	end
end

local function applyProps(p, items)
	for k, item in items do
		if k ~= "ref" and k ~= "children" then
			applyProp(p, k, item)
		end
	end
end

local function safelyApplyProperties(p, list, p2)
	for i = 1, #list, 2 do
		local v3 = list[i]
		local v4 = list[i + 1]

		if v4 == object.None then
			v4 = nil
		end

		if v3 ~= "ref" and v3 ~= "children" then
			applyProp(p, v3, v4, p2[v3])
		end
	end
end

local function cleanupBindings(p)
	local v3 = instanceToBindings[p]

	if v3 ~= nil then
		for _, v4 in v3 do
			v4()
		end

		instanceToBindings[p] = nil
	end
end

local RobloxComponentProps = {}

function RobloxComponentProps.setInitialProperties(instance, _: string, p, _)
	local v3, v4 = xpcall(applyProps, identity, instance, p)

	if not v3 then
		local v5 = string.format([[
Error applying initial props to Roblox Instance '%s' (%s):
  %s
]], instance.Name, instance.ClassName, v4)
		console.error(v5)
		error(v5, 0)
	end

	if instanceToEventManager[instance] ~= nil then
		instanceToEventManager[instance]:resume()
	end
end

function RobloxComponentProps.updateProperties(instance, p, p2)
	if instanceToEventManager[instance] ~= nil then
		instanceToEventManager[instance]:suspend()
	end

	local v3, v4 = xpcall(safelyApplyProperties, identity, instance, p, p2)

	if not v3 then
		local v5 = string.format([[
Error updating props on Roblox Instance '%s' (%s):
  %s
]], instance.Name, instance.ClassName, v4)
		console.error(v5)
		error(v5, 0)
	end

	if instanceToEventManager[instance] ~= nil then
		instanceToEventManager[instance]:resume()
	end
end

function RobloxComponentProps.cleanupHostComponent(folder)
	if instanceToEventManager[folder] ~= nil then
		instanceToEventManager[folder] = nil
	end

	local v3 = instanceToBindings[folder]

	if v3 ~= nil then
		for _, v4 in v3 do
			v4()
		end

		instanceToBindings[folder] = nil
	end

	if typeof(folder) ~= "Instance" then
		return
	end

	removeAllTags(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in folder:GetDescendants() do
		if instanceToEventManager[descendant] ~= nil then
			instanceToEventManager[descendant] = nil
		end

		local v4 = instanceToBindings[descendant]

		if v4 ~= nil then
			for _, v5 in v4 do
				v5()
			end

			instanceToBindings[descendant] = nil
		end

		removeAllTags(folder) -- equivalent call inferred; original call site unknown
	end
end

RobloxComponentProps._instanceToEventManager = instanceToEventManager
RobloxComponentProps._instanceToBindings = instanceToBindings
return RobloxComponentProps