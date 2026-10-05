local StalemateCollapse = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function StalemateCollapse.Start(_, player, list)
	if not player.Character then
		return
	end

	local clone = script.Scene:Clone()
	clone.Parent = workspace.Effects
	table.insert(list, clone)
	task.spawn(function()
		local appliedDescription = player.Character and player.Character.Humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(player.UserId)
		clone.Rig.Humanoid:ApplyDescriptionReset(appliedDescription)
	end)
	task.spawn(function()
		local team = player.Team
		local team2 = localPlayer.Team
		local v = localPlayer
		local v2 = localPlayer == player or team == team2
		local players = Players:GetPlayers()
		local players2 = {}

		if v2 then
			for _, player2 in players do
				if player2 ~= player and player2 ~= localPlayer then
					table.insert(players2, player2)
				end
			end
		end

		if v2 and #players2 > 0 then
			v = players2[math.random(1, #players2)]
		end

		if not v2 or v ~= localPlayer then
			local appliedDescription = v.Character and v.Character.Humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(v.UserId)
			clone.Rig2.Humanoid:ApplyDescriptionReset(appliedDescription)
		end
	end)
	local clone2 = script.SFX:Clone()
	clone2.SoundGroup = game.SoundService.Effect
	clone2.Parent = workspace
	table.insert(list, clone2)
	local clone3 = script.Voice:Clone()
	clone3.SoundGroup = game.SoundService.Voice
	clone3.Parent = workspace
	table.insert(list, clone3)
	local clone4 = script.Music:Clone()
	clone4.SoundGroup = game.SoundService.Effect
	clone4.Parent = workspace
	table.insert(list, clone4)
	local track = clone.Rig.Humanoid:LoadAnimation(script.Character)
	local track2 = clone.Rig2.Humanoid:LoadAnimation(script.Character2)
	local track3 = clone.Camera.Humanoid:LoadAnimation(script.Camera)
	track:Play(0, nil, 0)
	table.insert(list, track)
	track2:Play(0, nil, 0)
	table.insert(list, track2)
	track3:Play(0, nil, 0)
	table.insert(list, track3)
	task.wait(2.5)
	localPlayer.PlayerGui.Main.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	table.insert(list, RunService.RenderStepped:Connect(function()
		currentCamera.FieldOfView = track.TimePosition > 5.5 and 10 or 40
		currentCamera.CFrame = clone.Camera.Torso.CFrame
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and track3.Length > 0 and clone2.IsLoaded and clone3.IsLoaded and clone4.IsLoaded or v < tick()

	track:AdjustSpeed(1)
	track2:AdjustSpeed(1)
	track3:AdjustSpeed(1)
	clone2:Play()
	clone3:Play()
	clone4:Play()
	local clone5 = script.DepthOfField:Clone()
	clone5.Parent = game.Lighting
	table.insert(list, clone5)
	local clone6 = script.ColorCorrection:Clone()
	clone6.Parent = game.Lighting
	table.insert(list, clone6)

	for _, child in clone.BG:GetChildren() do
		child:SetAttribute("OGTP", child.Transparency)
		child.Transparency = 1
	end

	local clone7 = script.Vignette:Clone()
	clone7.Parent = localPlayer.PlayerGui
	table.insert(list, clone7)
	task.defer(function()
		local fade = localPlayer.PlayerGui:FindFirstChild("Fade")

		if not fade then
			return
		end

		TweenService:Create(fade.Frame, TweenInfo.new(0), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(0.3)
		fade.Frame.BackgroundTransparency = 1
		task.wait(0.05)
		clone7.Flash.Frame.Size = UDim2.new(0.15, 0, 2, 0)
		task.wait(0.05)
		clone7.Flash.Visible = false
	end)
	task.wait(0.6)
	clone.Rig2.Torso.Beam.Enabled = true
	clone.Rig2.Torso.Attachment.Blood.Enabled = true
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(clone.Rig2.Torso.Beam, tweenInfo, {
		TextureSpeed = 1
	}):Play()
	TweenService:Create(clone.Rig2.Torso.Attachment.Blood, tweenInfo, {
		TimeScale = 0.05
	}):Play()
	task.wait(1.4)
	clone5:Destroy()
	clone6:Destroy()

	for _, child in clone.BG:GetChildren() do
		child.Transparency = child:GetAttribute("OGTP")
	end

	for _, part in clone.Rig2:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency ~= 1) then
			continue
		end

		local clone8 = script.Shadow:Clone()

		if part.Name == "Left Arm" then
			clone8.Face = Enum.NormalId.Left
		elseif part.Name == "Right Arm" then
			clone8.Face = Enum.NormalId.Right
		end

		clone8.Parent = part
		table.insert(list, clone8)
	end

	task.wait(4.5)
	track:AdjustSpeed(0)
	track3:AdjustSpeed(0)
	clone.Rig2.Torso.Beam.TextureSpeed = 0
	clone.Rig2.Torso.Attachment.Blood.TimeScale = 0
end

return StalemateCollapse