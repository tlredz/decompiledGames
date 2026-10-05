local Meditation = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer

function Meditation.Start(_, player, list)
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
	local clone2 = script["birds-chirping"]:Clone()
	clone2.SoundGroup = game.SoundService.Effect
	clone2.Parent = workspace
	table.insert(list, clone2)
	local clone3 = script.waterfall3_looped:Clone()
	clone3.SoundGroup = game.SoundService.Effect
	clone3.Parent = workspace
	table.insert(list, clone3)
	local clone4 = script["Clap Todo"]:Clone()
	clone4.SoundGroup = game.SoundService.Effect
	clone4.Parent = workspace
	table.insert(list, clone4)
	local tracks = {}

	for _, child in pairs(clone:GetChildren()) do
		if string.sub(child.Name, 1, 9) ~= "Butterfly" then
			continue
		end

		local track = child.AnimationController:LoadAnimation(child.Animation)
		track.Looped = false
		track:Play(0, nil, 0)
		track.Stopped:Connect(function()
			track:Play(0, nil, 0)
			track.TimePosition = track.Length
		end)
		table.insert(tracks, track)
	end

	local track = clone.Rig.Humanoid:LoadAnimation(script.Character)
	local track2 = clone.Camera.AnimationController.Animator:LoadAnimation(script.Camera)
	track:Play(0, nil, 0)
	table.insert(list, track)
	track2:Play(0, nil, 0)
	table.insert(list, track2)
	track.Looped = false
	track2.Looped = false
	task.wait(2.5)
	local depthOfFieldEffect = Instance.new("DepthOfFieldEffect", game.Lighting)
	depthOfFieldEffect.FarIntensity = 0.5
	depthOfFieldEffect.InFocusRadius = 20
	depthOfFieldEffect.NearIntensity = 0.75
	depthOfFieldEffect.FocusDistance = 0.05
	table.insert(list, depthOfFieldEffect)
	game.Lighting.ColorShift_Bottom = Color3.fromRGB(0, 48, 255)
	game.Lighting.ColorShift_Top = Color3.fromRGB(253, 255, 159)
	game.Lighting.Ambient = Color3.fromRGB(20, 192, 255)
	game.Lighting.Brightness = 5
	table.insert(list, function()
		local config = game.Lighting.Config
		game.Lighting.ColorShift_Bottom = config:GetAttribute("ColorShift_Bottom")
		game.Lighting.ColorShift_Top = config:GetAttribute("ColorShift_Top")
		game.Lighting.Ambient = config:GetAttribute("Ambient")
		game.Lighting.Brightness = config:GetAttribute("Brightness")
	end)
	localPlayer.PlayerGui.Main.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.FieldOfView = 30
	currentCamera.CameraType = Enum.CameraType.Scriptable
	table.insert(list, RunService.RenderStepped:Connect(function()
		currentCamera.FieldOfView = 30
		currentCamera.CFrame = clone.Camera.camera.CFrame
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and clone2.IsLoaded and clone3.IsLoaded and clone4.IsLoaded or v < tick()

	track:AdjustSpeed(1)
	track2:AdjustSpeed(1)

	for _, v2 in pairs(tracks) do
		v2:AdjustSpeed(1)
	end

	clone2:Play()
	clone3:Play()
	task.wait(2.15)
	clone4:Play()
	task.wait(0.25)
	track:AdjustSpeed(0)
	task.wait(2)
	track2:AdjustSpeed(0)
	task.wait(1.6)

	for _, v2 in pairs(tracks) do
		v2:AdjustSpeed(0)
	end

	for _, effect in clone:GetDescendants() do
		if effect:IsA("Beam") then
			effect.TextureSpeed = 0
		elseif effect:IsA("ParticleEmitter") then
			effect.TimeScale = 0
		end
	end
end

return Meditation