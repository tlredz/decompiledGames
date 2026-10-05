local modes = {
	beginner2v2 = {
		Mode = "beginner2v2",
		Text = "2 Plr",
		Description = "Play against 2 other people",
		Image = "rbxassetid://70566964510084",
		PlayerCount = 2
	},
	fourPlayer = {
		Mode = "fourPlayer",
		Text = "4 Plr",
		Description = "Play against 4 other people",
		Image = "rbxassetid://78924753025144",
		PlayerCount = 4
	},
	sixPlayer = {
		Mode = "sixPlayer",
		Text = "6 Plr",
		Description = "Play against 6 other people",
		Image = "rbxassetid://98865893437198",
		PlayerCount = 6
	},
	comingSoon1 = {
		Text = "",
		Image = "rbxassetid://70566964510084"
	},
	comingSoon2 = {
		Text = "",
		Image = "rbxassetid://70566964510084"
	},
	comingSoon3 = {
		Text = "",
		Image = "rbxassetid://70566964510084"
	}
}

local function setModeText(p)
	if not p.PlayerCount then
		return p
	end

	p.ModeText = string.format("%d Player Match", p.PlayerCount)
	return p
end

local ModesData = {
	DefaultImage = "rbxassetid://70566964510084",
	DefaultMode = "beginner2v2",
	LeftMode = "beginner2v2",
	TopModes = { "comingSoon1", "comingSoon2", "comingSoon3" },
	BottomModes = { "fourPlayer", "sixPlayer" },
	Modes = modes
}

for _, v2 in pairs(modes) do
	if v2.PlayerCount then
		v2.ModeText = string.format("%d Player Match", v2.PlayerCount)
	end
end

function ModesData.get(p)
	return modes[p or ModesData.DefaultMode]
end

function ModesData.getMany(list)
	local result = {}

	for i, v2 in ipairs(list) do
		result[i] = ModesData.get(v2)
	end

	return result
end

return ModesData