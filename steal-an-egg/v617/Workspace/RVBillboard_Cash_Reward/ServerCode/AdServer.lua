local AdService = game:GetService("AdService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Analytics = require(ServerScriptService.UserGenerated.Analytics)
local GuardTutorialProgressionService = require(ServerScriptService.Controllers.GuardTutorialProgressionService)
local success, saveData = pcall(require, script.Parent:FindFirstChild("SaveData"))

if not (success and saveData) then
	warn("[RVBillboard] SaveData module missing — claim data will not persist.")
	saveData = {
		Load = function() end,
		Unload = function() end,
		CanClaim = function()
			return true
		end,
		GetActiveClaimCount = function()
			return 0
		end,
		GetLastClaimTime = function()
			return 0
		end,
		AddEntry = function()
			return true
		end,
		GetCache = function()
			return {}
		end,
		SetClaimCount = function() end
	}
end

local success2, telemetry = pcall(require, script.Parent:FindFirstChild("Telemetry"))

if not (success2 and telemetry) then
	warn("[RVBillboard] Telemetry module missing — analytics will not be logged.")
	telemetry = {
		new = function()
			return {
				Log = function() end,
				SetBucket = function() end
			}
		end
	}
end

local success3, rewardSelector = pcall(require, script.Parent:FindFirstChild("RewardSelector"))
local v = success3 and rewardSelector or {
	Init = function()
		return true
	end,
	AssignPlayer = function() end,
	UnassignPlayer = function() end,
	AcceptSync = function()
		return false
	end,
	HasMultiReward = function()
		return false
	end,
	IsSynced = function()
		return false
	end,
	MarkSynced = function() end,
	IsAssigned = function()
		return true
	end,
	GetReward = function()
		return nil
	end,
	GetAssignedProductId = function()
		return 0
	end,
	GetBucket = function()
		return "A"
	end
}
local v2 = nil
local v3 = false
local AdServer = {}
local v4 = nil
local v5 = nil
local v6 = {}
local v7 = {}
local v8 = {}
local names = {}
local devProductId = ""
local v9 = ""

-- equivalent calls inferred from this helper; original call sites unknown
local function debugPrint(formatted: string)
	if v3 then
		print(formatted)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getProductName(devProductId2: number)
	if names[devProductId2] then
		return names[devProductId2]
	end

	local success4, productInfo = pcall(
		MarketplaceService.GetProductInfo,
		MarketplaceService,
		devProductId2,
		Enum.InfoType.Product
	)
	local name = success4 and productInfo and productInfo.Name and productInfo.Name or ""
	names[devProductId2] = name
	return name
end

local function getAdVariant(player)
	if v:IsAssigned(player) then
		return v:GetBucket(player)
	end

	return ""
end

function AdServer.ShowAd(player)
	if v7[player] then
		return
	end

	local activeClaimCount = saveData:GetActiveClaimCount(player.UserId, devProductId, v4.PlacementId, v4.ResetInDays)
	debugPrint(("[Board %s] SHOW_AD — %s: %d/%d active before attempt"):format(
		v9,
		player.Name,
		activeClaimCount,
		v4.ClaimLimit
	)) -- equivalent call inferred; original call site unknown

	if saveData:CanClaim(player.UserId, devProductId, v4.PlacementId, v4.ClaimLimit, v4.ResetInDays) then
		if v4.Cooldown > 0 and math.ceil(saveData:GetLastClaimTime(player.UserId, devProductId, v4.PlacementId) + v4.Cooldown * 60 - os.time()) > 0 then
			v5.AdResult:FireClient(player, {
				devProductId = v4.DevProductId,
				placementId = v4.PlacementId,
				completed = false,
				claimed = false,
				reason = "Cooldown"
			})
			return
		end

		v7[player] = true
		v2:SetBucket(v:GetBucket(player))
		v2:SetRawConfigValue(v:GetRawConfigValue(player))
		v2:SetDevProductId(v:GetAssignedProductId(player))
		v2:Log(player, "AdStarted")
		local reward = v:GetReward(player)
		local success4, result = pcall(AdService.ShowRewardedVideoAdAsync, AdService, player, reward, v4.PlacementId)
		v7[player] = nil

		if success4 then
			if result == Enum.ShowAdResult.ShowCompleted then
				local now = os.time()
				local cooldownEndsAt

				if v4.Cooldown > 0 then
					cooldownEndsAt = now + v4.Cooldown * 60
				end

				local claimsUsed = saveData:GetActiveClaimCount(
					player.UserId,
					devProductId,
					v4.PlacementId,
					v4.ResetInDays
				) + 1
				local claimLimit = v4.ClaimLimit
				local v12 = v4.ResetInDays * 86400
				local windowResetsAt = math.floor(now / v12) * v12 + v12
				v5.AdResult:FireClient(player, {
					devProductId = v4.DevProductId,
					placementId = v4.PlacementId,
					completed = true,
					claimed = true,
					result = result,
					cooldownEndsAt = cooldownEndsAt,
					claimsUsed = claimsUsed,
					claimsMax = claimLimit,
					windowResetsAt = windowResetsAt
				})
				debugPrint(("[Board %s] CLAIM_SUCCESS — %s: now %d/%d"):format(v9, player.Name, claimsUsed, claimLimit)) -- equivalent call inferred; original call site unknown

				for _, v14 in v6 do
					local remotes = v14:FindFirstChild("Remotes")
					local syncSignal = remotes and remotes:FindFirstChild("SyncSignal")

					if not syncSignal then
						continue
					end

					debugPrint(("[Board %s] SYNC_OUT — firing count=%d to other board"):format(v9, claimsUsed)) -- equivalent call inferred; original call site unknown
					syncSignal:Fire(player, v4.DevProductId, claimsUsed, nil, v4.PlacementId)
				end

				v2:Log(player, "AdComplete")
				Analytics:IncrementPlayerAttribute(player, "TotalAdsWatched", 1)
				Analytics:LogPlayerEvent(player, "PlayerAdWatched", {
					Feature = "Ads",
					Variant = not v:IsAssigned(player) and "" or v:GetBucket(player),
					PlacementId = tostring(v4.PlacementId),
					DevProductId = tostring(v:GetAssignedProductId(player)),
					Multiplier = v:GetMultiplier(player)
				})
				local productName = getProductName(v4.DevProductId) -- equivalent call inferred; original call site unknown
				saveData:AddEntry(player.UserId, devProductId, v4.PlacementId, productName, v4.ResetInDays)
			else
				v2:Log(player, "AdIncomplete")
				v5.AdResult:FireClient(player, {
					devProductId = v4.DevProductId,
					placementId = v4.PlacementId,
					completed = false,
					claimed = false,
					result = result
				})
			end
		else
			warn(("[RVBillboard] ShowRewardedVideoAdAsync error for %s — %s"):format(player.Name, (tostring(result))))
			v2:Log(player, "AdIncomplete")
			v5.AdResult:FireClient(player, {
				devProductId = v4.DevProductId,
				placementId = v4.PlacementId,
				completed = false,
				claimed = false,
				result = nil
			})
		end
	else
		local activeClaimCount2 = saveData:GetActiveClaimCount(
			player.UserId,
			devProductId,
			v4.PlacementId,
			v4.ResetInDays
		)
		local v10 = v4.ResetInDays * 86400
		local windowResetsAt = math.floor(os.time() / v10) * v10 + v10
		v5.AdResult:FireClient(player, {
			devProductId = v4.DevProductId,
			placementId = v4.PlacementId,
			completed = false,
			claimed = false,
			reason = "ClaimLimitReached",
			claimsUsed = activeClaimCount2,
			claimsMax = v4.ClaimLimit,
			windowResetsAt = windowResetsAt
		})
	end
end

function AdServer:Init(instance, data, data2, flag: boolean?)
	v3 = flag or false
	v4 = data
	v5 = data2
	devProductId = tostring(data.DevProductId)

	if not v:Init(data) then
		warn("[RVBillboard] RewardSelector failed — no valid rewards. Board disabled on " .. instance:GetFullName())
		return
	end

	v2 = telemetry.new({
		DevProductId = data.DevProductId,
		PlacementId = data.PlacementId or 0,
		Bucket = "A"
	})
	data2.LogTelemetry.OnServerEvent:Connect(function(p, value)
		if type(value) ~= "string" then
			return
		end

		v2:SetBucket(v:GetBucket(p))
		v2:SetRawConfigValue(v:GetRawConfigValue(p))
		v2:SetDevProductId(v:GetAssignedProductId(p))
		v2:Log(p, value)
	end)

	local function loadAndAssignPlayer(player)
		saveData:Load(player.UserId)

		if v:HasMultiReward() and data.PlacementId and data.PlacementId ~= 0 then
			local magnitude = instance:GetPivot().Position.Magnitude
			local v10 = magnitude / 50
			debugPrint(("[RVBillboard/Sync] Board %s | distance=%.1f studs | waiting %.3fs"):format(v9, magnitude, v10)) -- equivalent call inferred; original call site unknown
			task.wait(v10)
			local isSynced = v:IsSynced(player)
			debugPrint(("[RVBillboard/Sync] Board %s | wait complete | synced=%s"):format(v9, (tostring(isSynced)))) -- equivalent call inferred; original call site unknown

			if not isSynced then
				local v11 = math.random() * 0.01
				debugPrint(("[RVBillboard/Sync] Board %s | jitter=%.4fs"):format(v9, v11)) -- equivalent call inferred; original call site unknown
				task.wait(v11)
			end

			if v:IsSynced(player) then
				debugPrint(("[RVBillboard/Sync] Board %s FOLLOWER — synced to product=%d"):format(
					v9,
					v:GetAssignedProductId(player)
				)) -- equivalent call inferred; original call site unknown
			else
				v:AssignPlayer(player)
				debugPrint(("[RVBillboard/Sync] Board %s LEADER — picked product=%d, firing to %d boards"):format(
					v9,
					v:GetAssignedProductId(player),
					#v6
				)) -- equivalent call inferred; original call site unknown

				for _, v11 in v6 do
					local remotes = v11:FindFirstChild("Remotes")
					local syncSignal = remotes and remotes:FindFirstChild("SyncSignal")

					if syncSignal then
						syncSignal:Fire(player, data.DevProductId, nil, {
							placementId = data.PlacementId,
							assignedProductId = v:GetAssignedProductId(player)
						})
					end
				end

				debugPrint(("[RVBillboard/Sync] Board %s LEADER — sync fired"):format(v9)) -- equivalent call inferred; original call site unknown
			end
		else
			v:AssignPlayer(player)
		end

		local hasPlayerCompletedTutorial = GuardTutorialProgressionService.HasPlayerCompletedTutorial(player)
		print(("[RVB4.0] %s | bucket=%s|%s | product=%d | multiplier=%.1f | tutorial_complete=%s"):format(
			player.Name,
			v:GetBucket(player),
			v:GetRawConfigValue(player),
			v:GetAssignedProductId(player),
			v:GetMultiplier(player),
			(tostring(hasPlayerCompletedTutorial))
		))
		Analytics:SetPlayerAttribute(player, "Shared.AdVariant", getAdVariant(player))

		if v:GetBucket(player) == "A" then
			print(("[RVB4.0] %s | CONTROL GROUP — board will be moved to ReplicatedStorage"):format(player.Name))
			v5.AdResult:FireClient(player, {
				devProductId = data.DevProductId,
				placementId = data.PlacementId,
				completed = false,
				claimed = false,
				reason = "ControlGroup",
				gated = true
			})
		else
			print(("[RVB4.0] %s | bucket=%s|%s | ACTIVE — board will load with product=%d, multiplier=%.1f"):format(
				player.Name,
				v:GetBucket(player),
				v:GetRawConfigValue(player),
				v:GetAssignedProductId(player),
				v:GetMultiplier(player)
			))
			v5.AdResult:FireClient(player, {
				devProductId = data.DevProductId,
				placementId = data.PlacementId,
				completed = false,
				claimed = false,
				reason = "RewardAssigned",
				assignedProductId = v:GetAssignedProductId(player),
				multiplier = v:GetMultiplier(player),
				rewardDuration = v:GetRewardDuration()
			})
			local activeClaimCount = saveData:GetActiveClaimCount(
				player.UserId,
				devProductId,
				data.PlacementId,
				data.ResetInDays
			)
			local v10 = 0
			local v11 = saveData:GetCache()[player.UserId]

			if v11 then
				v10 = v11[devProductId] and #v11[devProductId] or v10
			end

			debugPrint(("[Board %s] LOAD — %s: %d/%d active (raw#=%d) bucket=%s"):format(
				v9,
				player.Name,
				activeClaimCount,
				data.ClaimLimit,
				v10,
				v:GetBucket(player)
			)) -- equivalent call inferred; original call site unknown
		end
	end

	for _, v10 in Players:GetPlayers() do
		task.spawn(loadAndAssignPlayer, v10)
	end

	Players.PlayerAdded:Connect(function(player)
		loadAndAssignPlayer(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		v:UnassignPlayer(player)
		v7[player] = nil
		v8[player] = nil
		saveData:Unload(player.UserId)
	end)

	data2.GetPlacementInfo.OnServerInvoke = function(p)
		if not v:IsAssigned(p) then
			return {
				pending = true
			}
		end

		if v:IsAssigned(p) and v:GetBucket(p) == "A" then
			return {
				controlGroup = true
			}
		end

		local userId = p.UserId
		local now = os.time()
		local activeClaimCount = saveData:GetActiveClaimCount(userId, devProductId, data.PlacementId, data.ResetInDays)
		local cooldownEndsAt = saveData:GetLastClaimTime(userId, devProductId, data.PlacementId) + data.Cooldown * 60
		local secondsLeft = math.max(0, cooldownEndsAt - now)
		local v12 = data.ResetInDays * 86400
		local v13 = math.floor(now / v12) * v12
		return {
			eligible = (data.ClaimLimit == 0 or activeClaimCount < data.ClaimLimit) and secondsLeft == 0,
			cooldownEndsAt = cooldownEndsAt,
			secondsLeft = secondsLeft,
			claimsUsed = activeClaimCount,
			claimsMax = data.ClaimLimit,
			windowResetsAt = v13 + v12,
			devProductId = data.DevProductId,
			placementId = data.PlacementId,
			assignedProductId = v:GetAssignedProductId(p),
			multiplier = v:GetMultiplier(p),
			rewardDuration = v:GetRewardDuration()
		}
	end

	data2.ShowAd.OnServerEvent:Connect(function(player)
		local now = os.time()

		if now - (v8[player] or 0) < 5 then
			data2.AdResult:FireClient(player, {
				devProductId = data.DevProductId,
				placementId = data.PlacementId,
				completed = false,
				claimed = false,
				reason = "RateLimited"
			})
			return
		end

		v8[player] = now
		AdServer.ShowAd(player)
	end)

	for _, v10 in CollectionService:GetTagged("RVBillboard") do
		if v10 ~= instance then
			table.insert(v6, v10)
		end
	end

	v9 = tostring(#v6 + 1)
	CollectionService:GetInstanceAddedSignal("RVBillboard"):Connect(function(instance2)
		if instance2 ~= instance then
			table.insert(v6, instance2)
			local remotes = instance2:FindFirstChild("Remotes")
			local syncSignal = remotes and remotes:FindFirstChild("SyncSignal")

			if syncSignal then
				for k, v10 in saveData:GetCache() do
					if not v10[devProductId] then
						continue
					end

					local playerByUserId = Players:GetPlayerByUserId(k)

					if not playerByUserId then
						continue
					end

					local activeClaimCount = saveData:GetActiveClaimCount(
						k,
						devProductId,
						data.PlacementId,
						data.ResetInDays
					)

					if activeClaimCount > 0 then
						syncSignal:Fire(playerByUserId, data.DevProductId, activeClaimCount, nil, data.PlacementId)
					end

					if not (v:IsSynced(playerByUserId) and data.PlacementId and data.PlacementId ~= 0) then
						continue
					end

					debugPrint(("[RVBillboard/Sync] Board %s redistributing verified sync to new board — product=%d"):format(
						v9,
						v:GetAssignedProductId(playerByUserId)
					)) -- equivalent call inferred; original call site unknown
					syncSignal:Fire(playerByUserId, data.DevProductId, nil, {
						placementId = data.PlacementId,
						assignedProductId = v:GetAssignedProductId(playerByUserId)
					})
				end
			end
		end
	end)
	CollectionService:GetInstanceRemovedSignal("RVBillboard"):Connect(function(p)
		for k, v10 in v6 do
			if v10 ~= p then
				continue
			end

			table.remove(v6, k)
			break
		end
	end)
	data2.SyncSignal.Event:Connect(function(player, p, claimsUsed, p3, p4)
		if p ~= data.DevProductId then
			return
		end

		if p3 then
			local placementId = data.PlacementId
			local placementId2 = p3.placementId

			if not placementId or placementId == 0 or (not placementId2 or placementId2 == 0) then
				return
			end

			if placementId ~= placementId2 then
				return
			end

			if v:AcceptSync(player, p3.assignedProductId) then
				v5.AdResult:FireClient(player, {
					devProductId = data.DevProductId,
					placementId = data.PlacementId,
					completed = false,
					claimed = false,
					reason = "RewardAssigned",
					assignedProductId = p3.assignedProductId,
					multiplier = v:GetMultiplier(player),
					rewardDuration = v:GetRewardDuration()
				})
			end
		else
			if not claimsUsed then
				return
			end

			local placementId = data.PlacementId

			if p4 and p4 ~= 0 then
				if not placementId or placementId == 0 or placementId ~= p4 then
					return
				end
			elseif placementId and placementId ~= 0 then
				return
			end

			local activeClaimCount = saveData:GetActiveClaimCount(
				player.UserId,
				devProductId,
				data.PlacementId,
				data.ResetInDays
			)
			local v10 = 0
			local v11 = saveData:GetCache()[player.UserId]

			if v11 then
				v10 = v11[devProductId] and #v11[devProductId] or v10
			end

			debugPrint(("[Board %s] SYNC_IN — received count=%d for %s (before: active=%d, raw#=%d)"):format(
				v9,
				claimsUsed,
				player.Name,
				activeClaimCount,
				v10
			)) -- equivalent call inferred; original call site unknown
			saveData:SetClaimCount(player.UserId, devProductId, data.PlacementId, claimsUsed, data.ResetInDays)
			local activeClaimCount2 = saveData:GetActiveClaimCount(
				player.UserId,
				devProductId,
				data.PlacementId,
				data.ResetInDays
			)
			debugPrint(("[Board %s] SYNC_IN — after SetClaimCount: active=%d/%d"):format(
				v9,
				activeClaimCount2,
				data.ClaimLimit
			)) -- equivalent call inferred; original call site unknown
			local cooldownEndsAt = saveData:GetLastClaimTime(player.UserId, devProductId, data.PlacementId) + data.Cooldown * 60
			local secondsLeft = math.max(0, cooldownEndsAt - os.time())
			local v14 = data.ResetInDays * 86400
			local v15 = math.floor(os.time() / v14) * v14
			data2.AdResult:FireClient(player, {
				devProductId = data.DevProductId,
				placementId = data.PlacementId,
				completed = false,
				claimed = false,
				reason = "SyncUpdate",
				cooldownEndsAt = cooldownEndsAt,
				secondsLeft = secondsLeft,
				claimsUsed = claimsUsed,
				claimsMax = data.ClaimLimit,
				windowResetsAt = v15 + v14
			})
		end
	end)
end

return AdServer