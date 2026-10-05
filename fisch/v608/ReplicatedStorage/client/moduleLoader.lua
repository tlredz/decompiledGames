local ReplicatedStorage = game:GetService("ReplicatedStorage")
local logger = require(ReplicatedStorage.shared.utils.logger)
local v = {}
local ModuleLoader = {}

function ModuleLoader.init()
	local setup

	setup = function(instance)
		for _, child in instance:GetChildren() do
			local folder = child
			task.spawn(function()
				if folder:IsA("Folder") then
					setup(folder)
					return
				end

				local module = require(folder)

				if not (typeof(module) == "table" and module.init) then
					return
				end

				if typeof(module.init) ~= "function" then
					logger.warn((`{folder.Name}'s init property is not a function`))
					return
				end

				os.clock()
				local name = folder.Name
				v[name] = task.spawn(function()
					debug.setmemorycategory(name)
					module.init()
				end)
				os.clock()
			end)
		end
	end

	setup(script.Parent.modules)
	task.spawn(function()
		while true do
			ModuleLoader._loopThroughServiceThreads()
			task.wait(1)
		end
	end)
end

function ModuleLoader._loopThroughServiceThreads()
	local v2 = {}

	for k, v3 in v do
		if coroutine.status(v3) == "dead" then
			table.insert(v2, k)
		end
	end

	for _, v3 in v2 do
		v[v3] = nil
	end
end

return ModuleLoader