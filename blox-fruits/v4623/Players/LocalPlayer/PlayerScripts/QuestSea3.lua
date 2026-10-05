local commF_ = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local turtle = workspace:WaitForChild("Map"):WaitForChild("Turtle", 10)

if not turtle then
	return
end

local questTorches = turtle:WaitForChild("QuestTorches")
local tushitaGate = turtle:WaitForChild("TushitaGate")
local tushitaGate1 = tushitaGate:WaitForChild("TushitaGate1")
tushitaGate1.CFrame *= CFrame.new(0, 150, 0)
local tushitaGate2 = tushitaGate:WaitForChild("TushitaGate2")
tushitaGate2.CFrame *= CFrame.new(0, 150, 0)
local localPlayer = game.Players.LocalPlayer
local character = nil
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	pcall(refresh)
	localPlayer:WaitForChild("Backpack").ChildAdded:Connect(function(child)
		if child.Name == "Holy Torch" then
			pcall(refresh)
		end
	end)
end)

if localPlayer.Character then
	character = localPlayer.Character
end

local v = nil

function refresh()
	v = commF_:InvokeServer("TushitaProgress")

	if v.OpenedDoor then
		pcall(function()
			tushitaGate:Destroy()
		end)
		return
	end

	for k, torch in next, v.Torches, nil do
		local child = questTorches:WaitForChild("Torch" .. k)

		if torch then
			child.Particles.Main.Enabled = true
			child.Particles.PointLight.Enabled = true
		else
			local flag = false
			local touchedConnection = nil
			local v2 = k
			local v3 = child
			touchedConnection = child.Touched:Connect(function(otherPart)
				if flag then
					return
				end

				if otherPart:IsDescendantOf(character) then
					flag = true
					pcall(function()
						if commF_:InvokeServer("TushitaProgress", "Torch", v2) then
							touchedConnection:Disconnect()
							v3.Particles.Main.Enabled = true
							v3.Particles.PointLight.Enabled = true
							refresh()
						end
					end)
					flag = false
				end
			end)
		end
	end
end

repeat
	wait(3)
	local success, result = pcall(refresh)
until success and not result

localPlayer:WaitForChild("Backpack").ChildAdded:Connect(function(child)
	if child.Name == "Holy Torch" then
		refresh()
	end
end)