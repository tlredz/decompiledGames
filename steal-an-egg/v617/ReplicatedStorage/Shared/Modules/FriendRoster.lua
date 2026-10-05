local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local Signal = require(ReplicatedStorage.Packages.Signal)
local v2 = {
	RosterUpdated = Signal.new(),
	FriendsInServerAttribute = "FriendsInServer"
}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function pairKey(p: number, p2: number)
	if p < p2 then
		return (`{p}:{p2}`)
	end

	return (`{p2}:{p}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function verdictFor(userId: number, userId2: number)
	local v5 = pairKey(userId, userId2) -- equivalent call inferred; original call site unknown
	return v3[v5]
end

local function dropVerdicts(userId: number)
	local v4 = tostring(userId)

	for k in v3 do
		local v5, v6 = string.match(k, "^(%d+):(%d+)$")

		if v5 == v4 or v6 == v4 then
			v3[k] = nil
		end
	end
end

local function resolvePair(instance, instance2)
	local v4 = pairKey(instance.UserId, instance2.UserId) -- equivalent call inferred; original call site unknown

	if v3[v4] ~= nil then
		return nil
	end

	v3[v4] = "asking"
	local success, result = pcall(instance.IsFriendsWith, instance, instance2.UserId)

	if instance.Parent == nil or instance2.Parent == nil then
		v3[v4] = nil
		return nil
	end

	if success then
		v3[v4] = result == true
		return result == true
	end

	v3[v4] = nil
	v:AtWarning():Log((`friendship check between {instance.Name} and {instance2.Name} failed: {result}`))
	return nil
end

local sweep

sweep = function(p)
	if p.Parent == nil then
		return
	end

	local v4 = { p }
	local v5 = false

	for _, v6 in Players:GetPlayers() do
		if v6 == p then
			continue
		end

		if resolvePair(p, v6) then
			table.insert(v4, v6)
		end

		if not v5 then
			v5 = verdictFor(p.UserId, v6.UserId) == nil
		end
	end

	if p.Parent == nil then
		return
	end

	for _, v6 in v4 do
		if v6.Parent ~= nil then
			v2.RosterUpdated:Fire(v6)
		end
	end

	if v5 then
		task.delay(45, sweep, p)
	end
end

if RunService:IsServer() then
	Players.PlayerAdded:Connect(sweep)
	Players.PlayerRemoving:Connect(function(player)
		dropVerdicts(player.UserId)
	end)

	for _, v4 in Players:GetPlayers() do
		task.spawn(sweep, v4)
	end
end

local function friendsHere(p)
	local result = {}

	for _, v4 in Players:GetPlayers() do
		if v4 ~= p and verdictFor(p.UserId, v4.UserId) == true then
			table.insert(result, v4)
		end
	end

	return result
end

function v2.CountPresent(p)
	return #friendsHere(p)
end

function v2.IdList(p)
	local userIds = {}

	for _, v4 in friendsHere(p) do
		table.insert(userIds, v4.UserId)
	end

	return userIds
end

return table.freeze(v2)