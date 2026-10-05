game:GetService("TweenService")
return {
	{
		Action = "LoadSet",
		SetName = "CaveScene"
	},
	{
		Action = "Function",
		Callback = function(p)
			game.ReplicatedStorage.Core.Sounds.HorrorMusic:Play()

			for _, child in pairs(p.Set.CaveScene:GetChildren()) do
				if not (child.Name == "Cultist" and child:FindFirstChild("HumanoidRootPart")) then
					continue
				end

				local v = child.NPC:LoadAnimation(child.Animations.Bow)
				task.spawn(function()
					wait(Random.new():NextNumber(0, 1.9))
					v:Play(0.1, 1, 0.6)
				end)
			end

			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			ReplicatedStorage:WaitForChild("Core"):WaitForChild("Sounds"):WaitForChild("HorrorMusic"):Play()
		end
	},
	{
		Action = "Pause",
		Duration = 2
	},
	{
		Action = "FadeOut",
		Duration = 2
	},
	{
		Action = "MakeNote",
		Message = "Somewhere, deep in the forest...",
		Timer = 3
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			14.7562075,
			-93.5321884,
			-45.7291183,
			-0.990292132,
			-0.0338671505,
			0.134813309,
			-0,
			0.969864666,
			0.243644714,
			-0.139002204,
			0.241279438,
			-0.960449219
		)
	},
	{
		Action = "FadeIn",
		Duration = 1.5
	},
	{
		Action = "Pause",
		Duration = 5
	},
	{
		Action = "FadeOut",
		Duration = 1.5
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
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			ReplicatedStorage:WaitForChild("Core"):WaitForChild("Sounds"):WaitForChild("HorrorMusic"):Stop()
		end
	}
}