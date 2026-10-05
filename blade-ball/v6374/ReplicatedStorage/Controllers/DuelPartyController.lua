local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage3.ServerInfo)
local clientGameModules = ReplicatedStorage3.ClientGameModules
local v2 = require3(ReplicatedStorage3.Packages.Net)
local v3 = require3(ReplicatedStorage3.Packages.Replion)
local v4 = require3(clientGameModules.GuiHandler)
local remoteEvent = v2:RemoteEvent("DuelPartyInvite")
local remoteEvent2 = v2:RemoteEvent("DuelPartyAccept")
local remoteEvent3 = v2:RemoteEvent("DuelPartyLeave")
local remoteEvent4 = v2:RemoteEvent("DuelPartyReady")
local remoteEvent5 = v2:RemoteEvent("ItemDuelsInviteReceived")
local remoteEvent6 = v2:RemoteEvent("ItemDuelsAcceptInvite")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
playerGui:WaitForChild("DuelUI")
local duelPartyInvite = playerGui:WaitForChild("DuelPartyInvite")
local main = duelPartyInvite.Main
local readyButton = main.ReadyButton
local declineButton = main.DeclineButton
local invite = main.Invite
local main2 = playerGui:WaitForChild("DuelParty").Main
local players = main2.Players
local searchBox = main2.SearchBar.SearchBox
local closeButton = main2.CloseButton
local leaveButton = main2.LeaveButton
local readyButton2 = main2.ReadyButton
local teammatesPanel = main2.TeammatesPanel
local uIListLayout = teammatesPanel.UIListLayout
local _ = uIListLayout.Host
local member = uIListLayout.Member
local v5 = 0
local v6 = nil
local v7 = "DuelParty"
local playerRemovingConnection = nil
local v8 = nil
local DuelPartyController = {}

function updateSearchResults()
	for _, button in players:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local playerName = button:FindFirstChild("PlayerName")
		local displayName = button:FindFirstChild("DisplayName")

		if not (playerName and displayName) then
			continue
		end

		local v9 = string.find(string.lower(playerName.Text), string.lower(searchBox.Text), 1, true)
		local v10 = string.find(string.lower(displayName.Text), string.lower(searchBox.Text), 1, true)
		button.Visible = v9 or v10
	end
end

function onPartyInvite(p)
	v5 = 30
	v6 = p
	v7 = "DuelParty"

	if playerRemovingConnection then
		playerRemovingConnection:Disconnect()
	end

	playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if player == p then
			v5 = 0
		end
	end)
	invite.Text = `{p.Name} invited you to {v.isDuelLobbyServer() and "their duel team!" or "a duel!"}`
end

function createPlayerCard(p)
	if players:FindFirstChild(localPlayer.Name) or p == localPlayer then
		return
	end

	local clone = players:WaitForChild("UIListLayout"):WaitForChild("Player"):Clone()
	local playerName = clone:WaitForChild("PlayerName")
	local displayName = clone:WaitForChild("DisplayName")
	clone.Name = p.Name
	playerName.Text = p.Name
	displayName.Text = `@{p.DisplayName}`
	clone.Visible = not searchBox:IsFocused()
	clone.Activated:Connect(function()
		remoteEvent:FireServer(p)
	end)
	clone.Parent = players
end

function createPartyMemberCard(instance)
	local child = teammatesPanel:FindFirstChild(instance.UserId)
	local inDuelParty = instance:GetAttribute("InDuelParty")
	local v9 = inDuelParty and inDuelParty == tostring(instance.UserId)
	local visible = inDuelParty and inDuelParty == tostring(localPlayer.UserId) and instance.UserId ~= localPlayer.UserId
	local v11 = child or member:Clone()
	local playerIcon = v11:WaitForChild("PlayerIcon")
	local playerName = v11:WaitForChild("PlayerName")
	local removePlayerButton = v11:WaitForChild("RemovePlayerButton")
	v11.Name = instance.UserId
	playerName.Text = v9 and `{instance.Name} 👑` or instance.Name
	playerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=60&h=60`
	removePlayerButton.Visible = visible
	v11.LayoutOrder = v9 and 0 or 1
	playerName.Position = visible and UDim2.fromScale(0.605, 0.5) or UDim2.fromScale(0.534, 0.5)
	playerName.Size = visible and UDim2.fromScale(0.678, 0.374) or UDim2.fromScale(0.536, 0.366)

	if not child then
		removePlayerButton.Activated:Connect(function()
			remoteEvent3:FireServer(instance)
		end)
		instance:GetAttributeChangedSignal("InDuelParty"):Connect(displayParty)
	end

	v11.Parent = teammatesPanel
end

function displayParty()
	local parties = v8:Get("Parties")
	local inDuelParty = localPlayer:GetAttribute("InDuelParty")
	local v9 = inDuelParty and parties[inDuelParty] or parties[tostring(localPlayer.UserId)] or {
		Members = {}
	}

	for k, _ in v9.Members do
		createPartyMemberCard(Players:GetPlayerByUserId(k))
	end

	createPartyMemberCard(localPlayer)

	for _, frame in teammatesPanel:GetChildren() do
		if not frame:IsA("Frame") or v9.Members[frame.Name] or frame.Name == tostring(localPlayer.UserId) then
			continue
		end

		frame:Destroy()
	end

	leaveButton.Visible = inDuelParty
end

function DuelPartyController.Start(_)
	v8 = v3.Client:WaitReplion("DuelParties")
	closeButton.Activated:Connect(function()
		v4:Close("DuelParty")
	end)
	leaveButton.Activated:Connect(function()
		remoteEvent3:FireServer()
	end)
	readyButton2.Activated:Connect(function()
		remoteEvent4:FireServer()
	end)
	readyButton2.Visible = not v.isDuelLobbyServer()
	readyButton.Activated:Connect(function()
		v5 = 0

		if v7 == "ItemDuels" then
			remoteEvent6:FireServer(v6)
		else
			remoteEvent2:FireServer(v6)
		end
	end)
	declineButton.Activated:Connect(function()
		v5 = 0
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		onPartyInvite(p)
	end)
	remoteEvent5.OnClientEvent:Connect(function(player)
		if typeof(player) ~= "Instance" or not player:IsA("Player") then
			return
		end

		v5 = 30
		v6 = player
		v7 = "ItemDuels"

		if playerRemovingConnection then
			playerRemovingConnection:Disconnect()
		end

		playerRemovingConnection = Players.PlayerRemoving:Connect(function(player2)
			if player2 == player then
				v5 = 0
			end
		end)
		invite.Text = `{player.DisplayName} challenged you to a item duel!`
	end)
	displayParty()
	v8:OnChange("Parties", displayParty)
	localPlayer:GetAttributeChangedSignal("InDuelParty"):Connect(displayParty)
	searchBox:GetPropertyChangedSignal("Text"):Connect(updateSearchResults)

	for _, v9 in Players:GetPlayers() do
		task.spawn(createPlayerCard, v9)
	end

	Players.PlayerAdded:Connect(createPlayerCard)
	Players.PlayerRemoving:Connect(function(player)
		local child = players:FindFirstChild(player.Name)

		if child then
			child:Destroy()
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		if v5 > 0 then
			v5 = math.max(0, v5 - dt)
		end

		duelPartyInvite.Enabled = v5 > 0
	end)
end

return DuelPartyController