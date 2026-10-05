local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local utils = ReplicatedStorage:WaitForChild("Utils")
local Net = require(packages.Net)
local FFlags = require(packages.FFlags)
local NumberUtils = require(utils.NumberUtils)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local map = Workspace.Map
local v = {}
local v2 = {}

local function CountryCodeToFlag(country: string)
	if not country or #country ~= 2 then
		return ""
	end

	local v3 = string.upper(country)
	return utf8.char(string.byte(v3, 1) + 127462 - 65) .. utf8.char(string.byte(v3, 2) + 127462 - 65)
end

local v3 = {}
local color = Color3.fromRGB(255, 213, 0)
local color2 = Color3.fromRGB(116, 116, 116)
local color3 = Color3.fromRGB(143, 87, 35)
local color4 = Color3.fromRGB(255, 255, 255)
local color5 = Color3.fromRGB(81, 158, 86)
local color6 = Color3.fromRGB(115, 152, 172)
local remoteFunction = Net:RemoteFunction("Leaderboard/GetTopPlayers")
local remoteFunction2 = Net:RemoteFunction("Leaderboard/GetTopFriends")
local remoteFunction3 = Net:RemoteFunction("Leaderboard/GetDisplayNames")
local remoteEvent = Net:RemoteEvent("Leaderboard/ReplicateUpdate")
local remoteEvent2 = Net:RemoteEvent("Leaderboard/ReplicateDisplayNames")
local remoteFunction4 = Net:RemoteFunction("Leaderboard/GetCountryLeaderboard")
local remoteEvent3 = Net:RemoteEvent("Leaderboard/ReplicateCountryUpdate")

-- equivalent calls inferred from this helper; original call sites unknown
local function getRankColor(rank: number)
	if rank == 1 then
		return color
	elseif rank == 2 then
		return color2
	elseif rank == 3 then
		return color3
	end

	return color4
end

local function removeLineFromFrames(line)
	local userId = line:GetAttribute("UserId")

	if not userId then
		return
	end

	local v4 = v2[userId]

	if not v4 then
		return
	end

	local index = table.find(v4, line)

	if not index then
		return
	end

	table.remove(v4, index)

	if #v4 == 0 then
		v2[userId] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addLineToFrames(clone, userId: number)
	if not v2[userId] then
		v2[userId] = { clone }
	elseif not table.find(v2[userId], clone) then
		table.insert(v2[userId], clone)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActiveDataList(data)
	local activeTab = data.ActiveTab or "Global"

	if activeTab == "Friends" then
		return data.FriendsData
	elseif activeTab == "Country" then
		return data.CountryData
	end

	return data.PlayerData
end

