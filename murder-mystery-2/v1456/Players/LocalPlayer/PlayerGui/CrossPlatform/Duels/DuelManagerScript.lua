local parent = script.Parent
local container = parent:WaitForChild("Container")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local container2 = container:WaitForChild("PlayerList"):WaitForChild("Container")
local teams = container:WaitForChild("Teams")
local start = container:WaitForChild("PlayerList"):WaitForChild("Start")
local close = container:WaitForChild("Title"):WaitForChild("Close")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local duelRound = parent:WaitForChild("DuelRound")
local duelStart = duelRound:WaitForChild("Container"):WaitForChild("DuelStart")
local duelDisplay = duelRound:WaitForChild("Container"):WaitForChild("DuelDisplay")
local team1 = duelDisplay:WaitForChild("Team1")
local team2 = duelDisplay:WaitForChild("Team2")
local settings = container:WaitForChild("Settings")
local listPlayer = container2:WaitForChild("ListPlayer")
listPlayer.Parent = script
local teamPlayer = teams.Team1.Container.Players:WaitForChild("TeamPlayer")
teamPlayer.Parent = script
local v = nil
local roundPlayer = duelDisplay:WaitForChild("Team1"):WaitForChild("RoundPlayer")
roundPlayer.Parent = script
local v2 = {
	Team1 = {},
	Team2 = {}
}
local v3 = {}
local clonesByChildName = {}
local v4 = remotes:WaitForChild("CustomGames"):WaitForChild("CanStartDuels"):InvokeServer()
local _ = {
	KnifeVsGun = "KnifeVsGun",
	KnifeVsKnife = "KnifeVsKnife",
	GunVsGun = "GunVsGun",
	BothVsBoth = "BothVsBoth",
	Custom = "Custom"
}
local name = "KnifeVsGun"
local _ = {
	Both = "rbxassetid://18147380345",
	Gun = "rbxassetid://197518111",
	Knife = "rbxassetid://584555920"
}

local function countTeamSize(p: string)
	local count = 0

	for _, _ in v2[p] do
		count += 1
	end

	return count
end

local function UpdateWeaponsForMode(instance)
	local team = instance:GetAttribute("Team")

	if name == "KnifeVsGun" then
		if team == "Team1" then
			instance.Weapon.Icon.Image = "rbxassetid://584555920"
		else
			instance.Weapon.Icon.Image = "rbxassetid://197518111"
		end

		instance.Knife:SetAttribute("Enabled", team == "Team1")
		instance.Gun:SetAttribute("Enabled", team == "Team2")
	elseif name == "KnifeVsKnife" then
		instance.Weapon.Icon.Image = "rbxassetid://584555920"
		instance.Knife:SetAttribute("Enabled", true)
		instance.Gun:SetAttribute("Enabled", false)
	elseif name == "GunVsGun" then
		instance.Weapon.Icon.Image = "rbxassetid://197518111"
		instance.Knife:SetAttribute("Enabled", false)
		instance.Gun:SetAttribute("Enabled", true)
	elseif name == "BothVsBoth" then
		instance.Weapon.Icon.Image = "rbxassetid://18147380345"
		instance.Knife:SetAttribute("Enabled", true)
		instance.Gun:SetAttribute("Enabled", true)
	end

	instance.Weapon.Visible = name ~= "Custom"
	instance.Gun.Visible = name == "Custom"
	instance.Knife.Visible = name == "Custom"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPlayerIcon(p)
	local userId = math.abs(p.UserId)
	return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
end

local function updateTeamFrames()
	for _, v5 in v2 do
		for k, v6 in v5 do
			if not (k.Parent == nil and v6 ~= nil) then
				continue
			end

			v6:Destroy()
			v5[k] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removePlayerFromTeam(p)
	if v2.Team1[p] then
		v2.Team1[p]:Destroy()
	end

	if v2.Team2[p] then
		v2.Team2[p]:Destroy()
	end

	v2.Team1[p] = nil
	v2.Team2[p] = nil
