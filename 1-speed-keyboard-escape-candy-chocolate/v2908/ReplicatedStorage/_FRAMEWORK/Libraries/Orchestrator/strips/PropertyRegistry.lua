local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Parent.types.Authoring)
require(script.Parent.Parent.types.Property)
require(script.Parent.Parent.types.Save)
require(script.Parent.Parent.types.Strip)
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
local PropertyRuntime = require(script.Parent.PropertyRuntime)
local moduleScripts = {}
local modulesByPropertyName = {}
local modulesByPropertyName2 = {}

for _, moduleScript in script.Parent.properties:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		table.insert(moduleScripts, moduleScript)
	end
end

table.sort(moduleScripts, function(a, b)
	return a:GetFullName() < b:GetFullName()
end)

for _, moduleScript in moduleScripts do
	local module = require(moduleScript)
	modulesByPropertyName[module.propertyName] = module
	modulesByPropertyName2[module.propertyName] = module
end

local function copyDefinition(data)
	return {
		stripType = data.stripType,
		propertyName = data.propertyName,
		context = data.context,
		catchUpPolicies = table.clone(data.catchUpPolicies),
		dataTemplate = TableUtils.Copy(data.dataTemplate, true),
		supportsGlobal = data.supportsGlobal,
		buildEditor = data.buildEditor,
		supports = data.supports,
		capture = data.capture
	}
end

local PropertyRegistry = {}

function PropertyRegistry.get(p: string)
	return modulesByPropertyName[p]
end

function PropertyRegistry.getAuthoringDefinitions()
	local result = {}

	for _, v in modulesByPropertyName do
		table.insert(result, (copyDefinition(v)))
	end

	table.sort(result, function(a, b)
		return a.propertyName < b.propertyName
	end)
	return result
end

function PropertyRegistry.createRuntime(p, callback)
	local v = modulesByPropertyName2[p.propertyName]

	if v ~= nil then
		return PropertyRuntime.create(v, p, callback)
	end

	error(string.format("Unsupported property '%s'.", p.propertyName))
end

function PropertyRegistry.getAssets(p)
	local v = modulesByPropertyName2[p.propertyName]
	local result = {}

	if v ~= nil and v.playbackMode == "custom" and v.getAssets ~= nil then
		for _, keyframe in p.keyframes do
			for _, v2 in v.getAssets(keyframe.data) do
				table.insert(result, v2)
			end
		end
	end

	return result
end

function PropertyRegistry.preload(p)
	local v = modulesByPropertyName2[p.propertyName]

	if v ~= nil and v.preload ~= nil then
		for _, keyframe in p.keyframes do
			v.preload(keyframe.data)
		end
	end
end

function PropertyRegistry.supportsActor(p: string, p2)
	local v = modulesByPropertyName2[p]

	if v == nil then
		return false
	end

	if v.playbackMode == "action" then
	end

	return v.supports(p2)
end

function PropertyRegistry.validate(p: string, p2)
	local v = modulesByPropertyName[p]

	if v == nil then
		return false, string.format("Unsupported property '%s'.", p)
	end

	if p2 == nil or table.find(v.catchUpPolicies, p2) ~= nil then
		return true, nil
	end

	return false, string.format("%s does not support this catch-up policy.", p)
end

function PropertyRegistry.getDefaultCatchUpPolicy(p: string)
	local v = modulesByPropertyName[p]

	if v == nil then
		return nil
	end

	return v.catchUpPolicies[1]
end

function PropertyRegistry.reconcileData(p: string, p2)
	local v = modulesByPropertyName2[p]

	if v == nil then
		return nil
	end

	return TableUtils.Reconcile(p2, v.dataTemplate)
end

return PropertyRegistry