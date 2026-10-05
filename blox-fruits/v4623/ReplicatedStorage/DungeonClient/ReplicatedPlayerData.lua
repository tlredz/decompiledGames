local ReplicatedPlayerData = {}
local v = nil
local Signal = require(game.ReplicatedStorage.Util.Signal)
ReplicatedPlayerData.OnUpdated = Signal()

function ReplicatedPlayerData.get(flag: boolean?)
	local RunService = game:GetService("RunService")

	if not RunService:IsRunning() then
		return {
			DungeonReservedServerCode = nil,
			DungeonPrivateServerId = nil,
			DataForDungeonTypes = {
				["Simulation Dungeon"] = {
					MaxFloorReached = 0,
					UnlockedDifficulties = {
						Normal = {
							MaxFloorReached = 0
						}
					}
				}
			},
			CurrentEnergy = 99,
			LastEnergyRegenTime = 0
		}
	end

	if v and not flag then
		return v
	end

	local v2 = game.ReplicatedStorage.DungeonShared:WaitForChild("DataRemote"):InvokeServer("GetData")
	v = v2
	return v2
end

task.spawn(function()
	local RunService = game:GetService("RunService")

	if not RunService:IsRunning() then
		return
	end

	local dataRemote = game.ReplicatedStorage.DungeonShared:WaitForChild("DataRemote")

	dataRemote.OnClientInvoke = function(p: string, ...)
		if p == "DataUpdated" then
			ReplicatedPlayerData.get(true)
			ReplicatedPlayerData.OnUpdated:Fire()
		end
	end
end)
return ReplicatedPlayerData