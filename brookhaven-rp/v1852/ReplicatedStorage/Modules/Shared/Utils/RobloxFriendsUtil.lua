local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseCache = require(ReplicatedStorage.Packages.PromiseCache)
local Promise = require(ReplicatedStorage.Packages.Promise)
local StarterGui = game:GetService("StarterGui")
local v = PromiseCache.new(nil, 60)

-- equivalent calls inferred from this helper; original call sites unknown
local function getFriends(p)
	local userId = p.UserId
	return v:GetValue(userId, nil, function(_)
		local v2 = {
			Friends = {}
		}
		local success, result = pcall(function()
			return Players:GetFriendsAsync(userId)
		end)

		if not success then
			return v2
		end

		while true do
			for _, v3 in ipairs(result:GetCurrentPage()) do
				table.insert(v2.Friends, {
					Username = v3.Username,
					DisplayName = v3.DisplayName,
					UserId = v3.Id
				})
			end

			if result.IsFinished then
				break
			else
				result:AdvanceToNextPageAsync()
			end
		end

		return v2
	end)
end

local v2 = {}
Players.PlayerAdded:Connect(function(player)
	if v2[player.UserId] then
		task.cancel(v2[player.UserId])
		v2[player.UserId] = nil
	end
end)
Players.PlayerRemoving:Connect(function(player)
	v2[player.UserId] = task.delay(60, function()
		v:RemoveScope(player.UserId)
		v2[player.UserId] = nil
	end)
end)
local RobloxFriendsUtil = {}

function RobloxFriendsUtil.areFriends(p, p2)
	local friends = getFriends(p) -- equivalent call inferred; original call site unknown
	local userId = p2.UserId
	local v2 = { friends, (v:GetValue(userId, nil, function(_)
			local v3 = {
				Friends = {}
			}
			local success, result = pcall(function()
				return Players:GetFriendsAsync(userId)
			end)

			if not success then
				return v3
			end

			while true do
				for _, v4 in ipairs(result:GetCurrentPage()) do
					table.insert(v3.Friends, {
						Username = v4.Username,
						DisplayName = v4.DisplayName,
						UserId = v4.Id
					})
				end

				if result.IsFinished then
					break
				else
					result:AdvanceToNextPageAsync()
				end
			end

			return v3
		end)) }
	return Promise.race(v2):andThen(function(p3)
		for _, friend in pairs(p3.Friends) do
			if friend.UserId == p.UserId or friend.UserId == p2.UserId then
				return true
			end
		end

		return false
	end)
end

function RobloxFriendsUtil.isFriendsWithUserId(p, p2: number)
	local userId = p.UserId
	return v:GetValue(userId, nil, function(_)
		local v2 = {
			Friends = {}
		}
		local success, result = pcall(function()
			return Players:GetFriendsAsync(userId)
		end)

		if not success then
			return v2
		end

		while true do
			for _, v3 in ipairs(result:GetCurrentPage()) do
				table.insert(v2.Friends, {
					Username = v3.Username,
					DisplayName = v3.DisplayName,
					UserId = v3.Id
				})
			end

			if result.IsFinished then
				break
			else
				result:AdvanceToNextPageAsync()
			end
		end

		return v2
	end):andThen(function(p3)
		for _, friend in pairs(p3.Friends) do
			if friend.UserId == p2 then
				return true
			end
		end

		return false
	end)
end

function RobloxFriendsUtil.getFriendsData(p)
	return getFriends(p)
end

function RobloxFriendsUtil.getFriendsUserIds(p)
	local userId = p.UserId
	return v:GetValue(userId, nil, function(_)
		local v2 = {
			Friends = {}
		}
		local success, result = pcall(function()
			return Players:GetFriendsAsync(userId)
		end)

		if not success then
			return v2
		end

		while true do
			for _, v3 in ipairs(result:GetCurrentPage()) do
				table.insert(v2.Friends, {
					Username = v3.Username,
					DisplayName = v3.DisplayName,
					UserId = v3.Id
				})
			end

			if result.IsFinished then
				break
			else
				result:AdvanceToNextPageAsync()
			end
		end

		return v2
	end):andThen(function(p2)
		local userIds = {}

		for _, friend in pairs(p2.Friends) do
			table.insert(userIds, friend.UserId)
		end

		return userIds
	end)
end

function RobloxFriendsUtil.getFriendsInServer(p)
	local userId = p.UserId
	return v:GetValue(userId, nil, function(_)
		local v2 = {
			Friends = {}
		}
		local success, result = pcall(function()
			return Players:GetFriendsAsync(userId)
		end)

		if not success then
			return v2
		end

		while true do
			for _, v3 in ipairs(result:GetCurrentPage()) do
				table.insert(v2.Friends, {
					Username = v3.Username,
					DisplayName = v3.DisplayName,
					UserId = v3.Id
				})
			end

			if result.IsFinished then
				break
			else
				result:AdvanceToNextPageAsync()
			end
		end

		return v2
	end):andThen(function(p2)
		local playerByUserIds = {}

		for _, friend in pairs(p2.Friends) do
			local playerByUserId = Players:GetPlayerByUserId(friend.UserId)

			if playerByUserId then
				table.insert(playerByUserIds, playerByUserId)
			end
		end

		return playerByUserIds
	end)
end

function RobloxFriendsUtil.sendFriendRequest(p)
	StarterGui:SetCore("PromptSendFriendRequest", p)
end

return RobloxFriendsUtil