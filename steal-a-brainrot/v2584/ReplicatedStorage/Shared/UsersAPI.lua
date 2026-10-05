local UserService = game:GetService("UserService")
local Players = game:GetService("Players")
local UsersAPI = {
	RequestQuota = 250,
	UserCache = {},
	RequestBatch = {},
	ResumeThreads = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function addToBatch(p: number)
	if UsersAPI.UserCache[p] then
		return
	end

	if not table.find(UsersAPI.RequestBatch, p) then
		table.insert(UsersAPI.RequestBatch, p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function consumeQuota(p: number)
	UsersAPI.RequestQuota -= p
	task.delay(60, function()
		UsersAPI.RequestQuota += p
	end)
end

local function tryUpdate()
	local count = #UsersAPI.RequestBatch

	if count == 0 then
		return true, false
	end

	local v = math.min(count, UsersAPI.RequestQuota, 250)

	if v == 0 then
		return true, false
	end

	local v2 = table.move(UsersAPI.RequestBatch, 1, v, 1, {})
	consumeQuota(#v2) -- equivalent call inferred; original call site unknown
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(v2)
	end)

	if not success or type(result) ~= "table" then
		return false, false
	end

	for _, id in v2 do
		local v5 = nil

		for _, v7 in result do
			if v7.Id ~= id then
				continue
			end

			v5 = v7
			break
		end

		if v5 then
			v5.IsLoaded = true
			UsersAPI.UserCache[id] = v5
		else
			v5 = {
				IsLoaded = false,
				DisplayName = "Failed to load",
				HasVerifiedBadge = false,
				Id = id,
				Username = "Failed to load"
			}
		end

		local index = table.find(UsersAPI.RequestBatch, id)

		if index then
			table.remove(UsersAPI.RequestBatch, index)
		end

		local resumeThread = UsersAPI.ResumeThreads[id]

		if not resumeThread then
			continue
		end

		for _, callback in resumeThread do
			if coroutine.status(callback) == "suspended" then
				task.spawn(callback, v5)
			end
		end

		UsersAPI.ResumeThreads[id] = nil
	end

	return true, true
end

local function start()
	while true do
		if #UsersAPI.RequestBatch <= 0 then
			task.wait(1)
		else
			task.wait(5)
		end

		tryUpdate()
	end
end

function UsersAPI.AddToBatch(_, value)
	if type(value) == "number" then
		addToBatch(value) -- equivalent call inferred; original call site unknown
	else
		for _, v in value do
			addToBatch(v) -- equivalent call inferred; original call site unknown
		end
	end
end

function UsersAPI.GetUser(_, id: number)
	assert(type(id) == "number", "UsersAPI:GetUser | userId must be a number")

	if id <= 0 then
		local formatted = `Player{id}`
		return {
			IsLoaded = true,
			DisplayName = formatted,
			HasVerifiedBadge = false,
			Id = id,
			Username = formatted
		}
	end

	local v = UsersAPI.UserCache[id]

	if v and v.IsLoaded then
		return v
	end

	local playerByUserId = Players:GetPlayerByUserId(id)

	if playerByUserId then
		UsersAPI.UserCache[id] = {
			IsLoaded = true,
			DisplayName = playerByUserId.DisplayName,
			HasVerifiedBadge = playerByUserId.HasVerifiedBadge,
			Id = id,
			Username = playerByUserId.Name
		}
		return UsersAPI.UserCache[id]
	end

	local thread = coroutine.running()

	if not (UsersAPI.UserCache[id] or table.find(UsersAPI.RequestBatch, id)) then
		table.insert(UsersAPI.RequestBatch, id)
	end

	if UsersAPI.ResumeThreads[id] then
		table.insert(UsersAPI.ResumeThreads[id], thread)
	else
		UsersAPI.ResumeThreads[id] = { thread }
	end

	return coroutine.yield()
end

task.spawn(start)
return UsersAPI