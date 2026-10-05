local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaController = require(ReplicatedStorage.Modules.External.Madwork.ReplicaController)
require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local v = { "PlayerProfile" }
local v2 = {}

function ReplicatedStorage.Bindables.RegisterReplicaClass.OnInvoke(p, p2)
	ReplicaController.ReplicaOfClassCreated(p, p2)
	table.insert(v2, p)
end

task.defer(function()
	while #v2 < #v do
		task.wait()
	end

	ReplicaController.RequestData()
end)