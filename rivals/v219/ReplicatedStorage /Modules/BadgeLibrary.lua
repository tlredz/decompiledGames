local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BadgeLibrary = {
	Info = {},
	Order = {},
	LookupID = {}
}
local v = {}
local v2 = {}

local function add_badge(section, name, badgeID, rewards, isHidden, p6)
	if p6 and CONSTANTS.IS_CLIENT then
		return
	end

	local v3 = {
		Name = name,
		Section = section,
		BadgeID = badgeID,
		Rewards = rewards,
		IsHidden = isHidden
	}
	BadgeLibrary[section] = BadgeLibrary[section] or {}
	BadgeLibrary[section][name] = v3
	BadgeLibrary.Info[name] = v3
	BadgeLibrary.LookupID[tostring(badgeID)] = v3
	table.insert(BadgeLibrary.Order, name)

	if CONSTANTS.IS_SERVER then
		if badgeID == 0 then
			warn("[BADGE] Badge ID missing: " .. section .. name)
		end

		if v[tostring(badgeID)] and badgeID > 0 then
			warn("[BADGE] Duplicate badge ID: " .. badgeID)
		else
			v[tostring(badgeID)] = true
		end

		if v2[name] then
			warn("[BADGE] Duplicate badge section & name: " .. section .. name)
		else
			v2[name] = true
		end
	end
end

add_badge("Misc", "Welcome", 2904819966736756)
add_badge("Misc", "AlphaTesterTesting", 1651092271685623)
add_badge("Misc", "AlphaTester", 1330297521556384, {
	{
		Name = "Alpha Coin",
		Weapon = "IsUniversal"
	}
})
add_badge("SpecialChallenge", "2024WinterSpotlight1", 3550066675718)
add_badge("SpecialChallenge", "2024WinterSpotlight2", 3480019912304713)
add_badge("SpecialChallenge", "TheHuntMegaEdition1", 2472187632273965)
add_badge("SpecialChallenge", "TheHuntMegaEdition2", 2731731095831523)
return BadgeLibrary