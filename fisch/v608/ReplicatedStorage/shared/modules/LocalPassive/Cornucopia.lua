local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("CornucopiaSlam", -1)
local Cornucopia = {
	Morph = function(p, p2, object)
		task.spawn(function()
			object:WaitUntilReady()
			p.reelTrove:Add(remoteEvent.OnClientEvent:Connect(function(p3)
				if workspace:GetServerTimeNow() - p3 >= 1 then
					return
				end

				object:AddProgress(10)
				object.fx:Shake(p2, 0.5, 1.5, 0.01, true)
			end))
		end)
	end
}
setmetatable(Cornucopia, module)
return Cornucopia