local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("UserService")
local sharedPersonalAquarium = ReplicatedStorage.shared.modules.SharedPersonalAquarium
local OtherData = require(sharedPersonalAquarium.SharedData.OtherData)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers.CutsceneController)
local FriendsList = require(ReplicatedStorage.client.modules.FriendsList)
local packages = ReplicatedStorage.packages
local State = require(packages.State)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
require("../Types")
local v = {
	[Enum.KeyCode.Unknown] = true
}
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Join")
local everyone = State.new("Everyone")
local flag = false
local flag2 = false
local _ = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local anno_localthought = ReplicatedStorage.events.anno_localthought

-- equivalent calls inferred from this helper; original call sites unknown
local function localPlayerIsSeated()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	return not humanoid or humanoid.Sit
end

local AquariumSearch = {}

function AquariumSearch.Start(_, dependencies)
	AquariumSearch.Trove = Trove.new()
	AquariumSearch.Dependencies = dependencies
	AquariumSearch._loadToken = 0
	local container = dependencies.Instance.Container
	AquariumSearch.Container = container
	local scrollingFrame = container.ScrollContainer.ScrollingFrame
	AquariumSearch.ListTemplate = scrollingFrame.Player:Clone()
	scrollingFrame.Player:Destroy()
	dependencies.Shared.HandleButtonFn(container.MyAquarium, function()
		if localPlayerIsSeated() then
			anno_localthought:Fire("You can't teleport while seated!")
		else
			AquariumSearch._TeleportWrapper(Players.LocalPlayer.UserId)
		end
	end, false)
	dependencies.Shared.HandleButtonFn(container.PlayerListView.Everyone, function()
		everyone:set("Everyone")
	end, false)
	dependencies.Shared.HandleButtonFn(container.PlayerListView.Friends, function()
		everyone:set("Friends")
	end, false)
	dependencies.Shared.HandleButtonFn(container.Search.EnterQuery, function()
		AquariumSearch._SubmitSearch(true)
	end, false)
	container.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if everyone:get() ~= "Friends" then
			return
		end

		AquariumSearch._RefreshFriends(container.Search.TextBox.Text)
	end)
	everyone:observe(AquariumSearch._OnListTypeChange)
	Players.PlayerAdded:Connect(AquariumSearch._OnPlayerAdded)
	Players.PlayerRemoving:Connect(AquariumSearch._OnPlayerRemoving)
end

function AquariumSearch.Opened()
	if everyone:get() == "Everyone" then
		AquariumSearch._OnListTypeChange("Everyone")
	else
		everyone:set("Everyone")
	end
end

function AquariumSearch.Closed()
	AquariumSearch.Trove:Clean()
	AquariumSearch.Container.Search.TextBox.Text = ""
	AquariumSearch.Container.ScrollContainer.ScrollingFrame.CanvasPosition = Vector2.zero
end

function AquariumSearch._OnListTypeChange(p: string)
	local container = AquariumSearch.Container
	container.PlayerListView.Everyone.Tabbed.Visible = p == "Everyone"
	container.PlayerListView.Everyone.Label.TextColor3 = p == "Everyone" and Color3.fromRGB(126, 199, 255) or Color3.fromRGB(
		255,
		255,
		255
	)
	container.PlayerListView.Friends.Tabbed.Visible = p == "Friends"
	container.PlayerListView.Friends.Label.TextColor3 = p == "Friends" and Color3.fromRGB(126, 199, 255) or Color3.fromRGB(
		255,
		255,
		255
	)
	container.Search.EnterQuery.Visible = p == "Everyone"
	container.Search.TextBox.PlaceholderText = p == "Everyone" and "Username (Global)" or "Search Friends.."
	container.Search.TextBox.Text = ""

	if p == "Everyone" then
		AquariumSearch._RefreshServer()
	elseif p == "Friends" then
		AquariumSearch._RefreshFriends(container.Search.TextBox.Text)
	end
end

function AquariumSearch._ResetList()
	AquariumSearch._loadToken += 1
	local scrollingFrame = AquariumSearch.Container.ScrollContainer.ScrollingFrame

	for _, uIListLayout in scrollingFrame:GetChildren() do
		if not uIListLayout:IsA("UIListLayout") then
			uIListLayout:Destroy()
		end
	end

	scrollingFrame.CanvasPosition = Vector2.zero
	return AquariumSearch._loadToken
end

function AquariumSearch._RefreshServer()
	local _ResetList = AquariumSearch._ResetList()
	task.spawn(function()
		for _, player in Players:GetPlayers() do
			if _ResetList ~= AquariumSearch._loadToken then
				break
			end

			AquariumSearch._LoadCard({
				UserId = player.UserId,
				DisplayName = player.DisplayName,
				Player = player
			}, _ResetList)
			RunService.PostSimulation:Wait()
		end
	end)
end

