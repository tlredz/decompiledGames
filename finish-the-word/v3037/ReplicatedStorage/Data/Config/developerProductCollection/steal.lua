local MessagingService = game:GetService("MessagingService")
local import = _G.import("global")
local import2 = _G.import("configuration")
local Steal = {}

for k, amount in pairs({
	p3596878467 = 500,
	p3596878473 = 1000,
	p3596878479 = 2500,
	p3596878486 = 5000,
	p3596878489 = 10000
}) do
	local amount2 = amount
	Steal[k] = {
		Amount = amount,
		Server = function(p, p2, p3, p4)
			local DataStoreService = game:GetService("DataStoreService")
			local dataStore = DataStoreService:GetDataStore("TEST_" .. import2.DataVersion)
			local stealTarget = p4.StealTarget

			if not stealTarget then
				return false
			end

			p3.Statistics:plus("Cash", amount2)
			local playerByUserId = game.Players:GetPlayerByUserId(stealTarget)

			if playerByUserId then
				local playerSave = import.get("playerSave", playerByUserId)
				playerSave.Statistics:replicate("Cash", (math.max(0, playerSave.Statistics.Cash - amount2)))
			else
				dataStore:UpdateAsync(stealTarget, function(p5)
					p5.Statistics.Cash -= amount2
				end)
				MessagingService:PublishAsync("steal", {
					StealTarget = stealTarget,
					Amount = amount2
				})
			end

			return true
		end
	}
end

return Steal