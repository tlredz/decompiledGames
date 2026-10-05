local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "MandrakeSeed"
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
				wait(6)
				task.spawn(function()
					for _, child in pairs(p.Set.MandrakeSeed.SeedSpots:GetChildren()) do
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
						child.SaplingPlant:Play()
						wait(0.05)
					end
				end)
				wait(2)
				Client.PopUpUI.AddPopUp("planted seeds near the halloween houses")
			end)
		end
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			-87.893959,
			-370.179657,
			107.859917,
			0.381181896,
			0.687057316,
			-0.618589342,
			-1.49011612e-8,
			0.669106841,
			0.743166268,
			0.924500108,
			-0.283281535,
			0.255051434
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