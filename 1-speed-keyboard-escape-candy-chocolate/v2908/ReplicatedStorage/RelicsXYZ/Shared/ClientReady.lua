local Players = game:GetService("Players")
local parent = script.Parent
local Network = require(parent.Network)
local RunContext = require(parent.RunContext)
local reliableEvent = Network.ReliableEvent("RELICSxyz_ClientReady")
local v = {}

local function waitForClientReady(p)
	if v[p] then
		return
	end

	local total = 0

	while not v[p] and total < 15 do
		task.wait(0.1)
		total += 0.1
	end
end

if RunContext.IsClient then
	reliableEvent:Client():Fire()
else
	reliableEvent:Server():On(function(p)
		v[p] = true
	end)
	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
	end)
end

return table.freeze({
	WaitForClient = waitForClientReady
})