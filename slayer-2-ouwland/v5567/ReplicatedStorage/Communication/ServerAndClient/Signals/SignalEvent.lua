local remotePlus = game.ReplicatedStorage.RemotePlus
local Utility = require(remotePlus.Handlers.Utility)
local remote = Utility.GetRemote(script, "Event")
local EventerMain = require(remotePlus.Handlers.EventerMain)
local fireFunction = Utility.GetFireFunction(remote, true)
local fireFunction2 = Utility.GetFireFunction(remote)
local SignalEvent = {}

function SignalEvent.Connect(_, callback)
	if remote == nil then
		return
	else
		return EventerMain.Connect(remote, callback)
	end
end

function SignalEvent.ToAll(...)
	if fireFunction == nil then
		return
	end

	EventerMain.ToAll(remote, fireFunction, ...)
end

function SignalEvent.ToClient(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, p, ...)
end

function SignalEvent.ToServer(...)
	if Utility.IsServer or fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, ...)
end

function SignalEvent.ToAllExcept(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToAllExcept(remote, fireFunction2, p, ...)
end

function SignalEvent.ToAllInRange(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToAllInRange(remote, fireFunction2, p, 500, ...)
end

function SignalEvent.ToOthersInRange(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToOthersInRange(remote, fireFunction2, p, 500, ...)
end

return SignalEvent