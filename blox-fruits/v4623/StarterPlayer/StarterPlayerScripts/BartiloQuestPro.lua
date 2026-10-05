local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local dressrosa = workspace:WaitForChild("Map"):WaitForChild("Dressrosa", 15)

if not dressrosa then
	return
end

local bartiloPlates = dressrosa:WaitForChild("BartiloPlates")
local cellDoor = dressrosa:WaitForChild("CellDoor")
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
local v = nil

function refresh(p)
	v = commF_:InvokeServer("BartiloQuestProgress")
	local killedBandits = v.KilledBandits
	local killedSpring = v.KilledSpring
	local didPlates = v.DidPlates

	if killedBandits and killedSpring and didPlates then
		for _, child in pairs(cellDoor:GetChildren()) do
			child.CanCollide = false
			child.Transparency = 1
		end
	end

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	local flag = false
	local v2 = {}
	local v3 = {}
	local now = 0

	if killedBandits and killedSpring and not didPlates then
		for _, child in pairs(bartiloPlates:GetChildren()) do
			local id = tonumber(string.match(child.Name, "%d+"))
			local obj = child
			table.insert(connections, child.Touched:Connect(function(otherPart)
				if flag or tick() - now < 2 then
					return
				end

				if otherPart and otherPart:IsDescendantOf(character) and not v3[id] then
					v3[id] = true
					obj.Color = Color3.fromRGB(150, 255, 125)
					table.insert(v2, {
						obj = obj,
						id = id
					})

					if #v2 == 8 then
						flag = true

						for i = 1, 8 do
							if v2[i].id == i then
								continue
							end

							flag = false
							break
						end

						if flag then
							if commF_:InvokeServer("BartiloQuestProgress", "DidPlates") == true then
								DialogueController.start(DialoguesList.PrisonersThanks)

								for i, child2 in pairs(cellDoor:GetChildren()) do
									child2.CanCollide = false
									child2.Transparency = 1
								end
							end
						else
							for i, child2 in pairs(bartiloPlates:GetChildren()) do
								child2.Color = Color3.fromRGB(150, 138, 125)
							end

							v2 = {}
							v3 = {}
							now = tick()
						end
					end
				end
			end))
		end
	end

	if p == "promptDialogue" then
		DialogueController.start(DialoguesList.KilledSpringBoss)
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

	remotes:WaitForChild("RefreshBartiloQuestPro").OnClientEvent:Connect(refresh)
	break
end