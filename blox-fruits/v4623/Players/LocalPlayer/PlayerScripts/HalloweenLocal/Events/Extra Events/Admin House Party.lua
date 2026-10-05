local AdminHouseParty = {}
AdminHouseParty.Name = "PumpkinPrize"
AdminHouseParty.Type = "Treat"
AdminHouseParty.BaseCandy = 25

function AdminHouseParty.Server(p, _)
	local Global = require(game.ReplicatedStorage.Global)
	local wrappedPlayer = Global.getWrappedPlayer(p)
	local Global2 = require(game.ReplicatedStorage.Global)
	local data = Global2.session[p].Data
	data.HalloweenEvent2025 = data.HalloweenEvent2025 or {
		LastEvent = os.time(),
		CandyCollected = 0
	}
	local halloweenEvent2025 = data.HalloweenEvent2025

	if halloweenEvent2025.LastEvent ~= os.time() // 3600 then
		halloweenEvent2025.LastEvent = os.time() // 3600
		halloweenEvent2025.CandyCollected = 0
	end

	local v = math.floor(math.clamp(1 - halloweenEvent2025.CandyCollected / 2000, 0.25, 1) * 25)
	halloweenEvent2025.CandyCollected += v
	wrappedPlayer:AwardEtcItems("Candy Corn", v)
end

function AdminHouseParty.Client(_, _) end

return AdminHouseParty