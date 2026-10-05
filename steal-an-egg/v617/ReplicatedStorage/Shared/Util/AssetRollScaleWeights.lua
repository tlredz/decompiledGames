local frozen = table.freeze({
	table.freeze({
		low = 1,
		high = 1.01,
		weight = 250
	}),
	table.freeze({
		low = 0.48,
		high = 0.5,
		weight = 45.17
	}),
	table.freeze({
		low = 0.24,
		high = 0.25,
		weight = 17.09
	}),
	table.freeze({
		low = 1.49,
		high = 1.5,
		weight = 4.27
	}),
	table.freeze({
		low = 1.99,
		high = 2,
		weight = 0.1857
	})
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind(
	"Game.Balance.AssetScaleBands",
	frozen,
	true,
	false,
	function(items)
		local total = 0

		for _, item in items do
			local v

			if item.low > 0 then
				v = item.high >= item.low
			else
				v = false
			end

			assert(v)
			total += item.weight
		end

		assert(total > 0)
	end
)