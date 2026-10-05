local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local Network = require(game.ReplicatedStorage.Modules.Network)
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "PanHitBlur"
blurEffect.Size = 0
blurEffect.Parent = game.Lighting
local tween = TweenService:Create(script.Ringing, TweenInfo.new(3, Enum.EasingStyle.Linear), {
	Volume = 0
})
local tween2 = TweenService:Create(blurEffect, TweenInfo.new(4, Enum.EasingStyle.Linear), {
	Size = 0
})
local v = {}
local v2 = {}
local flag = false

for _, soundGroup in pairs(game.SoundService:GetChildren()) do
	if not soundGroup:IsA("SoundGroup") then
		continue
	end

	local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
	equalizerSoundEffect.HighGain = 0
	equalizerSoundEffect.MidGain = 0
	equalizerSoundEffect.LowGain = 0
	equalizerSoundEffect.Parent = soundGroup
	table.insert(v, equalizerSoundEffect)
	table.insert(v2, (TweenService:Create(equalizerSoundEffect, TweenInfo.new(3), {
		LowGain = 0,
		MidGain = 0,
		HighGain = 0
	})))
end

Network:listen("PanHit", function()
	if flag then
		return
	end

	flag = true
	tween:Cancel()
	tween2:Cancel()
	blurEffect.Size = 16
	script.Ringing.Volume = 0.05

	function controls.moveFunction(p, data, p2)
		local v3 = math.atan2(data.Z, data.X) + math.sin(os.clock() * 6) * 0.7853981633974483
		local v4 = Vector3.new(math.cos(v3), 0, (math.sin(v3))) * data.magnitude
		localPlayer.Move(p, v4, p2)
	end

	for _, v3 in pairs(v) do
		v3.HighGain = -60
		v3.MidGain = -60
		v3.LowGain = 4
	end

	for _, v3 in pairs(v2) do
		if v3.PlaybackState == Enum.PlaybackState.Begin then
			v3:Play()
		end

		v3:Cancel()
	end

	task.wait(2.5)
	tween2:Play()
	tween:Play()

	for _, v3 in pairs(v2) do
		v3:Play()
	end

	task.wait(1.5)
	controls.moveFunction = localPlayer.Move
	flag = false
end)