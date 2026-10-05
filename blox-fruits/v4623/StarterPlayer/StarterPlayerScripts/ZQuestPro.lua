local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
workspace:WaitForChild("Map")
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

local v = nil

function refresh(p)
	v = commF_:InvokeServer("ZQuestProgress")

	if p == "promptDialogue" then
		DialogueController.start(DialoguesList.KilledIndraBoss)
	elseif p == "cutscene" then
		print("cutscene playing")
	end
end

while true do
	wait(3)
	local success, result = pcall(refresh)

	if not success and result then
		warn(result)
	end

	if not success or result then
		continue
	end

	remotes:WaitForChild("RefreshZQuestPro").OnClientEvent:Connect(refresh)
	break
end