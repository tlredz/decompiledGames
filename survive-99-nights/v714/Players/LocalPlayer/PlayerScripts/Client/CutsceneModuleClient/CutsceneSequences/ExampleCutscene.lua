return {
	{
		Action = "LoadSet",
		SetName = "CultistsArriving"
	},
	{
		Action = "Function",
		Callback = function(p)
			local cultist1 = p.Set.ExampleSet.Cultist1
			cultist1.NPC:LoadAnimation(cultist1.Animations.Run):Play()
		end
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			-46.6961746,
			-68.1368179,
			-38.3072433,
			-0.999886036,
			0.00585238263,
			-0.0139198303,
			-0,
			0.921838999,
			0.387573242,
			0.0151000684,
			0.387529075,
			-0.921733856
		)
	},
	{
		Action = "FadeIn",
		Duration = 2
	},
	{
		Action = "Pause",
		Duration = 3
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "ReturnCamera"
	},
	{
		Action = "FadeIn",
		Duration = 2
	}
}