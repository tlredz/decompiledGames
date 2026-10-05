local game2 = script.Parent.Parent.Game
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
local ViewProfileModule = require(game.ReplicatedStorage.Modules.ViewProfileModule)
local viewProfile = script.Parent.Parent.Game.ViewProfile
ViewProfileModule.GUI.ProfileContainer = viewProfile.Main.Profile.Container
ViewProfileModule.GUI.SearchFrameTextBox = viewProfile.Main.Weapons.Items.Tabs.Search.Container.SearchText
local TradeModule = require(game.ReplicatedStorage.Modules.TradeModule)
local LevelModule = require(game.ReplicatedStorage.Modules.LevelModule)
_G.LeaderboardOpen = _G.LeaderboardOpen == nil or _G.LeaderboardOpen
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
local v3 = {
	[true] = "^",
	[false] = "v"
}
local RankIconsEmpty = require(game.ReplicatedStorage.RankIconsEmpty)
local _ = Sync.NameTags
local color = Color3.fromRGB(232, 42, 42)
local leaderboard = script.Parent.Parent.Game.Leaderboard
local v4 = nil
local inspect = leaderboard.Inspect
local robloxRoundDefaultButton = Enum.ButtonStyle.RobloxRoundDefaultButton
local robloxRoundButton = Enum.ButtonStyle.RobloxRoundButton

local function UpdateLeaderboard()
	local v5 = {}

	for childName, player in pairs(players) do
		if game.Players:FindFirstChild(childName) then
			table.insert(v5, {
				PlayerName = childName,
				Level = player.Level or 1,
				Elite = player.Elite,
				Prestige = player.Prestige or 0,
				XP = player.XP or 0
			})
		end
	end

	table.sort(v5, function(a, b)
		return (a.Prestige or 0) * 100 + (a.Level or 1) > (b.Prestige or 0) * 100 + (b.Level or 1)
	end)

	for k, v6 in pairs(v5) do
		local playerName = v6.PlayerName
		local clone = v[playerName]

		if clone == nil or clone.Parent == nil then
			clone = script.Player_Frame:Clone()
			local visible = playerName == game.Players.LocalPlayer.Name
			clone.PlayerLabel.Text = (v6.Elite == true and "[ELITE] " or "") .. playerName
			clone.PlayerLabel.TextColor3 = v6.Elite == true and color or Color3.new(1, 1, 1)
			clone.XPBar.Visible = visible

			if visible then
				-- equivalent calls inferred from this helper; original call sites unknown
				local v8 = clone

				local function updateXPBar()
					local newXP = ProfileData.NewXP
					local progressToNextLevel = LevelModule.GetProgressToNextLevel(newXP)
					local bar = v8.XPBar.Bar
					bar.Size = UDim2.new(progressToNextLevel, bar.Size.X.Offset, bar.Size.Y.Scale, bar.Size.Y.Offset)
				end

				updateXPBar() -- equivalent call inferred; original call site unknown
				local v9 = clone
				local v10 = v6
				remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged").Event:Connect(function(p, p2)
					if p == "NewXP" or p == "Prestige" then
						updateXPBar() -- equivalent call inferred; original call site unknown
						local v11 = LevelModule.GetLevel(v10.XP) >= 100
						inspect.Container.Prestige.Style = v11 and robloxRoundDefaultButton or robloxRoundButton
					end
				end)
			end

			local text = playerName
			local v9 = clone
			local v11 = v6
			clone.ActionButton.Activated:Connect(function()
				local v12 = v4 == text
				v4 = text
				inspect.Container.Username.Text = text
				inspect.Position = UDim2.new(inspect.Position.X, UDim.new(0, v9.AbsolutePosition.Y + 45))
				inspect.Container.Trade.Visible = not visible and true
				inspect.Container.Prestige.Visible = visible

				if visible then
					local v13 = LevelModule.GetLevel(v11.XP) >= 100
					inspect.Container.Prestige.Style = v13 and robloxRoundDefaultButton or robloxRoundButton
				end

				if v12 then
					inspect.Visible = not inspect.Visible
				else
					inspect.Visible = true
				end
			end)
			clone.Visible = _G.LeaderboardOpen
			clone.Name = playerName
			clone.Parent = leaderboard.Container
			v[playerName] = clone
		end

		clone.Level.Prestige.Text = v2[tonumber(v6.Prestige)]
		clone.Level.Level.Text = LevelModule.GetLevel(v6.XP) or "?"
		clone.Level.Image = RankIconsEmpty[v6.Level]
		clone.LayoutOrder = k

		if game.Players:FindFirstChild(playerName) ~= nil then
			continue
		end

		v[playerName] = nil
		clone:Destroy()
		v5[k] = nil
	end

	for _, child in pairs(leaderboard.Container:GetChildren()) do
		if not (child:FindFirstChild("IsPlayerFrame") and game.Players:FindFirstChild(child.Name) == nil) then
			continue
		end

		child:Destroy()
	end
