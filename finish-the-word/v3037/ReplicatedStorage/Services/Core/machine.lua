local dictUtil = require(game.ReplicatedStorage.Services.Utility.dictUtil)
local validUtil = require(game.ReplicatedStorage.Services.Utility.validUtil)
local v = {}
local Machine = {
	req = function(child, ...)
		for _, childName in pairs({ ... }) do
			child = child:WaitForChild(childName)
		end

		return require(child)
	end,
	setup = function(...)
		function _G.import(p, p2, p3)
			local v2 = {}

			for _, v3 in pairs(type(p) == "table" and p or { p }) do
				local v4 = v[v3]

				if p2 == false and not v4 then
					return
				end

				assert(v4, "IMPORT: Attempted to import unknown module: " .. v3)
				table.insert(v2, p3 and v4 or require(v4))
			end

			return unpack(v2)
		end

		function _G.fetch(p, p2)
			return _G.import(p, p2, true)
		end

		for _, v2 in pairs({ ... }) do
			dictUtil.runDescendantsOfType(v2, "ModuleScript", function(p)
				assert(not v[p.Name], "IMPORT: Attempted to add known module: " .. p.Name)
				v[p.Name] = p
			end, function(instance)
				return instance.ClassName == "ModuleScript" or instance.Name:sub(1, 1) == "_"
			end)
		end
	end,
	runHandlers = function(instance)
		local v2 = {}

		for _, moduleScript in pairs(instance:GetChildren()) do
			local module = require(moduleScript)
			validUtil.assertFields(module, "Priority", "Run")
			local priority = module.Priority
			local runs = v2[priority] or {}
			runs[#runs + 1] = module.Run
			v2[priority] = runs
		end

		for _, v3 in pairs(v2) do
			local threads = {}

			for _, callback in pairs(v3) do
				local thread = task.spawn(callback)
				threads[#threads + 1] = thread
			end

			while true do
				local flag = true

				for _, v4 in pairs(threads) do
					if coroutine.status(v4) ~= "dead" then
						flag = false
					end
				end

				if flag then
					break
				else
					task.wait()
				end
			end
		end
	end
}
local instancesByChildName = {}

function Machine.load(instance, ...)
	for _, childName in pairs({ ... }) do
		instance = instancesByChildName[childName] or instance:WaitForChild(childName)
		instancesByChildName[childName] = instance
	end

	return require(instance)
end

return Machine