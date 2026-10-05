local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "DeerDraggingWolf"
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "Function",
		Callback = function(p)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()
			local deer = p.Set.DeerDraggingWolf.Deer
			deer.NPC:LoadAnimation(deer.Animations.DragWolf):Play()
			deer.HumanoidRootPart.Anchored = true
			UtilityAlec.tweenModel(deer, deer:GetPivot() * CFrame.new(0, 0, -11), 5, Enum.EasingStyle.Linear)
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
			88.3508682,
			-97.6391983,
			12.434515,
			-0.0559015498,
			-0.0627679974,
			0.996461391,
			2.32830616e-10,
			0.99802202,
			0.0628663003,
			-0.998436272,
			0.00351432385,
			-0.0557909794
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
			ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
		end
	}
}