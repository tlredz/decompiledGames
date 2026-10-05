local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local alienRevengeIntro = nil

function SetTransparency(folder, p)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, part in pairs(descendants) do
		if not part:IsA("BasePart") then
			continue
		end

		if part:GetAttribute("OrigTransparency") == nil then
			part:SetAttribute("OrigTransparency", part.Transparency)
		end

		local origTransparency = part:GetAttribute("OrigTransparency")
		part.Transparency = origTransparency + (1 - origTransparency) * p
	end
end

function Show(p)
	SetTransparency(p, 0)
end

function Hide(p)
	SetTransparency(p, 1)
end

return {
	{
		Action = "LoadSet",
		SetName = "AlienRevengeIntro"
	},
	{
		Action = "Function",
		Callback = function(p)
			alienRevengeIntro = p.Set:FindFirstChild("AlienRevengeIntro")
			local musicNORMAL = workspace.MusicNORMAL

			if alienRevengeIntro.Sounds:FindFirstChild("Music") then
				musicNORMAL = alienRevengeIntro.Sounds.Music
			end

			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 50
				musicNORMAL:Play()
			end)
			task.spawn(function()
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam1)
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam2)
				task.wait(5.620000000000001)
				Show(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam1)
				Show(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam2)
				task.wait(2.2200000000000024)
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam1)
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam2)
			end)
			task.spawn(function()
				task.wait(10.75)
				Show(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam1)
				Show(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam2)
				task.wait(1.25)
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam1)
				Hide(alienRevengeIntro.Scene.SceneRIG.UFO.AlienBeam2)
			end)
			task.spawn(function()
				local alienSatelliteDish = alienRevengeIntro.Scene.Maps.Folder["Alien Satellite Dish"]
				Hide(alienSatelliteDish)
				task.wait(5.620000000000001)
				Show(alienSatelliteDish)
			end)
			task.spawn(function()
				local alienScanningStation = alienRevengeIntro.Scene.Maps.Folder["Alien Scanning Station"]
				Hide(alienScanningStation)
				task.wait(11.25)
				Show(alienScanningStation)
			end)
			task.spawn(function()
				for _, child in pairs(alienRevengeIntro.Sounds:GetChildren()) do
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

				local _ = alienRevengeIntro.Sounds
				task.spawn(function()
					wait(25)
					TweenService:Create(
						musicNORMAL,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Volume = 0
						}
					):Play()
				end)
				task.spawn(function() end)
			end)
			require(ReplicatedStorage.Modules.UtilityAlec)
			local animations = alienRevengeIntro.Animations

			for _, animation in pairs(animations:GetChildren()) do
				if not animations.Parent.Scene:FindFirstChild(animation.Name) then
					continue
				end

				local child = animations.Parent.Scene:FindFirstChild(animation.Name)
				local humanoid = child:FindFirstChild("Humanoid") or child:FindFirstChild("AnimationController") or child:FindFirstChild("NPC")

				if child then
					humanoid:FindFirstChild("Animator"):LoadAnimation(animation):Play()
				else
					print(animation.Name .. "NO ANIMATION CONTROLLER!")
				end
			end
		end
	},
	{
		Action = "Function",
		Callback = function(_)
			local torso = alienRevengeIntro.Scene.HumanoidCameraRig.Torso
			local humanoidCameraRig = alienRevengeIntro.Animations.HumanoidCameraRig
			local track = alienRevengeIntro.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(humanoidCameraRig)
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