end

UpdateLeaderboard()

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateLeaderboardVisibility()
	for _, v5 in pairs(v) do
		v5.Visible = _G.LeaderboardOpen
	end

	leaderboard.Container.Close.Title.Text = v3[_G.LeaderboardOpen]
end

UpdateLeaderboardVisibility() -- equivalent call inferred; original call site unknown
WindowService:RegisterFrame(viewProfile, "ViewProfile")
inspect.Container.Profile.Activated:Connect(function()
	local v5 = game.ReplicatedStorage.Remotes.Misc.GetPlayerProfile:InvokeServer(v4)
	inspect.Visible = false
	ViewProfileModule.GenerateProfile(viewProfile, v4, v5)
	WindowService:ViewFrame("ViewProfile")
end)
local _ = game.GameId == 119460199
inspect.Container.Trade.MouseButton1Click:Connect(function()
	TradeModule.SendTradeRequest(v4)
	inspect.Visible = false
end)
inspect.Close.MouseButton1Click:Connect(function()
	v4 = nil
	inspect.Visible = false
end)
game.ReplicatedStorage.Remotes.Misc.UpdateLeaderboard.OnClientEvent:connect(function(_)
	players = getTableFromInstance(game.Players).Players
	UpdateLeaderboard()
end)
leaderboard.Container.Close.Toggle.MouseButton1Click:connect(function()
	_G.LeaderboardOpen = not _G.LeaderboardOpen
	UpdateLeaderboardVisibility() -- equivalent call inferred; original call site unknown
end)
ViewProfileModule.ConnectViewProfile(viewProfile)
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
local _ = viewProfile.Main.Weapons.Items.Tabs.Search.Container.SearchText
local visible2 = LevelModule.GetLevel(ProfileData.NewXP) >= 10 or ProfileData.Prestige > 0
leaderboard.Container.ToggleRequests.Visible = visible2
leaderboard.Container.TradeInfo.Visible = visible2
leaderboard.Container.MinimumTradeLevel.Visible = not visible2

if not visible2 then
	TradeModule.RequestsEnabled = false
end

remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged").Event:Connect(function(p, _)
	if p == "NewXP" then
		local visible = LevelModule.GetLevel(ProfileData.NewXP) >= 10 or ProfileData.Prestige > 0
		leaderboard.Container.ToggleRequests.Visible = visible
		leaderboard.Container.TradeInfo.Visible = visible
		leaderboard.Container.MinimumTradeLevel.Visible = not visible

		if not visible then
			TradeModule.RequestsEnabled = false
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateServerRestartNotification()
	if workspace:GetAttribute("ServerRestarting") then
		leaderboard.Container.TradeInfo.Title.Text = "⚠️ Trading Unavailable"
	end
end

workspace:GetAttributeChangedSignal("ServerRestarting"):Connect(updateServerRestartNotification)
updateServerRestartNotification() -- equivalent call inferred; original call site unknown
game.ReplicatedStorage.Remotes.Extras.Admin.OnClientEvent:Connect(function(p, p2)
	if p == "CheckInventory" then
		ViewProfileModule.DisplayInventoryFromData(viewProfile, "Player", p2)
		WindowService:ViewFrame("ViewProfile")
	end
end)
local now = -100
local TeleportService = game:GetService("TeleportService")
local friendsOnline = leaderboard.Container.FriendsOnline
local friendsOnline2 = game2.FriendsOnline
local container2 = friendsOnline2.Main.ScrollFrame.Container
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v6 = {
	[142823291] = "Standard",
	[335132309] = "Disguises",
	[636649648] = "Assassin"
}
friendsOnline2.Title.Close.MouseButton1Click:connect(function()
	friendsOnline2.Visible = false
end)
friendsOnline2.Retry.Back.MouseButton1Click:connect(function()
	friendsOnline2.Retry.Visible = false
	friendsOnline2.Main.Visible = true
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function canSendGameInvite(p, p2)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p, p2)
	end)
	return success, result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openInvites()
	local success, _ = canSendGameInvite(localPlayer, nil) -- equivalent call inferred; original call site unknown

	if success then
		local _, _ = pcall(function()
			SocialService:PromptGameInvite(localPlayer)
		end)
	end
