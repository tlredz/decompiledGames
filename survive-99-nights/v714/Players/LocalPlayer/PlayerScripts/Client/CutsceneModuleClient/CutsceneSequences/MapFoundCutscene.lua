local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mapFoundCutscene = nil
return {
	{
		Action = "LoadSet",
		SetName = "MapFoundCutscene"
	},
	{
		Action = "Function",
		Callback = function(p)
			mapFoundCutscene = p.Set:FindFirstChild("MapFoundCutscene")
			local musicNORMAL = workspace.MusicNORMAL

			if workspace.CutsceneMusic:FindFirstChild("MapFoundCutscene", true) then
				musicNORMAL = workspace.CutsceneMusic:FindFirstChild("MapFoundCutscene", true)
			end

			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 40
				musicNORMAL:Play()
			end)
			task.spawn(function()
				for _, child in pairs(mapFoundCutscene.Sounds:GetChildren()) do
					local v = child
					task.spawn(function()
						if v:GetAttribute("EndTime") then
							task.spawn(function()
								wait(v:GetAttribute("EndTime"))
								v:Stop()
							end)
						end

						wait(tonumber(v:GetAttribute("StartTime")) or 0)
						v:Play()
					end)
				end

				local _ = mapFoundCutscene.Sounds
				task.spawn(function()
					wait(15)
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
			local animations = mapFoundCutscene.Animations

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
			local torso = mapFoundCutscene.Scene.HumanoidCameraRig.Torso
			local humanoidCameraRig = mapFoundCutscene.Animations.HumanoidCameraRig
			local track = mapFoundCutscene.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(humanoidCameraRig)
			track:Play()
			local currentCamera = workspace.CurrentCamera
			local custom = Enum.CameraType.Custom

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				custom = currentCamera.CameraType
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			local v = true
			task.spawn(function()
				while v and Client.CutsceneModuleClient.GetCurrentCutscene() do
					currentCamera.CFrame = torso.CFrame
					task.wait()
				end
			end)
			track.Stopped:Wait()
			v = false
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