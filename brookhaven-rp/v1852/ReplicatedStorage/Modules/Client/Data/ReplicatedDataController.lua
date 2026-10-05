local ReplicatedDataController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaClient = require(ReplicatedStorage.Modules.Client.Data.ReplicaClient)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
ReplicatedDataController.clientReplica = nil
local v = Signal.new()
local v2 = Signal.new()
ReplicatedDataController.currentReplicatedDataPromise = nil
ReplicatedDataController.clientReplicaPromise = nil
local v3 = nil
local v4 = nil

function ReplicatedDataController.GetReplicatedDataPromise()
	if v3 then
		return Promise.resolve(v3.Data)
	end

	if ReplicatedDataController.currentReplicatedDataPromise then
		return ReplicatedDataController.currentReplicatedDataPromise
	end

	ReplicatedDataController.currentReplicatedDataPromise = Promise.new(function(callback, _)
		return callback((ReplicatedDataController.clientReplica or v:Wait()).Data)
	end)
	return ReplicatedDataController.currentReplicatedDataPromise
end

function ReplicatedDataController.GetClientReplicaPromise()
	if v3 then
		return Promise.resolve(v3)
	end

	if ReplicatedDataController.clientReplicaPromise then
		return ReplicatedDataController.clientReplicaPromise
	end

	ReplicatedDataController.clientReplicaPromise = Promise.new(function(callback, _)
		local clientReplica = ReplicatedDataController.clientReplica or v:Wait()
		v3 = clientReplica
		return callback(clientReplica)
	end)
	return ReplicatedDataController.clientReplicaPromise
end

function ReplicatedDataController.GetSessionReplicaPromise()
	if v4 then
		return Promise.resolve(v4)
	end

	ReplicatedDataController.sessionReplicaPromise = Promise.new(function(callback, _)
		local sessionReplica = ReplicatedDataController.sessionReplica or v2:Wait()
		v4 = sessionReplica
		return callback(sessionReplica)
	end)
	return ReplicatedDataController.sessionReplicaPromise
end

function ReplicatedDataController.FrameworkInit()
	ReplicaClient.OnNew("ReplicatedPlayerData", function(clientReplica)
		ReplicatedDataController.clientReplica = clientReplica
		v:Fire(ReplicatedDataController.clientReplica)
		v:Destroy()
		v = nil
	end)
	ReplicaClient.OnNew("ReplicatedSessionData", function(sessionReplica)
		ReplicatedDataController.sessionReplica = sessionReplica
		v2:Fire(ReplicatedDataController.sessionReplica)
		v2:Destroy()
		v2 = nil
	end)
	ReplicaClient.RequestData()
end

function ReplicatedDataController.FrameworkStart()
	Remotes.fireServer("ClientReadyForReplicatedDataSynchronization")
end

return ReplicatedDataController