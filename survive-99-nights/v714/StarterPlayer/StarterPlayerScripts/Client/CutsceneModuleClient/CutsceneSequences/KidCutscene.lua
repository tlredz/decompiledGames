local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "KidCutscene"
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "Function",
		Callback = function(p)
			local lostChild = p.Set.KidCutscene["Lost Child"]
			local track = lostChild.NPC:LoadAnimation(lostChild.Animations.LostAnim)
			lostChild.Head.KidCrying:Play()
			track:Play()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			ReplicatedStorage2:WaitForChild("Core"):WaitForChild("Sounds"):WaitForChild("HorrorMusic"):Play()
		end
	},
	{
		Action = "MakeNote",
		Message = "Somewhere, deep in the forest...",
		Timer = 2
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			-445.571533,
			-147.388718,
			27.0455933,
			0.000139277923,
			-0.166702211,
			0.986007333,
			-1.8189894e-12,
			0.986007333,
			0.166702211,
			-1,
			-0.0000232179391,
			0.000137329058
		)
	},
	{
		Action = "FadeIn",
		Duration = 1.5
	},
	{
		Action = "Pause",
		Duration = 4.1
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
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			ReplicatedStorage2:WaitForChild("Core"):WaitForChild("Sounds"):WaitForChild("HorrorMusic"):Stop()
		end
	}
}