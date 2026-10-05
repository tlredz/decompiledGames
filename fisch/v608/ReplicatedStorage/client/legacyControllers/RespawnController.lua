local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local localPlayer = Players.LocalPlayer
local v = nil
local RespawnController = {
	Setup = function(self, instance)
		instance:WaitForChild("Humanoid").Died:Once(function()
			local zone = instance:FindFirstChild("zone")

			if zone then
				if (zone and zone.Value and zone.Value.Name) == "The Depths - Maze" then
					v = CFrame.new(978.143, -686.911, 1253.742) * CFrame.Angles(0, 1.7976891295541595, 0)
				else
					v = nil
				end
			end
		end)
	end
}

function RespawnController.Start(_)
	localPlayer.CharacterAdded:Connect(function(character)
		RespawnController:Setup(character)
	end)

	if localPlayer.Character then
		RespawnController:Setup(localPlayer.Character)
	end

	local remoteFunction = Net:RemoteFunction("GetSpawnPosition")

	remoteFunction.OnClientInvoke = function()
		return v
	end
end

return RespawnController