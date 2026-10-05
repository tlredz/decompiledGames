local gameSettings = require(script.Parent.Global.gameSettings)
local minimap = {
	Image = {
		{
			"rbxassetid://122726915559820",
			"rbxassetid://126478315213404",
			"rbxassetid://83854516599440",
			"rbxassetid://135846092739063"
		},
		{
			"rbxassetid://100760495545423",
			"rbxassetid://75844099380860",
			"rbxassetid://112548642468767",
			"rbxassetid://74129545153354"
		},
		{
			"rbxassetid://94267737571637",
			"rbxassetid://86566116521928",
			"rbxassetid://117953739036731",
			"rbxassetid://124509291942928"
		},
		{
			"rbxassetid://80660300812124",
			"rbxassetid://74694360341608",
			"rbxassetid://120088468476283",
			"rbxassetid://78889280949062"
		}
	},
	TopLeft = {
		X = -3087.361,
		Z = -3989.256
	},
	BottomRight = {
		X = 2977.139,
		Z = 1635.244
	}
}
local Worlds = {
	Grid = {
		["Test Place"] = {
			Id = 17047024836,
			RequiredGroup = {
				Id = 12851171,
				Rank = 3
			},
			Minimap = {
				Image = "rbxassetid://77255534096018",
				TopLeft = {
					X = 1020,
					Z = 1023
				},
				BottomRight = {
					X = -1024,
					Z = -1022
				}
			},
			Icon = "rbxassetid://85111783817768",
			Browsable = true,
			BiwaBellEnabled = true,
			PrivateServerHostable = true,
			SunDamage = true,
			NoPvpSwitch = true,
			NoDayNight = true
		},
		Ouwland = {
			Id = 136406881576517,
			Minimap = minimap,
			Icon = "rbxassetid://113581254918526",
			Browsable = true,
			BiwaBellEnabled = true,
			PrivateServerHostable = true,
			SunDamage = true,
			SpawnAnywhere = true,
			NoPvpSwitch = true
		},
		["Ouwland Test"] = {
			Id = 130395143593224,
			RequiredGroup = {
				Id = 12851171,
				Rank = 3
			},
			Minimap = minimap,
			Icon = "rbxassetid://113581254918526",
			Browsable = true,
			BiwaBellEnabled = true,
			PrivateServerHostable = true,
			SunDamage = true,
			SpawnAnywhere = true,
			NoPvpSwitch = true
		},
		["Main Menu"] = {
			Id = 16205713724,
			Icon = "",
			Ignore = true,
			BanPartyTeleport = true
		},
		Minigames = {
			Id = gameSettings.HUDQueuPlaceId,
			Icon = "",
			Ignore = true,
			BanPartyTeleport = true,
			NoPvpSwitch = true
		}
	},
	ById = {},
	ByName = {}
}

for k, v2 in Worlds.Grid do
	v2.Name = k
	Worlds.ByName[k] = v2
	Worlds.ById[v2.Id] = v2
end

function Worlds.MeetsRequirements(p, data, instance)
	local requiredGroup = data.RequiredGroup

	if requiredGroup ~= nil then
		local success, rankInGroup = pcall(p.GetRankInGroup, p, requiredGroup.Id)

		if not success or rankInGroup < requiredGroup.Rank then
			return false, (`You don't have access to {data.Name}.`)
		end
	end

	local requiredLevel = data.RequiredLevel

	if requiredLevel == nil then
		return true
	end

	local exp

	if instance ~= nil then
		exp = instance:FindFirstChild("Exp")
	end

	local goal

	if exp ~= nil then
		goal = exp:FindFirstChild("Goal")
	end

	if goal == nil or goal.Value / gameSettings.expPerLevel < requiredLevel then
		return false, (`You need to be level {requiredLevel} to play {data.Name}.`)
	end

	return true
end

function Worlds.CanSee(p, p2, p3)
	return (Worlds.MeetsRequirements(p, p2, p3))
end

function Worlds.IsMenuPlace()
	local mainMenu = Worlds.ByName["Main Menu"]
	return mainMenu ~= nil and game.PlaceId == mainMenu.Id or workspace:GetAttribute("IsMenu") == true
end

return Worlds