local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
return {
	Start = function(_, player, list)
		local character = player.Character

		if not character then
			return
		end

		local clone = script.Scene:Clone()
		clone.Parent = workspace.Effects
		table.insert(list, clone)
		local cam = clone.Cam
		local animator = cam.AnimationController.Animator
		local rig = clone.Rig
		local humanoid = rig.Humanoid
		task.spawn(function()
			local appliedDescription = character and character.Humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(player.UserId)
			humanoid:ApplyDescriptionReset(appliedDescription)
		end)
		local track = humanoid:LoadAnimation(script.User)
		local track2 = animator:LoadAnimation(script.Cam)
		local clone2 = script.Slash:Clone()
		clone2.Enabled = false
		clone2.Parent = localPlayer.PlayerGui
		local clone3 = script.SFX:Clone()
		clone3.SoundGroup = game.SoundService.Effect
		clone3.Parent = clone
		track:Play(0, nil, 0)
		track2:Play(0, nil, 0)
		table.insert(list, track)
		table.insert(list, track2)
		table.insert(list, clone3)
		table.insert(list, clone2)
		task.wait(2)
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = cam.CamPart.CFrame
		task.wait(0.5)
		localPlayer.PlayerGui.Main.Enabled = false
		table.insert(list, RunService.RenderStepped:Connect(function()
			currentCamera.FieldOfView = 17
			cam.RootPart.CFrame = rig.PrimaryPart.CFrame * CFrame.new(0, -3, 0)
			currentCamera.CFrame = cam.CamPart.CFrame
		end))
		local v = tick() + 0.25

		repeat
			task.wait()
		until track.Length > 0 and track2.Length > 0 and clone3.IsLoaded or v < tick()

		track:AdjustSpeed(1)
		track2:AdjustSpeed(1)
		clone3:Play()
		local v2 = track:GetTimeOfKeyframe("Cut") - 0.14
		TweenService:Create(rig.PrimaryPart, TweenInfo.new(4.5), {
			CFrame = rig.PrimaryPart.CFrame * CFrame.new(0, 0, -10)
		}):Play()
		task.wait(v2)
		clone2.Enabled = true
		TweenService:Create(clone2.Clip, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Size = UDim2.fromScale(1, 0)
		}):Play()
		track:AdjustSpeed(0)
		track2:AdjustSpeed(0)
		task.wait(0.14)
		clone2.Cut.BackgroundTransparency = 1
		clone2.Cut.UIStroke.Transparency = 1
		clone2.Cut.Deep.BackgroundTransparency = 1
		task.wait(0.28)
	end
}