local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage4:WaitForChild("Remotes")
local getTableFromInstance = require(script.getTableFromInstance)
local players = getTableFromInstance(game.Players).Players
local v = {}
local parent = script.Parent.Parent
local lobby = script.Parent.Parent:WaitForChild("Lobby")
lobby:WaitForChild("Screens")
parent:WaitForChild("Game")
local viewProfileModule = game.ReplicatedStorage.Modules.ViewProfileModule
local module = require(viewProfileModule)
local viewProfile = lobby.ViewProfile
WindowService:RegisterFrame(viewProfile, "ViewProfile")
module.GUI.ProfileContainer = viewProfile.Main.Profile.Container.ScrollingFrame
module.GUI.SearchFrameTextBox = viewProfile.Main.Weapons.TitleBar.Container.Search.Container.SearchText
local TradeModule = require(game.ReplicatedStorage.Modules.TradeModule)
local LevelModule = require(game.ReplicatedStorage.Modules.LevelModule)
local v2 = {
	[0] = "",
	[1] = "I",
	[2] = "II",
	[3] = "III",
	[4] = "IV",
	[5] = "V",
	[6] = "VI",
	[7] = "VII",
	[8] = "VIII",
	[9] = "IX",
	[10] = "X"
}
local RankIconsEmpty = require(game.ReplicatedStorage.RankIconsEmpty)
local _ = Sync.NameTags
local color = Color3.fromRGB(232, 42, 42)
local leaderboard = lobby:WaitForChild("Leaderboard")
local leaderBar = lobby:WaitForChild("LeaderBar")
local gameBar = lobby:WaitForChild("GameBar")
local playerList = leaderboard:WaitForChild("Container"):WaitForChild("PlayerList")
local popup = leaderboard:WaitForChild("Popup")
local v3 = nil

local function UpdateLeaderboard()
	local v4 = {}

	for childName, player in pairs(players) do
		if game.Players:FindFirstChild(childName) then
			table.insert(v4, {
				PlayerName = childName,
				Level = player.Level,
				Elite = player.Elite,
				Prestige = player.Prestige or 0,
				XP = player.XP
			})
		end
	end

	table.sort(v4, function(a, b)
		local prestige = a.Prestige or 0
		local prestige2 = b.Prestige or 0
		local level = a.Level or 0
		local level2 = b.Level or 0
		local v5 = (prestige or 0) * 100 + level
		return (prestige2 or 0) * 100 + level2 < v5
	end)
	local count = #v4
	leaderBar.Main.Players.PlayerCount.Text = count or 1
	gameBar.Main.Players.PlayerCount.Text = count or 1
	local itemSizer = leaderboard.Container:FindFirstChild("ItemSizer")
	local Y

	if itemSizer then
		Y = itemSizer.AbsoluteSize.Y
	end

	if Y then
		local cellSize = playerList.GridLayout.CellSize
		playerList.GridLayout.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, Y)
	end

	for k, v5 in pairs(v4) do
		local playerName = v5.PlayerName
		local clone = v[playerName]
		local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
			math.abs(game.Players[playerName].userId),
			Enum.ThumbnailType.AvatarBust,
			Enum.ThumbnailSize.Size352x352
		) or ""

		if clone == nil then
			clone = script.Player_Frame:Clone()
			clone.UsernameFrame.PlayerLabel.Text = (v5.Elite == true and "[ELITE] " or "") .. playerName
			clone.UsernameFrame.PlayerLabel.TextColor3 = v5.Elite == true and color or Color3.new(1, 1, 1)
			local text = playerName
			local image = userThumbnailAsync
			clone.ActionButton.MouseButton1Click:connect(function()
				local v8 = v3 == text
				v3 = text
				popup.Container.Username.Text = text
				popup.Container.Action.Trade.Style = v3 == game.Players.LocalPlayer.Name and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton
				popup.Container.IconContainer.PlayerIcon.Image = image
				popup.Visible = true
			end)
			clone.Name = playerName
			clone.Parent = playerList
			v[playerName] = clone
		end

		clone.Icon.Image = userThumbnailAsync
		clone.Level.Level.Text = LevelModule.GetLevel(v5.XP)
		clone.Level.Prestige.Text = v2[v5.Prestige]
		clone.Level.Image = RankIconsEmpty[v5.Level or 1]
		clone.LayoutOrder = k

		if game.Players:FindFirstChild(playerName) == nil then
			v[playerName] = nil
			clone:Destroy()
			v4[k] = nil
		end

		leaderboard.Container.PlayerList.CanvasSize = UDim2.new(0, 0, 0, (clone.AbsoluteSize.Y + 9) * #v4)
	end

	for _, child in pairs(playerList:GetChildren()) do
		if not (child:FindFirstChild("IsPlayerFrame") and game.Players:FindFirstChild(child.Name) == nil) then
			continue
		end

		child:Destroy()
	end
end

UpdateLeaderboard()
game.ReplicatedStorage.Remotes.Misc.UpdateLeaderboard.OnClientEvent:connect(function(_)
	players = getTableFromInstance(game.Players).Players
	UpdateLeaderboard()
end)
popup.Container.Close.MouseButton1Click:connect(function()
	popup.Visible = false
	v3 = nil
end)
popup.Close2.MouseButton1Click:connect(function()
	popup.Visible = false
	v3 = nil
end)
local PolicyService = game:GetService("PolicyService")
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer)
end)