local function updateBoard(p: string)
	local v4 = v3[p]

	if not v4 then
		return
	end

	local container = v4.Container
	local template = v4.Template
	local activeDataList = getActiveDataList(v4) -- equivalent call inferred; original call site unknown
	local lines = v4.Lines or {}
	local clonesByUserId = {}

	for i = 1, math.min(100, #activeDataList) do
		local v5 = activeDataList[i]
		local userId = v5.UserId

		if clonesByUserId[userId] then
			continue
		end

		local clone = lines[userId]

		if clone then
			lines[userId] = nil
		else
			clone = template:Clone()
			clone.Visible = true
			clone.Parent = container
			clone:SetAttribute("UserId", userId)
			addLineToFrames(clone, userId) -- equivalent call inferred; original call site unknown
		end

		clone.LayoutOrder = i
		local rankColor = getRankColor(v5.Rank) -- equivalent call inferred; original call site unknown
		local positionLabel = clone:FindFirstChild("PositionLabel")

		if positionLabel then
			positionLabel.Text = tostring(v5.Rank) .. "."
			positionLabel.TextColor3 = rankColor
		end

		local nameLabel = clone:FindFirstChild("NameLabel")

		if nameLabel then
			nameLabel.AutoLocalize = false
			local v6 = not v5.Country and "" or " " .. CountryCodeToFlag(v5.Country)
			nameLabel.Text = (v[v5.UserId] or "Loading...") .. v6
			nameLabel:SetAttribute("Flag", v6)
			nameLabel.TextColor3 = rankColor
		end

		local child = clone:FindFirstChild(p .. "Label")

		if child then
			local string2 = NumberUtils:ToString(math.round(v5.Value), 2)

			if p == "Generation" then
				string2 ..= "/s"
			end

			child.Text = string2
			child.TextColor3 = rankColor
		end

		local avatarImage = clone:FindFirstChild("AvatarImage")

		if avatarImage then
			avatarImage.Image = `rbxthumb://type=AvatarHeadShot&id={v5.UserId}&w=100&h=100`
			local uIStroke = avatarImage:FindFirstChild("UIStroke")

			if uIStroke then
				uIStroke.Color = rankColor
			end
		end

		clonesByUserId[userId] = clone
	end

	for _, line in lines do
		removeLineFromFrames(line)
		line:Destroy()
	end

	v4.Lines = clonesByUserId
end

local function setActiveTab(p: string, activeTab: string)
	local v4 = v3[p]

	if not v4 then
		return
	end

	v4.ActiveTab = activeTab
	local buttons = v4.Gui:WaitForChild("MainFrame"):WaitForChild("Buttons")
	local global = buttons:FindFirstChild("Global")
	local friends = buttons:FindFirstChild("Friends")
	local country = buttons:FindFirstChild("Country")

	if global then
		local backgroundColor

		if activeTab == "Global" then
			backgroundColor = color5
		else
			backgroundColor = color6
		end

		global.BackgroundColor3 = backgroundColor
	end

	if friends then
		local backgroundColor

		if activeTab == "Friends" then
			backgroundColor = color5
		else
			backgroundColor = color6
		end

		friends.BackgroundColor3 = backgroundColor
	end

	if country then
		local backgroundColor

		if activeTab == "Country" then
			backgroundColor = color5
		else
			backgroundColor = color6
		end

		country.BackgroundColor3 = backgroundColor
	end

	updateBoard(p)
end

local function fetchFriendsLeaderboard(p: string)
	local v4 = v3[p]

	if not v4 or v4.FriendsFetched then
		return
	end

	v4.FriendsFetched = true
	local v5 = nil
	local v6 = nil
	pcall(function()
		v5, v6 = remoteFunction2:InvokeServer(p)
	end)

	if not v5 or type(v6) ~= "table" then
		v4.FriendsFetched = nil
		return
	end

	table.sort(v6, function(a, b)
		return (a.Amount or 0) > (b.Amount or 0)
	end)
	local friendsData = {}

	for k, v8 in v6 do
		v[v8.Id] = v8.DisplayName or v8.Username
		table.insert(friendsData, {
			UserId = v8.Id,
			Value = v8.Amount or 0,
			Rank = k,
			Country = v8.Country
		})
	end

	v4.FriendsData = friendsData

	if v4.ActiveTab == "Friends" then
		updateBoard(p)
	end
end

local function fetchCountryLeaderboard(p: string)
	local v4 = v3[p]

	if not v4 or v4.CountryFetched then
		return
	end

	v4.CountryFetched = true
	local countryData = nil
	local countryCode = nil
	pcall(function()
		countryData, countryCode = remoteFunction4:InvokeServer(p)
	end)

	if type(countryData) == "table" then
		v4.CountryData = countryData
		v4.CountryCode = countryCode

		if v4.ActiveTab == "Country" then
			updateBoard(p)
		end
	else
		v4.CountryFetched = nil
	end
end

local function refreshLeaderboard(p, playerData)
	if not playerData then
		pcall(function()
			playerData = remoteFunction:InvokeServer(p)
		end)
	end

	if type(playerData) == "table" then
		v3[p].PlayerData = playerData

		if (v3[p].ActiveTab or "Global") == "Global" then
			updateBoard(p)
		end
	end
end

local function onPlayerAdded(player)
	v[player.UserId] = player.DisplayName
end

return {
	Start = function(_)
		if ServerData.IsDuelsServer() or ServerData.IsTsunamiServer() then
			return
		end

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		v3 = {
			Generation = {
				Model = map:WaitForChild("GenerationBoard"),
				PlayerData = {},
				FriendsData = {},
				CountryData = {},
				ActiveTab = "Global",
				Lines = {}
			},
			Steals = {
				Model = map:WaitForChild("StealsBoard"),
				PlayerData = {},
				FriendsData = {},
				CountryData = {},
				ActiveTab = "Global",
				Lines = {}
			}
		}

		for k, v4 in v3 do
			local main = v4.Model:WaitForChild("Main")
			local surfaceGui = main:WaitForChild("SurfaceGui")
			surfaceGui.Adornee = main
			surfaceGui.Parent = playerGui
			v4.Gui = surfaceGui
			local mainFrame = surfaceGui:WaitForChild("MainFrame")
			v4.Container = mainFrame:WaitForChild("ScrollingFrame")
			v4.Template = v4.Container:WaitForChild("LeaderboardTemplate")
			local buttons = mainFrame:WaitForChild("Buttons")
			local global = buttons:FindFirstChild("Global")
			local friends = buttons:FindFirstChild("Friends")
			local country = buttons:FindFirstChild("Country")
			v4.ButtonsFrame = buttons
			v4.GlobalBtn = global
			v4.FriendsBtn = friends
			v4.CountryBtn = country
			v4.OriginalContainerSize = v4.Container.Size

			if global then
				local v5 = k
				global.Activated:Connect(function()
					if FFlags:GetInstant("Leaderboard/GlobalDisabled", false) then
						return
					end

					setActiveTab(v5, "Global")
				end)
			end

			if friends then
				local v5 = k
				friends.Activated:Connect(function()
					if FFlags:GetInstant("Leaderboard/FriendsDisabled", false) then
						return
					end

					setActiveTab(v5, "Friends")
					task.spawn(fetchFriendsLeaderboard, v5)
				end)
			end

			if not country then
				continue
			end

			local v5 = k
			country.Activated:Connect(function()
				if FFlags:GetInstant("Leaderboard/CountryDisabled", false) then
					return
				end

				setActiveTab(v5, "Country")
				task.spawn(fetchCountryLeaderboard, v5)
			end)
		end

		local function updateFlagVisibility()
			local instant = FFlags:GetInstant("Leaderboard/GlobalDisabled", false)
			local instant2 = FFlags:GetInstant("Leaderboard/FriendsDisabled", false)
			local instant3 = FFlags:GetInstant("Leaderboard/CountryDisabled", false)

			for k, v4 in v3 do
				local globalBtn = v4.GlobalBtn
				local friendsBtn = v4.FriendsBtn
				local countryBtn = v4.CountryBtn

				if globalBtn then
					globalBtn.Visible = not instant
				end

				if friendsBtn then
					friendsBtn.Visible = not instant2
				end

				if countryBtn then
					countryBtn.Visible = not instant3
				end

				local count = 0

				if globalBtn and not instant then
					count += 1
				end

				if friendsBtn and not instant2 then
					count += 1
				end

				if countryBtn and not instant3 then
					count += 1
				end

				if count <= 1 then
					v4.ButtonsFrame.Visible = false
					v4.Container.Size = UDim2.new(
						v4.OriginalContainerSize.X.Scale,
						v4.OriginalContainerSize.X.Offset,
						0.9,
						0
					)
				else
					v4.ButtonsFrame.Visible = true
					v4.Container.Size = v4.OriginalContainerSize
				end

				local activeTab = v4.ActiveTab
				local v5

				if activeTab == "Global" and instant then
					v5 = instant
				elseif activeTab == "Friends" and instant2 then
					v5 = instant2
				elseif activeTab == "Country" then
					v5 = instant3
				else
					v5 = false
				end

				if v5 then
					setActiveTab(
						k,
						instant and (instant2 and (instant3 and "Global" or "Country") or "Friends") or "Global"
					)
				end
			end
		end

		task.spawn(updateFlagVisibility)
		FFlags:OnUpdate(updateFlagVisibility)

		for _, v4 in Players:GetPlayers() do
			task.spawn(onPlayerAdded, v4)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)

		local function updateNameCache(items)
			if type(items) ~= "table" then
				return
			end

			for k, item in items do
				local v4 = tonumber(k)

				if not v4 then
					continue
				end

				v[v4] = item
				local v5 = v2[v4]

				if type(v5) ~= "table" then
					continue
				end

				for _, v6 in v5 do
					local nameLabel = v6:FindFirstChild("NameLabel")

					if nameLabel and nameLabel:IsA("TextLabel") then
						nameLabel.Text = item .. (nameLabel:GetAttribute("Flag") or "")
					end
				end
			end
		end

		remoteEvent.OnClientEvent:Connect(function(p: string, p2)
			refreshLeaderboard(p, p2)
		end)
		remoteEvent3.OnClientEvent:Connect(function(p: string, countryData)
			local v4 = v3[p]

			if not v4 then
				return
			end

			v4.CountryData = countryData

			if v4.ActiveTab == "Country" then
				updateBoard(p)
			end
		end)
		remoteEvent2.OnClientEvent:Connect(updateNameCache)
		updateNameCache(remoteFunction3:InvokeServer())

		for k, v4 in v3 do
			if v4.ActiveTab == "Global" then
				task.spawn(refreshLeaderboard, k)
			elseif v4.ActiveTab == "Friends" then
				task.spawn(fetchFriendsLeaderboard, k)
			elseif v4.ActiveTab == "Country" then
				task.spawn(fetchCountryLeaderboard, k)
			end
		end

		local total = 0
		RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if total < 0.25 then
				return
			end

			total = 0
			local currentCamera = Workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local position = currentCamera.CFrame.Position

			for _, v4 in v3 do
				local model = v4.Model
				local container = v4.Container

				if model and container then
					container.ScrollingEnabled = (model:GetPivot().Position - position).Magnitude <= 60
				end
			end
		end)
	end
}