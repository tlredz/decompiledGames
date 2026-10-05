local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
game:GetService("TweenService")
game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local northPoleTransition = nil
return {
	{
		Action = "LoadSet",
		SetName = "NorthPoleTransition"
	},
	{
		Action = "Function",
		Callback = function(p)
			northPoleTransition = p.Set:FindFirstChild("NorthPoleTransition")
			local northPoleTransition2

			if workspace.CutsceneMusic:FindFirstChild("NorthPoleTransition", true) then
				northPoleTransition2 = workspace.CutsceneMusic:FindFirstChild("NorthPoleTransition", true)
			else
				northPoleTransition2 = nil
			end

			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 50
				northPoleTransition2:Play()
				wait(26)
				northPoleTransition2:Stop()
			end)
			task.spawn(function()
				local map = northPoleTransition.Scene.Map
				local children = {}

				for _, child in pairs(map:GetChildren()) do
					if child.Name == "Lit Christmas Pine" then
						table.insert(children, child)
					end
				end

				while true do
					for _, folder in pairs(children) do
						for _, descendant in pairs(folder:GetDescendants()) do
							if descendant.Name == "Lights" or descendant.Name == "PointLight" then
								descendant.Color = Color3.fromRGB(255, 0, 4)
							end
						end
					end

					wait(1)

					for _, folder in pairs(children) do
						for _, descendant in pairs(folder:GetDescendants()) do
							if descendant.Name == "Lights" or descendant.Name == "PointLight" then
								descendant.Color = Color3.fromRGB(47, 255, 0)
							end
						end
					end

					wait(1)

					for _, folder in pairs(children) do
						for _, descendant in pairs(folder:GetDescendants()) do
							if descendant.Name == "Lights" or descendant.Name == "PointLight" then
								descendant.Color = Color3.fromRGB(0, 255, 238)
							end
						end
					end

					wait(1)
				end
			end)
			task.spawn(function()
				for _, child in pairs(northPoleTransition.Sounds:GetChildren()) do
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

				local _ = northPoleTransition.Sounds
				task.spawn(function()
					wait(19.5)
					wait(27)
				end)
			end)
			require(ReplicatedStorage.Modules.UtilityAlec)
			local animations = northPoleTransition.Animations

			for _, animation in pairs(animations:GetChildren()) do
				if not animations.Parent.Scene:FindFirstChild(animation.Name) then
					continue
				end

				local child = animations.Parent.Scene:FindFirstChild(animation.Name)
				;(child:FindFirstChild("Humanoid") or child:FindFirstChild("AnimationController") or child:FindFirstChild("NPC")):FindFirstChild("Animator"):LoadAnimation(animation):Play()
			end
		end
	},
	{
		Action = "Function",
		Callback = function(_)
			local torso = northPoleTransition.Scene.HumanoidCameraRig.Torso
			local humanoidCameraRig = northPoleTransition.Animations.HumanoidCameraRig
			local track = northPoleTransition.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(humanoidCameraRig)
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