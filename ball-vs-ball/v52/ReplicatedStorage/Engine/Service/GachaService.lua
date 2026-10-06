local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local Config = require(script.Parent.Config)
local CurrencyService = require(script.Parent.CurrencyService)
local PlayerData = require(script.Parent.PlayerData)
local ItemService = require(script.Parent.ItemService)
local OnboardingFunnelService = require(script.Parent.OnboardingFunnelService)
local GachaPool = require(script.Parent.GachaPool)
local remoteFunction = Net:RemoteFunction("GachaRoll")
local remoteEvent = Net:RemoteEvent("NewbieFreeChestReady")
local remoteEvent2 = Net:RemoteEvent("NewbieFreeChestResult")
local remoteEvent3 = Net:RemoteEvent("FirstRaceFreeChestResult")
local remoteEvent4 = Net:RemoteEvent("NewbieBallDialogHandled")
local remoteEvent5 = Net:RemoteEvent("FirstRaceBallDialogHandled")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {
	coins = "coinsPrice",
	diamonds = "diamondsPrice"
}
local random = Random.new()

local function ownedKeys(p)
	local result = {}

	for _, v10 in PlayerData.server[p].items() do
		if not (typeof(v10.itemType) == "string" and typeof(v10.itemId) == "string") then
			continue
		end

		result[GachaPool.ownedKey(v10.itemType, v10.itemId)] = true
	end

	return result
end

local function pickForCrate(p, p2, p3)
	local pick = GachaPool.pick
	local exclude

	if p2.dedup then
		exclude = ownedKeys(p)
	end

	return pick(p3, random, {
		exclude = exclude,
		context = GachaPool.getPlayerContext(p)
	})
end

local function getCratePool(p: string, flag: boolean)
	local v10 = Config.crate.byCnId[p]

	if not v10 or flag and not v10.isForSale then
		return nil, nil, "invalid_crate"
	end

	local pool = GachaPool.getPool(v10.gachaCnId)

	if pool then
		return v10, pool, nil
	end

	return nil, nil, "invalid_pool"
end

local function grantPickedItem(p, data, source: string, p3: string?)
	local engineItemType = GachaPool.toEngineItemType(data.itemType)
	local instanceId, serial = ItemService.server.grant(p, engineItemType, data.targetId, {
		tradable = data.allowTrade ~= false,
		canFusion = data.canFusion == true,
		useCounter = data.useCounter == true,
		source = source,
		sourceCrateCnId = p3
	})
	local v12 = PlayerData.server[p].items()[instanceId]
	local killCount

	if v12 and typeof(v12.metadata) == "table" then
		killCount = v12.metadata.killCount
	end

	return {
		ok = true,
		cnId = data.targetId,
		instanceId = instanceId,
		itemType = engineItemType,
		serial = serial,
		killCount = killCount,
		crateCnId = p3
	}
end

local function buildBallDedupeState(items)
	local excluded = {}

	for _, v11 in Config.lvl.list do
		for _, v12 in v11.rewardBalls or {} do
			if typeof(v12) == "string" and v12 ~= "x" then
				excluded[v12] = true
			end
		end

		for _, v12 in Config.reward.byCnId[v11.rewardId] or {} do
			if v12.itemType == "小球" or v12.itemType == "Ball" then
				excluded[v12.itemId] = true
			end
		end
	end

	local balls = {}
	local count = 0

	for _, item in items do
		if item.itemType ~= "Ball" or typeof(item.itemId) ~= "string" or (excluded[item.itemId] or balls[item.itemId]) then
			continue
		end

		balls[item.itemId] = true
		count += 1
	end

	return {
		excluded = excluded,
		balls = balls,
		count = count
	}
end

