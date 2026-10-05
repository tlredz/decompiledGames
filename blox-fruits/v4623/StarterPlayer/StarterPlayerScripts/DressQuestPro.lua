local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local ice = workspace:WaitForChild("Map"):WaitForChild("Ice", 10)

if not ice then
	return
end

local door = ice:WaitForChild("Door")
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
	v = commF_:InvokeServer("DressrosaQuestProgress")
	local talkedDetective = v.TalkedDetective
	local usedKey = v.UsedKey
	local killedIceBoss = v.KilledIceBoss

	if usedKey then
		if not killedIceBoss then
			door.CanCollide = false
			door.Transparency = 1
		end
	elseif talkedDetective then
		repeat
			wait(1)
		until character:FindFirstChild("Key")

		local key = character.Key
		local flag = false

		if not key:FindFirstChild("HasTouch") then
			local folder = Instance.new("Folder")
			folder.Name = "HasTouch"
			folder.Parent = key
			local touchedConnection = nil
			touchedConnection = key.Handle.Touched:Connect(function(otherPart)
				if flag then
					return
				end

				flag = true

				if otherPart == door and commF_:InvokeServer("DressrosaQuestProgress", "UseKey") then
					touchedConnection:Disconnect()
					refresh()
				end

				flag = false
			end)
		end
	end

	if p == "promptDialogue" then
		DialogueController.start(DialoguesList.KilledIceBoss)
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

	remotes:WaitForChild("RefreshDressrosaQuestPro").OnClientEvent:Connect(refresh)
	break
end