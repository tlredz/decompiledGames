local CurrencyMigration = {
	RATE = 100
}

function CurrencyMigration.DoubloonsToCoins(p: number)
	return p * CurrencyMigration.RATE
end

return CurrencyMigration