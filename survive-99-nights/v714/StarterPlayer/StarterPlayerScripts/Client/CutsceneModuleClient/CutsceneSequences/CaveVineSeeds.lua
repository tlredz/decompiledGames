local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "CaveVineSeeds"
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
				wait(6)
				task.spawn(function()
					for _, child in pairs(p.Set.CaveVineSeeds.SeedSpots:GetChildren()) do
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
				Client.PopUpUI.AddPopUp("planted seeds underground")
			end)
		end
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			7.92184734,
			-116.78833,
			-21.822567,
			-0.94881618,
			0.157919094,
			-0.273513079,
			-0,
			0.866016805,
			0.500014842,
			0.3158288,
			0.474422187,
			-0.821690798
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