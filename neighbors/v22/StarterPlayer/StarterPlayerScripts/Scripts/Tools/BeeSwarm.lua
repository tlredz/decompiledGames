local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local _ = ReplicatedStorage.Modules
local Network = require(ReplicatedStorage.Modules.Network)
local tweens = {}
local imageLabel = localPlayer.PlayerGui:WaitForChild("Damage"):WaitForChild("ImageLabel")
local bees = script:WaitForChild("Bees")
local tween = TweenService:Create(imageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	ImageTransparency = 1
})
local cframe = CFrame.new(0, 0, -4)

local function enableParticleEmitters(enabled: boolean)
	for _, emitter in bees:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function startBeesLoop()
	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (currentCamera and character and humanoid and animator) then
		return nil
	end

	local track = animator:LoadAnimation(script.Idle)
	local track2 = animator:LoadAnimation(script.Run)
	local flag = true
	track.Priority = Enum.AnimationPriority.Idle
	track2.Priority = Enum.AnimationPriority.Movement
	bees.Parent = currentCamera

	function controls.moveFunction(_, data, p)
		local v = math.atan2(data.Z, data.X) + math.sin(os.clock() * 6) * 0.7853981633974483
		local magnitude = data.magnitude
		localPlayer:Move(Vector3.new(math.cos(v), 0, (math.sin(v))) * magnitude, p)
	end

	enableParticleEmitters(true)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		bees.CFrame = currentCamera.CFrame * cframe

		if flag then
			if humanoid.MoveDirection.Magnitude > 0 then
				if track.IsPlaying then
					track:Stop()
				end

				if not track2.IsPlaying then
					track2:Play()
				end
			else
				if not track.IsPlaying then
					track:Play()
				end

				if track2.IsPlaying then
					track2:Stop()
				end
			end
		else
			if track.IsPlaying then
				track:Stop(0.1)
			end

			if track2.IsPlaying then
				track2:Stop(0.1)
			end

			track:Destroy()
			track2:Destroy()
		end
	end)
	return function()
		flag = false
		controls.moveFunction = localPlayer.Move
		enableParticleEmitters(false)

		for _, v in tweens do
			v:Play()
		end

		task.wait(1)
		bees.Parent = script
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

Network:listen("BeeSwarm", function()
	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (currentCamera and character and humanoid and animator) then
		return
	end

	if #tweens == 0 then
		for _, soundGroup in SoundService:GetChildren() do
			if not soundGroup:IsA("SoundGroup") then
				continue
			end

			local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
			equalizerSoundEffect.HighGain = 0
			equalizerSoundEffect.MidGain = 0
			equalizerSoundEffect.LowGain = 0
			equalizerSoundEffect.Parent = soundGroup
			local tween2 = TweenService:Create(equalizerSoundEffect, TweenInfo.new(3), {
				LowGain = 0,
				MidGain = 0,
				HighGain = 0
			})
			table.insert(tweens, tween2)
		end
	end

	local v = startBeesLoop()

	for _, v2 in tweens do
		if v2.PlaybackState == Enum.PlaybackState.Begin then
			v2:Play()
		end

		v2:Cancel()
	end

	while not character:GetAttribute("Swarming") do
		task.wait()
	end

	while character.Parent and character:GetAttribute("Swarming") do
		tween:Cancel()
		imageLabel.ImageTransparency = 0.5
		tween:Play()
		script.Sting.SoundGroup = nil
		script.Sting:Play()
		task.wait(1)
	end

	if v then
		v()
	end
end)