if success then
	if not result.IsPaidItemTradingAllowed then
		popup.Container.Action.Trade.Visible = false
		TradeModule.RequestsEnabled = false
		return "Trading Not Allowed"
	end
else
	warn("PolicyService error: " .. result)
end

if not (LevelModule.GetLevel(ProfileData.NewXP) >= 10 or ProfileData.Prestige > 0) then
	popup.Container.Action.Trade.Visible = false
	leaderboard.Container.Title.Tooltip.Visible = false
	leaderboard.Container.Title.Unlock.Visible = true
	TradeModule.RequestsEnabled = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateServerRestartNotification()
	if workspace:GetAttribute("ServerRestarting") then
		leaderboard.Container.Title.Tooltip.Text = "⚠️ Trading Unavailable"
	end
end

workspace:GetAttributeChangedSignal("ServerRestarting"):Connect(updateServerRestartNotification)
updateServerRestartNotification() -- equivalent call inferred; original call site unknown
popup.Container.Action.Trade.Activated:Connect(function()
	TradeModule.SendTradeRequest(v3)
	popup.Visible = false
end)
popup.Container.Action.ViewProfile.MouseButton1Click:connect(function()
	local v4 = game.ReplicatedStorage.Remotes.Misc.GetPlayerProfile:InvokeServer(v3)
	popup.Visible = false
	module.GenerateProfile(viewProfile, v3, v4, viewProfileModule.Phone.ViewProfileGridLayout)
	WindowService:AddToStack("ViewProfile")
end)
leaderboard.Container.Close.MouseButton1Click:Connect(function()
	leaderboard.Visible = false
end)
viewProfile.Nav.Close.MouseButton1Click:Connect(function()
	WindowService:Back()
end)
leaderBar.Main.Plus.Button.Activated:Connect(function()
	WindowService:ToggleFrame("Leaderboard")
end)
gameBar.Main.Plus.Button.Activated:Connect(function()
	WindowService:ToggleFrame("Leaderboard")
end)
module.ConnectViewProfile(viewProfile)
local container = viewProfile.Main.Weapons.Items.Container
container.Holiday.Container.EventLayout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
	container.Holiday.Container.Size = UDim2.new(
		1,
		0,
		0,
		container.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 3
	)
	container.Holiday.CanvasSize = UDim2.new(1, 0, 0, container.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 6)
