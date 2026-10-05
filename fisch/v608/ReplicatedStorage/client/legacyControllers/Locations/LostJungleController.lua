local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local module = require("@self/LocalDataState")
local LostJungleController = {}

function LostJungleController:Start()
	require("@self/Components")
	DataController.PlayerDataReplicator:Observe({ "LostJungle" }, LostJungleController._OnDataChanged)

	for _, child in script.Controllers:GetChildren() do
		local v = child
		task.spawn(function()
			local module2 = require(v)
			module2:Start()
		end)
	end
end

function LostJungleController._OnDataChanged(p)
	if not p then
		return
	end

	module:set(p)
end

return LostJungleController