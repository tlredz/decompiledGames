local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local LayoutActions = {
	Move = function(p: string, p2: string?, p3: number, p4: number)
		SignalEvent.ToServer("MoveMobileButton", p, p2, p3, p4)
	end
}

function LayoutActions.Reset(p: string, p2: string?)
	LayoutActions.Move(p, p2, 0, 0)
end

return LayoutActions