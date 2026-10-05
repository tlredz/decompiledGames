local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(...)
	local self = setmetatable(ReplicatedClass.new(...), object)
	self:_Init()
	return self
end

function object.GetActualQueueName(object2)
	return DuelLibrary:GetFirstQueueNameByDuelLogic(object2:Get("QueueName")) or object2:Get("QueueName")
end

function object:GetDuelLogics(p, p2)
	local displayNames = {}

	for _, v in pairs(DuelLibrary.PlaySourceOrder) do
		local playSource = DuelLibrary.PlaySources[v]

		if playSource.Type ~= "MatchmakingQueue" then
			continue
		end

		local matchmakingQueue = DuelLibrary.MatchmakingQueues[v]
		local displayName

		if p2 then
			displayName = matchmakingQueue.DisplayName
		else
			displayName = playSource.DuelLogic or matchmakingQueue.TitleName or matchmakingQueue.DisplayName
		end

		if table.find(displayNames, displayName) or ServerOsTime:Get() < matchmakingQueue.TerminalsReleaseTime then
			continue
		end

		local v2

		if matchmakingQueue.NumTeams == self:Get("NumTeams") then
			v2 = true
		elseif matchmakingQueue.NumTeams == 1 then
			v2 = self:Get("NumTeams") == 2
		else
			v2 = false
		end

		if not v2 then
			continue
		end

		local hasVerifiedBadge

		if p then
			hasVerifiedBadge = p.HasVerifiedBadge

			if not hasVerifiedBadge then
				if #p.DisplayName >= 2 then
					hasVerifiedBadge = string.sub(p.DisplayName, 1, 2) == "00"
				else
					hasVerifiedBadge = false
				end
			end
		else
			hasVerifiedBadge = p
		end

		if playSource.DuelLogic ~= "Easy Exploits" or not p or hasVerifiedBadge or CONSTANTS.IS_STUDIO then
			table.insert(displayNames, displayName)
		end
	end

	return displayNames
end

function object:GetMapPools(p)
	return self:GetDuelLogics(p, true)
end

function object.GetSortedMapNames(object2)
	local maps = DuelLibrary:GetMaps(
		object2:Get("PlayersPerTeam") * object2:Get("NumTeams"),
		object2:Get("NumTeams"),
		object2:Get("QueueName"),
		true
	)
	table.sort(maps, function(a, b)
		return Utility:StringLessThan(a, b)
	end)
	return maps
end

function object.GetMatchmakingQueueInfoFromQueueName(_, p)
	return DuelLibrary.MatchmakingQueueDuelLogicToQueueName[p] or DuelLibrary.MatchmakingQueues[p]
end

function object.GetMaxPlayersPerTeam(_)
	return 16
end

function object.CountTeam(object2, p)
	local count = 0

	for _ in pairs(object2:Get("PlayersWaiting")[p]) do
		count += 1
	end

	return count
end

function object:IsReady(p)
	local isInQueue = self:IsInQueue(p)
	return isInQueue and self:Get("PlayersWaiting")[isInQueue][tostring(p.UserId)]
end

function object:IsInQueue(p)
	for k, v in pairs(self:Get("PlayersWaiting")) do
		if v[tostring(p.UserId)] ~= nil then
			return k
		end
	end
end

function object:IsWithin(player, p)
	if p then
		local child = self:Get("Model"):WaitForChild("Important"):WaitForChild("Team" .. p)
		local position = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
		return child and position and Utility:IsWithinRotatedShape(position, child.CFrame, child.Size, child.Shape)
	else
		for i = 1, self:Get("NumTeams") do
			if self:IsWithin(player, i) then
				return i
			end
		end

		return false
	end
end

function object:_Init() end

return object