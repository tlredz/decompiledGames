local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(packages.Signal)
local Debounce = require(packages.Debounce)
local Promise = require(ReplicatedStorage.Packages.Promise)
local friendMain = script:WaitForChild("FriendMain")
local v = {}
local Friends = {
	OnFriendsUpdate = Signal.new()
}

local function OnPlayerAdded(object)
	v[object] = v[object] or {}
	local v2 = v[object]

	for _, v3 in Players:GetPlayers() do
		if v3 == object then
			continue
		end

		local v4 = v3
		local success, result = pcall(function()
			return object:IsFriendsWithAsync(v4.UserId)
		end)

		if not (success and result) then
			continue
		end

		v[v3] = v[v3] or {}

		if not table.find(v2, v3) then
			table.insert(v2, v3)
		end

		if not table.find(v[v3], object) then
			table.insert(v[v3], object)
		end
	end
end

local function OnPlayerRemoving(p)
	for k, list in v do
		if k == p then
			continue
		end

		local index = table.find(list, p)

		if index then
			table.remove(list, index)
		end
	end

	v[p] = nil
end

function Friends.GetFriendBoostPercentage(_, p)
	if p then
		return math.clamp(Friends:GetAmountOfFriendsOnline(p), 0, 3) * 10
	end

	return 0
end

function Friends.GetFriendBoostModifier(_, p)
	if p then
		return math.clamp(Friends:GetAmountOfFriendsOnline(p), 0, 3) / 10
	end

	return 0
end

function Friends:GetAmountOfFriendsOnline(p)
	local v2 = v[p]
	return v2 and #v2 or 0
end

local v2 = {}
local v3 = {}

function Friends.GetOnlineFriends(_, localPlayer)
	if localPlayer == nil then
		assert(RunService:IsClient())
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local unixTimestamp = DateTime.now().UnixTimestamp

	if v2[localPlayer] == nil or unixTimestamp - (v3[localPlayer] or 0) >= 600 or v2[localPlayer]:getStatus() == Promise.Status.Rejected then
		v3[localPlayer] = unixTimestamp
		v2[localPlayer] = Promise.try(function()
			return localPlayer:GetFriendsOnlineAsync(200)
		end)
	end

	return v2[localPlayer]:await()
end

local v4 = {}

function Friends:GetFriendsAsync(localPlayer)
	if localPlayer == nil then
		assert(RunService:IsClient())
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local _ = DateTime.now().UnixTimestamp

	if v4[localPlayer] == nil or v4[localPlayer]:getStatus() == Promise.Status.Rejected then
		v4[localPlayer] = Promise.new(function(callback, _, callback2)
			local friendsAsync = Players:GetFriendsAsync(localPlayer.UserId)
			local v5 = {}

			while not callback2() do
				local currentPage = friendsAsync:GetCurrentPage()
				table.move(currentPage, 1, #currentPage, #v5 + 1, v5)

				if friendsAsync.IsFinished or not pcall(function()
					friendsAsync:AdvanceToNextPageAsync()
				end) then
					break
				end
			end

			callback(v5)
		end)
	end

	return v4[localPlayer]:await()
end

Players.PlayerRemoving:Connect(function(player)
	if v2[player] then
		v2[player]:cancel()
		v2[player] = nil
	end

	if v4[player] then
		v4[player]:cancel()
		v4[player] = nil
	end

	v3[player] = nil
end)

function Friends.HasFriendInGameAsync(_, object)
	for _, v5 in Players:GetPlayers() do
		if v5 == object then
			continue
		end

		local v6 = v5
		local success, result = pcall(function()
			return object:IsFriendsWithAsync(v6.UserId)
		end)

		if success and result then
			return true
		end
	end

	return false
end

function Friends.GetInGameFriends(_, p)
	return v[p] or {}
end

function Friends:Start()
	if RunService:IsServer() then
		friendMain.OnServerEvent:Connect(function(player, flag: boolean?, instance)
			if Debounce(`Friends/Check/{player.Name}`, 0.1) then
				return
			end

			if flag ~= true then
				friendMain:FireClient(player, v[player] or {})
				return
			end

			if not instance or typeof(instance) ~= "Instance" or not instance:IsDescendantOf(Players) or instance == player then
				return
			end

			local instances = v[player]

			if not instances then
				return
			end

			local players = v[instance]

			if not (players and player:IsFriendsWithAsync(instance.UserId)) then
				return
			end

			if not table.find(instances, instance) then
				table.insert(instances, instance)
			end

			if not table.find(players, player) then
				table.insert(players, player)
			end

			friendMain:FireClient(player, instances)
			friendMain:FireClient(instance, players)
			Friends.OnFriendsUpdate:Fire()
		end)
		Players.PlayerAdded:Connect(OnPlayerAdded)
		Players.PlayerRemoving:Connect(OnPlayerRemoving)

		for _, v5 in Players:GetPlayers() do
			task.spawn(OnPlayerAdded, v5)
		end
	else
		local localPlayer = Players.LocalPlayer
		friendMain.OnClientEvent:Connect(function(p)
			v[localPlayer] = p
			Friends.OnFriendsUpdate:Fire()
		end)

		while true do
			local success, _ = pcall(function()
				return StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
					friendMain:FireServer(true, p)
				end)
			end)

			if success then
				break
			end

			task.wait(0.1)
		end

		friendMain:FireServer()
		task.spawn(function()
			while task.wait(15) do
				friendMain:FireServer()
			end
		end)
	end
end

Friends:Start()
return Friends