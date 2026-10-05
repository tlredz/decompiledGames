local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local v = nil

local function report()
	local value = Platform_Handler.Platform.Value

	if value == "" or value == v then
		return
	end

	v = value
	SignalEvent.ToServer("Device", value)
end

Platform_Handler.Platform.Changed.Event:Connect(report)
local value = Platform_Handler.Platform.Value

if value ~= "" and value ~= v then
	v = value
	SignalEvent.ToServer("Device", value)
end