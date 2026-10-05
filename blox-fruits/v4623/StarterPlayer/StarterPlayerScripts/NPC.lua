local nPCs = workspace:WaitForChild("NPCs")

while not nPCs:GetAttribute("OptimizationComplete") do
	task.wait()
end

local NPCManager = require(game.ReplicatedStorage.NPCManager)
require(game.ReplicatedStorage.NPCManager.NPCList)
NPCManager.onInit()