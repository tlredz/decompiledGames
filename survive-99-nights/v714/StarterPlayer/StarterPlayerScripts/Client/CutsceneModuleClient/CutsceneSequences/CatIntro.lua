local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "CatIntro"
	},
	{
		Action = "FadeOut",
		Duration = 1.4
	},
	{
		Action = "SetCamera",
		CFrame = CFrame.new(
			510.079315,
			885.153625,
			7552.79102,
			0.656059086,
			-8.74247306e-8,
			-0.754709482,
			0.0000114383629,
			1,
			9.82738038e-6,
			0.754709482,
			-0.0000150799842,
			0.656059086
		)
	},
	{
		Action = "Function",
		Callback = function(p)
			task.spawn(function()
				UtilityAlec.preload({
					"rbxassetid://78592848034620",
					"rbxassetid://121885640616247",
					"rbxassetid://119297450849404",
					"rbxassetid://133884080581183"
				})
			end)
			workspace.CurrentCamera.FieldOfView = 40
			require(ReplicatedStorage.Modules.UtilityAlec)
			local cat = p.Set.CatIntro.Scene.Cat
			local track = cat.NPC.Animator:LoadAnimation(cat.Animations.Intro)
			task.spawn(function()
				track:Play()
				ReplicatedStorage.Core.Sounds.CatIntro:Play()
			end)

			local function fadeIn()
				local blackScreen = game.Players.LocalPlayer.PlayerGui.CutsceneGui.BlackScreen
				blackScreen.BackgroundTransparency = 0
				blackScreen.Visible = true
				local tween = TweenService:Create(blackScreen, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					BackgroundTransparency = 1
				})
				table.insert(p.Debris, tween)
				tween:Play()
				wait(1)
				blackScreen.Visible = false
			end

			task.spawn(function()
				fadeIn()
			end)
		end
	},
	{
		Action = "Pause",
		Duration = 9.5
	},
	{
		Action = "Function",
		Callback = function(_)
			workspace.CurrentCamera.FieldOfView = 70
		end
	},
	{
		Action = "ReturnCamera"
	}
}