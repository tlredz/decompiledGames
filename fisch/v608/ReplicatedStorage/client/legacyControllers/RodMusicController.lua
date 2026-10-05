local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local rodmusic = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("rodmusic")
local RodMusicController = {
	Listener = nil,
	SetupPlayer = function(audioPlayer)
		if not audioPlayer:IsA("AudioPlayer") then
			return
		end

		local exclusiveFader = audioPlayer:WaitForChild("ExclusiveFader")
		exclusiveFader.WiringChanged:Connect(function(p, p2)
			if p2 ~= "Output" then
				return
			end

			if p and not audioPlayer.IsPlaying then
				audioPlayer:Play()
			elseif not p and audioPlayer.IsPlaying and #exclusiveFader:GetConnectedWires("Output") == 0 then
				audioPlayer:Stop()
			end
		end)

		if #exclusiveFader:GetConnectedWires("Output") > 0 and not audioPlayer.IsPlaying then
			audioPlayer:Play()
		end
	end,
	ResolvePlayerFromEmitter = function(_, _) end
}

function RodMusicController.Tick(_: number)
	if tick() - 0 < 0.25 then
		return
	end

	for _, v in RodMusicController.Listener:GetInteractingEmitters() do
		v:SetAttribute("MusicName")
	end
end

function RodMusicController.Start(_)
	local audioListener = Instance.new("AudioListener")
	audioListener.Name = "RodMusicListener"
	audioListener.AudioInteractionGroup = "RodMusic"
	local wire = Instance.new("Wire")
	wire.SourceInstance = audioListener
	wire.TargetInstance = SoundService:WaitForChild("AudioDeviceOutput")
	wire.Parent = audioListener
	audioListener.Parent = workspace.CurrentCamera
	RodMusicController.Listener = audioListener
	rodmusic.ChildAdded:Connect(RodMusicController.SetupPlayer)

	for _, child in rodmusic:GetChildren() do
		task.spawn(RodMusicController.SetupPlayer, child)
	end
end

return RodMusicController