if not script:IsDescendantOf(workspace) then
	return
end

local track = script.Parent:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script.Animation)
track.Looped = true
track:Play()