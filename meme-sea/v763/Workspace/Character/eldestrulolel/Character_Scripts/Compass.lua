local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 30)
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 30)
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local compassAssets = ReplicatedStorage:WaitForChild("GuiTemplate"):WaitForChild("CompassAssets")
visualFX:WaitForChild("Arrow")
local location = workspace:WaitForChild("Location")
local spawnLocations = location:WaitForChild("SpawnLocations")
local questLocaion = location:WaitForChild("QuestLocaion")
local clientUI = otherEvent:WaitForChild("GuiEvents"):WaitForChild("ClientUI")
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local quest_Tracker = playerData:WaitForChild("Quest_Tracker")
local island_Tracker = playerData:WaitForChild("Island_Tracker")
local quest_Tracker2 = compassAssets:WaitForChild("Quest_Tracker")
local island_Tracker2 = compassAssets:WaitForChild("Island_Tracker")
local clone = nil
local diedConnection = nil
local renderSteppedConnection = nil
local onClientEventConnection = nil
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearAll()
	if clone and clone.Parent then
		clone:Destroy()
		clone = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

function Track(p)
	if p.Name == "Island_Tracker" then
		ClearAll() -- equivalent call inferred; original call site unknown

		if p.Value ~= "None" and p.Value ~= "" then
			clone = island_Tracker2:Clone()
			clone.Parent = workspace.Location.SpawnLocations:FindFirstChild(p.Value)
			clone.Enabled = true
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local child = spawnLocations:FindFirstChild(p.Value)

				if child then
					if clone then
						if localPlayer:GetAttribute("TH") then
							clone.Distance.Text = `ห่างจากคุณ {math.floor((humanoidRootPart.Position - child.Position).Magnitude)} เมตร`
						else
							clone.Distance.Text = `{math.floor((humanoidRootPart.Position - child.Position).Magnitude)}m away`
						end
					else
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end
				else
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end
	elseif p.Name == "Quest_Tracker" then
		ClearAll() -- equivalent call inferred; original call site unknown

		if p.Value ~= "None" and p.Value ~= "" then
			clone = quest_Tracker2:Clone()
			clone.Parent = workspace.Location.QuestLocaion:FindFirstChild(p.Value)
			clone.Enabled = true
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local child = questLocaion:FindFirstChild(p.Value)

				if child then
					if clone then
						if localPlayer:GetAttribute("TH") then
							clone.Distance.Text = `ห่างจากคุณ {math.floor((humanoidRootPart.Position - child.Position).Magnitude)} เมตร`
						else
							clone.Distance.Text = `{math.floor((humanoidRootPart.Position - child.Position).Magnitude)}m away`
						end
					else
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end
				else
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end
	end
end

if quest_Tracker and quest_Tracker.Value ~= "None" and quest_Tracker.Value ~= "" then
	Track(quest_Tracker)
elseif island_Tracker and island_Tracker.Value ~= "None" and island_Tracker.Value ~= "" then
	Track(island_Tracker)
end

connections[#connections + 1] = quest_Tracker.Changed:Connect(function()
	Track(quest_Tracker)
end)
connections[#connections + 1] = island_Tracker.Changed:Connect(function()
	Track(island_Tracker)
end)
onClientEventConnection = clientUI.OnClientEvent:Connect(function(p: string)
	if p == "Load_Character" then
		ClearAll() -- equivalent call inferred; original call site unknown

		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		if onClientEventConnection then
			onClientEventConnection:Disconnect()
			onClientEventConnection = nil
		end

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
end)
diedConnection = humanoid.Died:Connect(function()
	ClearAll() -- equivalent call inferred; original call site unknown

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
end)