local parentModule = require(script.Parent)
local v = {
	List = {
		Fire = {
			Icon = "rbxassetid://93795088426216",
			Description = "Chance to burn enemies."
		},
		Water = {
			Icon = "rbxassetid://99291196688389",
			Description = "Chance to strike twice."
		},
		Lightning = {
			Icon = "rbxassetid://120379036001688",
			Description = "Chain lightning to nearby enemies."
		},
		Ice = {
			Icon = "rbxassetid://116096969598314",
			Description = `Slows enemies; explodes at {parentModule.Config.Ice.MaxStacks} stacks.`
		},
		Wind = {
			Icon = "rbxassetid://78699451267448",
			Description = "Faster movement and attacks."
		},
		Earth = {
			Icon = "rbxassetid://129986113333715",
			Description = "More damage; slower attacks."
		},
		Poison = {
			Icon = "rbxassetid://121499269601756",
			Description = "Chance to poison enemies."
		},
		Light = {
			Icon = "rbxassetid://100901963087791",
			Description = "Temporary attack and movement boost."
		},
		Dark = {
			Icon = "rbxassetid://80747637803833",
			Description = "Temporary damage and speed swings."
		},
		Physical = {
			Icon = "rbxassetid://119583443989638",
			Description = "More frequent, stronger criticals."
		}
	}
}

function v.Get(p)
	local v2 = parentModule.Normalize(p)[1]

	if v2 then
		return v.List[v2], v2
	end

	return nil
end

return table.freeze(v)