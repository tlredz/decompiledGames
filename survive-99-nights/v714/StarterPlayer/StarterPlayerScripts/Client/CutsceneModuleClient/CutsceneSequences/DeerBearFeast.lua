local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	{
		Action = "LoadSet",
		SetName = "DeerBearFeast"
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "Function",
		Callback = function(p)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()
			local deer = p.Set.DeerBearFeast.Deer
			deer.NPC:LoadAnimation(deer.Animations.Feast):Play()
		end
	},
	{
		Action = "MakeNote",
		Message = "Somewhere, deep in the forest...",
		Timer = 3
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			49.3926468,
			-109.911743,
			6.63162374,
			0.354927331,
			0.00977889448,
			0.934842825,
			-0,
			0.999945402,
			-0.0104598971,
			-0.934893966,
			0.00371250347,
			0.3549079
		)
	},
	{
		Action = "FadeIn",
		Duration = 1.5
	},
	{
		Action = "Pause",
		Duration = 3.2
	},
	{
		Action = "FadeOut",
		Duration = 1
	},
	{
		Action = "ReturnCamera"
	},
	{
		Action = "FadeIn",
		Duration = 2
	},
	{
		Action = "Function",
		Callback = function(_)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
		end
	}
}