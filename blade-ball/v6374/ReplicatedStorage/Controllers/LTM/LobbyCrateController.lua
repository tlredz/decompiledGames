local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
game:GetService("Players")
local subControllers = script:WaitForChild("SubControllers")
local v = {}

function LoadEventControllers()
	if #v == 0 then
		for _, moduleScript in ipairs((subControllers:GetChildren())) do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local scriptSource = require3(moduleScript)
			table.insert(v, {
				Name = moduleScript.Name,
				ScriptSource = scriptSource,
				_Initialized = false,
				_Started = false
			})
		end
	end

	for _, v2 in ipairs(v) do
		if v2._Initialized or not v2.ScriptSource or not v2.ScriptSource.Init or typeof(v2.ScriptSource.Init) ~= "function" then
			continue
		end

		v2._Initialized = true
		v2.ScriptSource:Init()
	end

	for _, v2 in ipairs(v) do
		if v2._Started or not v2.ScriptSource or not v2.ScriptSource.Start or typeof(v2.ScriptSource.Start) ~= "function" then
			continue
		end

		v2._Started = true
		task.spawn(v2.ScriptSource.Start, v2.ScriptSource)
	end
end

local LobbyCrateController = {}

function LobbyCrateController.Start(_)
	task.wait(2)
	LoadEventControllers()
end

function LobbyCrateController.GetCrateController(_, p: string)
	for _, v2 in ipairs(v) do
		if v2.Name == p then
			return v2.ScriptSource
		end
	end
end

return LobbyCrateController