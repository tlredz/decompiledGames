local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local Flight = require(script:WaitForChild("Flight"))
local remoteEvent = Net:RemoteEvent("VolcanoDipResult")
local remoteEvent2 = Net:RemoteEvent("VolcanoDipCancelled")
remoteEvent.OnClientEvent:Connect(function(p)
	if type(p) == "table" then
		Flight.Play(p)
	end
end)
remoteEvent2.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" then
		return
	end

	if type(p.Owner) == "number" and type(p.StartedAt) == "number" then
		Flight.Cancel(p.Owner, p.StartedAt)
	end
end)