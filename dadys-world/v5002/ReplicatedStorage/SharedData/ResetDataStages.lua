local ResetDataStages = {}
local STAGES = {
	{
		value = 0,
		displayName = "0 — Brand new (full reset)",
		description = "Cleanest state; FTUE runs from scratch with no retrofit.",
		data = {}
	},
	{
		value = 1,
		displayName = "1 — Picked Poppy, left game",
		description = "Owns Poppy only; expected retrofit → step 6 (ToonConfirmed).",
		data = {
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" }
			},
			SelectedCharacter = "Poppy"
		}
	},
	{
		value = 2,
		displayName = "2 — Poppy + 1 floor, 50 ichor, 1 gen",
		description = "Mid-onboarding legacy player; expected retrofit → step 17 (GamePlaceEntered).",
		data = {
			Coin = 50,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" }
			},
			SelectedCharacter = "Poppy",
			["Statistics.FloorsTraveled"] = 1,
			["Statistics.GeneratorsCompleted"] = 1,
			["Statistics.TotalIchorEarned"] = 50
		}
	},
	{
		value = 3,
		displayName = "3 — Poppy + 5 floors, 150 ichor, 3 gens",
		description = "More legacy progress; missions not all complete (no 2nd toon). Expected → step 17.",
		data = {
			Coin = 150,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" }
			},
			SelectedCharacter = "Poppy",
			["Statistics.FloorsTraveled"] = 5,
			["Statistics.GeneratorsCompleted"] = 3,
			["Statistics.TotalIchorEarned"] = 150
		}
	},
	{
		value = 4,
		displayName = "4 — Poppy + shoes, 10 floors, 200 ichor, 10 gens",
		description = "Has trinket but still single-toon. Expected → step 17.",
		data = {
			Coin = 200,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 10,
			["Statistics.GeneratorsCompleted"] = 10,
			["Statistics.TotalIchorEarned"] = 200
		}
	},
	{
		value = 5,
		displayName = "5 — +Boxten, 220 ichor",
		description = "All inferred missions complete. Expected retrofit → step 27 (BloomCompleted).",
		data = {
			Coin = 220,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" },
				{ "Boxten", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 15,
			["Statistics.GeneratorsCompleted"] = 15,
			["Statistics.TotalIchorEarned"] = 220
		}
	},
	{
		value = 6,
		displayName = "6 — +Boxten, 300 ichor",
		description = "Past bloom, partway through blossoming. Expected → step 27.",
		data = {
			Coin = 300,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" },
				{ "Boxten", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 15,
			["Statistics.GeneratorsCompleted"] = 15,
			["Statistics.TotalIchorEarned"] = 300
		}
	},
	{
		value = 7,
		displayName = "7 — +Boxten, 600 ichor",
		description = "Mid-blossoming. Expected → step 27.",
		data = {
			Coin = 600,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" },
				{ "Boxten", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 15,
			["Statistics.GeneratorsCompleted"] = 15,
			["Statistics.TotalIchorEarned"] = 600
		}
	},
	{
		value = 8,
		displayName = "8 — +Boxten, 900 ichor (most noobs sit here or below)",
		description = "Close to graduation threshold. Expected → step 27.",
		data = {
			Coin = 900,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" },
				{ "Boxten", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 15,
			["Statistics.GeneratorsCompleted"] = 15,
			["Statistics.TotalIchorEarned"] = 900
		}
	},
	{
		value = 9,
		displayName = "9 — +Boxten, 1100 ichor (most experienced sit here or above)",
		description = "Past 1000 ichor threshold. Expected retrofit → step 32 (BlossomingThresholdReached).",
		data = {
			Coin = 1100,
			SeenTutorial = true,
			Towers = {
				{ "Poppy", "Default" },
				{ "Boxten", "Default" }
			},
			SelectedCharacter = "Poppy",
			Trinkets = { "SpeedShoes" },
			EquippedTrinket1 = "SpeedShoes",
			["Statistics.FloorsTraveled"] = 15,
			["Statistics.GeneratorsCompleted"] = 15,
			["Statistics.TotalIchorEarned"] = 1100
		}
	}
}
ResetDataStages.STAGES = STAGES

function ResetDataStages.Get(p: number?)
	if p == nil then
		return nil
	end

	for _, v2 in ipairs(STAGES) do
		if v2.value == p then
			return v2
		end
	end

	return nil
end

function ResetDataStages.GetOptions()
	local result = {}

	for _, v2 in ipairs(STAGES) do
		result[#result + 1] = {
			Key = tostring(v2.value),
			DisplayName = v2.displayName
		}
	end

	return result
end

local function setPath(p, value, p2)
	local v2 = string.split(value, ".")

	for i = 1, #v2 - 1 do
		local v3 = v2[i]

		if type(p[v3]) ~= "table" then
			p[v3] = {}
		end

		p = p[v3]
	end

	p[v2[#v2]] = p2
end

function ResetDataStages.ApplyTo(p, p2: number?)
	local v2 = ResetDataStages.Get(p2)

	if not v2 then
		return false, string.format("Unknown stage %s", (tostring(p2)))
	end

	if type(p) ~= "table" then
		return false, "profileData must be a table"
	end

	for k, v3 in pairs(v2.data) do
		setPath(p, k, v3)
	end

	return true, v2.displayName
end

return ResetDataStages