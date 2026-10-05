if not script:IsDescendantOf(workspace) then
	return
end

local waveLoop = script.Parent.AnimationController.WaveLoop
local track = script.Parent.AnimationController:WaitForChild("Animator"):LoadAnimation(waveLoop)
track.Looped = true
track:Play()
track:AdjustSpeed(0.33)