local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "PlantExample"
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
				wait(6)
				task.spawn(function()
					if not p.Set:FindFirstChild("PlantExample") then
						return
					end

					for _, child in pairs(p.Set.PlantExample.SeedSpots:GetChildren()) do
						if child.Name ~= "SeedSpot" then
							continue
						end

						child.Transparency = 0.35
						TweenService:Create(
							child,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Size = createVector(0.1, 2.5, 2.5)
							}
						):Play()

						if child:FindFirstChild("SaplingPlant") then
							child.SaplingPlant:Play()
						end

						wait(0.05)
					end
				end)
				wait(2)
				Client.PopUpUI.AddPopUp("planted seeds all over the map")
			end)
		end
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			-74.5807571,
			-790.961548,
			286.911774,
			0.0630021468,
			-0.985723674,
			0.156139702,
			-0,
			0.15645051,
			0.9876858,
			-0.998013437,
			-0.0622263253,
			0.00985671673
		)
	},
	{
		Action = "Pause",
		Duration = 8
	},
	{
		Action = "ReturnCamera"
	}
}