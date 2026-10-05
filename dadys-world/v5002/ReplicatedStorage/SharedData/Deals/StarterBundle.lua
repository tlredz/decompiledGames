return {
	id = "StarterBundle",
	displayName = "Starter Bundle",
	enabled = true,
	delivery = {
		triggers = { "starterBundle" },
		durationSeconds = 604800,
		historyId = "StarterBundle_v1",
		mailType = "StarterBundleOffer",
		targets = "all",
		onExpiry = "remove"
	},
	display = {
		subject = "Starter Bundle!",
		message = table.concat({
			"",
			"A one-time welcome deal, just for you!",
			"",
			"<font color=\"#228B22\">Rodger</font> - normally 1,000 Ichor + 50% research on any Twisted.",
			"<font color=\"#228B22\">Research Map</font> <font color=\"#777777\">trinket</font> - normally 200 Ichor.",
			"Plus <font color=\"#228B22\">250 Ichor</font>!",
			"",
			"Already own Rodger or the Research Map? You'll get the equivalent Ichor instead."
		}, "\n"),
		image = "rbxassetid://70447053478214",
		iconAssetId = "rbxassetid://0",
		buttonText = "Purchase"
	},
	contents = {
		always = {
			{
				kind = "Coin",
				amount = 250
			}
		},
		items = {
			{
				kind = "Tower",
				id = "Rodger",
				displayName = "Rodger",
				ifOwned = {
					kind = "Coin",
					amount = 1000
				}
			},
			{
				kind = "Trinket",
				id = "ResearchMap",
				displayName = "Research Map",
				ifOwned = {
					kind = "Coin",
					amount = 200
				}
			}
		}
	},
	productKey = "STARTER_BUNDLE"
}