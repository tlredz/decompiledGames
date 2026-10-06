return {
	Index = 2,
	Icon = "rbxassetid://111947316002334",
	Description = "Adjust the game performance",
	List = {
		{
			Name = "Low Mode",
			Description = "Increase the performance reducting the quality",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Distant Entities Quality",
			Description = "How smoothly far enemies and fighters update (lower is faster)",
			Type = "Slider",
			Default = 50,
			Minimum = 0,
			Maximum = 100
		},
		{
			Name = "Show My Skills",
			Description = "Show your own skills",
			Type = "Toggle",
			Default = true
		},
		{
			Name = "Show Other Skills",
			Description = "Show skills from other players",
			Type = "Toggle",
			Default = true
		},
		{
			Name = "Hide My Accessories",
			Description = "Hide your own equipped accessories",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Hide Other Accessories",
			Description = "Hide equipped accessories from other players",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Hide Other Fighters",
			Description = "Hide fighters from other players",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Show Auto Attack Range",
			Description = "Show your auto attack range on the ground",
			Type = "Toggle",
			Default = true
		},
		{
			Name = "Hide My Haki",
			Description = "Hide your own haki effect",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Hide Other Haki",
			Description = "Hide haki effects from other players",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Hide Weather Effects",
			Description = "Hide weather effects and lighting changes",
			Type = "Toggle",
			Default = false
		},
		{
			Name = "Hide Damage Popups",
			Description = "Hide damage numbers above enemies",
			Type = "Toggle",
			Default = false
		}
	}
}