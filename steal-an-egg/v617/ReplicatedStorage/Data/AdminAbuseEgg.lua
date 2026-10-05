local AdminAbuseEgg = {}
AdminAbuseEgg.EggDisplayName = "Demonic Egg"
AdminAbuseEgg.DropTable = {
	{ "Demon Imp", 42 }
}

function AdminAbuseEgg.IsEventCategory(p: string?)
	if p == nil then
		return false
	end

	for _, v in AdminAbuseEgg.DropTable do
		if v[1] == p then
			return true
		end
	end

	return false
end

function AdminAbuseEgg.GetTotalWeight()
	local total = 0

	for _, v in AdminAbuseEgg.DropTable do
		total += v[2]
	end

	return total
end

function AdminAbuseEgg.Roll(p)
	local v = p or Random.new()
	local totalWeight = AdminAbuseEgg.GetTotalWeight()

	if totalWeight <= 0 then
		return AdminAbuseEgg.DropTable[1][1]
	end

	local v2 = v:NextNumber() * totalWeight
	local total = 0

	for _, v3 in AdminAbuseEgg.DropTable do
		total += v3[2]

		if v2 <= total then
			return v3[1]
		end
	end

	return AdminAbuseEgg.DropTable[#AdminAbuseEgg.DropTable][1]
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
AdminAbuseEgg = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind(
	"Game.Balance.AdminAbuseEgg",
	AdminAbuseEgg,
	{
		DropTable = true
	},
	false,
	function(p)
		local total = 0

		for _, v in p.DropTable do
			total += v[2]
		end

		assert(total > 0)
	end
)
return AdminAbuseEgg