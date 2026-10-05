local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local troves = {}
local reelTroves = {}
local v3 = {}
return {
	_troves = troves,
	_reelTroves = reelTroves,
	Start = function(_)
		Net:RemoteEvent("PassiveVfx/Replicate", -1).OnClientEvent:Connect(function(childName, p, p2, ...)
			if v3[p2] then
				return
			end

			local v4 = troves[p2]
			local v5 = reelTroves[p2]

			if not v4 then
				v4 = Trove.new()
				troves[p2] = v4
				v5 = v4:Extend()
				reelTroves[p2] = v5
			end

			local module = require(script:WaitForChild(childName))
			module[p](v4, v5, p2, ...)
		end)
		Net:RemoteEvent("PassiveVfx/Cleanup", -1).OnClientEvent:Connect(function(items)
			for _, item in items do
				if reelTroves[item] then
					reelTroves[item]:Clean()
				end
			end
		end)
		Net:RemoteEvent("PassiveVfx/Destroy", -1).OnClientEvent:Connect(function(items)
			for _, item in items do
				v3[item] = true
				local v4 = item
				task.delay(60, function()
					v3[v4] = nil
				end)

				if troves[item] then
					troves[item]:Destroy()
					troves[item] = nil
				end

				reelTroves[item] = nil
			end
		end)
	end
}