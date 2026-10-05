local Phenomenal = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer

function Phenomenal.Start(_, player, list)
	if not player.Character then
		return
	end

	local clone = script.Scene:Clone()
	clone.Parent = workspace.Effects
	table.insert(list, clone)
	task.spawn(function()
		local v

		if player.Character then
			v = player.Character.Humanoid:GetAppliedDescription()
		else
			v = game.Players:GetHumanoidDescriptionFromUserId(player.UserId)
		end

		clone.Rig.Humanoid:ApplyDescriptionReset(v)
	end)
	local clone2 = script.Voice:Clone()
	clone2.SoundGroup = game.SoundService.Voice
	clone2.Parent = workspace
	table.insert(list, clone2)
	local clone3 = script.Music:Clone()
	clone3.SoundGroup = game.SoundService.Music
	clone3.Parent = workspace
	table.insert(list, clone3)
	local clone4 = script.Effect:Clone()
	clone4.SoundGroup = game.SoundService.Effect
	clone4.Parent = workspace
	table.insert(list, clone4)
	local track = clone.Rig.Humanoid:LoadAnimation(script.Character)
	local track2 = clone.Camera.Humanoid:LoadAnimation(script.Camera)
	track:Play(0, nil, 0)
	table.insert(list, track)
	track2:Play(0, nil, 0)
	table.insert(list, track2)
	task.wait(2.4)
	local clone5 = script.Text:Clone()
	clone5.Parent = localPlayer.PlayerGui
	TweenService:Create(clone5.Frame.TextLabel, TweenInfo.new(0.4), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(clone5.Frame.TextLabel.UIStroke, TweenInfo.new(0.4), {
		Transparency = 0
	}):Play()
	table.insert(list, clone5)
	clone.Rig["ExtraLeft Arm"].Color = clone.Rig["Left Arm"].Color
	clone.Rig["ExtraRight Arm"].Color = clone.Rig["Right Arm"].Color
	task.wait(0.1)
	localPlayer.PlayerGui.Main.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	table.insert(list, RunService.RenderStepped:Connect(function()
		currentCamera.CFrame = clone.Camera.Torso.CFrame
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and clone2.IsLoaded and clone3.IsLoaded and clone4.IsLoaded or v < tick()

	track:AdjustSpeed(0.9230769230769231)
	track2:AdjustSpeed(0.9230769230769231)
	clone2:Play()
	clone3:Play()
	clone4:Play()
	task.wait(1.3)
	TweenService:Create(clone5.Frame, TweenInfo.new(0.6), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(clone5.Frame.TextLabel.UIStroke, TweenInfo.new(0.6), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone5.Frame.TextLabel, TweenInfo.new(0.6), {
		TextTransparency = 1
	}):Play()
	task.wait(2)
	TweenService:Create(clone.Rig.Torso.PointLight, TweenInfo.new(1), {
		Brightness = 0
	}):Play()

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			TweenService:Create(emitter, TweenInfo.new(1), {
				Brightness = 0,
				LightEmission = 0
			}):Play()
		end
	end

	task.wait(3.2)
	track:AdjustSpeed(0)
	track2:AdjustSpeed(0)

	for _, effect in clone:GetDescendants() do
		if effect:IsA("Beam") then
			effect.TextureSpeed = 0
		elseif effect:IsA("ParticleEmitter") then
			effect.TimeScale = 0
		end
	end
end

return Phenomenal