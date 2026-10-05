local DeepConfig = {
	Sectors = {
		"1P-1",
		"1P-2",
		"1P-3",
		"1P-4",
		"1P-5"
	},
	SectorQuests = {
		["1P-1"] = {
			Quest = "Deep3_Core1",
			Core = "Hydro-Core",
			InstallObjective = 4
		},
		["1P-2"] = {
			Quest = "Deep3_Core2",
			Core = "Abyssal Lens",
			InstallObjective = 4
		},
		["1P-3"] = {
			Quest = "Deep3_Core3",
			Core = "Bioluminescent Battery",
			InstallObjective = 4
		},
		["1P-4"] = {
			Quest = "Deep3_Core4",
			Core = "Reinforced Housing",
			InstallObjective = 5
		},
		["1P-5"] = {
			Quest = "Deep4_MasterRelay",
			InstallObjective = 1
		}
	},
	BlackoutFlickerCount = 3,
	BlackoutFlickerInterval = 0.08,
	BlackoutMinDuration = 5,
	BlackoutMaxDuration = 10,
	BlackoutAtmosphereDensity = 0.98,
	BeaconActiveColor = Color3.fromRGB(180, 113, 87)
}

function DeepConfig.IsSector(p: string)
	return table.find(DeepConfig.Sectors, p) ~= nil
end

return DeepConfig