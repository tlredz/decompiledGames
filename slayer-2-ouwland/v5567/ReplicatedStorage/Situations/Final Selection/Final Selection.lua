local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UITimedEvent = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.UITimedEvent)
local TimedEvents = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedEvents)
local v = nil
local count = 0
local FinalSelection = {}

function FinalSelection.Start(_)
	count += 1
	local v2 = count

	if v ~= nil then
		v()
		v = nil
	end

	local billboardGui = workspace:WaitForChild("Debree"):WaitForChild("Final Selection Assets"):WaitForChild("PersistentModel"):WaitForChild("BillboardHandler"):WaitForChild("BillboardGui")

	if v2 ~= count then
		return
	end

	v = UITimedEvent(billboardGui, TimedEvents.FinalSelection)
end

function FinalSelection.End(_)
	count += 1

	if v ~= nil then
		v()
		v = nil
	end
end

return FinalSelection