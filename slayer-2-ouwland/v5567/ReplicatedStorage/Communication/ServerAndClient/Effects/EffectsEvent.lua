local remotePlus = game.ReplicatedStorage.RemotePlus
local Utility = require(remotePlus.Handlers.Utility)
local remote = Utility.GetRemote(script, "Event")
local EventerMain = require(remotePlus.Handlers.EventerMain)
local fireFunction = Utility.GetFireFunction(remote, true)
local fireFunction2 = Utility.GetFireFunction(remote)
local EffectsEvent = {}

function EffectsEvent.Connect(_, callback)
	if remote == nil then
		return
	else
		return EventerMain.Connect(remote, callback)
	end
end

function EffectsEvent.ToAll(...)
	if fireFunction == nil then
		return
	end

	EventerMain.ToAll(remote, fireFunction, ...)
end

function EffectsEvent.ToClient(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, p, ...)
end

function EffectsEvent.ToServer(...)
	if Utility.IsServer or fireFunction2 == nil then
		return
	end

	EventerMain.To(remote, fireFunction2, ...)
end

function EffectsEvent.ToAllExcept(p, ...)
	if fireFunction2 == nil then
		return
	end

	EventerMain.ToAllExcept(remote, fireFunction2, p, ...)
end

function EffectsEvent.ToAllInRange(model, ...)
	if fireFunction2 == nil or typeof(model) == "Instance" and model:IsA("Model") and model.PrimaryPart == nil then
		return
	end

	EventerMain.ToAllInRange(remote, fireFunction2, model, 500, ...)
end

function EffectsEvent.ToOthersInRange(model, ...)
	if fireFunction2 == nil or typeof(model) == "Instance" and model:IsA("Model") and model.PrimaryPart == nil then
		return
	end

	EventerMain.ToOthersInRange(remote, fireFunction2, model, 500, ...)
end

return EffectsEvent