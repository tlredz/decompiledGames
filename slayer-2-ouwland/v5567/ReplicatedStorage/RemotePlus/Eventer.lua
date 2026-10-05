local remotePlus = game.ReplicatedStorage.RemotePlus
local Utility = require(remotePlus.Handlers.Utility)
local remote = Utility.GetRemote(script, "Event")
local EventerMain = require(remotePlus.Handlers.EventerMain)
local fireFunction = Utility.GetFireFunction(remote, true)
local fireFunction2 = Utility.GetFireFunction(remote)
local Eventer = {}

function Eventer.Connect(_, callback)
	if remote == nil then
		return
	else
		return EventerMain.Connect(remote, callback)
	end
end

function Eventer.ToAll(...)
	if fireFunction == nil then
		return
	end

	EventerMain.ToAll(remote, fireFunction, ...)
end

function Eventer.ToClient(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, p, ...)
end

function Eventer.ToServer(...)
	if Utility.IsServer or fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, ...)
end

function Eventer.ToAllExcept(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToAllExcept(remote, fireFunction2, p, ...)
end

function Eventer.ToAllInRange(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToAllInRange(remote, fireFunction2, p, 500, ...)
end

function Eventer.ToOthersInRange(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToOthersInRange(remote, fireFunction2, p, 500, ...)
end

return Eventer