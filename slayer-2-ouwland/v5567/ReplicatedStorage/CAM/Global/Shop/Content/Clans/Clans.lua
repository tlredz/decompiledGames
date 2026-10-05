local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local clan = Spinners.Clan
local odds = clan.Odds()
local Clans = {}

for _, clan2 in clan.Pool() do
	local odd = odds[clan2]

	if odd == nil or odd <= 0 then
		continue
	end

	Clans[clan2] = {
		Type = Menum.ShopItemType.Clan,
		Clan = clan2,
		Price = {
			Spins = math.ceil(clan.Cost / odd)
		}
	}
end

return Clans