local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "TorchflowerSeed"
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
				wait(6)
				task.spawn(function()
					for _, child in pairs(p.Set.TorchflowerSeed.SeedSpots1:GetChildren()) do
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
			6.98194647,
			-214.371735,
			-67.2410431,
			-0.825063586,
			0.267000735,
			-0.497976661,
			-0,
			0.88131237,
			0.472534299,
			0.565039933,
			0.389870852,
			-0.727138698
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