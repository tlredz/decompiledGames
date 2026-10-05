local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
return {
	{
		Action = "LoadSet",
		SetName = "RamIntro"
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
			workspace.CurrentCamera.FieldOfView = 40
			require(ReplicatedStorage.Modules.UtilityAlec)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()
			local ramCutscene = p.Set.RamIntro.RamCutscene
			local track = ramCutscene.AnimationController.Animator:LoadAnimation(ramCutscene.Animations.Cutscene)
			task.spawn(function()
				track:Play()
				ReplicatedStorage.Core.Sounds.RamChargingUp:Play()
				wait(0.1)
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
			local camera = p.Set.RamIntro.RamCutscene.RootPart.GLOBAL.Camera
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
					local cFrame = camera.TransformedWorldCFrame * CFrame.Angles(
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