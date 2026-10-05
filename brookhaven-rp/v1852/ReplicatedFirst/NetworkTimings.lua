local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local count = 0
local v = {}

while RunService:IsRunning() and count < 30 do
	local v2 = {
		time = count,
		dataReceive = Stats.DataReceiveKbps,
		dataSend = Stats.DataSendKbps,
		physicsReceive = Stats.PhysicsReceiveKbps,
		physicsSend = Stats.PhysicsSendKbps,
		latency = math.max(localPlayer:GetNetworkPing(), 0)
	}
	table.insert(v, v2)
	count += 1
	task.wait(1)
end

task.spawn(function()
	local clientTimingsSendNetworkData = ReplicatedStorage:WaitForChild("ClientTimings:SendNetworkData", 60)

	if clientTimingsSendNetworkData == nil then
		warn("Failed to find ClientTimings:SendNetworkData remote event")
		return
	end

	clientTimingsSendNetworkData:FireServer(v)
	v = {}
end)