local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local turtle = workspace:WaitForChild("Map"):WaitForChild("Turtle", 15)

if not turtle then
	return
end

local WaitFor = require(game.ReplicatedStorage.Util.WaitFor)
local waitFor = WaitFor(turtle, "Treasure")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialoguesList = require(game.ReplicatedStorage:WaitForChild("DialoguesList"))
local DialogueController = require(ReplicatedStorage:WaitForChild("DialogueController"))
local localPlayer = game.Players.LocalPlayer
local character = nil
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	pcall(refresh)
end)

if localPlayer.Character then
	character = localPlayer.Character
end

local connections = {}
local v2 = nil

function refresh(p)
	v2 = commF_:InvokeServer("CitizenQuestProgress")
	local killedBandits = v2.KilledBandits
	local killedBoss = v2.KilledBoss
	local foundTreasure = v2.FoundTreasure

	if killedBandits and killedBoss and foundTreasure then
		waitFor:Destroy()
		return
	end

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	if killedBandits and killedBoss and not foundTreasure then
		local flag = false
		table.insert(connections, waitFor.Touched:Connect(function(otherPart)
			if flag then
				return
			end

			flag = true

			if otherPart and otherPart:IsDescendantOf(character) then
				pcall(function()
					if commF_:InvokeServer("CitizenQuestProgress", "FoundTreasure") == true then
						DialogueController.start(DialoguesList.CitizenThanks)
						waitFor:Destroy()
					end
				end)
			end

			flag = false
		end))
	end

	if p == "promptDialogue" then
		DialogueController.start(DialoguesList.KilledCitizenBoss)
	end
end

repeat
	wait(3)
	local success, result = pcall(refresh)
until success and not result

remotes:WaitForChild("RefreshCitizenQuestPro").OnClientEvent:Connect(refresh)