local function hasBallDedupeProtection(p, p2)
	local ballGachaDedupeCount = Config.misc.ballGachaDedupeCount
	return (p.gachaCnId == "金币小球箱子" or p.gachaCnId == "钻石小球箱子") and typeof(ballGachaDedupeCount) == "number" and ballGachaDedupeCount == ballGachaDedupeCount and ballGachaDedupeCount >= 0 and ballGachaDedupeCount < 1e999 and p2.count <= ballGachaDedupeCount
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recordPickedBall(ballDedupeState, p)
	if GachaPool.toEngineItemType(p.itemType) == "Ball" and not (ballDedupeState.excluded[p.targetId] or ballDedupeState.balls[p.targetId]) then
		ballDedupeState.balls[p.targetId] = true
		ballDedupeState.count += 1
	end
end

local function serverRoll(p, value: string, p2)
	if typeof(value) ~= "string" or p2 ~= "coins" and p2 ~= "diamonds" then
		return {
			ok = false,
			reason = "invalid_request"
		}
	end

	local v10 = Config.crate.byCnId[value]
	local v11, reason

	if v10 and v10.isForSale then
		v11 = GachaPool.getPool(v10.gachaCnId)

		if not v11 then
			v10 = nil
			v11 = nil
			reason = "invalid_pool"
		end
	else
		v10 = nil
		reason = "invalid_crate"
	end

	if not (v10 and v11) then
		return {
			ok = false,
			reason = reason
		}
	end

	local drawCount = v10.drawCount or 1

	if typeof(drawCount) ~= "number" or drawCount % 1 ~= 0 or drawCount < 1 or drawCount > 100 then
		return {
			ok = false,
			reason = "invalid_config"
		}
	end

	local v13 = v10[v9[p2]]

	if typeof(v13) ~= "number" or v13 ~= v13 or v13 == 1e999 or v13 <= 0 then
		return {
			ok = false,
			reason = "invalid_currency"
		}
	end

	if not CurrencyService.server.hasEnough(p, p2, v13) then
		return {
			ok = false,
			reason = "insufficient"
		}
	end

	local v14 = ownedKeys(p)
	local ballDedupeState = buildBallDedupeState(PlayerData.server[p].items())
	local playerContext = GachaPool.getPlayerContext(p)
	local v15 = {}

	for i = 1, drawCount do
		local ballGachaDedupeCount = Config.misc.ballGachaDedupeCount
		local v16

		if (v10.gachaCnId == "金币小球箱子" or v10.gachaCnId == "钻石小球箱子") and typeof(ballGachaDedupeCount) == "number" and ballGachaDedupeCount == ballGachaDedupeCount and ballGachaDedupeCount >= 0 and ballGachaDedupeCount < 1e999 then
			v16 = ballDedupeState.count <= ballGachaDedupeCount
		else
			v16 = false
		end

		local dedup = v10.dedup or v16

		if RunService:IsStudio() and (v10.gachaCnId == "金币小球箱子" or v10.gachaCnId == "钻石小球箱子") then
			print(string.format(
				"[GachaDedupe] 玩家=%s 箱子=%s 抽数=%d/%d 计数球种=%d 门槛=%s 门槛保护=%s 箱子去重=%s 本抽去重=%s",
				p.Name,
				value,
				i,
				drawCount,
				ballDedupeState.count,
				tostring(Config.misc.ballGachaDedupeCount),
				tostring(v16),
				tostring(v10.dedup == true),
				(tostring(dedup == true))
			))
		end

		local pick = GachaPool.pick
		local exclude

		if dedup then
			exclude = v14
		end

		local v20 = pick(v11, random, {
			exclude = exclude,
			context = playerContext
		})

		if not v20 then
			return {
				ok = false,
				reason = "invalid_pool"
			}
		end

		table.insert(v15, v20)
		v14[GachaPool.ownedKey(GachaPool.toEngineItemType(v20.itemType), v20.targetId)] = true
		recordPickedBall(ballDedupeState, v20) -- equivalent call inferred; original call site unknown
	end

	local result = ItemService.server.purchaseBatch(p, v15, value, p2, v13)

	if not result.ok then
		return result
	end

	local success, result2 = pcall(
		OnboardingFunnelService.server.log,
		p,
		OnboardingFunnelService.ref.Step.PurchasedCrate
	)

	if not success then
		warn("[GachaService] 开箱漏斗上报失败: " .. tostring(result2))
	end

	if drawCount == 1 then
		for k, v16 in result.results[1] do
			result[k] = v16
		end
	end

	return result
