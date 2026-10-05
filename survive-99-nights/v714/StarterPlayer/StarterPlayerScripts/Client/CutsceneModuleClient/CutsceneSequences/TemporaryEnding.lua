local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
return {
	{
		Action = "LoadSet",
		SetName = "TemporaryEnding"
	},
	{
		Action = "Function",
		Callback = function(p)
			local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Play()
			local deer = p.Set.TemporaryEnding.Deer
			local track = deer.NPC:LoadAnimation(deer.Animations.DeerCutscene)
			print(UtilityAlec.GetAnimationLength(deer.Animations.DeerCutscene))
			track:Play()
		end
	},
	{
		Action = "Function",
		Callback = function(p)
			local torso = p.Set.TemporaryEnding.HumanoidCameraRig.Torso
			local track = p.Set.TemporaryEnding.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(p.Set.TemporaryEnding.HumanoidCameraRig.Animation)
			track:Play()
			local currentCamera = workspace.CurrentCamera
			local custom = Enum.CameraType.Custom

			if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				custom = currentCamera.CameraType
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			task.spawn(function()
				wait(18.46)

				if not (p.Set and p.Set:FindFirstChild("TemporaryEnding")) then
					return
				end

				p.Set.TemporaryEnding:PivotTo(p.Set.TemporaryEnding:GetPivot() * CFrame.new(0, -270, 0))
				wait(2.33)
				print("here")
				p.Set.TemporaryEnding.DeerLairEntrance.Cave.Grate.Bars.Whole:Destroy()

				for _, part in pairs(p.Set.TemporaryEnding.DeerLairEntrance.Cave.Grate.Bars.Broken:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 0
					end
				end
			end)
			local Client = require(game.Players.LocalPlayer.PlayerScripts.Client)
			local v = true
			task.spawn(function()
				while v and Client.CutsceneModuleClient.GetCurrentCutscene() do
					currentCamera.CFrame = torso.CFrame
					task.wait()
				end
			end)
			track.Stopped:Wait()
			v = false
			task.spawn(function()
				Client.PopUpUI.AddPopUp(
					"More story and an ending will be revealed soon. Stay tuned for future updates.",
					"note",
					3
				)
			end)
			currentCamera.CameraType = custom

			if not game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.CharacterAdded:Wait()
			end

			workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
		end
	},
	{
		Action = "ReturnCamera"
	},
	{
		Action = "Function",
		Callback = function(_)
			ReplicatedStorage.Core.Sounds.HorrorMusic:Stop()
		end
	}
}