function AquariumSearch._RefreshFriends(value: string?)
	local _ResetList = AquariumSearch._ResetList()
	task.spawn(function()
		local _GetCachedFriends = AquariumSearch._GetCachedFriends()

		if _ResetList ~= AquariumSearch._loadToken then
			return
		end

		local v2 = string.lower(value or "")
		local _GetCachedFriends2 = {}
		local _GetCachedFriends3 = {}

		for _, _GetCachedFriend in _GetCachedFriends do
			if not (not (#v2 > 0) or string.find(string.lower(_GetCachedFriend.DisplayName), v2, 1, true) or string.find(
				string.lower(_GetCachedFriend.Username),
				v2,
				1,
				true
			)) then
				continue
			end

			if Players:GetPlayerByUserId(_GetCachedFriend.UserId) then
				table.insert(_GetCachedFriends2, _GetCachedFriend)
			else
				table.insert(_GetCachedFriends3, _GetCachedFriend)
			end
		end

		local v3 = {}

		for _, v4 in _GetCachedFriends2 do
			table.insert(v3, v4)
		end

		for _, v4 in _GetCachedFriends3 do
			table.insert(v3, v4)
		end

		for k, v4 in v3 do
			if k > 25 or _ResetList ~= AquariumSearch._loadToken then
				break
			end

			AquariumSearch._LoadCard({
				UserId = v4.UserId,
				DisplayName = v4.DisplayName,
				Username = v4.Username,
				Player = Players:GetPlayerByUserId(v4.UserId)
			}, _ResetList)
		end
	end)
end

function AquariumSearch._GetCachedFriends()
	return FriendsList.GetFriendsAsync()
end

function AquariumSearch._LoadCard(player, p: number)
	if p ~= AquariumSearch._loadToken then
		return
	end

	local clone = AquariumSearch.ListTemplate:Clone()
	local userId = player.UserId
	AquariumSearch.Dependencies.Shared.HandleButtonFn(clone, function()
		AquariumSearch._OnCardActivated(player)
	end, false)
	local player2 = player.Player
	local v2

	if player2 then
		local hasVerifiedBadge = player2.HasVerifiedBadge
		local v3 = player2.MembershipType == Enum.MembershipType.Premium
		local hasRobloxSubscription = player2.HasRobloxSubscription
		local v5 = not hasVerifiedBadge and "" or utf8.char(57344)
		local v6

		if hasRobloxSubscription then
			v6 = utf8.char(57347)
		else
			v6 = not v3 and "" or utf8.char(57345)
		end

		v2 = ` {v5}{v6}`
	else
		v2 = ""
	end

	clone.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=180&h=180`
	clone.Username.Text = (player.Username or player.DisplayName) .. v2
	clone.Name = tostring(userId)
	local scrollingFrame = AquariumSearch.Container.ScrollContainer.ScrollingFrame

	if p == AquariumSearch._loadToken and not scrollingFrame:FindFirstChild(clone.Name) then
		clone.Parent = scrollingFrame
	else
		clone:Destroy()
	end
end

function AquariumSearch._OnCardActivated(p)
	if localPlayerIsSeated() then
		anno_localthought:Fire("You can't teleport while seated!")
	elseif Players:GetPlayerByUserId(p.UserId) then
		AquariumSearch._TeleportWrapper(p.UserId)
	else
		AquariumSearch._TryOfflineVisit(p.UserId, p.Username)
	end
end

function AquariumSearch._OnPlayerAdded(player)
	if everyone:get() ~= "Everyone" then
		return
	end

	AquariumSearch._LoadCard({
		UserId = player.UserId,
		DisplayName = player.DisplayName,
		Player = player
	}, AquariumSearch._loadToken)
end

function AquariumSearch._OnPlayerRemoving(p)
	if everyone:get() ~= "Everyone" then
		return
	end

	local child = AquariumSearch.Container.ScrollContainer.ScrollingFrame:FindFirstChild((tostring(p.UserId)))

	if child then
		child:Destroy()
	end
end

function AquariumSearch._SubmitSearch(flag3: boolean?, p)
	if everyone:get() ~= "Everyone" or (not flag3 or p and v[p.KeyCode]) then
		return
	end

	local text = AquariumSearch.Container.Search.TextBox.Text

	if #text == 0 then
		return
	end

	if flag then
		anno_localthought:Fire("Please wait a bit before requesting another player...")
		return
	end

	flag = true
	task.delay(OtherData.OfflineJoinDebounceLength, function()
		flag = false
	end)
	local userIdFromNameAsync = nil

	if not (pcall(function()
		userIdFromNameAsync = Players:GetUserIdFromNameAsync(text)
	end) and userIdFromNameAsync) then
		anno_localthought:Fire("Failed to retrieve user information.")
	elseif Players:GetPlayerByUserId(userIdFromNameAsync) then
		AquariumSearch._TeleportWrapper(userIdFromNameAsync)
	else
		AquariumSearch._FireOfflineVisit(userIdFromNameAsync, nil)
	end
end

function AquariumSearch._TeleportWrapper(p: number)
	if flag2 then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	flag2 = true
	task.delay(1.5, function()
		flag2 = false
	end)

	if not humanoid.Sit then
		CutsceneController:Fade(2.85)
	end

	AquariumSearch.Dependencies.Signals.ForceClose:Fire()
	remoteEvent:FireServer(p)
end

function AquariumSearch._TryOfflineVisit(p: number, p2: string?)
	if flag then
		anno_localthought:Fire("Please wait a bit before requesting another player...")
		return
	end

	flag = true
	task.delay(OtherData.OfflineJoinDebounceLength, function()
		flag = false
	end)
	AquariumSearch._FireOfflineVisit(p, p2)
end

function AquariumSearch._FireOfflineVisit(p: number, p2: string?)
	local nameFromUserIdAsync = p2

	if nameFromUserIdAsync or pcall(function()
		nameFromUserIdAsync = Players:GetNameFromUserIdAsync(p)
	end) and nameFromUserIdAsync then
		AquariumSearch.Dependencies.Signals.VisitAquarium:Fire(nameFromUserIdAsync, p)
	else
		anno_localthought:Fire("Failed to retrieve user information.")
	end
end

return AquariumSearch