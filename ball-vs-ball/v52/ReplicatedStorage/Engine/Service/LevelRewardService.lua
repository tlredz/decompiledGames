local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)
local PlayerData = require(script.Parent.PlayerData)
local ExperienceService = require(script.Parent.ExperienceService)
local LevelRewardRules = require(script.Parent.LevelRewardRules)
local remoteEvent = Net:RemoteEvent("LevelRewardResult")
local remoteEvent2 = Net:RemoteEvent("LevelRewardReady")
local v = {
	server = {},
	client = {}
}

if RunService:IsServer() then
	local ItemService = require(script.Parent.ItemService)
	local RewardItemService = require(script.Parent.RewardItemService)
	local entries = LevelRewardRules.buildEntries(Config.lvl.list, Config.ball.byCnId, Config.reward.byCnId)
	local random = Random.new()
	local v2 = {}
	local v3 = {}
	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flush(player)
		local v5 = v4[player]

		if v3[player] and v5 and #v5 > 0 and player.Parent == Players then
			remoteEvent:FireClient(player, v5)
			v4[player] = nil
		end
	end

	local function check(player)
		local v5 = v2[player]

		if not v5 or player.Parent ~= Players then
			return
		end

		if v5.busy then
			v5.again = true
			return
		end

		v5.busy = true
		local success, result = pcall(function()
			repeat
				v5.again = false
				local v6 = PlayerData.server[player]
				local state = LevelRewardRules.normalizeState(v6.levelRewards())
				local ownedUntradable = LevelRewardRules.ownedUntradable(v6.items())
				local level = ExperienceService.getLevelInfo(v6.exp.total()).level

				for _, v7 in LevelRewardRules.pending(entries, state, ownedUntradable, level) do
					if player.Parent ~= Players then
						break
					end

					if v7.rewardId then
						local v8 = RewardItemService.grant(player, v7.rewardId)

						if v8.ok then
							state.grantedRewards[tostring(v7.level)] = v7.rewardId
							v6.levelRewards(LevelRewardRules.normalizeState(state))
							local v9 = v4[player] or {}
							table.insert(v9, {
								rewardId = v7.rewardId,
								level = v7.level,
								results = v8.results
							})
							v4[player] = v9
						else
							warn("[LevelRewardService] 发奖失败：" .. v7.rewardId .. "，" .. tostring(v8.reason))
						end
					elseif Config.ball.byCnId[v7.cnId] then
						local instanceId = ItemService.server.grant(player, "Ball", v7.cnId, {
							tradable = false,
							canFusion = false,
							source = "等级奖励:" .. tostring(v7.level)
						})

						if not v7.fixed then
							state.grantedRandom[tostring(v7.level)] = v7.cnId
							v6.levelRewards(LevelRewardRules.normalizeState(state))
						end

						local v9 = v4[player] or {}
						table.insert(v9, {
							cnId = v7.cnId,
							level = v7.level,
							instanceId = instanceId
						})
						v4[player] = v9
					else
						warn("[LevelRewardService] 已保存奖励球不存在：" .. v7.cnId)
					end
				end
			until not v5.again
		end)
		v5.busy = false
		flush(player) -- equivalent call inferred; original call site unknown

		if not success then
			warn("[LevelRewardService] 自动发奖失败：" .. tostring(result))
		end
	end

	function v.server.initPlayer(p)
		if v2[p] or p.Parent ~= Players then
			return
		end

		local v5 = PlayerData.server[p]
		local fill = LevelRewardRules.fill(
			entries,
			v5.levelRewards(),
			LevelRewardRules.ownedUntradable(v5.items()),
			random
		)
		v5.levelRewards(fill)
		local v6 = {
			busy = false,
			again = false
		}
		v2[p] = v6
		v6.disconnect = v5.exp.total.Changed(function()
			check(p)
		end)
		check(p)
	end

	remoteEvent2.OnServerEvent:Connect(function(player)
		if v3[player] then
			return
		end

		v3[player] = true
		flush(player) -- equivalent call inferred; original call site unknown
	end)
	Players.PlayerRemoving:Connect(function(player)
		local v5 = v2[player]

		if v5 and v5.disconnect then
			v5.disconnect()
		end

		v2[player] = nil
		v3[player] = nil
		v4[player] = nil
	end)
	return v
else
	local flag = false

	local function init()
		if flag then
			return
		end

		flag = true
		local ClaimQueue = require(ReplicatedStorage.Engine.Gui.ClaimQueue)
		remoteEvent.OnClientEvent:Connect(function(items)
			for _, item in items do
				if item.rewardId then
					local v2 = Config.reward.byCnId[item.rewardId][1]

					if v2.itemType ~= "头衔" then
						if v2.itemType == "箱子" then
							local v3 = item.results and item.results[1]

							if v3 then
								local RewardRollQueue = require(ReplicatedStorage.Engine.Gui.RewardRollQueue)
								RewardRollQueue.enqueue(v3, v2.itemId, "levelReward")
							end
						else
							local describe = LevelRewardRules.describe({
								level = item.level,
								pool = {},
								rewardId = item.rewardId
							}, LevelRewardRules.normalizeState(nil), Config)

							if describe then
								local colorHex = "FFFFFF"

								for _, v4 in Config.rating.list do
									if v4.lvl ~= describe.rating then
										continue
									end

									colorHex = v4.colorHex
									break
								end

								ClaimQueue.enqueue({
									image = describe.image,
									name = describe.name,
									colorHex = colorHex
								})
							end
						end
					end
				else
					local v2 = Config.ball.byCnId[item.cnId]

					if v2 then
						local colorHex = "FFFFFF"

						for _, v4 in Config.rating.list do
							if v4.lvl ~= v2.rating then
								continue
							end

							colorHex = v4.colorHex
							break
						end

						ClaimQueue.enqueue({
							image = v2.image,
							name = v2.displayName,
							colorHex = colorHex
						})
					end
				end
			end
		end)
		remoteEvent2:FireServer()
	end

	v.client.init = init
	return v
end