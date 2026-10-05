local RunService = game:GetService("RunService")
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

		local v = RunService:IsServer() and 5 or 1
		local v2 = moduleScript
		local thread = task.delay(v, function()
			task.spawn(error, (`"{v2.Name}" module took more than {v}s to be required!`))
		end)
		local module = require(moduleScript)
		modulesByName[moduleScript.Name] = module

		if coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
		end
	end

	return modulesByName
end

function Loader.LoadDescendantsSafe(folder, callback)
	local result = {}

	for _, moduleScript in folder:GetDescendants() do
		if not (moduleScript:IsA("ModuleScript") and (not callback or callback(moduleScript))) then
			continue
		end

		local v = RunService:IsServer() and 5 or 1
		local v2 = moduleScript
		local thread = task.delay(v, function()
			task.spawn(error, (`"{v2.Name}" module took more than {v}s to be required!`))
		end)
		local success, result2 = pcall(require, moduleScript)

		if success then
			result[moduleScript.Name] = result2

			if coroutine.status(thread) == "suspended" then
				pcall(task.cancel, thread)
			end
		else
			task.spawn(error, (`"{moduleScript.Name}" module failed to be required\n{result2}`))
		end
	end

	return result
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