end

local function invitePlayer(experienceInviteOptions)
	local success2, result2 = canSendGameInvite(localPlayer, experienceInviteOptions.InviteUser) -- equivalent call inferred; original call site unknown

	if success2 then
		local success, result = pcall(function()
			SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
		end)

		if not success then
			warn(result)
		end
	else
		warn(success2, result2)
	end
end

friendsOnline2.Title.Invite.Activated:Connect(function()
	openInvites() -- equivalent call inferred; original call site unknown
end)
friendsOnline2.Title.Modes.Activated:Connect(function()
	WindowService:ToggleFrame("ModeBrowser")
end)
local count = 0
friendsOnline.Join.Activated:connect(function()
	if count > 0 then
		WindowService:ToggleFrame("FriendsOnline")
		return
	end

	openInvites() -- equivalent call inferred; original call site unknown
end)
WindowService:RegisterFrame(friendsOnline2, "FriendsOnline")
local FriendsModule = require(game.ReplicatedStorage.Modules.FriendsModule)
local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
	if os.clock() - now >= 1 and game.Players.LocalPlayer.PlayerGui:FindFirstChild("ESP") ~= nil then
		game.Players.LocalPlayer:Kick("You have been banned from MM2.")
	end

	if os.clock() - now >= 10 then
		now = os.clock()
		local friendsOnline3 = FriendsModule:GetFriendsOnline()
		container2:ClearAllChildren()
		count = 0

		for _, v7 in pairs(friendsOnline3) do
			if not v6[v7.PlaceId] then
				continue
			end

			local clone = script.Friend:Clone()
			local nameFromUserIdAsync = game.Players:GetNameFromUserIdAsync(v7.VisitorId)
			clone.PlayerName.Text = nameFromUserIdAsync
			clone.GameMode.Text = v7.PlaceId == 335132309 and "Disguises" or v7.PlaceId == 636649648 and "Assassin" or ""
			clone.Position = UDim2.new(0, 0, 0, clone.Size.Y.Offset * count)
			clone.Parent = container2
			local child = game.Players:FindFirstChild(nameFromUserIdAsync)
			clone.Join.Visible = not child
			clone.Invite.Visible = not child
			clone.IsInServer.Visible = child
			local v8 = v7
			clone.Invite.Activated:Connect(function()
				local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
				experienceInviteOptions.InviteUser = v8.VisitorId
				invitePlayer(experienceInviteOptions)
			end)
			local v9 = v7
			clone.Join.Activated:connect(function()
				friendsOnline2.Main.Visible = false
				friendsOnline2.Teleporting.Visible = true
				TeleportService:TeleportToPlaceInstance(v9.PlaceId, v9.GameId, game.Players.LocalPlayer, "", {
					Joined = true
				})
				wait(5)
				friendsOnline2.Teleporting.Visible = false
				friendsOnline2.Retry.Visible = true
				spawn(function()
					while friendsOnline2.Retry.Visible == true do
						friendsOnline2.Retry.Spinner.Rotation = friendsOnline2.Retry.Spinner.Rotation + 5
						local RunService2 = game:GetService("RunService")
						RunService2.RenderStepped:wait()
					end
				end)
				spawn(function()
					local v10 = 1

					while friendsOnline2.Retry.Visible == true do
						friendsOnline2.Retry.Retrying.Text = "Retrying... (" .. v10 .. ")"
						TeleportService:TeleportToPlaceInstance(v9.PlaceId, v9.GameId, game.Players.LocalPlayer, "", {
							Joined = true
						})

						for i = 1, 50 do
							wait(0.1)

							if not friendsOnline2.Retry.Visible then
								break
							end
						end

						v10 += 1
					end
				end)
			end)
			count += 1
		end

		friendsOnline.Title.Text = "Friends Playing: " .. count
		friendsOnline.Join.Visible = true
	end
end)