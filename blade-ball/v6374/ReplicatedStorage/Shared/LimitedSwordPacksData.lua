local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils)
require3(script.Types)
local v = require3(script.BundleToPack)
local rewardsByGiftName = require3(script.GiftToBundle)
local v2 = {}

for _, module in script.Packs:QueryDescendants("ModuleScript:not(#TEMPLATE)") do
	local v4, v5, v6 = string.match(module.Name, "^(%d%d)-(%d%d)-(%d%d%d%d)")

	if not (v4 and v5 and v6) then
		warn((`[!!] Invalid date provided for pack {module.Name}`))
	end

	local success, result = pcall(DateTime.fromIsoDate, (`{v6}-{v4}-{v5}`))

	if not (success and result) then
		warn((`[!!] Failed to parse provided date for pack {module.Name}`))
	end

	table.insert(v2, {
		Module = module,
		DateTime = success and result or DateTime.fromUnixTimestamp(0)
	})
end

table.sort(v2, function(a, b)
	return a.DateTime.UnixTimestamp + (a.Module:GetAttribute("ExtraTime") or 0) > b.DateTime.UnixTimestamp + (b.Module:GetAttribute("ExtraTime") or 0)
end)
local LimitedSwordPacksData = {}

for _, v3 in v2 do
	local dateTime = v3.DateTime
	local v4 = require3(v3.Module)

	if v4.Disabled then
		continue
	end

	for _, v5 in v4 do
		v5.ModuleDateTime = dateTime

		if v5.Rewards then
			for _, reward in v5.Rewards do
				v[reward.Name] = v5

				if reward.Rewards then
					for _, reward2 in reward.Rewards do
						if reward2.GiftName then
							rewardsByGiftName[reward2.GiftName] = reward
						elseif not reward2.IgnoreMarket then
							warn((`[!!] Bundle {reward.Name} has no gift name`))
						end
					end
				else
					warn((`[!!] Bundle {reward.Name} has no rewards`))
				end
			end
		else
			warn((`[!!] Pack {v3.Module.Name} has no rewards`))
		end
	end

	table.move(v4, 1, #v4, #LimitedSwordPacksData + 1, LimitedSwordPacksData)
end

return LimitedSwordPacksData