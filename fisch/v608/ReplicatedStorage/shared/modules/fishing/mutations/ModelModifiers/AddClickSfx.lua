game:GetService("ReplicatedStorage")
require("../util")
local AddClickSfx = {}

function AddClickSfx.MutateModel(p, data)
	local rollOffMinDistance = math.max(p.ExtentsSize.X, p.ExtentsSize.Y, p.ExtentsSize.Z)
	local sound = Instance.new("Sound")
	sound.SoundId = data.SoundId
	sound.Volume = data.Volume or 1
	sound.PlaybackSpeed = data.PlaybackSpeed or 1
	sound.RollOffMinDistance = rollOffMinDistance
	sound.RollOffMaxDistance = math.max(rollOffMinDistance * 4, 128)
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.Name = "MutationSound"
	sound.Parent = p.Center

	if data.Autoplay then
		task.delay(function()
			sound:Play()
		end)
	end
end

function AddClickSfx.new(p)
	p.Type = "AddClickSfx"
	return p
end

return AddClickSfx