local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local deerBatCave = nil
local v = nil
local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
return {
	{
		Action = "LoadSet",
		SetName = "DeerBatCave"
	},
	{
		Action = "Function",
		Callback = function(p)
			deerBatCave = p.Set:FindFirstChild("DeerBatCave")
			local musicNORMAL = workspace.MusicNORMAL

			if workspace.CutsceneMusic:FindFirstChild("DeerBatCave", true) then
				musicNORMAL = workspace.CutsceneMusic:FindFirstChild("DeerBatCave", true)
			end

			v = Client.ColorCorrectionLightingClient.GetBiome() or nil
			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 50
				musicNORMAL:Play()
			end)
			task.spawn(function()
				wait(13)
				deerBatCave.Scene.Deer.EyeHighlights.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
				deerBatCave.Scene.Deer.EyeHighlights.LeftEyeWhiteHighlight.Color = Color3.fromRGB(255, 0, 0)
				deerBatCave.Scene.Deer.EyeHighlights.RightEyeWhiteHighlight.Color = Color3.fromRGB(255, 0, 0)
			end)
			task.spawn(function()
				for _, child in pairs(deerBatCave.Sounds:GetChildren()) do
					local v2 = child
					task.spawn(function()
						if v2:GetAttribute("EndTime") then
							task.spawn(function()
								wait(v2:GetAttribute("EndTime"))
								v2:Stop()
							end)
						end

						wait(tonumber(v2:GetAttribute("StartTime")) or 0)
						v2:Play()
					end)
				end

				local _ = deerBatCave.Sounds
				task.spawn(function()
					wait(35)
					TweenService:Create(
						musicNORMAL,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Volume = 0
						}
					):Play()
				end)
			end)
			require(ReplicatedStorage.Modules.UtilityAlec)
			local animations = deerBatCave.Animations

			for _, animation in pairs(animations:GetChildren()) do
				if not animations.Parent.Scene:FindFirstChild(animation.Name) then
					continue
				end

				local child = animations.Parent.Scene:FindFirstChild(animation.Name)
				local humanoid = child:FindFirstChild("Humanoid") or child:FindFirstChild("AnimationController") or child:FindFirstChild("NPC")

				if child then
					humanoid:FindFirstChild("Animator"):LoadAnimation(animation):Play()
				else
					print(animation.Name)
				end
			end
		end
	},
	{
		Action = "Function",
		Callback = function(_)
			local torso = deerBatCave.Scene.HumanoidCameraRig.Torso
			local humanoidCameraRig = deerBatCave.Animations.HumanoidCameraRig
			local track = deerBatCave.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(humanoidCameraRig)
			track:Play()
			local currentCamera = workspace.CurrentCamera
			local custom = Enum.CameraType.Custom

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				custom = currentCamera.CameraType
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			local v2 = true
			task.spawn(function()
				while v2 and Client.CutsceneModuleClient.GetCurrentCutscene() do
					currentCamera.CFrame = torso.CFrame
					task.wait()
				end
			end)
			track.Stopped:Wait()
			v2 = false
			workspace.CurrentCamera.FieldOfView = 70
			currentCamera.CameraType = custom

			if not game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.CharacterAdded:Wait()
			end

			workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
		end
	},
	{
		Action = "ReturnCamera"
	}
}