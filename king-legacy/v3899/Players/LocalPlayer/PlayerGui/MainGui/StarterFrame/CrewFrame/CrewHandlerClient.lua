local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local crewAssets = script:WaitForChild("CrewAssets")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PanelWhitelists = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets").Modules.Features.PanelWhitelists)
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
game:GetService("TeleportService")
local flag = nil
local v = true
local crewInfo = parent.CrewInfo
local invites = parent.Invites
local achievement = parent.Achievement
local leaderboards = parent.Leaderboards
local shop = parent.Shop
local achievementFrame = parent.AchievementFrame
local createCrewFrame = parent.CreateCrewFrame
local crewInfoFrame = parent.CrewInfoFrame
local crewShopFrame = parent.CrewShopFrame
local invitesFrame = parent.InvitesFrame
local invitesListFrame = parent.InvitesListFrame
local leaderBoardsFrame = parent.LeaderBoardsFrame
local whitelist = PanelWhitelists.Whitelists[localPlayer.UserId]

function HideFrame(p)
	if p then
		p.Visible = nil
	end
end

function UpdateCrewFrameStatus()
	if v then
		if flag then
			return
		end

		flag = true
		crewInfoFrame.Visible = true
		invitesListFrame.Visible = nil
		createCrewFrame.Visible = nil
	else
		flag = nil
		crewInfoFrame.Visible = nil
		createCrewFrame.Visible = true
	end
end

function UpdateAllFrame(p)
	local frame = p.Frame or nil
	local button = p.Button or nil

	for _, guiObject in pairs(parent:GetChildren()) do
		if guiObject:IsA("Frame") and guiObject:GetAttribute("FirstFrame") then
			if frame == guiObject then
				if frame == guiObject then
					guiObject.Visible = true
				end
			else
				HideFrame(guiObject)
			end
		elseif guiObject:IsA("ImageButton") and guiObject:GetAttribute("FirstButton") then
			if button == guiObject then
				if button == guiObject then
					TweenService:Create(guiObject, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
						Position = UDim2.new(guiObject.Position.X.Scale, 0, -0.065, 0)
					}):Play()
					local uDim = UDim2.new(0.15, 0, 0.22, 0)
					local uDim2 = UDim2.new(0.1725, 0, 0.253, 0)
					button.Size = uDim
					TweenService:Create(
						button,
						TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							Size = uDim2
						}
					):Play()

					if button:FindFirstChild("ImageLabel") then
						button.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
						TweenService:Create(
							button.ImageLabel,
							TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
							{
								ImageColor3 = Color3.fromRGB(0, 0, 0)
							}
						):Play()
					end
				end
			else
				guiObject.Position = UDim2.new(guiObject.Position.X.Scale, 0, -0.05, 0)
			end
		end
	end
end

local refreshButton = crewInfoFrame.RefreshButton
local settingButton = crewInfoFrame.SettingButton
local information = crewInfoFrame.Information
local configure = crewInfoFrame.Configure

function FormatNumber(p)
	if p >= 1000000000 then
		return string.format("%.1fB", math.floor(p / 100000000) / 10)
	end

	if p >= 1000000 then
		return string.format("%.1fM", math.floor(p / 100000) / 10)
	end

	if p >= 1000 then
		return string.format("%.1fK", math.floor(p / 100) / 10)
	end

	return (tostring(p))
end

function ConfigFrameUpdate(p)
	local button = p.Button or nil
	local frame = p.Frame or nil

	if button then
		for _, button2 in pairs(configure.ButtonFrame:GetChildren()) do
			if not (button2:IsA("TextButton") and button2:GetAttribute("ConfigButton") and button2:FindFirstChild("SelectedMark")) then
				continue
			end

			if button2 == button then
				button2.SelectedMark.Visible = true
			else
				button2.SelectedMark.Visible = nil
			end
		end
	end

	if frame then
		for _, frame2 in pairs(configure:GetChildren()) do
			if not (frame2:IsA("Frame") and frame2:GetAttribute("ConfigFrame")) then
				continue
			end

			if frame2 == frame then
				frame2.Visible = true
			else
				frame2.Visible = nil
			end
		end
	end
end

function ConfigRanksButtonUpdate(p)
	local button = p.Button or nil

	if button then
		for _, button2 in pairs(configure.ConfigRanksFrame.ScrollingRanks:GetChildren()) do
			if not (button2:IsA("TextButton") and button2:GetAttribute("ConfigRanksButton") and button2:FindFirstChild("SelectedMark")) then
				continue
			end

			if button2 == button then
				button2.SelectedMark.Visible = true
			else
				button2.SelectedMark.Visible = nil
			end
		end
	end
end

local flag2 = nil
local flag3 = nil
local v2 = {
	[-1] = "Player1",
	[-2] = "Player2",
	[-3] = "Player3"
}

