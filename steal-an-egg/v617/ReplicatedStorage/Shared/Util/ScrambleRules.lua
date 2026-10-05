local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScrambleBossDrop = require(ReplicatedStorage.Shared.Util.ScrambleBossDrop)
local v = {
	MAX_SAMPLES = 9000000000000,
	PART_IDS = table.freeze({
		"LostPart1",
		"LostPart2",
		"DronePart1",
		"DronePart2",
		"DronePart3"
	}),
	Blank = function()
		return {
			Wallets = {},
			LostParts = {},
			DroneParts = 0,
			Discovered = false,
			Completed = false,
			RewardUid = "",
			ShopPurchases = {},
			MutationConsumables = 0,
			ShopSequence = 0,
			LastOperation = "",
			Receipts = {},
			Mastery = 0,
			ClaimedMilestoneIds = {},
			InfiniteRewardsClaimed = 0
		}
	end,
	Integer = function(value, p: number, p2: number)
		return type(value) == "number" and value == value and value % 1 == 0 and p <= value and value <= p2
	end,
	Count = function(items)
		local count = 0

		for _ in items do
			count += 1
		end

		return count
	end,
	Progress = function(p)
		return (p.LostParts.LostPart1 and 1 or 0) + (p.LostParts.LostPart2 and 1 or 0), p.DroneParts
	end,
	NextPart = function(p)
		if p.Completed or p.DroneParts >= 3 then
			return nil
		end

		return "DronePart" .. tostring(p.DroneParts + 1)
	end
}

function v.Project(data, p: string)
	local progress, droneParts = v.Progress(data)
	return {
		Samples = data.Wallets[p] or 0,
		ShopSequence = data.ShopSequence,
		ShopPurchases = table.clone((data.ShopPurchases or {})[p] or {}),
		LostParts = table.clone(data.LostParts),
		DroneParts = droneParts,
		TotalParts = progress + droneParts,
		Discovered = data.Discovered,
		Completed = data.Completed,
		Mastery = data.Mastery or 0,
		ClaimedMilestoneIds = table.clone(data.ClaimedMilestoneIds or {}),
		InfiniteRewardsClaimed = data.InfiniteRewardsClaimed or 0
	}
end

function v.Window(p: number, nextAt: number, endsAt: number, p4: number, p5: number)
	if nextAt <= 0 or endsAt <= nextAt or p < nextAt or endsAt <= p then
		return {
			Available = false,
			Active = false,
			Index = -1,
			EndsAt = endsAt,
			NextAt = nextAt
		}
	end

	local v2 = math.floor(p / p4)
	local startsAt = v2 * p4
	local endsAt2 = math.min(startsAt + p5, endsAt)
	return {
		Available = true,
		Active = p < endsAt2,
		Index = v2,
		StartsAt = startsAt,
		EndsAt = endsAt2,
		NextAt = math.min(startsAt + p4, endsAt)
	}
end

function v.SplitSamples(p: number, p2: number)
	assert(v.Integer(p, 0, v.MAX_SAMPLES) and v.Integer(p2, 1, 32))
	local v2 = math.min(p, p2)
	local result = {}

	if v2 == 0 then
		return result
	end

	local v3 = math.floor(p / v2)
	local v4 = p % v2

	for i = 1, v2 do
		result[i] = v3 + (i <= v4 and 1 or 0)
	end

	return result
end

