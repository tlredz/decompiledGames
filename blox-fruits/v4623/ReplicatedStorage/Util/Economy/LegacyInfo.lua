local LegacyInfo = require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local LegacyInfo2 = {
	Templates = {}
}
LegacyInfo2.Templates.Simple = {}

function LegacyInfo2.Templates.Simple.newRobuxItem(storageKey, p, flag: boolean?)
	local new = LegacyInfo.Class.new

	if type(storageKey) ~= "string" then
		storageKey = ItemId.getDataFromId(storageKey):unwrap().StorageKey
	end

	if type(flag) ~= "boolean" then
		flag = false
	end

	return (new("Robux", storageKey, flag, p))
end

return LegacyInfo2