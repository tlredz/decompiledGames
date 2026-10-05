local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local track = nil
return {
	{
		Action = "LoadSet",
		SetName = "OwlIntro"
	},
	{
		Action = "FadeOut",
		Duration = 1.4
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
			workspace.CurrentCamera.FieldOfView = 22
			require(ReplicatedStorage.Modules.UtilityAlec)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()
			local owlCutscene = p.Set.OwlIntro.OwlCutscene
			local track2 = owlCutscene.AnimationController.Animator:LoadAnimation(owlCutscene.Animation)
			local wolfCutscene = p.Set.OwlIntro.WolfCutscene
			track = wolfCutscene.AnimationController.Animator:LoadAnimation(wolfCutscene.Animation)

			for _, part in pairs(owlCutscene:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			track:Play()
			task.spawn(function()
				wait(2.916)
				track2:Play()
				wait(0.1)

				for _, part in pairs(owlCutscene:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "RootPart" then
						part.Transparency = 0
					end
				end
			end)
			task.spawn(function()
				wait(3.6)
				ReplicatedStorage.Core.Sounds.FlyingBy:Play()
				ReplicatedStorage.Core.Sounds.OwlSound:Play()
				wait(4.65)
				ReplicatedStorage.Core.Sounds.ClawGrab:Play()
				ReplicatedStorage.Core.Sounds.OwlSound:Play()
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
			local camerabone = p.Set.OwlIntro.WolfCutscene.RootPart.Camerabone
			local currentCamera = workspace.CurrentCamera
			local custom = Enum.CameraType.Custom

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				custom = currentCamera.CameraType
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
			local v = true
			task.spawn(function()
				while v and Client.CutsceneModuleClient.GetCurrentCutscene() do
					local cFrame = camerabone.TransformedWorldCFrame * CFrame.Angles(
						3.141592653589793,
						0,
						3.141592653589793
					)
					currentCamera.CFrame = cFrame
					currentCamera.Focus = cFrame * CFrame.new(-1, 0, -1)
					task.wait()
				end
			end)
			track.Stopped:Wait()
			v = false
			currentCamera.CameraType = custom

			if not game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.CharacterAdded:Wait()
			end

			workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
			workspace.CurrentCamera.FieldOfView = 70
		end
	},
	{
		Action = "ReturnCamera"
	}
}