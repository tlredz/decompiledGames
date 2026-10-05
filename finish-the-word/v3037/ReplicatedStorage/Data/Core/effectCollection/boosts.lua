local Boosts = {}

for k, flat in pairs({
	WinMult = 1,
	StreakMult = 1,
	CashMult = 1,
	XpMult = 1
}) do
	Boosts[k] = {
		Default = {
			Flat = flat,
			Mult = 1
		},
		reduce = function(p, p2)
			local value = p2.Value
			return {
				Flat = p.Flat + value.Flat,
				Mult = p.Mult * value.Mult
			}
		end,
		apply = function() end
	}
end

return Boosts