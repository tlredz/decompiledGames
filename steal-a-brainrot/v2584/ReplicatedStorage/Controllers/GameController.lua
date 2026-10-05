game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local v = false
local callbacks = {}
local GameController = {}

function GameController.Start(_)
	task.spawn(function()
		while ReplicatedFirst:GetAttribute("ClientLoaded") ~= true do
			task.wait()
		end

		while ReplicatedFirst:GetAttribute("DataLoaded") ~= true do
			task.wait()
		end

		v = true

		for i = 1, #callbacks do
			local v2 = callbacks[i]
			task.spawn(v2)
		end

		table.clear(callbacks)
	end)
end

function GameController.OnGameLoaded(_, callback)
	if v == true then
		return callback()
	end

	table.insert(callbacks, callback)
end

return GameController