for _, button in pairs(parent:GetDescendants()) do
	if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
		continue
	end

	local button2 = button
	button.MouseButton1Click:Connect(function()
		local DELAY_DURATION = 0.1

		if flag2 then
			return
		end

		flag2 = true
		task.delay(DELAY_DURATION, function()
			flag2 = nil
		end)
		_G.ClickFrameEffect({
			Sound = true
		})

		if button2.Name == "RoleButton" then
			information.RoleList.Visible = not information.RoleList.Visible
		elseif button2:GetAttribute("RoleButtonList") then
			information.RoleList.Visible = nil
			information.RoleButton.TextLabel.Text = button2.TextLabel.Text
		else
			if button2:GetAttribute("SaveLogo") then
				SendUpdateCrewImage()
				return
			end

			if button2:GetAttribute("ConfigPlayerButton") or button2:GetAttribute("KickPlayerButton") then
				return
			end

			if button2:GetAttribute("ConfigRankButton") then
				local roleList = configure.ConfigMembersFrame.MemberInformation.RoleList
				roleList.Visible = not roleList.Visible
			else
				if button2:GetAttribute("SetRoleButton") then
					return
				end

				if button2:GetAttribute("ConfigButton") then
					if button2.Name == "Leave" then
						ConfigFrameUpdate({
							Button = button2,
							Frame = configure.ConfigLeave
						})
					elseif button2.Name == "Logo" then
						ConfigFrameUpdate({
							Button = button2,
							Frame = configure.ConfigLogoFrame
						})
					elseif button2.Name == "Members" then
						ConfigFrameUpdate({
							Button = button2,
							Frame = configure.ConfigMembersFrame
						})
					elseif button2.Name == "Ranks" then
						ConfigFrameUpdate({
							Button = button2,
							Frame = configure.ConfigRanksFrame
						})
					end
				elseif button2:GetAttribute("ConfigRanksButton") then
					ConfigRanksButtonUpdate({
						Button = button2
					})
				elseif button2:GetAttribute("FirstButton") then
					if button2.Name == "CrewInfo" then
						if flag3 then
							return
						end

						flag3 = true
						task.delay(DELAY_DURATION, function()
							flag3 = nil
						end)
						local frame = createCrewFrame

						if v then
							frame = crewInfoFrame
						end

						UpdateAllFrame({
							Frame = frame,
							Button = crewInfo
						})
					elseif button2.Name == "Invites" then
						if flag3 then
							return
						end

						flag3 = true
						task.delay(DELAY_DURATION, function()
							flag3 = nil
						end)
						local frame = invitesListFrame

						if v then
							frame = invitesFrame
						end

						UpdateAllFrame({
							Frame = frame,
							Button = invites
						})
					elseif button2.Name == "Achievement" then
						if flag3 then
							return
						end

						flag3 = true
						task.delay(DELAY_DURATION, function()
							flag3 = nil
						end)
						local frame = achievementFrame

						if not v then
							frame = createCrewFrame
						end

						UpdateAllFrame({
							Frame = frame,
							Button = achievement
						})
					elseif button2.Name == "Leaderboards" then
						if flag3 then
							return
						end

						flag3 = true
						task.delay(DELAY_DURATION, function()
							flag3 = nil
						end)
						UpdateAllFrame({
							Frame = leaderBoardsFrame,
							Button = leaderboards
						})
					elseif button2.Name == "Shop" then
						if flag3 then
							return
						end

						flag3 = true
						task.delay(DELAY_DURATION, function()
							flag3 = nil
						end)
						local frame = crewShopFrame

						if not v then
							frame = createCrewFrame
						end

						UpdateAllFrame({
							Frame = frame,
							Button = shop
						})
					end
				elseif button2.Name == "SettingButton" then
					if not v or flag3 then
						return
					end

					flag3 = true
					task.delay(DELAY_DURATION, function()
						flag3 = nil
					end)
					settingButton.ImageLabel.Rotation = 0
					TweenService:Create(settingButton.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Rotation = 180
					}):Play()

					if information.Visible then
						information.Visible = nil
						configure.Visible = true
					else
						information.Visible = true
						configure.Visible = nil
					end
				elseif button2.Name == "RefreshButton" then
					if not v or flag3 then
						return
					end

					flag3 = true
					task.delay(DELAY_DURATION, function()
						flag3 = nil
					end)
					refreshButton.ImageLabel.Rotation = 0
					TweenService:Create(refreshButton.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Rotation = 180
					}):Play()
				else
					if button2.Name == "CreateRankButton" then
						configure.ConfigRanksFrame.CreateRankFrame.Visible = not configure.ConfigRanksFrame.CreateRankFrame.Visible
						return
					end

					if button2:GetAttribute("CreateCrewFrame") and button2.Name == "Create" then
						CreateCrew()
						return
					end

					if not (button2.Name ~= "NextPage" and button2.Name ~= "PreviousPage") then
						return
					end

					if button2.Name == "HistoryButton" then
						if crewShopFrame.ScrollingHistory.Visible then
							crewShopFrame.ScrollingHistory.Visible = nil
							crewShopFrame.ScrollingShop.Visible = true
							button2.Text = "History"
						else
							crewShopFrame.ScrollingHistory.Visible = true
							crewShopFrame.ScrollingShop.Visible = nil
							button2.Text = "Shop"
						end
					end
				end
			end
		end
	end)

	if not button:GetAttribute("FirstButton") then
		continue
	end

	local parent2 = button
	button.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent2
		})
		local textLabel = parent2:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Visible = true
		end
	end)
	local v5 = button
	button.MouseLeave:Connect(function()
		local textLabel = v5:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Visible = nil
		end
	end)
end

repeat
	wait(0.5)
until localPlayer:FindFirstChild("DataLoaded")

local crewNew = localPlayer:WaitForChild("PlayerStats").CrewNew
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local connections = {}
local v7 = 1
local roleData = {}
local v9 = {}
local memberName = nil
local memberUserId = nil
local lastTime = tick()
local v12 = math.floor(os.time() / 86400)
local v13 = {
	Common = "rbxassetid://113040651123861",
	Rare = "rbxassetid://114497260284217",
	Epic = "rbxassetid://129729909586446",
	Legendary = "rbxassetid://120041082063560"
}
local v14 = {
	Common = Color3.fromRGB(0, 170, 0),
	Rare = Color3.fromRGB(170, 255, 255),
	Epic = Color3.fromRGB(170, 0, 255),
	Legendary = Color3.fromRGB(170, 0, 0)
}
local v15 = {
	Common = 1,
	Rare = 2,
	Epic = 3,
	Legendary = 4
}

function SendNotification(text, failed)
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("CrewUpdate", {
		Text = text,
		Failed = failed
	})
end

function HasCrew()
	return crewNew.Value ~= ""
end

local v16 = {}
local threads = {}
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "CrewUpdater"
bindableEvent.Parent = script