end

local function clearTeams()
	for _, v5 in game.Players:GetPlayers() do
		removePlayerFromTeam(v5) -- equivalent call inferred; original call site unknown
	end
end

local function addPlayerToTeam(p, team: string)
	removePlayerFromTeam(p) -- equivalent call inferred; original call site unknown
	local clone = teamPlayer:Clone()
	clone.TextLabel.Text = p.Name
	local imageLabel = clone.ImageLabel
	imageLabel.Image = GetPlayerIcon(p)
	clone.ImageLabel.Button.Activated:Connect(function()
		clone:Destroy()
		removePlayerFromTeam(p) -- equivalent call inferred; original call site unknown
	end)
	clone.LayoutOrder = time() * 100
	clone:SetAttribute("Team", team)
	clone.Knife:SetAttribute("Enabled", true)
	clone.Knife.Button.Activated:Connect(function()
		if clone.Knife:GetAttribute("Enabled") then
			clone.Knife:SetAttribute("Enabled", false)
			clone.Knife.Icon.ImageColor3 = Color3.fromRGB(255, 0, 0)
		else
			clone.Knife:SetAttribute("Enabled", true)
			clone.Knife.Icon.ImageColor3 = Color3.fromRGB(0, 255, 0)
		end
	end)
	clone.Gun:SetAttribute("Enabled", true)
	clone.Gun.Button.Activated:Connect(function()
		if clone.Gun:GetAttribute("Enabled") then
			clone.Gun:SetAttribute("Enabled", false)
			clone.Gun.Icon.ImageColor3 = Color3.fromRGB(255, 0, 0)
		else
			clone.Gun:SetAttribute("Enabled", true)
			clone.Gun.Icon.ImageColor3 = Color3.fromRGB(0, 255, 0)
		end
	end)
	UpdateWeaponsForMode(clone)
	v2[team][p] = clone
	clone.Parent = teams[team].Container.Players
	updateTeamFrames()
end

local function resetSelection()
	for _, v5 in v3 do
		v5.ImageLabel.UIStroke.Color = Color3.fromRGB(0, 0, 0)
	end
end

local function updatePlayerList()
	task.wait()

	for _, v5 in game.Players:GetPlayers() do
		if v3[v5] ~= nil then
			continue
		end

		local clone = listPlayer:Clone()
		local imageLabel = clone.ImageLabel
		imageLabel.Image = GetPlayerIcon(v5)
		clone.TextLabel.Text = v5.Name
		clone.LayoutOrder = time() * 100
		local v6 = v5
		clone.Button.Activated:Connect(function()
			if v == v6 then
				clone.ImageLabel.UIStroke.Color = Color3.fromRGB(0, 0, 0)
				v = nil
			else
				resetSelection()
				v = v6
				clone.ImageLabel.UIStroke.Color = Color3.fromRGB(50, 200, 50)
			end
		end)
		clone.Parent = container2
		v3[v5] = clone
	end

	for k, v5 in v3 do
		if k:IsDescendantOf(game.Players) then
			continue
		end

		if v5 then
			v5:Destroy()
		end

		v3[k] = nil
	end
end

local eventConnection = nil

local function onPlayerDataUpdated()
	for k, v5 in CurrentRoundClient.PlayerData do
		local v6 = clonesByChildName[k]

		if not (v6 and v5.Dead) then
			continue
		end

		v6.Dead.Visible = true
		v6.ImageLabel.ImageColor3 = Color3.fromRGB(20, 20, 20)
	end
end

