local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local folder = Instance.new("Folder")
folder.Name = "ESPContainer"
folder.Parent = playerGui
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAdornee(data)
	local character = data.Player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		data.HeadGui.Adornee = humanoidRootPart
		data.OutlineGui.Adornee = character
	else
		data.HeadGui.Adornee = nil
		data.OutlineGui.Adornee = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyVisibility(p)
	local eSPEnabled = localPlayer:GetAttribute("ESPEnabled") == true
	p.HeadGui.Enabled = eSPEnabled
	p.OutlineGui.Enabled = eSPEnabled
end

local function applyAllVisibility()
	for _, v2 in v do
		applyVisibility(v2) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearCharacterConnections(p)
	for _, characterConnection in p.CharacterConnections do
		characterConnection:Disconnect()
	end

	table.clear(p.CharacterConnections)
end

local function bindCharacter(data, character)
	clearCharacterConnections(data) -- equivalent call inferred; original call site unknown
	refreshAdornee(data) -- equivalent call inferred; original call site unknown
	local childAddedConnection = character.ChildAdded:Connect(function(part)
		if part.Name == "HumanoidRootPart" and part:IsA("BasePart") then
			refreshAdornee(data) -- equivalent call inferred; original call site unknown
		end
	end)
	local childRemovedConnection = character.ChildRemoved:Connect(function(child)
		if child.Name == "HumanoidRootPart" then
			refreshAdornee(data) -- equivalent call inferred; original call site unknown
		end
	end)
	table.insert(data.CharacterConnections, childAddedConnection)
	table.insert(data.CharacterConnections, childRemovedConnection)
end

local function playerAdded(player)
	if player == localPlayer or v[player] then
		return
	end

	local clone = script.Head:Clone()
	local clone2 = script.Outline:Clone()
	clone.PlayerName.Text = player.Name
	clone.Parent = folder
	clone2.Parent = folder
	local v2 = {
		Player = player,
		HeadGui = clone,
		OutlineGui = clone2,
		Connections = {},
		CharacterConnections = {}
	}
	v[player] = v2
	table.insert(v2.Connections, player.CharacterAdded:Connect(function(character)
		bindCharacter(v2, character)
	end))
	table.insert(v2.Connections, player.CharacterRemoving:Connect(function(character)
		if v2.Player.Character ~= character then
			return
		end

		clearCharacterConnections(v2) -- equivalent call inferred; original call site unknown
		v2.HeadGui.Adornee = nil
		v2.OutlineGui.Adornee = nil
	end))

	if player.Character then
		bindCharacter(v2, player.Character)
	end

	refreshAdornee(v2) -- equivalent call inferred; original call site unknown
	applyVisibility(v2) -- equivalent call inferred; original call site unknown
end

local function playerRemoving(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, connection in v2.Connections do
		connection:Disconnect()
	end

	clearCharacterConnections(v2) -- equivalent call inferred; original call site unknown
	v2.HeadGui:Destroy()
	v2.OutlineGui:Destroy()
	v[p] = nil
end

localPlayer:GetAttributeChangedSignal("ESPEnabled"):Connect(applyAllVisibility)
Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v2 in Players:GetPlayers() do
	task.spawn(playerAdded, v2)
end