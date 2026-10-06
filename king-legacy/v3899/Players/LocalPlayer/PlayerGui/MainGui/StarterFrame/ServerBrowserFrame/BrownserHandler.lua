local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local Network = require(ReplicatedStorage.Chest.Assets.Modules.Network)
local TaskManager = require(ReplicatedStorage.Chest.Assets.Modules.TaskManager)
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local maid = TaskManager.new()
local parent = script.Parent
local mainFrame = parent.MainFrame
local friendFrame = parent.FriendFrame
local _ = parent.Parent
local serverBT = parent:WaitForChild("ServerBT")
local friendBT = parent:WaitForChild("FriendBT")
local refreshButton = mainFrame:WaitForChild("RefreshButton")
local serverFrame = mainFrame:WaitForChild("ServerFrame")
local settingFrame = mainFrame:WaitForChild("SettingFrame")
local serverCount = mainFrame:WaitForChild("ServerCount")
local regionFrame = settingFrame:WaitForChild("RegionFrame")
local regionButton = settingFrame:WaitForChild("RegionButton")
local searchBar = settingFrame:WaitForChild("SearchBar")
local seaFrame = parent:WaitForChild("SeaFrame")
local flag = nil
local v = true

function ButtonClick(instance, p)
	if not (instance and p and v) then
		return
	end

	v = nil
	local uDim = UDim2.new(0.125, 0, 0.22, 0)
	local uDim2 = UDim2.new(0.14375, 0, 0.253, 0)
	instance.Size = uDim
	TweenService:Create(
		instance,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = uDim2
		}
	):Play()

	if instance:FindFirstChild("ImageLabel") then
		instance.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			instance.ImageLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()
	end

	for _, child in pairs(parent:GetChildren()) do
		if child:GetAttribute("FirstButton") then
			if child == instance then
				child.Position = UDim2.new(child.Position.X.Scale, -0.05, 0)
				TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(child.Position.X.Scale, 0, -0.065, 0)
				}):Play()
			else
				TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(child.Position.X.Scale, 0, -0.05, 0)
				}):Play()
			end
		elseif child:GetAttribute("FirstFrame") then
			if child == p then
				child.Visible = true
			else
				child.Visible = false
			end
		end
	end

	spawn(function()
		wait(0.1)
		v = true
	end)
end

serverBT.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	ButtonClick(serverBT, mainFrame)
end)

function ClearFriendList()
	for _, frame in ipairs(friendFrame.ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local flag2 = nil

function IsInGame(p)
	for k, v2 in pairs(WorldsId.Testing) do
		if v2 == p then
			return k
		end
	end

	for k, v2 in pairs(WorldsId.KingLegacy) do
		if v2 == p then
			return k
		end
	end
end

local maid2 = TaskManager.new()

function UpdateFriendList()
	if flag2 then
		return
	end

	flag2 = true
	ClearFriendList()
	maid2:DoCleaning()
	friendFrame.FriendCount.Text = "Loading"
	local friendsOnlineAsync = Players.LocalPlayer:GetFriendsOnlineAsync()
	local X = friendFrame.ScrollingFrame.AbsoluteSize.X
	local v2 = friendFrame.ScrollingFrame.AbsoluteSize.Y / 5
	local count = 0

	for _, v3 in ipairs(friendsOnlineAsync) do
		local placeId = v3.PlaceId
		local gameId = v3.GameId

		if not (placeId and gameId) then
			continue
		end

		local v4 = IsInGame(placeId)

		if not v4 then
			continue
		end

		local displayName = v3.DisplayName
		local userName = v3.UserName
		local visitorId = v3.VisitorId
		local clone = script.FriendTemplate:Clone()
		clone.Name = userName
		clone.Size = UDim2.fromOffset(X - friendFrame.ScrollingFrame.ScrollBarThickness, v2)
		clone.UsernameLabel.Text = `@{userName}`
		clone.DisplayNameLabel.Text = `{displayName}`
		clone.SeaLabel.Text = `Location: {v4}`

		if gameId == game.JobId then
			clone.JoinButton.TextLabel.Text = "In Server"
		end

		clone.Parent = friendFrame.ScrollingFrame
		maid2:GiveTask(clone.JoinButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("JoinFriend", {
				UserId = visitorId
			})
		end))
		count += 1
	end

	friendFrame.FriendCount.Text = `Active: {count}`
	flag2 = nil
