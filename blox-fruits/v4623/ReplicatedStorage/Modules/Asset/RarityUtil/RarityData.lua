local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local colors = {
	[PseudoEnum.Rarity.Common] = Color3.fromRGB(179, 179, 179),
	[PseudoEnum.Rarity.Uncommon] = Color3.fromRGB(92, 140, 211),
	[PseudoEnum.Rarity.Rare] = Color3.fromRGB(140, 82, 255),
	[PseudoEnum.Rarity.Legendary] = Color3.fromRGB(213, 43, 228),
	[PseudoEnum.Rarity.Mythical] = Color3.fromRGB(238, 47, 50),
	[PseudoEnum.Rarity.Premium] = Color3.fromRGB(221, 188, 0)
}
local v = { PseudoEnum.Rarity.Mythical, PseudoEnum.Rarity.Premium }
local RarityData = {}

for _, name in PseudoEnum.getEnumItems("Rarity") do
	local valueFromEnumItem = PseudoEnum.getValueFromEnumItem("Rarity", name)
	RarityData[valueFromEnumItem] = {
		Value = valueFromEnumItem,
		Name = name,
		Color = colors[name],
		Outline = table.find(v, name) ~= nil
	}
end

TableUtil.deepFreeze(RarityData)
return RarityData