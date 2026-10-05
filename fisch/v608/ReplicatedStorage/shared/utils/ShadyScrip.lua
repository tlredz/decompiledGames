local ShadyScrip = {
	CurrencyKey = "Shady Scrip",
	GhostRewardDivisor = 300
}

function ShadyScrip.FromCoins(p: number)
	return (math.floor(p / ShadyScrip.GhostRewardDivisor))
end

return ShadyScrip