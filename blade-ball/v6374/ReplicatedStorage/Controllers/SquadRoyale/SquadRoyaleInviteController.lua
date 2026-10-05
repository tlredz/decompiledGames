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
local v2 = require3(ReplicatedStorage3.Packages.Net)
local v3 = require3(ReplicatedStorage3.Packages.Freeze)
local v4 = require3(ReplicatedStorage3.Packages.Replion)
local v5 = require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage3.Controllers.NotificationController)
local remoteEvent = v2:RemoteEvent("SquadRoyaleInvite")
local remoteEvent2 = v2:RemoteEvent("SquadRoyaleInviteAccept")
local remoteEvent3 = v2:RemoteEvent("SquadRoyaleInviteLeave")
local remoteEvent4 = v2:RemoteEvent("SquadRoyaleInviteReady")
local remoteEvent5 = v2:RemoteEvent("SetSquadRoyaleAutofill")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local squadRoyaleInvite = playerGui.SquadRoyaleInvite
local main = squadRoyaleInvite.Main
local squadRoyaleInvitePrompt = playerGui.SquadRoyaleInvitePrompt
local main2 = squadRoyaleInvitePrompt.Main
local squadRoyaleInviteList = playerGui.SquadRoyaleInviteList
local main3 = squadRoyaleInviteList.Main
local players = main3.Players
local searchBox = main3.SearchBar.SearchBox
local teammatesPanel = main3.TeammatesPanel
local v7 = 0
local v8 = nil
local playerRemovingConnection = nil
local v9 = nil
local SquadRoyaleInviteController = {}

local function updateSearchResults()
	for _, button in players:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local playerName = button:FindFirstChild("PlayerName")
		local displayName = button:FindFirstChild("DisplayName")

		if not (playerName and displayName) then
			continue
		end

		local v10 = string.find(string.lower(playerName.Text), string.lower(searchBox.Text), 1, true)
		local v11 = string.find(string.lower(displayName.Text), string.lower(searchBox.Text), 1, true)
		button.Visible = v10 or v11
	end
end

local function onPartyInvite(p)
	v7 = 30
	v8 = p

	if playerRemovingConnection then
		playerRemovingConnection:Disconnect()
	end

	playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if player == p then
			v7 = 0
		end
	end)
	main2.Invite.Text = `{p.Name} invited you to a Squad Royale party!`
end

local function createPlayerCard(player)
	local userId = tostring(player.UserId)

	if players:FindFirstChild(userId) or player == localPlayer then
		return
	end

	local clone = players.UIListLayout.Player:Clone()
	clone.Name = userId
	clone.PlayerName.Text = player.Name
	clone.DisplayName.Text = `@{player.DisplayName}`
	clone.Visible = not (searchBox:IsFocused() or player:GetAttribute("InSquadRoyaleInvite"))
	player:GetAttributeChangedSignal("InSquadRoyaleInvite"):Connect(function()
		clone.Visible = not (searchBox:IsFocused() or player:GetAttribute("InSquadRoyaleInvite"))
	end)
	clone.Activated:Connect(function()
		if not player:GetAttribute("InSquadRoyaleInvite") then
			remoteEvent:FireServer(player)
			return
		end

		v6:SendNotification((`{player.Name} is already in a party!`))
		ReplicatedStorage3.Misc.error:Play()
	end)
	clone.Parent = players
end