local function onDuelStarted(p)
	clonesByChildName = {}

	if eventConnection == nil then
		eventConnection = CurrentRoundClient.PlayerDataChanged.Event:Connect(onPlayerDataUpdated)
	end

	for childName, _ in p[p.Team1[game.Players.LocalPlayer.Name] and "Team1" or "Team2"] do
		local child = game.Players:FindFirstChild(childName)

		if not (child and child ~= game.Players.LocalPlayer and child.Character) then
			continue
		end

		local humanoidRootPart = child.Character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			continue
		end

		local clone = script.TeamMate:Clone()
		clone.Enabled = true
		clone.Parent = humanoidRootPart
	end

	for _, frame in team1:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, frame in team2:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for k, v5 in p do
		for childName, v6 in v5 do
			local child = game.Players:FindFirstChild(childName)

			if not child then
				continue
			end

			local clone = roundPlayer:Clone()
			clone.Name = childName
			clone.PlayerName.Text = childName
			local imageLabel = clone.ImageLabel
			imageLabel.Image = GetPlayerIcon(child)
			clone.Weapons.Knife.Visible = v6.Knife == true
			clone.Weapons.Gun.Visible = v6.Gun == true
			clone.Parent = k == "Team1" and team1 or team2
			clonesByChildName[childName] = clone
		end
	end

	duelRound.Visible = true
	duelStart.Visible = true
	duelDisplay.Visible = true
	local lastTime = os.clock()

	while os.clock() - lastTime < 10 do
		local v5 = math.ceil(os.clock() - lastTime)
		duelStart.Timer.Text = 10 - v5 + 1
		task.wait()
	end

	duelStart.Visible = false
end

local function onDuelSubmitted()
	local v5 = {
		Team1 = {},
		Team2 = {}
	}

	for k, v6 in v2.Team1 do
		v5.Team1[k.Name] = {
			Knife = v6.Knife:GetAttribute("Enabled"),
			Gun = v6.Gun:GetAttribute("Enabled")
		}
	end

	for k, v6 in v2.Team2 do
		v5.Team2[k.Name] = {
			Knife = v6.Knife:GetAttribute("Enabled"),
			Gun = v6.Gun:GetAttribute("Enabled")
		}
	end

	container.Visible = false
	remotes.CustomGames.SubmitDuel:FireServer(v5)
end

close.ImageButton.Activated:Connect(function()
	container.Visible = false
end)

if v4 then
	for _, frame in settings:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v5 = frame
		frame.Button.Activated:Connect(function()
			name = v5.Name

			for i, frame2 in settings:GetChildren() do
				if frame2:IsA("Frame") then
					frame2.Button.Style = frame2 == v5 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
				end
			end

			for k, v6 in v2 do
				for k2, v7 in v6 do
					UpdateWeaponsForMode(v7)
				end
			end
		end)
	end

	start.ImageButton.Activated:Connect(onDuelSubmitted)
	teams.Team1.Container.Players.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if v and v:IsDescendantOf(game.Players) then
			local count = 0

			for _, _ in v2.Team1 do
				count += 1
			end

			if count < 4 then
				addPlayerToTeam(v, "Team1")
				resetSelection()
				v = nil
			end
		end
	end)
	teams.Team2.Container.Players.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if v and v:IsDescendantOf(game.Players) then
			local count = 0

			for _, _ in v2.Team2 do
				count += 1
			end

			if count < 4 then
				addPlayerToTeam(v, "Team2")
				resetSelection()
				v = nil
			end
		end
	end)

	for _, frame in container2:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, frame in teams.Team1.Container.Players:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, frame in teams.Team2.Container.Players:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	updatePlayerList()
	game.Players.PlayerAdded:Connect(function()
		updatePlayerList()
		updateTeamFrames()
	end)
	game.Players.PlayerRemoving:Connect(function()
		updatePlayerList()
		updateTeamFrames()
	end)
end

duelRound.Visible = false
remotes.CustomGames.DuelKill.OnClientEvent:Connect(function(_: string, _: string, _: string) end)
remotes.Gameplay.RoundEndFade.OnClientEvent:Connect(function()
	duelRound.Visible = false
end)
remotes:WaitForChild("CustomGames"):WaitForChild("DuelStarted").OnClientEvent:Connect(onDuelStarted)
WindowService:RegisterFrame(container, "DuelSetup")