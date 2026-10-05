local FriendFinder = {}
local Promise = require(game.ReplicatedStorage:WaitForChild("Modules").Util.Promise)
local userId = game.Players.LocalPlayer.UserId
local now = 1
local v = nil

local function pagesToTable(object)
	local currentPages = {}
	local v2 = 1
	local v3 = false
	local count = 0

	while true do
		local success, result = pcall(function()
			currentPages[v2] = object:GetCurrentPage()

			if object.IsFinished then
				v3 = true
				return true
			end

			object:AdvanceToNextPageAsync()
			return true
		end)

		if success then
			if not v3 then
				v2 += 1
			end
		else
			count += 1
			print((`FriendFinderError: {result}:{count}/{5}`))
		end

		if v3 or count == 5 then
			return currentPages
		end
	end
end

local function iterPageItems(p)
	local v2 = pagesToTable(p)
	local v3 = 1
	local count = #v2
	return coroutine.wrap(function()
		while v3 <= count do
			for _, v4 in ipairs(v2[v3]) do
				coroutine.yield(v4, v3)
			end

			v3 += 1
		end
	end)
end

function FriendFinder:GetFriendsAsync(value: number?)
	local count = 0

	if not ((value or 1e999) < tick() - now) and v then
		return v
	end

	now = tick()
	local v2 = {}
	local friendsAsync = nil
	local success, result = pcall(function()
		if userId <= 0 then
			friendsAsync = game.Players:GetFriendsAsync(31265920)
		else
			friendsAsync = game.Players:GetFriendsAsync(userId)
		end
	end)

	if success then
		if friendsAsync then
			local v3 = pagesToTable(friendsAsync)
			local v4 = 1
			local count2 = #v3

			for k in coroutine.wrap(function()
				while v4 <= count2 do
					for _, v5 in ipairs(v3[v4]) do
						coroutine.yield(v5, v4)
					end

					v4 += 1
				end
			end) do
				if k.Id == userId then
					continue
				end

				v2[k.Id] = {
					Name = k.Username,
					DisplayName = k.DisplayName,
					UserId = k.Id
				}
				count += 1

				if count >= 200 then
					break
				end
			end

			v = v2
		end
	else
		print(result)
	end

	return v
end

function FriendFinder.GetFriends(_, p: number?)
	return Promise.new(function(callback, _, callback2)
		local v2 = false
		callback2(function()
			v2 = true
		end)
		local friendsAsync = nil

		while not v2 do
			friendsAsync = FriendFinder:GetFriendsAsync(p)

			if friendsAsync then
				break
			else
				task.wait(1)
			end
		end

		if not v2 then
			callback(friendsAsync or {})
		end
	end)
end

task.spawn(function()
	local friendFinder = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FriendFinder")

	friendFinder.OnClientInvoke = function()
		local friendsAsync = FriendFinder:GetFriendsAsync(5) or {}
		local result = {}

		for _, v2 in pairs(game.Players:GetPlayers()) do
			if friendsAsync[v2.UserId] then
				table.insert(result, v2)
			end
		end

		return result
	end

	game.Players.LocalPlayer:GetAttributeChangedSignal("FriendBoost"):Connect(function() end)
end)
return FriendFinder