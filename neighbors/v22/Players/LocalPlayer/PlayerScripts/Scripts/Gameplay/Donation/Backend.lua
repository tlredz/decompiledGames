local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local Donation = require(ReplicatedStorage.Modules.Donation)
local v = {
	[100] = 4,
	[500] = 5,
	[1000] = 10,
	[3000] = 20,
	[5000] = 30,
	[10000] = 40,
	[20000] = 50
}

local function getDonationCountFromAmount(p: number)
	local v2 = 2

	for k, v3 in next, v, nil do
		if k <= p then
			v2 = math.max(v2, v3)
		end
	end

	return v2
end

Network:listen("DonationEffect", function(player, player2, p: number)
	local character = player and player.Character
	local character2 = player2 and player2.Character

	if player2 and character and character2 and character.PrimaryPart and character2.PrimaryPart then
		Donation:HighlightPlayer(player2, 5)
		local primaryPart = character.PrimaryPart
		local primaryPart2 = character2.PrimaryPart
		local v3 = 2

		for k, v4 in next, v, nil do
			if k <= p then
				v3 = math.max(v3, v4)
			end
		end

		Donation:SendSeries(primaryPart, primaryPart2, v3)
	end
end)