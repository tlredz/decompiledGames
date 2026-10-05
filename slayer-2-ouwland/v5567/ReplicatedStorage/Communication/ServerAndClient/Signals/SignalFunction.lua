local remotePlus = game.ReplicatedStorage.RemotePlus
local Utility = require(remotePlus.Handlers.Utility)
local remote = Utility.GetRemote(script, "Function")
local InvokerMain = require(remotePlus.Handlers.InvokerMain)
local fireFunction = Utility.GetFireFunction(remote, true)
local fireFunction2 = Utility.GetFireFunction(remote)
local SignalFunction = {}

function SignalFunction.Connect(_, callback)
	if remote == nil then
		return
	end

	InvokerMain.Connect(remote, callback)
end

function SignalFunction.ToAll(...)
	if fireFunction == nil then
		return
	else
		return InvokerMain.ToAll(remote, fireFunction, ...)
	end
end

function SignalFunction.ToClient(p, ...)
	if fireFunction2 == nil then
		return
	else
		return InvokerMain.To(remote, fireFunction2, p, ...)
	end
end

function SignalFunction.ToServer(...)
	if Utility.IsServer or fireFunction2 == nil then
		return
	else
		return InvokerMain.To(remote, fireFunction2, ...)
	end
end

function SignalFunction.ToAllExcept(p, ...)
	if fireFunction2 == nil then
		return
	else
		return InvokerMain.ToAllExcept(remote, fireFunction2, p, ...)
	end
end

function SignalFunction.ToAllInRange(p, ...)
	if fireFunction2 == nil then
		return
	else
		return InvokerMain.ToAllInRange(remote, fireFunction2, p, 500, ...)
	end
end

function SignalFunction.ToOthersInRange(p, ...)
	if fireFunction2 == nil then
		return
	else
		return InvokerMain.ToOthersInRange(remote, fireFunction2, p, 500, ...)
	end
end

return SignalFunction