end)
local _ = {
	Disguises = 335132309,
	Assassin = 636649648
}
local v4 = {
	[142823291] = "MM2",
	[188331334] = "Testing",
	[335132309] = "Hardcore",
	[333740520] = "Testing",
	[636649648] = "Assassin",
	[594100598] = "Testing"
}
local friendsOnline = lobby.FriendsOnline
local container2 = friendsOnline.Main.ScrollFrame.Container
local TeleportService = game:GetService("TeleportService")
local now = -11
local FriendsModule = require(game.ReplicatedStorage.Modules.FriendsModule)
leaderBar:WaitForChild("Main")
local RunService = game:GetService("RunService")
RunService.PostSimulation:Connect(function(_: number)
	if os.clock() - now >= 10 then
		now = os.clock()
		local friendsOnline2 = FriendsModule:GetFriendsOnline()
		container2:ClearAllChildren()
		local clone = script:WaitForChild("FriendLayout"):Clone()
		clone.Parent = container2
		local Y = friendsOnline.Main:FindFirstChild("ItemSizer").AbsoluteSize.Y
		local cellSize = clone.CellSize
		clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, Y)
		local count = 0

		for _, v5 in pairs(friendsOnline2) do
			if not v4[v5.PlaceId] then
				continue
			end

			count += 1
			local clone2 = script.FriendFrame:Clone()
			clone2.PlayerName.Username.Text = v5.UserName
			local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
				math.abs(v5.VisitorId),
				Enum.ThumbnailType.AvatarBust,
				Enum.ThumbnailSize.Size352x352
			) or ""
			clone2.Icon.Image = userThumbnailAsync
			clone2.GameModeName.Text = v5.PlaceId == 636649648 and "Assassin" or v5.PlaceId == 335132309 and "Disguises" or ""
			clone2.Parent = container2
			local v6 = v5
			clone2.Join.MouseButton1Click:connect(function()
				friendsOnline.Main.Visible = false
				friendsOnline.Teleporting.Visible = true
				TeleportService:TeleportToPlaceInstance(v6.PlaceId, v6.GameId, game.Players.LocalPlayer, "", {
					Joined = true
				})
				wait(5)
				friendsOnline.Teleporting.Visible = false
				friendsOnline.Retry.Visible = true
			end)
		end

		leaderBar.Main.Friends.Container.Friends.Text = count
		leaderBar.Main.Friends.Visible = count > 0
		gameBar.Main.Friends.FriendsCount.Text = count
		gameBar.Main.Friends.Visible = count > 0
		leaderboard.Container.OverlayMenu.Friends.OnlineCount.Text = count .. " Friend" .. (count > 1 and "s" or "") .. " Online"
		leaderboard.Container.OverlayMenu.Friends.Visible = count > 0
	end
end)
leaderboard.Container.OverlayMenu.Friends.View.MouseButton1Click:connect(function()
	leaderboard.Visible = false
	friendsOnline.Visible = true
end)
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function canSendGameInvite(p, p2)
	local success2, result2 = pcall(function()
		return SocialService:CanSendGameInviteAsync(p, p2)
	end)
	return success2 and result2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openInvites()
	if canSendGameInvite(localPlayer, nil) then
		local _, _ = pcall(function()
			SocialService:PromptGameInvite(localPlayer)
		end)
	end
end

leaderboard.Container.Extras.Invite.Button.Activated:Connect(function()
	openInvites() -- equivalent call inferred; original call site unknown
end)

repeat
	task.wait()
until WindowService:GetFrame("ModeBrowser")

local frame = WindowService:GetFrame("ModeBrowser")
WindowService:RegisterFrame(leaderboard, "Leaderboard")
leaderboard.Container.Extras.Modes.Button.Activated:Connect(function()
	frame.Size = UDim2.new(1, 0, 1, 0)
	WindowService:AddToStack("ModeBrowser")
end)
frame.Container.Title.Close.Button.Activated:Connect(function()
	WindowService:Back()
end)
WindowService:RegisterFrame(friendsOnline, "FriendsOnline")
friendsOnline.Retry.Back.MouseButton1Click:connect(function()
	friendsOnline.Retry.Visible = false
end)
friendsOnline.Title.Close.MouseButton1Click:connect(function()
	WindowService:ToggleFrame("Leaderboard")
end)
local level = leaderBar.Main.Level

function UpdateLevel()
	local newXP = ProfileData.NewXP
	local xPBar = level:WaitForChild("XPBar")
	level.Level.Text = LevelModule.GetLevel(newXP)
	local progressToNextLevel = LevelModule.GetProgressToNextLevel(newXP)
	xPBar.Size = UDim2.new(progressToNextLevel, xPBar.Size.X.Offset, xPBar.Size.Y.Scale, xPBar.Size.Y.Offset)
end

remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged").Event:Connect(function(p, _)
	if p == "NewXP" then
		UpdateLevel()
	end
end)
UpdateLevel()