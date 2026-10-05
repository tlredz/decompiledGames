local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = {
	Explosion = { "Explosion Normal" },
	Emote = {
		"Emote1",
		"Emote2",
		"Emote3",
		"Emote4",
		"Emote5",
		"Emote6",
		"Emote7",
		"Emote14",
		"Emote293",
		"Emote300",
		"Emote298",
		"Emote299"
	},
	Sword = {
		"Base Sword",
		"InceptionTime's Hammer",
		"Nothing",
		"Pillar",
		"Small Sapling",
		"princ2",
		"Skib",
		"HardRockStick",
		"BAH",
		"Midas Thorn",
		"Stratocaster Electric Guitar",
		"Bobber",
		"Ultimate Ruby",
		"Pretty Princess Wand",
		"Princess Fan",
		"Godsaber",
		"COAL",
		"Alpha Mode",
		"Ancient Cutlass",
		"Great Axe",
		"Ancient Spear",
		"SentinelStaff",
		"Hallow's Wrath",
		"Dual Dragonfire Katana",
		"Ice Breaker",
		"Peppermint Slasher",
		"New Year's Edge",
		"Eggscalibur",
		"Guardian Blade",
		"Void Slicer",
		"Claymore of the Damned",
		"Regal Radianceblade",
		"Blight's Bane",
		"Tide Caller",
		"Arcane's Blade",
		"Veil's Descent",
		"Persistence Blade",
		"Sundered Skies",
		"Phoenix's Edge",
		"Griffon's Clasp",
		"Magic Wand",
		"giveable apex",
		"giveable champ",
		"Titan Blade",
		"RAPIER_PLACEHOLDER",
		"SpyderSammy",
		"Color Changing Sword Test",
		"Nightreign",
		"Retribution",
		"Hellfire Blade Level 1",
		"Hellfire Blade Level 2",
		"Apex Blade",
		"Champion Scythe"
	}
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
local result = require3(ReplicatedStorage2.Shared.DeepCopy)(v)

local function updateItems()
	local instantFFlag = v2.GetInstantFFlag("UntradableItems", {})

	for k, v3 in result do
		for _, v4 in v3 do
			if v[k] and table.find(v[k], v4) or not result[k] or not table.find(result[k], v4) then
				continue
			end

			if instantFFlag[k] and table.find(instantFFlag[k], v4) then
				continue
			end

			result[k] = result[k] or {}
			local index = table.find(result[k], v4)

			if index then
				table.remove(result[k], index)
			end
		end
	end

	for k, v3 in instantFFlag do
		for _, v4 in v3 do
			if v[k] and table.find(v[k], v4) or result[k] and table.find(result[k], v4) then
				continue
			end

			result[k] = result[k] or {}
			table.insert(result[k], v4)
		end
	end
end

v2.OnChange(updateItems)
task.spawn(updateItems)
return result