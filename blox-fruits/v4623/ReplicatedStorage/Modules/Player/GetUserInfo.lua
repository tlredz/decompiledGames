local GetUserInfo = {}
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}

local function log(...) end

function GetUserInfo:FromUsernameAsync(p: string)
	local lower = tostring(p):lower()
	local CachedUserInfo = require(script.CachedUserInfo)
	local v5 = CachedUserInfo[lower]

	if v5 then
		return {
			DisplayName = v5.DisplayName,
			Name = v5.Name,
			UserId = v5.UserId,
			_TimeExpires = -1
		}
	end

	if lower:len() < 3 or lower:len() > 20 or tonumber(lower) or TextUtil.stripSpecialCharacters(lower):len() == 0 then
		return nil
	end

	local userId = v4[lower] and v4[lower].UserId
	local playerByUserId = userId and game.Players:GetPlayerByUserId(userId)

	for _, v7 in pairs(game.Players:GetPlayers()) do
		if v7.Name:lower() ~= lower then
			continue
		end

		userId = v7.UserId
		playerByUserId = v7
		break
	end

	if not userId then
		log((`Not cached: {lower}`))
		local success, result = pcall(function()
			userId = game.Players:GetUserIdFromNameAsync(lower)
		end)

		if not success and result and result:lower():match("unknown") then
			userId = 0
		end
	end

	if not userId then
		return {
			UserId = 1,
			Name = "Roblox",
			DisplayName = "Roblox",
			_TimeExpires = -1
		}
	end

	local v7 = {
		UserId = userId,
		Name = lower,
		_TimeExpires = workspace:GetServerTimeNow() + 300
	}

	if playerByUserId then
		v7.UserId = playerByUserId.UserId
		v7.Name = playerByUserId.Name
		v7.DisplayName = playerByUserId.DisplayName
	else
		v7.DisplayName = (v3[tostring(userId)] or {
			DisplayName = nil
		}).DisplayName
	end

	if userId ~= 0 then
		v3[tostring(userId)] = v7
	end

	log(`fromUsername: {lower}`, v7)
	v4[lower] = v7
	return v7
end

function GetUserInfo:FromUserIdAsync(p)
	local userId = tonumber(p)

	if not userId or tostring(p):len() == 0 then
		return nil
	end

	if userId <= 1 then
		return {
			Name = "Roblox",
			DisplayName = "Roblox",
			UserId = 1,
			_TimeExpires = 1
		}
	end

	local v6 = tostring(userId)
	local CachedUserInfo = require(script.CachedUserInfo)
	local v7 = CachedUserInfo[v6]

	if v7 then
		return {
			DisplayName = v7.DisplayName,
			Name = v7.Name,
			UserId = v7.UserId,
			_TimeExpires = 1
		}
	end

	local name = v3[v6] and v3[v6].Name
	local v8 = nil

	for _, v10 in pairs(game.Players:GetPlayers()) do
		if v10.UserId ~= userId then
			continue
		end

		name = v10.Name
		v8 = v10
		break
	end

	if not name then
		log((`Not cached: {p}`))
		local success, result = pcall(function()
			name = game.Players:GetNameFromUserIdAsync(userId)
		end)

		if not success and result and result:lower():match("unknown") then
			name = "unknown"
		end
	end

	if not name then
		return {
			UserId = 1,
			Name = "Roblox",
			DisplayName = "Roblox",
			_TimeExpires = -1
		}
	end

	local v10 = {
		UserId = userId,
		Name = name,
		_TimeExpires = workspace:GetServerTimeNow() + 300
	}

	if v8 then
		v10.UserId = v8.UserId
		v10.Name = v8.Name
		v10.DisplayName = v8.DisplayName
	else
		v10.DisplayName = (v4[name] or {
			DisplayName = nil
		}).DisplayName
	end

	log(`fromUserId: {p}`, v10)

	if name ~= "unknown" then
		v4[name] = v10
	end

	return v3[v6]
end

function GetUserInfo.GetUserInfo(_, value)
	if typeof(value) == "string" and not tonumber(value) then
		if not v[value] then
			v[value] = Promise.new(function(callback, _)
				callback(GetUserInfo:FromUsernameAsync(value))
			end):catch(warn):finally(function(_)
				v[value] = nil
			end)
		end

		return v[value]
	else
		if typeof(value) ~= "number" and not tonumber(value) then
			error("Unknown")
			return
		end

		if not v2[value] then
			v2[value] = Promise.new(function(callback, _)
				callback(GetUserInfo:FromUserIdAsync(value))
			end):catch(warn):finally(function(_)
				v2[value] = nil
			end)
		end

		return v2[value]
	end
end

task.spawn(function()
	while true do
		local serverTimeNow = workspace:GetServerTimeNow()

		for _, v6 in pairs({ v3, v4 }) do
			for k, v7 in pairs(v6) do
				if v7._TimeExpires - serverTimeNow <= 0 then
					v6[k] = nil
				end
			end
		end

		task.wait(60)
	end
end)
return GetUserInfo