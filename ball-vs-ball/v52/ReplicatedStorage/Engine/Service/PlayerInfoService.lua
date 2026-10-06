local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerData = require(script.Parent.PlayerData)
local PublicInventoryEquipment = require(ReplicatedStorage.Engine.Service.PublicInventoryEquipment)
local remoteFunction = Net:RemoteFunction("PlayerPanelGetInfo")

local function getPublicProfile(player)
	PlayerData.server.Service:waitForData(player)

	if player.Parent ~= Players then
		return nil
	end

	local v = {}
	local flyers = {}
	local explosions = {}
	local balls = {}

	for _, v5 in PlayerData.server[player].boothListings() do
		if not (typeof(v5) == "table" and typeof(v5.itemInstanceId) == "string") then
			continue
		end

		v[v5.itemInstanceId] = true
	end

	local items = PlayerData.server[player].items()
	local resolved = PublicInventoryEquipment.resolve(items, PlayerData.server[player].equipment(), v)

	for k, item in items do
		if not (typeof(item) == "table" and typeof(item.itemId) == "string") then
			continue
		end

		if item.itemType == "Ball" then
			local v5 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v5.killCount = killCount
			v5.listed = v[item.instanceId or k] == true
			v5.equipped = resolved[item.instanceId or k] == true
			table.insert(balls, v5)
		elseif item.itemType == "爆炸特效" then
			local v5 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v5.killCount = killCount
			v5.listed = v[item.instanceId or k] == true
			v5.equipped = resolved[item.instanceId or k] == true
			table.insert(explosions, v5)
		elseif item.itemType == "飞行器" then
			local v5 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v5.killCount = killCount
			v5.listed = v[item.instanceId or k] == true
			v5.equipped = resolved[item.instanceId or k] == true
			table.insert(flyers, v5)
		end
	end

	return {
		userId = player.UserId,
		displayName = player.DisplayName,
		wins = PlayerData.server[player].matchStats.Duel.wins() + PlayerData.server[player].matchStats.RPS.wins() + PlayerData.server[player].matchStats.TwoVTwo.wins(),
		totalMatches = PlayerData.server[player].matchStats.Duel.matches() + PlayerData.server[player].matchStats.RPS.matches() + PlayerData.server[player].matchStats.TwoVTwo.matches(),
		totalExp = PlayerData.server[player].exp.total(),
		maxWinStreak = PlayerData.server[player].maxWinStreak(),
		balls = balls,
		explosions = explosions,
		flyers = flyers,
		equippedTitle = PlayerData.server[player].equippedTitle()
	}
end

local RunService = game:GetService("RunService")

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(_, value)
		if typeof(value) ~= "number" or value % 1 ~= 0 then
			return {
				ok = false,
				reason = "invalid_target"
			}
		end

		local playerByUserId = Players:GetPlayerByUserId(value)

		if not playerByUserId then
			return {
				ok = false,
				reason = "offline"
			}
		end

		local success, result = pcall(getPublicProfile, playerByUserId)

		if not success then
			warn((`[PlayerInfoService] 查询玩家公开资料失败（{value}）：{result}`))
			return {
				ok = false,
				reason = "error"
			}
		end

		if result then
			return {
				ok = true,
				profile = result
			}
		end

		return {
			ok = false,
			reason = "offline"
		}
	end
end

return {}