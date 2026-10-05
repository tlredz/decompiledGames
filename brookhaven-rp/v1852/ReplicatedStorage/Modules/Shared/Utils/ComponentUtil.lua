local ComponentUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.Component)
local TagsUtil = require(ReplicatedStorage.Modules.Shared.Utils.TagsUtil)
local InstantiableComponentsMap = require(ReplicatedStorage.Modules.Shared.Game.InstantiableComponentsMap)
local modulesByChildName = {}
local modulesByChildName2 = {}

function ComponentUtil.GetComponentFromInstance(instance, object, p: number?)
	return object:WaitForInstance(instance, p):catch(function(...)
		if not p then
			warn(...)
			warn("Warn occured on instance:", instance, "- Full name:", instance:GetFullName())
		end
	end):expect()
end

function ComponentUtil.FindAndWaitForAncestorComponent(p, p2: string, object)
	local ancestor = TagsUtil.FindAncestorByTag(p, p2)

	if ancestor then
		return object:WaitForInstance(ancestor):catch(warn):expect()
	end

	return nil
end

function ComponentUtil.FindComponentByAncestor(p, p2: string, object)
	local ancestor = TagsUtil.FindAncestorByTag(p, p2)

	if ancestor then
		return object:FromInstance(ancestor)
	end

	return nil
end

function ComponentUtil.FindAndWaitForComponentByTag(_, childName: string, flag: boolean)
	if flag and modulesByChildName2[childName] then
		return modulesByChildName2[childName]
	end

	if not flag and modulesByChildName[childName] then
		return modulesByChildName[childName]
	end

	if flag then
		local ServerScriptService = game:GetService("ServerScriptService")
		local child = ServerScriptService.Modules.Components:FindFirstChild(childName, true)

		if not child then
			warn(
				"Component class module not found for tag: " .. childName,
				" in context of:",
				flag and "Server" or "Client"
			)
			return nil
		end

		local module = require(child)
		modulesByChildName2[childName] = module
		return module
	else
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local child = ReplicatedStorage2.Modules.Client.Components:FindFirstChild(childName, true)

		if not child then
			warn(
				"Component class module not found for tag: " .. childName,
				" in context of:",
				flag and "Server" or "Client"
			)
			return nil
		end

		local module = require(child)
		modulesByChildName[childName] = module
		return module
	end
end

function ComponentUtil.CloneInstantiableComponent(p)
	local instantiableComponent = InstantiableComponentsMap.GetInstantiableComponent(p)

	if instantiableComponent then
		return instantiableComponent:Clone()
	end

	warn("Component not found: " .. p)
	return nil
end

function ComponentUtil.FindComponentInDescendants(folder, p)
	local components = {}

	for _, descendant in folder:GetDescendants() do
		if not descendant:HasTag(p.Tag) then
			continue
		end

		local component = ComponentUtil.GetComponentFromInstance(descendant, p)

		if component ~= nil then
			table.insert(components, component)
		end
	end

	return components
end

return ComponentUtil