local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Common.CratesContent)
local v3 = require3(ReplicatedStorage2.Common.GachaItemsData)
local v4 = require3(ReplicatedStorage2.Common.RewardInfo)
local v5 = require3(ReplicatedStorage2.Shared.ItemInfo)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v6 = require3(ReplicatedStorage2.Shared.GenericCrateData)

local function crateToContainer(p, p2: string)
	local swordRewards = {}
	local getContents

	getContents = function(items)
		for k, item in items do
			if type(item) ~= "table" then
				continue
			end

			local createSwordReward

			if k == "Swords" then
				createSwordReward = v4.createSwordReward
			elseif k == "Explosions" then
				createSwordReward = v4.createExplosionReward
			elseif k == "Emotes" then
				createSwordReward = v4.createEmoteReward
			end

			if createSwordReward then
				for _, v7 in item do
					local swordReward = createSwordReward(v7)

					if p2 == "Rarity" then
						local v8 = v5[swordReward.Type] and v5[swordReward.Type][swordReward.Value]

						if v8 and v8.Rarity then
							if v8.Rarity == "Secret" then
								continue
							else
								swordReward = {
									Type = "Rarity",
									Value = v8.Rarity
								}
							end
						end
					end

					local v8 = false

					for _, v10 in swordRewards do
						if not (v10.Type == swordReward.Type and v10.Value == swordReward.Value) then
							continue
						end

						v8 = true
						break
					end

					if not v8 then
						table.insert(swordRewards, swordReward)
					end
				end
			end

			getContents(item)
		end
	end

	getContents(p)
	return function(_)
		return swordRewards
	end
end

return (table.freeze({
	BattlepassGacha = function(p)
		local result = {}

		for _, v7 in { v3.BottomRewards, v3.TopRewards } do
			for _, v8 in v7 do
				if v8.GetCustomReward then
					table.insert(result, (v8.GetCustomReward(p)))
				elseif v8.AwardFunctionArguments then
					local createEmoteReward

					if v8.AwardFunctionName == "AddEmote" then
						createEmoteReward = v4.createEmoteReward
					elseif v8.AwardFunctionName == "AddSwordSkin" then
						createEmoteReward = v4.createSwordReward
					elseif v8.AwardFunctionName == "AddExplosion" then
						createEmoteReward = v4.createExplosionReward
					end

					if createEmoteReward then
						table.insert(result, createEmoteReward(v8.AwardFunctionArguments[1]))
					end
				end
			end
		end

		return result
	end,
	NormalSwordCrate = crateToContainer(v2.NormalSwordCrate, "Rarity"),
	PremiumSwordCrate = crateToContainer(v2.PremiumSwordCrate, "Rarity"),
	NormalExplosionCrate = crateToContainer(v2.NormalExplosionCrate, "Rarity"),
	PremiumExplosionCrate = crateToContainer(v2.PremiumExplosionCrate, "Rarity"),
	DungeonSwordCrate = crateToContainer(v2.DungeonSwordCrate, "Items"),
	GenericCrate = function(_)
		return v.List.map(v6.Rewards, function(p, p2)
			return p.Reward, p2
		end)
	end
}))