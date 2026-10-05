local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaClient = require(ReplicatedStorage.Modules.Client.Data.ReplicaClient)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local v = CountDownLatch.new(1)
local v2 = nil
local GlobalReplicatedDataController = {}

function GlobalReplicatedDataController.GetReplicatedData(p: number)
	if v2 == nil then
		warn(debug.traceback("Replica not received yet"))
		return nil
	end

	local v3 = v2.Data[tostring(p)]

	if v3 ~= nil then
		return v3
	end

	warn(debug.traceback("Player replica not received yet"))
	return nil
end

function GlobalReplicatedDataController.WaitForReplica()
	if v2 == nil then
		v:await()
	end

	return v2
end

function GlobalReplicatedDataController.FrameworkInit()
	ReplicaClient.OnNew("GlobalReplicatedPlayerData", function(p)
		v2 = p
		v:countDown()
	end)
	ReplicaClient.RequestData()
end

function GlobalReplicatedDataController.FrameworkStart() end

return GlobalReplicatedDataController