function ClearConnection()
	for _, connection in pairs(connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	for _, v17 in pairs(v16) do
		v17:Destroy()
	end

	for _, v17 in pairs(threads) do
		task.cancel(v17)
	end

	table.clear(connections)
	table.clear(v16)
	table.clear(threads)
end

function Reset()
	ClearConnection()
	v5 = nil
	connections = {}
	v7 = 1
end

function ClearMemberFrame()
	for _, frame in pairs(crewInfoFrame.Information.PlayerListFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function ClearRanksFrame()
	for _, button in pairs(crewInfoFrame.Configure.ConfigRanksFrame.ScrollingRanks:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

function ClearRoleFrame()
	for _, button in pairs(crewInfoFrame.Information.RoleList:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

function ClearRoleInMemberInfo()
	for _, button in pairs(crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

function UpdateImage(image)
	crewInfoFrame.Information.CrewLogo.Image = image
	crewInfoFrame.Configure.ConfigLogoFrame.ImageLabel.Image = image
end

function SetRoleConfig(p, flag4: boolean)
	if flag4 then
		TweenService:Create(p.Button.Circle, TweenInfo.new(0.2), {
			Position = UDim2.new(0.75, 0, 0.5, 0)
		}):Play()
		TweenService:Create(p.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(52, 226, 21)
		}):Play()
	else
		TweenService:Create(p.Button.Circle, TweenInfo.new(0.2), {
			Position = UDim2.new(0.25, 0, 0.5, 0)
		}):Play()
		TweenService:Create(p.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(111, 111, 111)
		}):Play()
	end
end

function UpdateRoleConfig()
	roleData = roleData or {}
	roleData.Role = roleData.Role or "N/A"
	roleData.Settings = roleData.Settings or {}
	local kickLowerRank = roleData.Settings.KickLowerRank or nil
	local spendFunds = roleData.Settings.SpendFunds or nil
	local manageRank = roleData.Settings.ManageRank or nil
	local rank = roleData.Settings.Rank or 10
	local role = roleData.Role or "N/A"
	local placeholderText = roleData.Settings.StarterRole and "Can't Change" or rank

	if roleData.Settings.Leader or roleData.Settings.StarterRole then
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetKickLowerRank.Button.BackgroundTransparency = 0.6
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetMembersRank.Button.BackgroundTransparency = 0.6
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetSpendFunds.Button.BackgroundTransparency = 0.6
	else
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetKickLowerRank.Button.BackgroundTransparency = 0
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetKickLowerRank.Button.Circle.BackgroundTransparency = 0
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetMembersRank.Button.BackgroundTransparency = 0
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetMembersRank.Button.Circle.BackgroundTransparency = 0
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetSpendFunds.Button.BackgroundTransparency = 0
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetSpendFunds.Button.Circle.BackgroundTransparency = 0
	end

	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetName.Frame.TextBox.Text = ""
	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetRank.Frame.TextBox.Text = ""
	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetName.Frame.TextBox.PlaceholderText = role
	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetRank.Frame.TextBox.PlaceholderText = placeholderText
	SetRoleConfig(crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetMembersRank, manageRank)
	SetRoleConfig(crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetSpendFunds, spendFunds)
	SetRoleConfig(crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetKickLowerRank, kickLowerRank)
	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetName.Frame.TextBox.PlaceholderText = role
	crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetRank.Frame.TextBox.PlaceholderText = placeholderText
end

function ClearShopFrame()
	for _, button in pairs(crewShopFrame.ScrollingShop:GetChildren()) do
		if button:IsA("TextButton") and button.Name ~= "IncreaseMember" then
			button:Destroy()
		end
	end
end

function CreateProfile(userId)
	local success, result = pcall(function()
		return game.Players:GetNameFromUserIdAsync(userId)
	end)
	local success2, result2 = pcall(function()
		return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local v17 = {
		Username = success and result or v2[userId] or "N/A",
		UserId = userId,
		Thumbnail = success2 and result2 or ""
	}
	v9[userId] = v17
	return v17
end

function ClearTopMemberFrame()
	for _, frame in pairs(parent.AchievementFrame.ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function ClearLeaderboardFrame()
	for _, frame in pairs(leaderBoardsFrame.ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local flag4 = nil
local v17 = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}
local month = os.date("!*t").month
local flag5 = nil
local adminFrame = parent:WaitForChild("AdminFrame")
local adminConfirmFrame = parent:WaitForChild("AdminConfirmFrame")

function PopupConfirmFrame()
	if adminConfirmFrame.Visible then
		return
	end

	adminConfirmFrame.Visible = true
	local connections2 = {}
	local v18 = nil
	table.insert(connections2, adminConfirmFrame.SendButton.MouseButton1Click:Connect(function()
		v18 = true
	end))
	table.insert(connections2, adminConfirmFrame.Close.MouseButton1Click:Connect(function()
		v18 = false
	end))

	while v18 == nil do
		task.wait(0.03333333333333333)
	end

	adminConfirmFrame.Visible = nil

	for _, connection in pairs(connections2) do
		connection:Disconnect()
	end

	return v18
end

function ClearOldAdminConquestFrame()
	for _, frame in pairs(adminFrame.ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function IsInGame(p)
	for k, v18 in pairs(WorldsId.Testing) do
		if v18 == p then
			return k
		end
	end

	for k, v18 in pairs(WorldsId.KingLegacy) do
		if v18 == p then
			return k
		end
	end
end

local thread = nil
local v18 = nil

function GetConquestMemberByAdmin(p)
	if flag5 then
		return
	end

	flag5 = true
	SendNotification((`Getting {p}'s conquest data`))
	local v19, v20 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer(
		"GetConquestDataCacheByAdmin",
		p
	)

	if v19 and v20 then
		local conquests = v19.Conquests
		local memberConquests = v19.MemberConquests
		v18 = p
		ClearOldAdminConquestFrame()
		local v21 = {}

		for k, memberConquest in pairs(memberConquests) do
			table.insert(v21, {
				UserId = k,
				Conquest = memberConquest
			})
		end

		table.sort(v21, function(a, b)
			return a.Conquest > b.Conquest
		end)

		if thread then
			task.cancel(thread)
			thread = nil
		end

		ClearTopMemberFrame()
		UpdateAllFrame({
			Frame = adminFrame
		})
		adminFrame.CrewName.Text = `<u>Crew: <font color="#ffff7f">{p}</font></u>`
		adminFrame.CrewConquest.Text = `CONQUESTS: {conquests}`
		SendNotification((`Found! Loading {p}'s conquest data...`))
		thread = task.spawn(function()
			if v20 then
				local v22 = v9[v20] or CreateProfile(v20)
				local username = v22.Username
				local _ = v22.Thumbnail
				adminFrame.CrewOwner.Text = `OWNER: {username}`
			end

			for i = 1, #v21 do
				local v22 = v21[i]

				if not v22 then
					continue
				end

				local userId = v22.UserId
				local conquest = v22.Conquest
				local v23 = v9[userId] or CreateProfile(userId)
				local username = v23.Username
				local thumbnail = v23.Thumbnail
				local clone = script.CrewAssets.TopMemberFrame2:Clone()
				clone.Name = username
				clone.Frame.RankNumber.Text = "#" .. tostring(i)
				clone.Frame.PlayerName.Text = username
				clone.Frame.Logo.Image = thumbnail
				clone.LayoutOrder = i
				clone.Frame.TotalConquest.Text = (conquest or 0) .. " Conquest"
				clone.Parent = adminFrame.ScrollingFrame
				local _, v24, _ = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer(
					"GetPlayerPlaceByAdmin",
					userId
				)

				if not (v24 and IsInGame(v24)) then
					continue
				end

				clone.Frame.JoinButton.Visible = true
				clone.Frame.Logo.OnlineFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
				local userId2 = userId
				clone.Frame.JoinButton.MouseButton1Click:Connect(function()
					ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("JoinFriend", {
						UserId = userId2
					})
				end)
			end
		end)
	else
		v18 = nil
		SendNotification(`{p}'s conquest data not found`, true)
	end

	task.delay(0.5, function()
		flag5 = nil
	end)
end

function UpdateTopCrew()
	if flag4 then
		return
	end

	flag4 = true
	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("GetCurrentCrewConquestPage")
	ClearLeaderboardFrame()
	leaderBoardsFrame.TextLabel.Text = ("<font color=\"#ffff7f\">Top Crews</font> (%s) (Conquest)"):format(v17[month] or "???")

	for _, v20 in pairs(v19) do
		local crewImage = v20.CrewImage
		local crewName = v20.CrewName
		local memberCount = v20.MemberCount
		local point = v20.Point
		local rank = v20.Rank
		local clone = crewAssets.TopCrewFrame:Clone()
		clone.Frame.CrewName.Text = crewName
		clone.Frame.RankNumber.Text = "#" .. rank
		clone.Frame.TotalConquest.Text = point .. " Conquest"
		clone.Frame.Logo.Image = crewImage
		clone.Frame.MemberCount.Text = tostring(memberCount) .. " <font color=\"#aa0000\">Pirates</font>"

		if whitelist then
			clone.Frame.ViewButton.Visible = true
			local v21 = crewName
			clone.Frame.ViewButton.MouseButton1Click:Connect(function()
				GetConquestMemberByAdmin(v21)
			end)
		end

		clone.Parent = leaderBoardsFrame.ScrollingFrame
	end

	flag4 = nil
end

if whitelist then
	leaderBoardsFrame.TextBox.Visible = true
	leaderBoardsFrame.TextBox.FocusLost:Connect(function()
		if #leaderBoardsFrame.TextBox.Text <= 0 then
			return
		end

		GetConquestMemberByAdmin(leaderBoardsFrame.TextBox.Text)
	end)
	adminFrame.WipeButton.MouseButton1Click:Connect(function()
		if PopupConfirmFrame() and adminFrame.Visible and v18 then
			warn("wiping", v18)
			ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("WipeCrewByAdmin", v18)
		end
	end)
end

function ConvertSeconds(p: number)
	local v19 = math.floor(p / 86400)
	local v20 = math.floor(p / 3600) % 24
	local v21 = math.floor(p / 60) % 60
	local v22 = math.floor(p) % 60

	if v19 > 0 then
		return string.format(
			"%d Day%s %d Hour%s %d Min%s ago",
			v19,
			v19 > 1 and "s" or "",
			v20,
			v20 > 1 and "s" or "",
			v21,
			v21 > 1 and "s" or ""
		)
	end

	if v20 > 0 then
		return string.format("%d Hour%s %d Min%s ago", v20, v20 > 1 and "s" or "", v21, v21 > 1 and "s" or "")
	end

	if v21 > 0 then
		return string.format("%d Minute%s ago", v21, v21 > 1 and "s" or "")
	end

	return string.format("%d Second%s ago", v22, v22 > 1 and "s" or "")
end

function ClearPlayerHistoryFrames()
	for _, frame in pairs(crewShopFrame.ScrollingHistory:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local GUID = HttpService:GenerateGUID(false)

function UpdateCrew()
	local GUID2 = HttpService:GenerateGUID(false)
	v = HasCrew()
	UpdateCrewFrameStatus()
	task.spawn(UpdateTopCrew)

	if v then
		local v19, v20, v21, v22 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("GetLastestDataCache_Event")

		if not v19 then
			return
		end

		GUID = GUID2

		if GUID2 ~= GUID then
			return
		end

		Reset()
		crewInfoFrame.Information.CrewName.Text = crewNew.Value
		local member = v19.Member
		local roles = v19.Roles
		local v23 = v20 or 0
		local v24 = v21 or {
			Conquests = 0,
			MemberConquests = {}
		}
		local bindableEvent2 = Instance.new("BindableEvent")
		table.insert(v16, bindableEvent2)
		local settings = v19.Settings or {}
		local captain = tonumber(v19.Captain)
		local crewImage = settings.CrewImage

		if crewImage then
			UpdateImage(crewImage)
		end

		if memberUserId and not member[tostring(memberUserId)] then
			memberName = nil
			memberUserId = nil
		end

		roleData = {}
		crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.Visible = nil
		v5 = member
		local success, result = pcall(function()
			return game.Players:GetNameFromUserIdAsync(captain)
		end)
		local v25 = success and result or "N/A"
		crewInfoFrame.Configure.ConfigureText.Text = "Configure " .. crewNew.Value
		crewInfoFrame.Information.CrewInfoList.CrewOwner.Text = "<font color=\"#bdbdbd\">By</font> " .. v25
		crewInfoFrame.Configure.ConfigureBy.Text = "<font color=\"#bdbdbd\">By</font> " .. v25

		local function UpdateTopMemberConquest()
			if not v24 then
				return
			end

			local memberConquests = v24.MemberConquests

			if not memberConquests then
				return
			end

			local v26 = {}

			for k, memberConquest in pairs(memberConquests) do
				table.insert(v26, {
					UserId = k,
					Conquest = memberConquest
				})
			end

			table.sort(v26, function(a, b)
				return a.Conquest > b.Conquest
			end)
			ClearTopMemberFrame()

			for i = 1, 10 do
				local v27 = v26[i]

				if not v27 then
					continue
				end

				local userId = v27.UserId
				local conquest = v27.Conquest
				local v28 = v9[userId] or CreateProfile(userId)
				local username = v28.Username
				local thumbnail = v28.Thumbnail
				local clone = script.CrewAssets.TopMemberFrame:Clone()
				clone.Name = username
				clone.Frame.RankNumber.Text = "#" .. tostring(i)
				clone.Frame.PlayerName.Text = username
				clone.Frame.Logo.Image = thumbnail
				clone.LayoutOrder = i
				clone.Frame.TotalConquest.Text = (conquest or 0) .. " Conquest"
				clone.Parent = parent.AchievementFrame.ScrollingFrame
			end
		end

		local function UpdateShop(p)
			v22 = p or v22

			if not (v22 and v22.Chests) then
				return
			end

			for _, button in pairs(crewShopFrame.ScrollingShop:GetChildren()) do
				if not (button:IsA("TextButton") and button.Name ~= "IncreaseMember") then
					continue
				end

				local v26 = nil

				for _, chest in pairs(v22.Chests) do
					if chest.ChestName ~= button.Name then
						continue
					end

					v26 = true
					break
				end

				if not v26 then
					button:Destroy()
				end
			end

			for _, chest in pairs(v22.Chests) do
				local chestName = chest.ChestName
				local price = chest.Price

				if not (chestName and price) then
					continue
				end

				local clone = crewShopFrame.ScrollingShop:FindFirstChild(chestName)

				if not clone then
					clone = crewAssets.Box:Clone()
					clone.Name = chestName
					clone.Parent = crewShopFrame.ScrollingShop
					local chestName2 = chestName
					local price2 = price
					table.insert(connections, clone.MouseButton1Click:Connect(function()
						local v28 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("BuyChest", {
							ChestName = chestName2,
							Price = price2
						})

						if v28 and v28 == true then
							SendNotification("Purchase successful.")
						elseif v28 then
							SendNotification(v28, true)
						end
					end))
				end

				clone.ProductName.Text = chestName
				clone.ImageLabel.Image = v13[chestName] or ""
				clone.Cost.Text = "τ " .. price
				clone.Border.ImageColor3 = v14[chestName] or Color3.fromRGB(255, 255, 255)
				clone.LayoutOrder = v15[chestName] or 1

				if (chest.Stocks or 0) <= 0 then
					clone.Amount.Text = "OUT OF STOCK"
					clone.Amount.TextColor3 = Color3.fromRGB(217, 0, 0)
				else
					clone.Amount.Text = ("x%s Stock"):format((tostring(chest.Stocks)))
					clone.Amount.TextColor3 = Color3.fromRGB(85, 255, 0)
				end

				clone.Parent = crewShopFrame.ScrollingShop
			end

			crewShopFrame.ScrollingShop.CanvasSize = UDim2.fromOffset(
				crewShopFrame.ScrollingShop.UIListLayout.AbsoluteContentSize.X,
				0
			)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateTokens(p)
			if p then
				v23 = p
			end

			crewShopFrame.TokensLabel.Text = "<font color=\"#00ffff\">Flag Tokens:</font> " .. v23
			crewInfoFrame.Information.CrewInfoList.TokenPoint.Text = v23 .. " <font color=\"#aaff00\">Flag Tokens</font>"
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateConquests(p)
			if p then
				v24 = p
			end

			crewInfoFrame.Information.CrewInfoList.ConquestPoint.Text = v24.Conquests .. " <font color=\"#ffff00\">Conquest</font>"
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateTokensAndConquests(p, p2)
			UpdateTokens(p) -- equivalent call inferred; original call site unknown
			UpdateConquests(p2) -- equivalent call inferred; original call site unknown
		end

		UpdateTokens() -- equivalent call inferred; original call site unknown
		UpdateConquests() -- equivalent call inferred; original call site unknown

		local function CreatePlayerHistoryFrame(data)
			if not (GUID2 == GUID and data) then
				return
			end

			local userId = data.UserId
			local purchasedTime = data.PurchasedTime
			local description = data.Description
			local layoutOrder = os.time() - purchasedTime
			local v27 = v9[userId] or CreateProfile(userId)
			local username = v27.Username
			local thumbnail = v27.Thumbnail
			local clone = crewAssets.PlayerHistory:Clone()
			clone.Name = username
			clone.Frame.PlayerName.Text = username
			clone.Frame.LastestTime.Text = ConvertSeconds(layoutOrder)
			clone.Frame.Logo.Image = thumbnail
			clone.Frame.Description.Text = description or ""
			clone.LayoutOrder = layoutOrder
			clone.Parent = crewShopFrame.ScrollingHistory
		end

		local function UpdatePurchasedHistory()
			ClearPlayerHistoryFrames()
			local v26 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer(
				"GetPurchaseHistoryDataCache_Event",
				{}
			)

			if v26 then
				table.sort(v26, function(a, b)
					return a.PurchasedTime > b.PurchasedTime
				end)
				local thread2 = task.spawn(function()
					for i = 1, #v26 do
						CreatePlayerHistoryFrame(v26[i])

						if i % 10 ~= 0 then
							continue
						end

						crewShopFrame.ScrollingHistory.LoadMoreButton.Visible = true
						bindableEvent2.Event:Wait()
					end

					crewShopFrame.ScrollingHistory.LoadMoreButton.Visible = false
				end)
				table.insert(threads, thread2)
			end
		end

		local function GetMyRank()
			if localPlayer.UserId == captain then
				return "Captain"
			end

			for k, v26 in pairs(v5) do
				if tonumber(k) == localPlayer.UserId then
					return v26
				end
			end

			return "N/A"
		end

		local function CreateMemberFrame(p: number, value: number)
			if GUID2 ~= GUID then
				return
			end

			local v26 = tonumber(p)

			if not v26 then
				return
			end

			local v27 = v9[v26] or CreateProfile(v26)
			local clone = crewAssets.MemberFrame:Clone()
			clone.Name = v27.Username
			clone.PlayerName.Text = v27.Username
			clone.PlayerIcon.Image = v27.Thumbnail
			clone.LayoutOrder = value or 1
			clone.Parent = crewInfoFrame.Information.PlayerListFrame
			return clone
		end

		local function UpdateMemberList(flag6: boolean)
			if not (GUID2 == GUID and v5) then
				return
			end

			task.defer(function()
				ClearMemberFrame()
				local v26 = 1

				if flag6 then
					crewInfoFrame.Information.RoleButton.TextLabel.Text = settings.LeaderCustomName or "Captain"
					CreateMemberFrame(captain)
				else
					crewInfoFrame.Information.RoleButton.TextLabel.Text = v4 or "N/A"

					for k, v27 in pairs(v5) do
						if v27 ~= v4 then
							continue
						end

						CreateMemberFrame(k, v26)
						v26 += 1
					end
				end
			end)
		end

		local function GetMemberCount()
			if not (GUID2 == GUID and v5) then
				return
			end

			local count = 0

			for _, _ in pairs(v5) do
				count += 1
			end

			return count
		end

		local function UpdatePage()
			if GUID2 ~= GUID then
				return
			end

			local v26 = (v7 - 1) * 5 + 1
			local v27 = v7 * 5
			crewInfoFrame.Information.PageFrame.PageLabel.Text = "Page " .. v7
			local v28 = nil

			for _, frame in pairs(crewInfoFrame.Information.PlayerListFrame:GetChildren()) do
				if not frame:IsA("Frame") then
					continue
				end

				if v26 <= frame.LayoutOrder and frame.LayoutOrder <= v27 then
					frame.Visible = true
					v28 = true
				else
					frame.Visible = false
				end
			end

			return v28
		end

		local function GetRoleMemberCount(p)
			if not v5 then
				return
			end

			local count = 0

			for _, v26 in pairs(v5) do
				if v26 == p then
					count += 1
				end
			end

			return count
		end

		local function CreateRole(leaderCustomName, p)
			if GUID2 ~= GUID then
				return
			end

			local v26 = leaderCustomName
			local v27 = 10
			local v28

			if p then
				leaderCustomName = settings.LeaderCustomName or leaderCustomName
				v28 = 1
				v27 = -1
			else
				local v29 = leaderCustomName

				if v5 then
					v28 = 0

					for _, v30 in pairs(v5) do
						if v30 == v29 then
							v28 += 1
						end
					end
				end
			end

			local rank

			if roles[v26] and roles[v26].Rank and not roles[v26].StarterRole then
				rank = roles[v26].Rank
			else
				rank = roles[v26] and roles[v26].StarterRole and 99 or v27
			end

			local text = leaderCustomName .. " (" .. v28 .. ")"
			local clone = crewAssets.RoleButton:Clone()
			clone.TextLabel.Text = text
			clone.Name = leaderCustomName
			table.insert(connections, clone.MouseButton1Click:Connect(function()
				wait()
				crewInfoFrame.Information.RoleList.Visible = nil
				v7 = 1
				v4 = leaderCustomName
				local v30 = p

				if GUID2 == GUID and v5 then
					task.defer(function()
						ClearMemberFrame()
						local v31 = 1

						if v30 then
							crewInfoFrame.Information.RoleButton.TextLabel.Text = settings.LeaderCustomName or "Captain"
							CreateMemberFrame(captain)
						else
							crewInfoFrame.Information.RoleButton.TextLabel.Text = v4 or "N/A"

							for k, v32 in pairs(v5) do
								if v32 ~= v4 then
									continue
								end

								CreateMemberFrame(k, v31)
								v31 += 1
							end
						end
					end)
				end

				if not UpdatePage() then
					v7 = 1
					UpdatePage()
				end
			end))
			clone.LayoutOrder = rank
			clone.Parent = crewInfoFrame.Information.RoleList

			if p then
				return clone
			end

			local clone2 = crewAssets.SetRoleButton:Clone()
			clone2.Name = leaderCustomName
			clone2.TextLabel.Text = leaderCustomName
			clone2.LayoutOrder = rank
			clone2.Parent = crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList
			table.insert(connections, clone2.MouseButton1Click:Connect(function()
				wait()

				if not (memberName and memberUserId) then
					return
				end

				local v30 = memberName
				local v31 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("SetMemberRole", {
					MemberName = memberName,
					MemberUserId = memberUserId,
					RoleSet = leaderCustomName
				})

				if v31 and v31 == true then
					SendNotification("Successfully changed the rank for " .. v30 .. ".")
				elseif v31 and v31 ~= true then
					SendNotification(v31, true)
				end
			end))
			return clone
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateRoleList()
			task.defer(function()
				ClearRoleFrame()
				ClearRoleInMemberInfo()
				CreateRole("Captain", true)

				for k, _ in pairs(roles) do
					CreateRole(k)
				end

				local uIListLayout = crewInfoFrame.Information.RoleList.UIListLayout
				local uIListLayout2 = crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList.UIListLayout
				crewInfoFrame.Information.RoleList.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
				crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList.CanvasSize = UDim2.new(
					0,
					0,
					0,
					uIListLayout2.AbsoluteContentSize.Y
				)
			end)
		end

		local function CreateMemberLabelInConfigFrame(userId)
			if GUID2 ~= GUID then
				return
			end

			local v26 = v9[userId] or CreateProfile(userId)
			local username = v26.Username
			local thumbnail = v26.Thumbnail
			local clone = crewAssets.PlayerLabel:Clone()
			clone.PlayerName.Text = v26.Username
			clone.PlayerImage.Image = v26.Thumbnail
			clone.Name = v26.Username
			clone.Parent = crewInfoFrame.Configure.ConfigMembersFrame.ScrollingFrame
			table.insert(connections, clone.MouseButton1Click:Connect(function()
				if memberName == username then
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.Visible = nil
					memberUserId = nil
					memberName = nil
				else
					memberName = username
					memberUserId = userId
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.Visible = true
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.PlayerIcon.Image = thumbnail
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.PlayerNameText.Text = username
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.PlayerBounty.Text = "Bounty: Loading.."
					crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.TotalPoints.Text = "Total Conquest: Loading.."

					if captain == userId then
						local leaderCustomName = settings.LeaderCustomName or "Captain"
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.ConfigRankButton.TextLabel.Text = leaderCustomName
					else
						local text = v5[tostring(userId)] or "N/A"
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.ConfigRankButton.TextLabel.Text = text
					end

					local v27 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("GetPlayerInfo", {
						UserId = userId
					})

					if v27 and memberName == username then
						local v28 = v27.Bounty and FormatNumber(v27.Bounty) or "Not found"
						local v29 = v24.MemberConquests and v24.MemberConquests[tostring(userId)] or "Not found"
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.PlayerBounty.Text = "Bounty: " .. v28
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.TotalPoints.Text = "Total Conquest: " .. v29
					elseif not v27 and memberName == username then
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.PlayerBounty.Text = "Bounty: Please refresh"
						crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.TotalPoints.Text = "Total Conquest: Please refresh"
					end
				end
			end))
			return clone
		end

		local function ClearMemberInConfig()
			for _, button in pairs(crewInfoFrame.Configure.ConfigMembersFrame.ScrollingFrame:GetChildren()) do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end
		end

		local function UpdateMemberInConfig()
			ClearMemberInConfig()
			CreateMemberLabelInConfigFrame(captain)

			for k, _ in pairs(v5) do
				local userId = tonumber(k)

				if not userId then
					break
				end

				CreateMemberLabelInConfigFrame(userId)
			end
		end

		local function UpdateRankConfig(role, options)
			if not crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.Visible then
				crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.Visible = true
			end

			roleData = roleData or {}
			roleData.Role = role
			roleData.Settings = table.clone(options or {})
			v6 = role
			UpdateRoleConfig()
		end

		local function CreateRoleButton(leaderCustomName, data)
			if GUID2 ~= GUID then
				return
			end

			local clone = crewAssets.RoleButton:Clone()
			clone.Name = leaderCustomName
			local rank = data.Rank

			if data.Leader then
				rank = -1

				if settings.LeaderCustomName then
					leaderCustomName = settings.LeaderCustomName
				end
			elseif data.StarterRole then
				rank = 99

				if settings.StarterRoleCustomName then
					leaderCustomName = settings.StarterRoleCustomName
				end
			end

			clone.TextLabel.Text = leaderCustomName
			clone.LayoutOrder = rank
			clone.Parent = crewInfoFrame.Configure.ConfigRanksFrame.ScrollingRanks
			table.insert(connections, clone.MouseButton1Click:Connect(function()
				UpdateRankConfig(leaderCustomName, data)
			end))
			return clone
		end

		local function UpdateRanks(p, p2)
			if GUID2 ~= GUID then
				return
			end

			if p then
				roles = p
			end

			if p2 then
				settings = p2
			end

			roleData = {}
			crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.Visible = nil
			ClearRanksFrame()
			CreateRoleButton("Captain", {
				KickLowerRank = true,
				SpendFunds = true,
				ManageRank = true,
				Leader = true,
				Rank = "Can't Change"
			})

			for k, role in pairs(roles) do
				CreateRoleButton(k, role)

				if v6 and v6 == k then
					UpdateRankConfig(k, role)
				end
			end

			local uIGridLayout = crewInfoFrame.Configure.ConfigRanksFrame.ScrollingRanks.UIGridLayout
			crewInfoFrame.Configure.ConfigRanksFrame.ScrollingRanks.CanvasSize = UDim2.new(
				0,
				0,
				0,
				uIGridLayout.AbsoluteContentSize.Y
			)
		end

		table.insert(connections, bindableEvent.Event:Connect(function(p, ...)
			if p == "UpdateRole" then
				UpdateRanks(...)
				UpdateRoleList() -- equivalent call inferred; original call site unknown
			elseif p == "UpdateTokenAndConquest" then
				local v26, v27 = ...
				UpdateTokensAndConquests(v26, v27) -- equivalent call inferred; original call site unknown
			elseif p == "UpdateToken" then
				local v26 = ...
				UpdateTokens(v26) -- equivalent call inferred; original call site unknown
			elseif p == "UpdateShop" then
				warn("updating")
				UpdateShop(...)
			else
				if p ~= "UpdateConquest" then
					return
				end

				local v26 = ...
				UpdateConquests(v26) -- equivalent call inferred; original call site unknown
			end
		end))
		table.insert(connections, crewShopFrame.ScrollingShop.IncreaseMember.MouseButton1Click:Connect(function()
			wait()
			local v26 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("IncreaseMaxMember", {
				InvitePlayer = invitesFrame.TextBox.Text
			})

			if v26 and v26 ~= true then
				SendNotification(v26, true)
			elseif v26 and v26 == true then
				SendNotification("Max members increased!")
			end
		end))
		table.insert(connections, crewShopFrame.ScrollingHistory.LoadMoreButton.MouseButton1Click:Connect(function()
			wait()
			bindableEvent2:Fire()
		end))
		table.insert(connections, crewInfoFrame.Information.PageFrame.NextPage.MouseButton1Click:Connect(function()
			wait()
			v7 += 1

			if not UpdatePage() then
				v7 = 1
				UpdatePage()
			end
		end))
		table.insert(connections, crewInfoFrame.Information.PageFrame.PreviousPage.MouseButton1Click:Connect(function()
			wait()
			v7 = math.max(v7 - 1, 1)

			if not UpdatePage() then
				v7 = 1
				UpdatePage()
			end
		end))
		local members = crewInfoFrame.Information.CrewInfoList.Members
		local v26

		if GUID2 == GUID and v5 then
			v26 = 0

			for _, _ in pairs(v5) do
				v26 += 1
			end
		end

		members.Text = (v26 or 0) + 1 .. "/" .. settings.MaxMember .. " <font color=\"#bdbdbd\">Members</font>"
		local rank = crewInfoFrame.Information.CrewInfoList.Rank
		local v27

		if localPlayer.UserId == captain then
			v27 = "Captain"
		else
			local flag6 = true

			for k, v28 in pairs(v5) do
				if tonumber(k) ~= localPlayer.UserId then
					continue
				end

				v27 = v28
				flag6 = false
				break
			end

			if flag6 then
				v27 = "N/A"
			end
		end

		rank.Text = v27 .. " <font color=\"#bdbdbd\">Rank</font>"

		if v4 and not roles[v4] then
			v4 = nil
		end

		if v4 then
			if GUID2 == GUID and v5 then
				local v28 = nil
				task.defer(function()
					ClearMemberFrame()
					local v29 = 1

					if v28 then
						crewInfoFrame.Information.RoleButton.TextLabel.Text = settings.LeaderCustomName or "Captain"
						CreateMemberFrame(captain)
					else
						crewInfoFrame.Information.RoleButton.TextLabel.Text = v4 or "N/A"

						for k, v30 in pairs(v5) do
							if v30 ~= v4 then
								continue
							end

							CreateMemberFrame(k, v29)
							v29 += 1
						end
					end
				end)
			end
		elseif GUID2 == GUID and v5 then
			local flag6 = true
			task.defer(function()
				ClearMemberFrame()
				local v28 = 1

				if flag6 then
					crewInfoFrame.Information.RoleButton.TextLabel.Text = settings.LeaderCustomName or "Captain"
					CreateMemberFrame(captain)
				else
					crewInfoFrame.Information.RoleButton.TextLabel.Text = v4 or "N/A"

					for k, v29 in pairs(v5) do
						if v29 ~= v4 then
							continue
						end

						CreateMemberFrame(k, v28)
						v28 += 1
					end
				end
			end)
		end

		ClearShopFrame()
		task.defer(function()
			ClearRoleFrame()
			ClearRoleInMemberInfo()
			CreateRole("Captain", true)

			for k, _ in pairs(roles) do
				CreateRole(k)
			end

			local uIListLayout = crewInfoFrame.Information.RoleList.UIListLayout
			local uIListLayout2 = crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList.UIListLayout
			crewInfoFrame.Information.RoleList.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
			crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.RoleList.CanvasSize = UDim2.new(
				0,
				0,
				0,
				uIListLayout2.AbsoluteContentSize.Y
			)
		end)
		UpdateMemberInConfig()
		UpdateRanks()
		UpdateTopMemberConquest()
		UpdateShop()
		task.spawn(UpdatePurchasedHistory)
	end
end

UpdateCrew()
invitesFrame.InviteButton.MouseButton1Click:Connect(function()
	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("Invite", {
		InvitePlayer = invitesFrame.TextBox.Text
	})

	if v19 and v19 ~= true then
		SendNotification(v19, true)
	end
end)
crewInfoFrame.RefreshButton.MouseButton1Click:Connect(function()
	if tick() - lastTime < 3 then
		SendNotification("On cooldown. Please wait.", true)
		return
	end

	lastTime = tick()
	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("RefreshCrew", {})

	if v19 then
		v12 = math.floor(os.time() / 86400)
		SendNotification(v19)
		UpdateCrew()
	end
end)

function CreateCrew()
	if createCrewFrame.TextBox.Text == "" then
		return
	end

	v3 = true
	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("CreateCrew", {
		CrewName = createCrewFrame.TextBox.Text
	})

	if v19 == true then
		UpdateCrew()
		SendNotification("Your Crew is established. A new journey awaits!")
	elseif v19 then
		SendNotification(v19, true)
	end

	v3 = nil
end

crewNew.Changed:Connect(function()
	wait()

	if crewNew.Value == "" then
		UpdateCrew()
	end
end)

function SendUpdateCrewImage()
	local textBox = crewInfoFrame.Configure.ConfigLogoFrame.TextBox

	if not (textBox.Text ~= "" and tonumber(textBox.Text)) then
		return
	end

	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("UpdateCrewLogo", {
		CrewImage = textBox.Text
	})

	if v19 == true then
		SendNotification("Your Crew's logo has been changed.")
	elseif v19 then
		SendNotification(v19, true)
	end
end

function SetConfigRole(p, p2)
	if not roleData or not (roleData.Settings and roleData.Role) or (roleData.Settings.Leader or roleData.Settings.StarterRole) and p ~= "Name" then
		return
	end

	if p == "Rank" or p == "Name" then
		if p2 == "" then
			p2 = nil
		end

		roleData.Settings[p] = p2
	else
		local v19 = not roleData.Settings[p] or nil
		roleData.Settings[p] = v19
		UpdateRoleConfig()
	end
end

function SendCreateRole(roleName)
	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("CreateCrewRole", {
		RoleName = roleName
	})

	if v19 and v19 == true then
		SendNotification("New Rank created successfully.")
	elseif v19 then
		SendNotification(v19, true)
	end

	configure.ConfigRanksFrame.CreateRankFrame.Visible = nil
end

crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetKickLowerRank.Button.MouseButton1Click:Connect(function()
	wait()
	SetConfigRole("KickLowerRank")
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetMembersRank.Button.MouseButton1Click:Connect(function()
	wait()
	SetConfigRole("ManageRank")
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetSpendFunds.Button.MouseButton1Click:Connect(function()
	wait()
	SetConfigRole("SpendFunds")
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetRank.Frame.TextBox.FocusLost:Connect(function()
	warn()
	SetConfigRole("Rank", crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetRank.Frame.TextBox.Text)
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetName.Frame.TextBox.FocusLost:Connect(function()
	warn()
	SetConfigRole("Name", crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.SetName.Frame.TextBox.Text)
end)
configure.ConfigRanksFrame.CreateRankFrame.Create.MouseButton1Click:Connect(function()
	wait()
	SendCreateRole(configure.ConfigRanksFrame.CreateRankFrame.TextBox.Text)
end)
configure.ConfigRanksFrame.CreateRankFrame.Cancel.MouseButton1Click:Connect(function()
	wait()
	configure.ConfigRanksFrame.CreateRankFrame.Visible = nil
end)
crewInfoFrame.Configure.ConfigMembersFrame.MemberInformation.KickButton.MouseButton1Click:Connect(function()
	warn()

	if not (memberName and memberUserId) then
		return
	end

	local v19 = memberName
	local v20 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("KickMember", {
		MemberUserId = memberUserId,
		MemberName = memberName
	})

	if v20 and v20 == true then
		SendNotification(v19 .. " has been kicked from the Crew.")
	elseif v20 then
		SendNotification(v20, true)
	end
end)
crewInfoFrame.Configure.ConfigLeave.Leave.MouseButton1Click:Connect(function()
	if configure.ConfigLeave.TextBox.Text == "1234" then
		local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("LeaveCrew")

		if v19 and v19 == true then
			SendNotification("Success")
		elseif v19 then
			SendNotification(v19, true)
		end
	end
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.FinalFrame.DeleteButton.MouseButton1Click:Connect(function()
	wait()

	if not (roleData and (roleData.Settings and roleData.Role)) then
		return
	end

	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("DeleteCrewRole", {
		RoleName = roleData.Role
	})

	if v19 and v19 == true then
		SendNotification("Rank deleted successfully.")
	elseif v19 then
		SendNotification(v19, true)
	end
end)
crewInfoFrame.Configure.ConfigRanksFrame.ScrollingConfig.FinalFrame.SaveButton.MouseButton1Click:Connect(function()
	wait()

	if not (roleData and (roleData.Settings and roleData.Role)) then
		return
	end

	local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("SetCrewRolePermissions", {
		RoleData = roleData
	})

	if v19 and v19 == true then
		SendNotification("Rank settings updated successfully.")
	elseif v19 then
		SendNotification(v19, true)
	end
end)
ReplicatedStorage.Chest.Remotes.Events.CrewClientOperations.OnClientEvent:Connect(function(p, ...)
	if p == "Update" then
		UpdateCrew(...)
	elseif p == "UpdateImage" then
		UpdateImage(...)
	else
		bindableEvent:Fire(p, ...)
	end
end)

ReplicatedStorage.Chest.Remotes.Functions.CrewInvite.OnClientInvoke = function(p)
	if not p.Captain or not p.CrewName or invitesListFrame.ScrollingFrame:FindFirstChild(p.Captain) then
		return
	end

	local _, result = pcall(function()
		return game.Players:GetUserIdFromNameAsync(p.Captain)
	end)
	local success, result2 = pcall(function()
		return game.Players:GetUserThumbnailAsync(result, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local clone = crewAssets.CrewInvitesFrame:Clone()
	clone.Name = p.Captain
	clone.Frame.PlayerName.Text = p.Captain
	clone.Frame.Logo.Image = success and result2 or ""
	clone.Parent = invitesListFrame.ScrollingFrame
	local connections2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Disconnect()
		for _, connection in pairs(connections2) do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		connections2 = nil
	end

	table.insert(connections2, clone.Frame.Accept.MouseButton1Click:Connect(function()
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
		local v19 = ReplicatedStorage.Chest.Remotes.Functions.CrewOperations:InvokeServer("AcceptCrewInvite", {
			CrewName = p.CrewName
		})

		if v19 and v19 ~= true then
			SendNotification(v19, true)
		end

		clone:Destroy()
		Disconnect() -- equivalent call inferred; original call site unknown
	end))
	table.insert(connections2, clone.Frame.Ignore.MouseButton1Click:Connect(function()
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
		clone:Destroy()
		Disconnect() -- equivalent call inferred; original call site unknown
	end))
end

function BeginSearching()
	local text = configure.ConfigMembersFrame.Frame.SearchingBox.Text

	for _, button in ipairs(configure.ConfigMembersFrame.ScrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button.Visible = (not (#text > 0) or string.find(button.Name:lower(), text:lower())) and true or nil
		end
	end
end

configure.ConfigMembersFrame.Frame.SearchingBox:GetPropertyChangedSignal("Text"):Connect(BeginSearching)

while true do
	if parent.Visible then
		task.wait(0.1)
		local now = os.time()
		local v19 = math.floor(now / 86400)
		local v20 = 86400 - now % 86400
		local v21 = math.floor(v20 / 3600) % 24
		local v22 = math.floor(v20 / 60) % 60
		local v23 = math.floor(v20) % 60
		local v24 = v21 > 0 and v21 or 0
		local v25 = v22 > 0 and v22 or 0
		local v26 = v23 > 0 and v23 or 0
		local v27 = string.format("%02d:%02d:%02d", v24, v25, v26)
		local text = v12 ~= v19 and "Shop data is outdated. Please refresh." or v27
		crewShopFrame.TImeLabel.Text = text
	else
		task.wait()
		parent:GetPropertyChangedSignal("Visible"):Wait()
	end
end