local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

require("@game/ReplicatedStorage/Omni/DataTemplate")
require(ReplicatedStorage.Omni.Libs.DataContainer.Client)
local callbacks = {}
local ClientData = {
	Ready = false,
	Data = nil,
	Container = nil
}

function ClientData.OnReady(callback)
	if not callback or typeof(callback) ~= "function" then
		return
	end

	table.insert(callbacks, callback)

	if ClientData.Ready then
		callback()
	end
end

task.spawn(function()
	while not ClientData.Ready do
		task.wait()
	end

	for _, v in callbacks do
		v()
	end
end)
return ClientData