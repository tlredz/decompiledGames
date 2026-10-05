local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local updateCutscene52 = nil
local musicNORMAL = nil

function OrangeFlash(backgroundTransparency, duration, p)
	local clone = localPlayer.PlayerGui.CutsceneGui.BlackScreen:Clone()
	clone.Name = "OrangeFlash"
	clone.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
	clone.BackgroundTransparency = backgroundTransparency
	clone.Visible = true
	clone.Parent = localPlayer.PlayerGui.CutsceneGui
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, p), {
		BackgroundTransparency = 1
	}):Play()
	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, p + duration)
end

function TransformGround(p)
	local function isOnPlot(position)
		for _, child in pairs(p.GrassFolder:GetChildren()) do
			local pointToObjectSpace = child.CFrame:PointToObjectSpace(position)

			if math.abs(pointToObjectSpace.X) <= child.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= child.Size.Z / 2 then
				return true
			end
		end

		return false
	end

	local map = updateCutscene52.Scene.Map

	for _, pVInstance in pairs(map:GetDescendants()) do
		if not (pVInstance:IsA("PVInstance") and pVInstance.Parent and pVInstance.Parent:IsA("Folder")) then
			continue
		end

		if not isOnPlot(pVInstance:GetPivot().Position) then
			continue
		end

		pVInstance:Destroy()
	end

	p.Parent = map
end

return {
	{
		Action = "LoadSet",
		SetName = "UpdateCutscene52"
	},
	{
		Action = "SetNight"
	},
	{
		Action = "Function",
		Callback = function(p)
			updateCutscene52 = p.Set:FindFirstChild("UpdateCutscene52")
			musicNORMAL = workspace.MusicNORMAL

			if workspace.CutsceneMusic:FindFirstChild("UpdateCutscene52", true) or updateCutscene52.Sounds:FindFirstChild("Music") then
				musicNORMAL = workspace.CutsceneMusic:FindFirstChild("UpdateCutscene52", true) or updateCutscene52.Sounds:FindFirstChild("Music")
			end

			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 40

				if Client.MusicClient then
					Client.MusicClient.PauseMusic()
				end

				musicNORMAL:Play()
			end)
			task.spawn(function()
				for _, child in pairs(updateCutscene52.Sounds:GetChildren()) do
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

				local _ = updateCutscene52.Sounds
			end)
			require(ReplicatedStorage.Modules.UtilityAlec)
			local animations = updateCutscene52.Animations

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
		Callback = function(p)
			local torso = updateCutscene52.Scene.HumanoidCameraRig.Torso
			local humanoidCameraRig = updateCutscene52.Animations.HumanoidCameraRig
			local track = updateCutscene52.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(humanoidCameraRig)
			local halloweenPlot1 = updateCutscene52.Scene.Map["Halloween Plot1"]
			halloweenPlot1.Parent = nil
			track:Play()
			task.spawn(function()
				while track.Length == 0 do
					task.wait()
				end

				local blackScreen = localPlayer.PlayerGui.CutsceneGui.BlackScreen

				local function reached(p2)
					task.wait((math.max(p2 - track.TimePosition, 0)))
					return Client.CutsceneModuleClient.GetCurrentCutscene() == p
				end

				task.wait((math.max(7.29 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				OrangeFlash(0, 1.5, 3)
				task.wait((math.max(62.21 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				blackScreen.BackgroundTransparency = 0
				blackScreen.Visible = true
				task.wait((math.max(65 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				blackScreen.Visible = false
				task.wait((math.max(69.75 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				OrangeFlash(0.35, 0.4, 0)
				TransformGround(halloweenPlot1)
			end)
			task.spawn(function()
				while track.Length == 0 do
					task.wait()
				end

				if track.Looped then
					track.Looped = false
				end

				task.wait((math.max(track.Length - track.TimePosition - 4, 0)))
				local updateText = game.Players.LocalPlayer.PlayerGui.Interface.UpdateText
				updateText.Text = ""
				updateText.Visible = true
				TweenService:Create(updateText, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					TextTransparency = 0
				}):Play()
				TweenService:Create(
					updateText.UIStroke,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Transparency = 0
					}
				):Play()
				task.wait(6)
				TweenService:Create(updateText, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					TextTransparency = 1
				}):Play()
				TweenService:Create(
					updateText.UIStroke,
					TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
				task.wait(6)
				updateText.Visible = false
			end)
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

			if Client.MusicClient then
				Client.MusicClient.ResumeMusicIfEnabled()
			end

			if musicNORMAL then
				TweenService:Create(musicNORMAL, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Volume = 0
				}):Play()
			end

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