local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local BattlepassEventData = require(ReplicatedStorage.Shared.BattlepassEventData)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("BattlepassEventEndTime", function(instance)
	local function updateEndTime()
		local v

		if FFlagClient:IsDataReady() then
			v = FFlagClient:GetKey(BattlepassEventData.GetFFlagKey("EndTime"))
		end

		instance:SetAttribute("EndTime", workspace:GetAttribute("BattlepassEventEnabled") and v or 0)
	end

	local dataUpdatedEventConnection = FFlagClient.DataUpdatedEvent:Connect(updateEndTime)
	local battlepassEventEnabledChangedConnection = workspace:GetAttributeChangedSignal("BattlepassEventEnabled"):Connect(updateEndTime)
	task.spawn(updateEndTime)
	return function()
		dataUpdatedEventConnection:Disconnect()
		battlepassEventEnabledChangedConnection:Disconnect()
		instance:SetAttribute("EndTime", nil)
	end
end)