local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Cache = require(packages:WaitForChild("Cache"))
local v = Cache:Create("Boost")
local remoteEvent = Net:RemoteEvent("BoostModifier", -1)
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
			v:Set(p, p2)
		end)
	end
}