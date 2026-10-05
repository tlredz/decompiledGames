local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local FriendsHandler = {
	lastUpdated = 0,
	updateEvery = 60,
	currentOnlineFriends = {},
	allLastUpdated = 0,
	allUpdateEvery = 300,
	currentAllFriends = {}
}

function FriendsHandler.getFriendsInPlace(p: number)
	local allOnlineFriends = FriendsHandler:getAllOnlineFriends()
	local allOnlineFriends2 = {}

	for _, allOnlineFriend in pairs(allOnlineFriends) do
		if allOnlineFriend.placeId == p then
			table.insert(allOnlineFriends2, allOnlineFriend)
		end
	end

	return allOnlineFriends2
end

local Friend = require(ReplicatedStorage.CAM.Global.Subsets.Classes.Friend)
local v = false

function FriendsHandler.getAllOnlineFriends()
	if v ~= false then
		return FriendsHandler.currentOnlineFriends
	end

	v = true

	if os.clock() - FriendsHandler.lastUpdated > FriendsHandler.updateEvery then
		if #FriendsHandler.currentOnlineFriends > 0 then
			table.clear(FriendsHandler.currentOnlineFriends)
		end

		local success, result = pcall(function()
			return game.Players.LocalPlayer:GetFriendsOnline()
		end)

		for _, v2 in pairs(not success and {} or result) do
			if not (v2.IsOnline == true and v2.PlaceId) then
				continue
			end

			local v3 = table.find(gameSettings.placesWithinGame, v2.PlaceId) ~= nil
			table.insert(
				FriendsHandler.currentOnlineFriends,
				Friend.New(v2.UserName, v2.VisitorId, v2.PlaceId, v2.GameId, v3)
			)
		end

		if success then
			FriendsHandler.lastUpdated = os.clock()
		end
	end

	v = false
	return FriendsHandler.currentOnlineFriends
end

local v2 = false

local function fetchAllFriends()
	v2 = true
	local currentAllFriends = {}

	if pcall(function()
		local friendsAsync = Players:GetFriendsAsync(Players.LocalPlayer.UserId)

		while true do
			for _, v4 in friendsAsync:GetCurrentPage() do
				table.insert(currentAllFriends, Friend.New(v4.Username, v4.Id, 0, nil, false))
			end

			if friendsAsync.IsFinished then
				break
			else
				friendsAsync:AdvanceToNextPageAsync()
			end
		end
	end) then
		FriendsHandler.currentAllFriends = currentAllFriends
		FriendsHandler.allLastUpdated = os.clock()
	end

	v2 = false
end

function FriendsHandler.getAllFriends(flag: boolean?)
	if os.clock() - FriendsHandler.allLastUpdated > FriendsHandler.allUpdateEvery and not v2 then
		if flag and FriendsHandler.allLastUpdated == 0 then
			fetchAllFriends()
		else
			task.spawn(fetchAllFriends)
		end
	elseif flag and v2 and FriendsHandler.allLastUpdated == 0 then
		repeat
			task.wait()
		until not v2
	end

	return FriendsHandler.currentAllFriends
end

return FriendsHandler