local remotePlus = game.ReplicatedStorage.RemotePlus
local Utility = require(remotePlus.Handlers.Utility)
local remote = Utility.GetRemote(script, "Function")
local InvokerMain = require(remotePlus.Handlers.InvokerMain)
local fireFunction = Utility.GetFireFunction(remote)
local QueueSignal = {}

function QueueSignal.Connect(_, callback)
	if remote == nil then
		return
	end

	InvokerMain.Connect(remote, callback)
end

function QueueSignal.ToClient(p, ...)
	if fireFunction == nil then
		return
	else
		return InvokerMain.To(remote, fireFunction, p, ...)
	end
end

function QueueSignal.ToServer(...)
	if Utility.IsServer or fireFunction == nil then
		return
	else
		return InvokerMain.To(remote, fireFunction, ...)
	end
end

return QueueSignal