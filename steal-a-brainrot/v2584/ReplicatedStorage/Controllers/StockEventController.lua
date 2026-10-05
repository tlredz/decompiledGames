local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local StockEventController = {}

function StockEventController.IsEnabled(_)
	local instant = FFlags:GetInstant("StockEventMachineEndTime", nil)
	return FFlags:GetInstant("StockEventEnabled", true) and (instant == nil or DateTime.now().UnixTimestamp < instant)
end

function StockEventController:Start()
	for _, moduleScript in script.Machines:GetChildren() do
		local module = require(moduleScript)
		module:Start()
	end
end

return StockEventController