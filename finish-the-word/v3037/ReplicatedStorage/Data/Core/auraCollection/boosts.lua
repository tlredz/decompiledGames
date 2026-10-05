local Boosts = {}

for _, v in pairs({
	"WinMult",
	"StreakMult",
	"CashMult",
	"XpMult"
}) do
	local v2 = v

	Boosts[v] = function(data)
		return {
			Duration = data.Duration,
			EffectInstances = {
				[v2] = {
					Value = {
						Flat = data.Flat or 0,
						Mult = data.Mult or 1
					}
				}
			}
		}
	end
end

return Boosts