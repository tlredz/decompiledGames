local Loader = {}

function Loader.LoadChildren(instance, callback)
	local modulesByName = {}

	for _, moduleScript in instance:GetChildren() do
		if not (moduleScript:IsA("ModuleScript") and (not callback or callback(moduleScript))) then
			continue
		end

		local module = require(moduleScript)
		modulesByName[moduleScript.Name] = module
	end

	return modulesByName
end

function Loader.LoadDescendants(folder, callback)
	local modulesByName = {}

	for _, moduleScript in folder:GetDescendants() do
		if not (moduleScript:IsA("ModuleScript") and (not callback or callback(moduleScript))) then
			continue
		end

		local module = require(moduleScript)
		modulesByName[moduleScript.Name] = module
	end

	return modulesByName
end

function Loader.MatchesName(p: string)
	return function(p2)
		return p2.Name:match(p) ~= nil
	end
end

function Loader.SpawnAll(items, p: string)
	for k, item in items do
		local v = item[p]

		if type(v) ~= "function" then
			continue
		end

		local v2 = k
		local v3 = v
		local v4 = item
		task.spawn(function()
			debug.setmemorycategory(v2)
			v3(v4)
		end)
	end
end

return Loader