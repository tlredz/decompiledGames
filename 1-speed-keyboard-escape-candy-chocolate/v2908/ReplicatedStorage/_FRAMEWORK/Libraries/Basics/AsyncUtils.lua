local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Utilities.Promise)
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local AsyncUtils = {
	getUsernameByUserId = function(p: number)
		if p < 0 then
			return Promise.resolve((`Player{p}`))
		end

		local v5 = v[p]

		if v5 == nil then
			return Promise.new(function(callback)
				local nameFromUserIdAsync = Players:GetNameFromUserIdAsync(p)
				v[p] = nameFromUserIdAsync
				v2[nameFromUserIdAsync] = p
				callback(nameFromUserIdAsync)
			end)
		end

		return Promise.resolve(v5)
	end
}

function AsyncUtils.getUsernameByUserIdNow(p: number)
	if v[p] == nil then
		AsyncUtils.getUsernameByUserId(p)
	end

	return v[p]
end

function AsyncUtils.getUserIdByUsername(p: string)
	local v5 = v2[p]

	if v5 == nil then
		return Promise.new(function(callback)
			local userIdFromNameAsync = Players:GetUserIdFromNameAsync(p)
			v2[p] = userIdFromNameAsync
			v[userIdFromNameAsync] = p
			callback(userIdFromNameAsync)
		end)
	end

	return Promise.resolve(v5)
end

function AsyncUtils.getUserThumbnail(p: number, p2, p3)
	return Promise.new(function(callback)
		callback((Players:GetUserThumbnailAsync(
			math.max(p, 1),
			p2 or Enum.ThumbnailType.HeadShot,
			p3 or Enum.ThumbnailSize.Size420x420
		)))
	end)
end

function AsyncUtils.fetchPaidItemTradingAllowed(p)
	local userId = p.UserId
	local v5 = v3[userId]

	if v5 ~= nil then
		return Promise.resolve(v5)
	end

	local v6 = v4[userId]

	if v6 ~= nil then
		return v6
	end

	local v7 = Promise.new(function(callback)
		local success, result = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(p)
		end)
		local v8 = not success or type(result) ~= "table" or result.IsPaidItemTradingAllowed ~= false
		v3[userId] = v8
		v4[userId] = nil
		callback(v8)
	end)
	v4[userId] = v7
	return v7
end

function AsyncUtils.clearPaidItemTradingAllowed(p: number)
	v3[p] = nil
	v4[p] = nil
end

return AsyncUtils