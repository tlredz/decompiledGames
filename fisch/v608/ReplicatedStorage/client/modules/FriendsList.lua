local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local FriendsList = {}

function FriendsList.GetFriendsAsync()
	if FriendsList.CachedFriends then
		return FriendsList.CachedFriends
	end

	local result = {}
	local success, result2 = pcall(function()
		local friendsWhoPlayedAsync = Players.LocalPlayer:GetFriendsWhoPlayedAsync()
		local userIds = {}

		for k, userId in friendsWhoPlayedAsync do
			if k > 50 then
				continue
			end

			if type(userId) == "table" then
				userId = userId.UserId
			end

			if userId then
				table.insert(userIds, userId)
			end
		end

		if #userIds == 0 then
			return
		end

		local userInfosByUserIdsAsync = UserService:GetUserInfosByUserIdsAsync(userIds)

		for _, v in userInfosByUserIdsAsync do
			table.insert(result, {
				UserId = v.Id,
				DisplayName = v.DisplayName or v.Username,
				Username = v.Username,
				IsVerified = v.HasVerifiedBadge
			})
		end
	end)

	if success then
		FriendsList.CachedFriends = result
		return result
	end

	anno_localthought:Fire("Failed to load your friends list.")
	warn((`Failed to load friends: {result2}`))
	return result
end

return FriendsList