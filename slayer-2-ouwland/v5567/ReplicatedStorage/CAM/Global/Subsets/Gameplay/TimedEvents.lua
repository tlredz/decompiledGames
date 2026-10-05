local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

local function every(p: number, p2: number)
	if isStudio then
		return p2
	end

	return p
end

return {
	FinalSelection = {
		Title = "Final Selection",
		Every = isStudio and 30 or 7200,
		Requirements = {
			Race = "Human",
			Level = 45
		}
	},
	TailorRestock = {
		Title = "Restock",
		Every = 3600,
		DisappearDistance = 80
	},
	BlackMarketArrival = {
		Title = "Black Market",
		Every = 7200
	},
	BossHunt = {
		Title = "Boss Hunt",
		Every = isStudio and 30 or 120
	}
}