end

friendFrame.RefreshFriend.MouseButton1Click:Connect(UpdateFriendList)
friendBT.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	ButtonClick(friendBT, friendFrame)
	UpdateFriendList()
end)

for _, button in pairs(seaFrame:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v2 = button
	button.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		local seaName = v2.Name == "Sea2" and "SecondSea" or v2.Name == "Sea3" and "ThirdSea" or "FirstSea"
		_G.ClickFrameEffect({
			Sound = true
		})

		if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("TeleportSea", {
			SeaName = seaName
		}) then
			return
		end

		task.delay(1, function()
			flag = nil
		end)
	end)
end

local flag3 = nil
local v2 = {}
local clones = {}
local v3 = {
	Region = nil,
	SearchingText = nil
}

function IsObjectMatched(instance)
	if instance:GetAttribute("AlwayShow") then
		return true
	end

	if instance:GetAttribute("Full") and not v3.ShowFullServer then
		return
	end

	if (v3.Region or v3.SearchingText) and (not v3.Region or v3.Region ~= instance:GetAttribute("Region")) and not (v3.SearchingText and Searching(instance.Name)) then
		return
	end

	return true
end

function Searching(value)
	if v3.SearchingText and string.find(string.lower(value), string.lower(v3.SearchingText)) then
		return true
	end
end

