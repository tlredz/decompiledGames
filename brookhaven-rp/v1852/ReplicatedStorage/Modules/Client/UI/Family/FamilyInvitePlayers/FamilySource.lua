local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local FamilySource = {}
FamilySource.__index = FamilySource

local function iterPageItems(object)
	return coroutine.wrap(function()
		local v = 1

		while true do
			for _, v2 in ipairs(object:GetCurrentPage()) do
				coroutine.yield(v2, v)
			end

			if object.IsFinished then
				break
			end

			object:AdvanceToNextPageAsync()
			v += 1
		end
	end)
end

function FamilySource.new()
	local self = setmetatable({}, FamilySource)
	self._Janitor = Janitor.new()
	self._savedTime = 0
	self._savedSource = nil
	return self
end

function FamilySource:GetPlayers()
	local now = os.time()

	if self._savedTime < now - 120 then
		self._savedTime = now
		self._savedSource = nil
	end

	if self._savedSource then
		return self._savedSource
	end

	local success, result = pcall(function()
		return Players.LocalPlayer:GetFriendsOnline()
	end)
	local v = {}

	if success then
		for _, v2 in result do
			v[v2.VisitorId] = v2
		end
	else
		warn("Failed to get online friends", result)
	end

	local success2, result2 = pcall(function()
		return Players:GetFriendsAsync(Players.LocalPlayer.UserId)
	end)

	if success2 then
		local result3 = {}

		for k, _ in coroutine.wrap(function()
			local v2 = 1

			while true do
				for _, v3 in ipairs(result2:GetCurrentPage()) do
					coroutine.yield(v3, v2)
				end

				if result2.IsFinished then
					break
				end

				result2:AdvanceToNextPageAsync()
				v2 += 1
			end
		end) do
			table.insert(result3, {
				Name = k.Username,
				UserId = k.Id,
				DisplayName = k.DisplayName,
				IsOnline = v[k.Id],
				InServer = Players:GetPlayerByUserId(k.Id) ~= nil
			})
		end

		table.sort(result3, function(a, b)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getPriority(p)
				if p.InServer then
					return 0
				end

				if p.IsOnline then
					return 1
				end

				return 2
			end

			local priority = getPriority(a) -- equivalent call inferred; original call site unknown
			local priority2 = getPriority(b) -- equivalent call inferred; original call site unknown

			if priority == priority2 then
				return a.Name:lower() < b.Name:lower()
			end

			return priority < priority2
		end)
		self._savedSource = result3
		self._savedTime = now
		return result3
	else
		NotificationController.NotifyCenter("There was an error getting your friends list. Please try again later.")
		warn("Failed to get friends", result2)
		return {}
	end
end

return FamilySource