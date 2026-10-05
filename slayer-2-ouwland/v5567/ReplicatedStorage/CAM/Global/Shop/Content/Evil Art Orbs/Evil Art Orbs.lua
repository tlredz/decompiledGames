local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local evilArt = Spinners.EvilArt
local odds = evilArt.Odds()
local EvilArtOrbs = {}

for _, v in evilArt.Pool() do
	local odd = odds[v]

	if odd == nil or odd <= 0 then
		continue
	end

	EvilArtOrbs[`{v} Orb`] = {
		Type = Menum.ShopItemType.IngameItem,
		Price = {
			Spins = math.ceil(evilArt.Cost / odd - 1e-6)
		},
		AutoEquip = true,
		Shout = {
			Icon = BunchaIcons.MuzanIcon,
			Text = MuzanSettings.OrbShoutText,
			Duration = MuzanSettings.GrantShoutDuration
		}
	}
end

return EvilArtOrbs