end

local function serverRollFree(p, p2: string, value: string?)
	local v10 = Config.crate.byCnId[p2]
	local v11, reason

	if v10 then
		v11 = GachaPool.getPool(v10.gachaCnId)

		if not v11 then
			v10 = nil
			v11 = nil
			reason = "invalid_pool"
		end
	else
		v10 = nil
		reason = "invalid_crate"
	end

	if not (v10 and v11) then
		return {
			ok = false,
			reason = reason
		}
	end

	local v13 = pickForCrate(p, v10, v11)

	if v13 then
		return (grantPickedItem(p, v13, value or "免费赠送", p2))
	end

	return {
		ok = false,
		reason = "error"
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendPendingNewbieResults(player)
	local v10 = v[player]

	if v10 and v2[player] then
		remoteEvent2:FireClient(player, v10)
		v3[player] = true
		v[player] = nil
	end
end

local function grantConfiguredFreeChest(p, p2, source: string)
	local id = p2 and p2["箱子id"]
	local v10 = p2 and p2["数量"]

	if v10 == 0 then
		return {
			ok = true,
			reason = "disabled"
		}
	end

	local v11, v12, v13

	if typeof(id) == "string" then
		v11 = Config.crate.byCnId[id]

		if v11 then
			v12 = GachaPool.getPool(v11.gachaCnId)

			if not v12 then
				v11 = nil
				v12 = nil
				v13 = "invalid_pool"
			end
		else
			v11 = nil
			v13 = "invalid_crate"
		end
	else
		v13 = "invalid_config"
	end

	if not v11 or not v12 or typeof(v10) ~= "number" or v10 < 1 or v10 % 1 ~= 0 then
		return {
			ok = false,
			reason = v13 or "invalid_config"
		}
	end

	local results = {}

	for _ = 1, v10 do
		local v15 = pickForCrate(p, v11, v12)

		if not v15 then
			return {
				ok = false,
				reason = "error"
			}
		end

		table.insert(results, (grantPickedItem(p, v15, source, id)))
	end

	return {
		ok = true,
		results = results
	}
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, p2: string, p3: string)
		local now = os.clock()
		local v10 = v7[p]

		if v8[p] or v10 and now - v10 < 1 then
			return {
				ok = false,
				reason = "cooldown"
			}
		end

		v7[p] = now
		v8[p] = true
		local success, result = pcall(serverRoll, p, p2, p3)
		v8[p] = nil

		if success then
			return result
		end

		warn((`[GachaService] 开箱出错: {result}`))
		return {
			ok = false,
			reason = "error"
		}
	end

	remoteEvent.OnServerEvent:Connect(function(player)
		v2[player] = true
		sendPendingNewbieResults(player) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent4.OnServerEvent:Connect(function(p)
		if v3[p] and not v4[p] then
			v4[p] = true
			OnboardingFunnelService.server.log(p, OnboardingFunnelService.ref.Step.ClaimedStarterBall)
		end
	end)
	remoteEvent5.OnServerEvent:Connect(function(p)
		if v5[p] and not v6[p] then
			v6[p] = true
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
		v2[player] = nil
		v3[player] = nil
		v4[player] = nil
		v5[player] = nil
		v6[player] = nil
		v7[player] = nil
	end)
end

local flag = false
return {
	server = {
		rollFree = serverRollFree,
		grantNewbieFreeChest = function(player)
			local v10 = PlayerData.server[player]

			if v10.hasClaimedNewbieFreeChestV2() then
				return {
					ok = true,
					reason = "already_claimed"
				}
			end

			local newbieFreeChest = Config.misc.newbieFreeChest

			if typeof(newbieFreeChest) ~= "table" then
				return {
					ok = false,
					reason = "invalid_config"
				}
			end

			local v11 = {}

			if typeof(newbieFreeChest["箱子id"]) == "string" then
				v11[newbieFreeChest["箱子id"]] = newbieFreeChest["数量"]
			else
				v11 = newbieFreeChest
			end

			local v12 = {}

			for k, count in v11 do
				if typeof(k) ~= "string" or typeof(count) ~= "number" or count < 1 or count % 1 ~= 0 then
					return {
						ok = false,
						reason = "invalid_config"
					}
				end

				local crate = Config.crate.byCnId[k]
				local pool, reason

				if crate then
					pool = GachaPool.getPool(crate.gachaCnId)

					if not pool then
						crate = nil
						pool = nil
						reason = "invalid_pool"
					end
				else
					crate = nil
					reason = "invalid_crate"
				end

				if crate and pool then
					table.insert(v12, {
						cnId = k,
						count = count,
						crate = crate,
						pool = pool
					})
				else
					return {
						ok = false,
						reason = reason
					}
				end
			end

			if #v12 == 0 then
				return {
					ok = false,
					reason = "invalid_config"
				}
			end

			table.sort(v12, function(a, b)
				return a.cnId < b.cnId
			end)
			local clone = table.clone(v10.newbieChestProgress())
			local results = {}

			for _, v14 in v12 do
				for i = (tonumber(clone[v14.cnId]) or 0) + 1, v14.count do
					local v15 = pickForCrate(player, v14.crate, v14.pool)

					if not v15 then
						return {
							ok = false,
							reason = "error"
						}
					end

					table.insert(results, (grantPickedItem(player, v15, "新手赠送", v14.cnId)))
					clone[v14.cnId] = i
					v10.newbieChestProgress(table.clone(clone))
				end
			end

			v10.hasClaimedNewbieFreeChestV2(true)
			v[player] = results
			sendPendingNewbieResults(player) -- equivalent call inferred; original call site unknown
			return {
				ok = true,
				results = results
			}
		end,
		grantJoinGroupFreeChest = function(p)
			return (grantConfiguredFreeChest(p, Config.misc.joinGroupFreeChest, "群组奖励"))
		end,
		grantFriendInviteFreeChest = function(p)
			return (grantConfiguredFreeChest(p, Config.misc.friendInviteFreeChest, "好友邀请奖励"))
		end,
		grantFirstRaceFreeChest = function(p)
			local v10 = PlayerData.server[p]

			if v10.hasClaimedFirstRaceFreeChest() then
				return {
					ok = true,
					reason = "already_claimed"
				}
			end

			local v11 = grantConfiguredFreeChest(p, Config.misc.firstRaceFreeChest, "首次对战奖励")

			if v11.ok then
				v10.hasClaimedFirstRaceFreeChest(true)
			end

			return v11
		end,
		grantConfiguredFreeChest = grantConfiguredFreeChest,
		grantPickedItem = grantPickedItem,
		markFirstRaceRewardSent = function(p)
			v5[p] = true
		end
	},
	client = {
		roll = function(p: string, p2)
			return remoteFunction:InvokeServer(p, p2)
		end,
		initNewbieReward = function()
			if flag then
				return
			end

			flag = true
			local RewardConfirmQueue = require(ReplicatedStorage.Engine.Gui.RewardConfirmQueue)
			remoteEvent2.OnClientEvent:Connect(function(list)
				local newbieFreeChest = Config.misc.newbieFreeChest
				local crateCnId = list[1] and list[1].crateCnId or newbieFreeChest and newbieFreeChest["箱子id"]

				if typeof(crateCnId) == "string" then
					RewardConfirmQueue.enqueue(list, crateCnId, "newbie")
				else
					warn("[GachaService] 新手奖励缺少有效箱子配置")
				end
			end)
			remoteEvent3.OnClientEvent:Connect(function(p)
				local firstRaceFreeChest = Config.misc.firstRaceFreeChest
				local id = firstRaceFreeChest and firstRaceFreeChest["箱子id"]

				if typeof(id) == "string" then
					RewardConfirmQueue.enqueue(p, id, "firstRace")
				else
					warn("[GachaService] 首次对战奖励缺少有效箱子配置")
				end
			end)
			remoteEvent:FireServer()
		end
	}
}