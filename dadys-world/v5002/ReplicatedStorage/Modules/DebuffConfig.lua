local DebuffConfig = {
	Definitions = {
		Slow = {
			displayName = "Slowness",
			icon = "rbxassetid://17887980484",
			color = Color3.fromRGB(158, 148, 44),
			refreshable = true,
			managedByManager = true,
			showInOverheadGui = true,
			isBuff = false
		},
		Tired = {
			displayName = "Tiredness",
			icon = "rbxassetid://17889130264",
			color = Color3.fromRGB(51, 158, 46),
			refreshable = true,
			managedByManager = true,
			showInOverheadGui = true,
			isBuff = false
		},
		Confused = {
			displayName = "Confusion",
			icon = "rbxassetid://17889450280",
			color = Color3.fromRGB(100, 52, 158),
			refreshable = false,
			managedByManager = true,
			showInOverheadGui = true,
			isBuff = false
		},
		Illness = {
			displayName = "Illness",
			icon = "rbxassetid://83230097328815",
			color = Color3.fromRGB(139, 69, 19),
			refreshable = true,
			managedByManager = true,
			showInOverheadGui = true,
			isBuff = false
		},
		TreadmillDazed = {
			displayName = "Dazed",
			icon = "rbxassetid://125152464787251",
			color = Color3.fromRGB(52, 91, 158),
			refreshable = false,
			managedByManager = true,
			showInOverheadGui = false,
			isBuff = false
		},
		Energized = {
			displayName = "Energized",
			icon = "rbxassetid://132742259361191",
			color = Color3.fromRGB(232, 252, 48),
			refreshable = false,
			managedByManager = false,
			showInOverheadGui = true,
			isBuff = true
		},
		Dazed = {
			displayName = "Dazed",
			icon = "rbxassetid://125152464787251",
			color = Color3.fromRGB(52, 91, 158),
			refreshable = false,
			managedByManager = false,
			showInOverheadGui = true,
			isBuff = false
		},
		Ignited = {
			displayName = "Ignited",
			icon = "rbxassetid://132742259361191",
			color = Color3.fromRGB(255, 96, 24),
			refreshable = false,
			managedByManager = false,
			showInOverheadGui = true,
			hideStageNumeral = true,
			isBuff = true
		}
	}
}

function DebuffConfig.Get(p)
	return DebuffConfig.Definitions[p]
end

function DebuffConfig.IsRefreshable(p)
	local definition = DebuffConfig.Definitions[p]
	return definition ~= nil and definition.refreshable == true
end

function DebuffConfig.ShowsInOverheadGui(p)
	local definition = DebuffConfig.Definitions[p]
	return definition ~= nil and definition.showInOverheadGui == true
end

function DebuffConfig.GetManagedNames()
	local result = {}

	for k, definition in pairs(DebuffConfig.Definitions) do
		if definition.managedByManager then
			table.insert(result, k)
		end
	end

	return result
end

function DebuffConfig.GetDisplayableNames()
	local result = {}

	for k, definition in pairs(DebuffConfig.Definitions) do
		if definition.showInOverheadGui then
			table.insert(result, k)
		end
	end

	return result
end

return DebuffConfig