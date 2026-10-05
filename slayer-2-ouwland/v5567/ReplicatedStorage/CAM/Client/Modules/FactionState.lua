local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local bindableEvent = Instance.new("BindableEvent")
local FactionState = {
	Record = nil,
	Changed = bindableEvent.Event
}

function FactionState.Apply(record)
	FactionState.Record = record
	bindableEvent:Fire(record)
end

function FactionState.Refresh()
	local success, result = pcall(SignalFunction.ToServer, "Get Faction")

	if not success then
		return FactionState.Record
	end

	local apply = FactionState.Apply

	if type(result) ~= "table" then
		result = nil
	end

	apply(result)
	return FactionState.Record
end

function FactionState.MemberOf(p, p2: number)
	if p == nil then
		return nil
	end

	for _, member in p.Members do
		if member.UserId == p2 then
			return member
		end
	end

	return nil
end

return FactionState