local function createPartyMemberCardInList(instance)
	local child = teammatesPanel:FindFirstChild(instance.UserId)
	local inSquadRoyaleInvite = instance:GetAttribute("InSquadRoyaleInvite")
	local v10 = inSquadRoyaleInvite and inSquadRoyaleInvite == tostring(instance.UserId)
	local visible = inSquadRoyaleInvite and inSquadRoyaleInvite == tostring(localPlayer.UserId) and instance.UserId ~= localPlayer.UserId
	local v12 = child or teammatesPanel.UIListLayout.Member:Clone()
	v12.Name = tostring(instance.UserId)
	local playerName = v12.PlayerName
	local text

	if v10 then
		text = `{instance.Name} 👑`
	else
		text = instance.Name
	end

	playerName.Text = text
	v12.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=60&h=60`
	v12.RemovePlayerButton.Visible = visible
	v12.LayoutOrder = v10 and 0 or 1
	local playerName2 = v12.PlayerName
	local position

	if visible then
		position = UDim2.fromScale(0.605, 0.5)
	else
		position = UDim2.fromScale(0.534, 0.5)
	end

	playerName2.Position = position
	local playerName3 = v12.PlayerName
	local size

	if visible then
		size = UDim2.fromScale(0.678, 0.374)
	else
		size = UDim2.fromScale(0.536, 0.366)
	end

	playerName3.Size = size

	if not child then
		v12.RemovePlayerButton.Activated:Connect(function()
			remoteEvent3:FireServer(instance)
		end)
		local inSquadRoyaleInviteChangedConnection = instance:GetAttributeChangedSignal("InSquadRoyaleInvite"):Connect(updatePartyMembers)
		v12.Destroying:Once(function()
			inSquadRoyaleInviteChangedConnection:Disconnect()
		end)
	end

	v12.Parent = teammatesPanel
end

local template = main.PlayerList.List.UIListLayout.Template

local function createPartyMemberCard(instance)
	local child = main.PlayerList.List:FindFirstChild(instance.UserId)
	local inSquadRoyaleInvite = instance:GetAttribute("InSquadRoyaleInvite")
	local visible = inSquadRoyaleInvite and inSquadRoyaleInvite == tostring(instance.UserId)
	local v11 = inSquadRoyaleInvite and inSquadRoyaleInvite == tostring(localPlayer.UserId)
	local v12 = child or template:Clone()
	v12.Name = tostring(instance.UserId)
	v12.PlayerName.Text = instance.Name
	v12.PlayerImage.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=100&h=100`
	v12.LayoutOrder = visible and 0 or 1
	v12.Kick.Visible = v11 and instance ~= localPlayer
	v12.Owner.Visible = visible

	if not child then
		v12.Kick.Activated:Connect(function()
			remoteEvent3:FireServer(instance)
		end)
		local inSquadRoyaleInviteChangedConnection = instance:GetAttributeChangedSignal("InSquadRoyaleInvite"):Connect(updatePartyMembers)
		v12.Destroying:Once(function()
			inSquadRoyaleInviteChangedConnection:Disconnect()
		end)
	end

	v12.Parent = main.PlayerList.List
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePartyMemberCard(p)
	createPartyMemberCardInList(p)
	createPartyMemberCard(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removePartyMemberCard(userId: number)
	local child = teammatesPanel:FindFirstChild((tostring(userId)))

	if child then
		child:Destroy()
	end

	local child2 = main.PlayerList.List:FindFirstChild((tostring(userId)))

	if child2 then
		child2:Destroy()
	end
end

function updatePartyMembers()
	local parties = v9:Get("Parties")
	local inSquadRoyaleInvite = localPlayer:GetAttribute("InSquadRoyaleInvite")
	local v10 = inSquadRoyaleInvite and inSquadRoyaleInvite == tostring(localPlayer.UserId)
	local v11 = inSquadRoyaleInvite and parties[inSquadRoyaleInvite] or parties[tostring(localPlayer.UserId)] or {
		Members = {}
	}

	for k in v11.Members do
		local playerByUserId = Players:GetPlayerByUserId((tonumber(k)))

		if not playerByUserId then
			continue
		end

		updatePartyMemberCard(playerByUserId) -- equivalent call inferred; original call site unknown
	end

	updatePartyMemberCard(localPlayer) -- equivalent call inferred; original call site unknown
	local count = v3.Dictionary.count(v11.Members)

	for i = 1, 3 do
		local child = main.PlayerList.List:FindFirstChild((`Add_{i}`))

		if child then
			child.Visible = count - 1 < i
		end
	end

	for _, guiObject in teammatesPanel:GetChildren() do
		if not guiObject:IsA("GuiObject") or v11.Members[guiObject.Name] or guiObject.Name == tostring(localPlayer.UserId) then
			continue
		end

		guiObject:Destroy()
	end

	for _, guiObject in main.PlayerList.List:GetChildren() do
		if not guiObject:IsA("GuiObject") or v11.Members[guiObject.Name] or guiObject.Name == tostring(localPlayer.UserId) then
			continue
		end

		if string.find(guiObject.Name, "Add_%d*") then
			continue
		end

		guiObject:Destroy()
	end

	main.Buttons.Leave.Visible = inSquadRoyaleInvite
	main.Buttons.Autofill.Visible = v10 or not inSquadRoyaleInvite
	main.Buttons.Autofill.Image = localPlayer:GetAttribute("SquadRoyaleAutofill") and "rbxassetid://75616120281849" or "rbxassetid://134300140675607"
	main.Buttons.Play.Visible = v10 or not inSquadRoyaleInvite
end

function SquadRoyaleInviteController.Start(_)
	if v.isLTMServer() then
		return
	end

	v9 = v4.Client:WaitReplion("SquadRoyaleParties")
	main3.CloseButton.Activated:Connect(function()
		v5:Open(squadRoyaleInvite.Name)
	end)
	main2.ReadyButton.Activated:Connect(function()
		v7 = 0
		remoteEvent2:FireServer(v8)
	end)
	main2.DeclineButton.Activated:Connect(function()
		v7 = 0
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		onPartyInvite(p)
	end)
	main.Close.Activated:Connect(function()
		v5:Close(squadRoyaleInvite.Name)
	end)
	main.Buttons.Autofill.Activated:Connect(function()
		remoteEvent5:FireServer()
	end)
	main.Buttons.Play.Activated:Connect(function()
		remoteEvent4:FireServer()
	end)
	main.Buttons.Leave.Activated:Connect(function()
		remoteEvent3:FireServer()
	end)

	for i = 1, 3 do
		local clone = main.PlayerList.List.UIListLayout.Add:Clone()
		clone.Name = `Add_{i}`
		clone.Parent = main.PlayerList.List
		clone.Activated:Connect(function()
			v5:Open(squadRoyaleInviteList.Name)
		end)
	end

	task.spawn(updatePartyMembers)
	v9:OnChange("Parties", updatePartyMembers)
	localPlayer:GetAttributeChangedSignal("InSquadRoyaleInvite"):Connect(updatePartyMembers)
	localPlayer:GetAttributeChangedSignal("SquadRoyaleAutofill"):Connect(updatePartyMembers)
	searchBox:GetPropertyChangedSignal("Text"):Connect(updateSearchResults)

	for _, v10 in Players:GetPlayers() do
		task.spawn(createPlayerCard, v10)
	end

	Players.PlayerAdded:Connect(createPlayerCard)
	Players.PlayerRemoving:Connect(function(player)
		removePartyMemberCard(player.UserId) -- equivalent call inferred; original call site unknown
	end)
	RunService.PostSimulation:Connect(function(dt)
		if v7 > 0 then
			v7 = math.max(0, v7 - dt)
		end

		squadRoyaleInvitePrompt.Enabled = v7 > 0
	end)
end

return SquadRoyaleInviteController