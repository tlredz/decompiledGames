local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = game.Players.LocalPlayer
return {
	Start = function(_, player, list)
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
		currentCamera.FieldOfView = 80
		currentCamera.CameraType = Enum.CameraType.Scriptable
		table.insert(list, RunService.RenderStepped:Connect(function()
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
		task.delay(0.1, function()
			clone.BG.BG.Clouds:Emit(200)
		end)
		task.wait(2)
		local clone5 = script.DepthOfField:Clone()
		clone5.Parent = game.Lighting
		table.insert(list, clone5)
		clone.Dust.Glass:Emit(200)
		clone.Dust.Sparks:Emit(200)
		local clone6 = script.BurstCC:Clone()
		clone6.Parent = game.Lighting
		TweenService:Create(clone6, TweenInfo.new(0.15), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
		Debris:AddItem(clone6, 0.15)
		task.delay(0.06, function()
			local clone7 = script.BurstBlur:Clone()
			clone7.Parent = game.Lighting
			TweenService:Create(clone7, TweenInfo.new(0.5), {
				Size = 0
			}):Play()
			Debris:AddItem(clone7, 0.5)
		end)
		currentCamera.FieldOfView = 60
		TweenService:Create(currentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			FieldOfView = 80
		}):Play()
		local clone7 = script.Vignette:Clone()
		clone7.Parent = localPlayer.PlayerGui
		table.insert(list, clone7)
		task.wait(4.5)
		track:AdjustSpeed(0)
		track2:AdjustSpeed(0)
		track3:AdjustSpeed(0)
		clone.Dust.Glass.TimeScale = 0
		clone.Dust.Sparks.TimeScale = 0
		clone.BG.BG.Clouds.TimeScale = 0
	end
}