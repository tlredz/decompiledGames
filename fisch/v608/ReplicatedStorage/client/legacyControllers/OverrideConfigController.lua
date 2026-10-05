local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ApplyOverrideConfig = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("ApplyOverrideConfig"))
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local remoteEvent = Net:RemoteEvent("OverrideConfig/ConfigUpdated", 1e999)
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p, p2)
			ApplyOverrideConfig:Apply(p, p2)
		end)
	end
}