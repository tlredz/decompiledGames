-- failed to load script (decompiled with syntax error):
-- oPaZVOfeFWBpOUZjzvWhJcuYH:98: Expected identifier when parsing expression, got ';'

local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local happyFinalRam = nil
local happyFinalRam2 = nil

function ShowDialogueLine(text)
	local halloweenDialogueFrame = Client.Interface.HalloweenDialogueFrame
	local clone = halloweenDialogueFrame:Clone()
	clone.Name = "CutsceneDialogue"
	clone.Responses.Visible = false
	clone.CloseButton.Visible = false
	local textLabel = clone.LastMessage.TextLabel
	textLabel.Text = text
	textLabel.MaxVisibleGraphemes = 0
	clone.Visible = true
	clone.Parent = halloweenDialogueFrame.Parent
	ReplicatedStorage.Core.Sounds.HalloweenTyping:Play()

	for i = 1, utf8.len(text) do
		textLabel.MaxVisibleGraphemes = i
		task.wait(0.02)
	end

	ReplicatedStorage.Core.Sounds.HalloweenTyping:Stop()
	return clone
end

function FadeOutGui(folder, duration)
	local tweenInfo = TweenInfo.new(duration)

	for _, descendant in pairs(folder:GetDescendants()) do
		local v = {}

		if descendant:IsA("GuiObject") then
			v.BackgroundTransparency = 1
		end

		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			v.TextTransparency = 1
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") or descendant:IsA("ViewportFrame") then
			v.ImageTransparency = 1
		elseif descendant:IsA("UIStroke") then
			v.Transparency = 1
		end

		if next(v) then
			TweenService:Create(descendant, tweenInfo, v):Play()
		end
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(folder, duration)
end

return {
	{
		Action = "LoadSet",
		SetName = "HappyFinalRam"
	},
	{
		Action = "Function",
		Callback = function(p)
			happyFinalRam = p.Set:FindFirstChild("HappyFinalRam")
			happyFinalRam2 = workspace.CutsceneMusic:FindFirstChild("HappyFinalRam", true) or happyFinalRam.Sounds:FindFirstChild("Music") or workspace.MusicNORMAL
			task.spawn(function()
				workspace.CurrentCamera.FieldOfView = 40

				if Client.MusicClient then
					Client.MusicClient.PauseMusic()
				end

				happyFinalRam2:Play()
			end)

			for _, child in pairs(happyFinalRam.Sounds:GetChildren()) do
				local v = child
				task.spawn(function()
					if v:GetAttribute("EndTime") then
						task.delay(v:GetAttribute("EndTime"), function()
							v:Stop()
						end)
					end

					task.wait(tonumber(v:GetAttribute("StartTime")) or 0)
					v:Play()
				end)
			end

			for _, animation in pairs(happyFinalRam.Animations:GetChildren()) do
				local child = happyFinalRam.Scene:FindFirstChild(animation.Name)

				if child then
					;(child:FindFirstChild("Humanoid") or child:FindFirstChild("AnimationController") or child:FindFirstChild("NPC")).Animator:LoadAnimation(animation):Play()
				end
			end
		end
	},
	{
		Action = "Function",
		Callback = function(p)
			local torso = happyFinalRam.Scene.HumanoidCameraRig.Torso
			local track = happyFinalRam.Scene.HumanoidCameraRig.Humanoid.Animator:LoadAnimation(happyFinalRam.Animations.HumanoidCameraRig)
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

				task.wait((math.max(16.21 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				blackScreen.BackgroundTransparency = 0
				blackScreen.Visible = true
				task.wait((math.max(17.88 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				blackScreen.Visible = false
				task.wait((math.max(21 - track.TimePosition, 0)))

				if Client.CutsceneModuleClient.GetCurrentCutscene() ~= p then
					return
				end

				local v = ShowDialogueLine("HEEEELLLLPPPPPPPPPP!!!!")

				repeat
					task.wait()
				until Client.CutsceneModuleClient.GetCurrentCutscene() ~= p

				FadeOutGui(v, 1)
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

			TweenService:Create(happyFinalRam2, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Volume = 0
			}):Play()
			v = false
			currentCamera.FieldOfView = 70
			currentCamera.CameraType = custom
			currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
		end
	},
	{
		Action = "ReturnCamera"
	}
}