function v.Apply(data, p: string, data2, data3)
	local scramble = data.Scramble

	if data2.OperationId and scramble.LastOperation == data2.OperationId then
		return false, "AlreadyGranted"
	end

	local clone = table.clone(scramble)
	clone.LastOperation = data2.OperationId or scramble.LastOperation
	local clone2 = table.clone(data)
	clone2.Scramble = clone
	local eventId = data2.EventId
	local rewards = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function credit(amount: number)
		if not v.Integer(amount, 1, v.MAX_SAMPLES) then
			return false
		end

		local v2 = scramble.Wallets[eventId] or 0

		if v.MAX_SAMPLES - amount < v2 then
			return false
		end

		clone.Wallets = table.clone(scramble.Wallets)
		clone.Wallets[eventId] = v2 + amount
		return true
	end

	local function addEggs(rewards2, p2: number, flag: boolean?)
		if type(rewards2) ~= "table" then
			return "MissingReward"
		end

		if not flag and v.Count(data.EggInventory) + p2 > data3.Eggs then
			return "EggInventoryFull"
		end

		if v.Count(rewards2) ~= p2 then
			return "MissingReward"
		end

		local clone3 = table.clone(data.EggInventory)

		for k, item in rewards2 do
			if type(k) ~= "string" or k == "" or type(item) ~= "table" then
				return "MissingReward"
			end

			if clone3[k] then
				return "DuplicateReward"
			else
				clone3[k] = item
			end
		end

		clone2.EggInventory = clone3
		return nil
	end

	if p == "Samples" then
		-- equivalent call inferred; original call site unknown
		if not credit(data2.Amount) then
			return false, "BalanceLimit"
		end
	elseif p == "Consumable" then
		local mutationConsumables = scramble.MutationConsumables or 0

		if not v.Integer(data2.Amount, 1, v.MAX_SAMPLES) or v.MAX_SAMPLES - data2.Amount < mutationConsumables then
			return false, "BalanceLimit"
		end

		clone.MutationConsumables = mutationConsumables + data2.Amount
	elseif p == "Part" then
		if scramble.Completed then
			return false, "AlreadyComplete"
		end

		if data2.Id == "LostPart1" or data2.Id == "LostPart2" then
			if scramble.LostParts[data2.Id] then
				return false, "AlreadyCollected"
			end

			clone.LostParts = table.clone(scramble.LostParts)
			clone.LostParts[data2.Id] = true
		elseif data2.Id == v.NextPart(scramble) then
			clone.DroneParts += 1
		else
			return false, "WrongPart"
		end
	elseif p == "Discover" then
		if scramble.Discovered then
			return false, "AlreadyDiscovered"
		else
			clone.Discovered = true
		end
	elseif p == "Vault" then
		if scramble.Completed then
			return false, "AlreadyComplete"
		end

		local progress, v2 = v.Progress(scramble)

		if not scramble.Discovered or progress + v2 ~= 5 then
			return false, "MissingParts"
		end

		if type(data2.Gear) ~= "string" or data2.Gear == "" or not v.Integer(data2.Amount, 1, 100) then
			return false, "MissingReward"
		end

		clone2.GearInventory = table.clone(data.GearInventory)
		clone2.GearInventory[data2.Gear] = math.max(clone2.GearInventory[data2.Gear] or 0, data2.Amount)
		local rewardUid = "Gear:" .. data2.Gear
		clone.Completed = true
		clone.RewardUid = rewardUid
	elseif p == "Shop" then
		if not v.Integer(data2.Sequence, 0, v.MAX_SAMPLES - 1) or data2.Sequence ~= scramble.ShopSequence then
			return false, "StalePurchase"
		end

		if not v.Integer(data2.Price, 1, v.MAX_SAMPLES) or not v.Integer(data2.Quantity, 1, 25) or type(data2.Rewards) ~= "table" then
			return false, "MissingReward"
		end

		local v2 = scramble.Wallets[eventId] or 0

		if v2 < data2.Price then
			return false, "NotEnoughSamples"
		end

		local v3 = ((scramble.ShopPurchases or {})[eventId] or {})[data2.OfferId]
		local v4 = (not v3 or v3.Period ~= data2.PurchasePeriod) and 0 or v3.Count

		if data2.PurchaseLimit ~= nil then
			if type(data2.OfferId) ~= "string" or type(data2.PurchasePeriod) ~= "string" or #data2.PurchasePeriod > 64 or not (v.Integer(
				data2.PurchaseLimit,
				1,
				100
			) and v.Integer(v4, 0, v.MAX_SAMPLES)) then
				return false, "MissingReward"
			end

			if v4 + data2.Quantity > data2.PurchaseLimit then
				return false, "PurchaseLimit"
			end
		end

		local kind = data2.Kind or "Egg"

		if kind == "Pet" then
			if v.Count(data.Inventory) + data2.Quantity > data3.Pets then
				return false, "PetInventoryFull"
			end

			if v.Count(data2.Rewards) ~= data2.Quantity then
				return false, "MissingReward"
			end

			local clone3 = table.clone(data.Inventory)
			local clone4 = table.clone(data.Index)

			for k, reward in data2.Rewards do
				if type(k) ~= "string" or k == "" or type(reward) ~= "table" then
					return false, "MissingReward"
				end

				if clone3[k] then
					return false, "DuplicateReward"
				end

				clone3[k] = reward
				clone4[reward.Category] = true
			end

			rewards = data2.Rewards
			clone2.Inventory = clone3
			clone2.Index = clone4
		elseif kind == "Egg" then
			local v5 = addEggs(data2.Rewards, data2.Quantity)

			if v5 then
				return false, v5
			end
		elseif kind == "MutationConsumable" then
			local mutationConsumables = scramble.MutationConsumables or 0

			if not v.Integer(mutationConsumables, 0, v.MAX_SAMPLES - data2.Quantity) then
				return false, "BalanceLimit"
			end

			clone.MutationConsumables = mutationConsumables + data2.Quantity
		else
			if kind ~= "CashBooster" and kind ~= "SpeedBoost" and kind ~= "TreadmillBoost" then
				return false, "MissingReward"
			end

			if data2.Quantity ~= 1 or not v.Integer(data2.DurationSeconds, 1, 86400) or type(data2.Now) ~= "number" or data2.Now ~= data2.Now or data2.Now <= 0 or data2.Now > 4000000000 then
				return false, "MissingReward"
			end

			local earningsBoostExpiresAt

			if kind == "CashBooster" then
				earningsBoostExpiresAt = data.EarningsBoostExpiresAt
			elseif kind == "SpeedBoost" then
				earningsBoostExpiresAt = data.BossMastery.SpeedBoostExpiresAt
			else
				earningsBoostExpiresAt = data3.TreadmillRemaining(data, data2.Now)
			end

			if type(earningsBoostExpiresAt) ~= "number" or earningsBoostExpiresAt ~= earningsBoostExpiresAt or earningsBoostExpiresAt < 0 or 4000000000 - data2.DurationSeconds < earningsBoostExpiresAt then
				return false, "BalanceLimit"
			end

			if kind == "CashBooster" then
				clone2.EarningsBoostExpiresAt = math.max(data2.Now, earningsBoostExpiresAt) + data2.DurationSeconds
			elseif kind == "SpeedBoost" then
				clone2.BossMastery = table.clone(data.BossMastery)
				clone2.BossMastery.SpeedBoostExpiresAt = math.max(data2.Now, earningsBoostExpiresAt) + data2.DurationSeconds
			else
				clone2.TemporarySpeedBoostRemainingSeconds = earningsBoostExpiresAt + data2.DurationSeconds
				clone2.TemporarySpeedBoostActiveStartedAt = data2.Now
			end
		end

		clone.Wallets = table.clone(scramble.Wallets)
		clone.Wallets[eventId] = v2 - data2.Price
		clone.ShopSequence = scramble.ShopSequence + 1

		if data2.PurchaseLimit ~= nil then
			clone.ShopPurchases = table.clone(scramble.ShopPurchases or {})
			local clone3 = table.clone(clone.ShopPurchases[eventId] or {})
			clone3[data2.OfferId] = {
				Period = data2.PurchasePeriod,
				Count = v4 + data2.Quantity
			}
			clone.ShopPurchases[eventId] = clone3
		end
	elseif p == "Receipt" then
		if scramble.Receipts[data2.PurchaseId] then
			local v2 = false

			if scramble.Receipts[data2.PurchaseId].ProductId == data2.ProductId then
				return false, "AlreadyGranted"
			end

			return v2, "ReceiptMismatch"
		else
			-- equivalent call inferred; original call site unknown
			if not credit(data2.Amount) then
				return false, "BalanceLimit"
			end

			clone.Receipts = table.clone(scramble.Receipts)
			clone.Receipts[data2.PurchaseId] = {
				ProductId = data2.ProductId,
				EventId = eventId,
				Amount = data2.Amount
			}
			clone2.MonetizationRobuxSpentTotal = (data.MonetizationRobuxSpentTotal or 0) + (data2.RobuxSpent or 0)
		end
	elseif p == "BossKill" then
		if not v.Integer(data2.Amount, 0, v.MAX_SAMPLES) then
			return false, "InvalidAmount"
		end

		if data2.Amount > 0 then
			-- equivalent call inferred; original call site unknown
			if not credit(data2.Amount) then
				return false, "BalanceLimit"
			end
		end

		clone.Mastery = (scramble.Mastery or 0) + 1
		clone2.MechaScramblerObtained = ScrambleBossDrop.HasObtained(data)

		if data2.Rewards ~= nil and not clone2.MechaScramblerObtained then
			local v2 = addEggs(data2.Rewards, 1, true)

			if v2 then
				return false, v2
			else
				clone2.MechaScramblerObtained = true
			end
		end
	else
		if p ~= "Milestone" then
			return false, "UnknownAction"
		end

		local mastery = scramble.Mastery or 0
		local claimedMilestoneIds = scramble.ClaimedMilestoneIds or {}

		if data2.Infinite then
			if type(data2.FinalMilestoneId) ~= "string" or not (v.Integer(data2.FinalKills, 1, v.MAX_SAMPLES) and v.Integer(
				data2.EveryKills,
				1,
				v.MAX_SAMPLES
			)) then
				return false, "MissingReward"
			end

			local infiniteRewardsClaimed = scramble.InfiniteRewardsClaimed or 0

			if not claimedMilestoneIds[data2.FinalMilestoneId] or (mastery - data2.FinalKills) // data2.EveryKills <= infiniteRewardsClaimed then
				return false, "MilestoneLocked"
			end

			clone.InfiniteRewardsClaimed = infiniteRewardsClaimed + 1
		else
			if type(data2.MilestoneId) ~= "string" or not v.Integer(data2.Kills, 1, v.MAX_SAMPLES) then
				return false, "MissingReward"
			end

			if claimedMilestoneIds[data2.MilestoneId] then
				return false, "MilestoneClaimed"
			end

			if mastery < data2.Kills then
				return false, "MilestoneLocked"
			end

			clone.ClaimedMilestoneIds = table.clone(claimedMilestoneIds)
			clone.ClaimedMilestoneIds[data2.MilestoneId] = true
		end

		local v2 = addEggs(data2.Rewards, 1)

		if v2 then
			return false, v2
		end
	end

	return clone2, "Granted", rewards
end

return table.freeze(v)