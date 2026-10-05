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
					for _, child in pairs(p.Set.TorchflowerSeed.SeedSpots2:GetChildren()) do
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
				Client.PopUpUI.AddPopUp("planted seeds near the ponds")
			end)
		end
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			-15.3620148,
			-196.517258,
			-71.1660309,
			-0.67419976,
			0.729456186,
			-0.11553549,
			7.4505806e-9,
			0.156435773,
			0.987688184,
			0.738549054,
			0.665899158,
			-0.105468966
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