function UpdateCurrentServers()
	local _ = serverFrame.AbsoluteSize.X * 1 - serverFrame.ScrollBarThickness
	local v4 = serverFrame.AbsoluteSize.Y * 0.25
	local total = 0
	local total2 = 0
	local count = 0

	for _, v5 in pairs(clones) do
		if IsObjectMatched(v5) then
			v5.Position = UDim2.fromOffset(0, total)
			total2 += v4
			total += v4
			serverFrame.CanvasSize = UDim2.fromOffset(0, total2)
			count += 1
		else
			v5.Visible = nil
		end
	end

	serverFrame.CanvasPosition = Vector2.zero
	serverCount.Text = ("%s / %s"):format(tostring(count), (tostring(#clones)))
	UpdateServerListScrolling()
end

function UpdateSelectingRegion()
	for _, button in pairs(regionFrame.ScrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundTransparency = v3.Region == button.Name and 0.5 or 1
		end
	end

	UpdateCurrentServers()
end

function UpdateRegionButtons()
	for childName, _ in pairs(v2) do
		if regionFrame.ScrollingFrame:FindFirstChild(childName) then
			continue
		end

		local clone = script.RegionButton:Clone()
		clone.Name = childName
		clone.Text = childName
		clone.Parent = regionFrame.ScrollingFrame
		local region = childName
		clone.MouseButton1Click:Connect(function()
			if v3.Region == region then
				v3.Region = nil
			else
				v3.Region = region
			end

			UpdateSelectingRegion()
		end)
	end
end

function UpdateServerListScrolling()
	local Y = serverFrame.CanvasPosition.Y
	local Y2 = serverFrame.AbsoluteSize.Y

	for _, v4 in ipairs(clones) do
		if IsObjectMatched(v4) then
			local offset = v4.Position.Y.Offset
			v4.Visible = Y <= offset + v4.AbsoluteSize.Y and offset <= Y + Y2
		else
			v4.Visible = nil
		end
	end
end

function ConvertUnixTime(p)
	local v4 = math.floor(p / 86400)
	local v5 = math.floor(p / 3600) % 24
	local v6 = math.floor(p / 60) % 60
	local v7 = math.floor(p) % 60
	return string.format("%02d:%02d:%02d:%02d", v4, v5, v6, v7)
end

function UpdateServerLists()
	if flag3 then
		return
	end

	flag3 = true
	serverCount.Text = "Loading"
	local v4 = Network:InvokeServer("GetServerLists")
	table.clear(clones)
	table.clear(v2)
	maid:DoCleaning()
	local total = 0

	for _, frame in pairs(serverFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local success, result = pcall(function()
		if not v4 or #v4 <= 0 then
			serverCount.Text = "Refresh"
			return
		end

		local v5 = serverFrame.AbsoluteSize.X * 1 - serverFrame.ScrollBarThickness
		local v6 = serverFrame.AbsoluteSize.Y * 0.25
		local now = os.time()
		table.sort(v4, function(a, b)
			local createdAt = a.CreatedAt
			local createdAt2 = b.CreatedAt

			if a.JobId == game.JobId then
				createdAt = 1e999
			elseif b.JobId == game.JobId then
				createdAt2 = 1e999
			end

			return createdAt2 < createdAt
		end)
		local total2 = 0
		local count = 0

		for i, v7 in ipairs(v4) do
			local region = v7.Region or "Unknow"
			local clone = script.ServerFrame:Clone()
			clone.Name = v7.Name or "Unknow"
			clone.NameLabel.Text = v7.Name or "Unknow"
			clone.RegionLabel.Text = region .. (" [%s/%s]"):format(
				tostring(v7.PlayerCount or "?"),
				(tostring(Players.MaxPlayers))
			)
			clone.Size = UDim2.fromOffset(v5, v6)
			clone.Position = UDim2.fromOffset(0, total2)
			clone:SetAttribute("Region", region)

			if (v7.PlayerCount or 0) >= Players.MaxPlayers then
				clone:SetAttribute("Full", true)
			end

			clone.Visible = nil
			local v8 = game.JobId == v7.JobId

			if v8 then
				clone:SetAttribute("AlwayShow", true)
			end

			v2[region] = (v2[region] or 0) + 1
			local v10 = v7
			maid:GiveTask(clone.JoinButton.MouseButton1Click:Connect(function()
				if v8 then
					return
				end

				local success2, result2 = pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, v10.JobId)
				end)

				if not success2 then
					warn(result2)
				end
			end))
			clone.JoinButton.TextLabel.Text = v8 and "You're here" or "Join"
			clone.ServerAgeLabel.Text = "Servertime: " .. ConvertUnixTime(now - v7.CreatedAt)
			clone.Parent = serverFrame
			total += v6
			total2 += v6
			serverFrame.CanvasSize = UDim2.fromOffset(0, total)
			table.insert(clones, clone)

			if IsObjectMatched(clone) then
				count += 1
			end

			serverCount.Text = ("%s / %s"):format(tostring(count), (tostring(#v4)))

			if not (i % 30) then
				continue
			end

			UpdateServerListScrolling()
			RunService.Heartbeat:Wait()
		end

		serverCount.Text = ("%s / %s"):format(tostring(count), (tostring(#v4)))
		UpdateCurrentServers()
		UpdateRegionButtons()
	end)
	flag3 = nil

	if not success then
		warn(result)
	end
end

serverFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	UpdateServerListScrolling()
end)
serverFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateCurrentServers()
end)
refreshButton.MouseButton1Click:Connect(function()
	UpdateServerLists()
end)
regionButton.MouseButton1Click:Connect(function()
	regionFrame.Visible = not regionFrame.Visible
end)
searchBar.TextBox.FocusLost:Connect(function()
	local text = searchBar.TextBox.Text

	if text == "" or not text then
		text = nil
	end

	v3.SearchingText = text
	UpdateCurrentServers()
end)
settingFrame["Show Full Server"].Button.MouseButton1Click:Connect(function()
	if v3.ShowFullServer then
		settingFrame["Show Full Server"].Button.BackgroundColor3 = Color3.fromRGB(176, 0, 0)
		settingFrame["Show Full Server"].Button.Text = "OFF"
		v3.ShowFullServer = nil
	else
		settingFrame["Show Full Server"].Button.BackgroundColor3 = Color3.fromRGB(11, 176, 0)
		settingFrame["Show Full Server"].Button.Text = "ON"
		v3.ShowFullServer = true
	end

	UpdateCurrentServers()
end)
task.spawn(function()
	while true do
		local serverCreatedAt = parent.Visible and ReplicatedStorage:GetAttribute("ServerCreatedAt")

		if serverCreatedAt then
			local v4 = ConvertUnixTime(os.time() - serverCreatedAt)
			parent.ServerTime.Text = "Servertime: " .. v4
			task.wait(1)
		else
			parent:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)