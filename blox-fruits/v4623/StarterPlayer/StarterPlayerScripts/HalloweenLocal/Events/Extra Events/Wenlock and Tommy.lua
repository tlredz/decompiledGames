local WenlockAndTommy = {}
WenlockAndTommy.Name = "PumpkinPrize"
WenlockAndTommy.Type = "Treat"
WenlockAndTommy.BaseCandy = 25

function WenlockAndTommy.Server(p, _)
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

function WenlockAndTommy.Client(_, _) end

return WenlockAndTommy