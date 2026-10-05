local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local SeasonBoards = require(ReplicatedStorage.CAM.Global.SeasonBoards)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RankedBoard

if isServer then
	RankedBoard = require(ServerStorage.SAM.Utility.RankedBoard)
else
	RankedBoard = nil
end

local ouwigahara = MinigameSettings.Settings.Ouwigahara
local TowerBoard = {
	Season = function(p: number?)
		return SeasonBoards.Kinds.Ouwigahara.Season(p)
	end,
	SeasonEnds = function(p: number?)
		return Ranked.SeasonEnds(p)
	end,
	Modes = function()
		local result = {}

		for k in ouwigahara.Modes do
			table.insert(result, k)
		end

		table.sort(result)
		return result
	end
}

local function named(p)
	for k in ouwigahara.Modes do
		if string.lower(k) == string.lower((tostring(p))) then
			return k
		end
	end

	return nil
end

function TowerBoard.Wipe(instance, p, p2: string?)
	local Discord = require(ServerStorage.SAM.Services.Reporting.Discord)
	local RankedRecord = require(ServerStorage.SAM.Utility.RankedRecord)
	local modes = TowerBoard.Modes()

	if p2 ~= nil and p2 ~= "" then
		local v = named(p2)

		if v == nil then
			return false, (`"{p2}" is not a mode ({table.concat(modes, ", ")})`)
		else
			modes = { v }
		end
	end

	local season = TowerBoard.Season()
	local playerByUserId = Players:GetPlayerByUserId(p.id)
	local v = {}
	local v2 = true

	for _, childName in modes do
		local v3, v4 = RankedBoard.Remove(p.id, childName, season)

		if v3 then
			local v5 = tonumber(v4)

			if playerByUserId ~= nil and playerByUserId.Parent ~= nil then
				local _, v6 = Utility.GetData(playerByUserId)
				local root = RankedRecord.Root(v6)
				local child

				if root ~= nil then
					child = root.Tower:FindFirstChild(childName)
				end

				if child ~= nil then
					child:Destroy()
				end
			end

			table.insert(v, (`{childName} {v5 or "no score"}`))
		else
			table.insert(v, (`{childName} failed ({v4})`))
			v2 = false
		end
	end

	local v3

	if playerByUserId == nil then
		v3 = false
	else
		v3 = playerByUserId.Parent ~= nil
	end

	local joined = table.concat(v, ", ")
	local standing = v3 and "cleared" or "not in this server, clears on their next run"
	local v5 = typeof(instance) == "Instance"
	local send = Discord.Send
	local player

	if v5 then
		player = instance
	end

	local v8 = {
		player = player,
		target = not v3 and {
			id = p.id,
			name = p.name
		} or playerByUserId,
		data = 0
	}
	local actor

	if v5 then
		actor = instance.Name
	else
		actor = instance.name
	end

	local actorDiscordId

	if not v5 then
		actorDiscordId = instance.discordId
	end

	v8.data = {
		actor = actor,
		actorDiscordId = actorDiscordId,
		season = season,
		modes = table.concat(modes, ", "),
		scores = joined,
		standing = standing
	}
	send("moderation", "ScoreReset", v8)
	return v2, (`{p.name} ({p.id}) season {season}: {joined}; standing {standing}`)
end

function TowerBoard.Seal(p: number)
	local RunService2 = game:GetService("RunService")

	if RunService2:IsStudio() then
		return
	end

	local season = TowerBoard.Season()

	for _, v in TowerBoard.Modes() do
		task.spawn(RankedBoard.Remove, p, v, season)
	end
end

function TowerBoard.Unseal(p)
	local RunService2 = game:GetService("RunService")

	if RunService2:IsStudio() then
		return
	end

	local RankedRecord = require(ServerStorage.SAM.Utility.RankedRecord)
	local _, v = Utility.GetData(p)
	local root = RankedRecord.Root(v)
	local tower

	if root ~= nil then
		tower = root:FindFirstChild("Tower")
	end

	if tower == nil then
		return
	end

	local season = TowerBoard.Season()

	for _, child in tower:GetChildren() do
		local season2 = child:FindFirstChild("Season")
		local best = child:FindFirstChild("Best")
		local v2 = best == nil and 0 or best.Value

		if season2 == nil or season2.Value ~= season or v2 <= 0 then
			continue
		end

		task.spawn(RankedBoard.Best, p.UserId, child.Name, v2)
	end
end

return TowerBoard