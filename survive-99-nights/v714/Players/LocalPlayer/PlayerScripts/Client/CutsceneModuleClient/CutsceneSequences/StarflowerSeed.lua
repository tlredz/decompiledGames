local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "StarflowerSeed"
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
				wait(6)
				task.spawn(function()
					for _, child in pairs(p.Set.StarflowerSeed.SeedSpots:GetChildren()) do
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
				Client.PopUpUI.AddPopUp("planted seeds all over the map")
			end)
		end
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			39.1648216,
			-172.788849,
			72.1230698,
			0.729052424,
			0.626752794,
			-0.275070071,
			-0,
			0.401880234,
			0.91569227,
			0.684457898,
			-0.667587698,
			0.292991757
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