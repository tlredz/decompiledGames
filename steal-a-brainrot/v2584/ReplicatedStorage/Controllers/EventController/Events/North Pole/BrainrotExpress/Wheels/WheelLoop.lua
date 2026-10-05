local wheelLoop = script.WheelLoop
local track = script.Parent.AnimationController:WaitForChild("Animator"):LoadAnimation(wheelLoop)
track.Looped = true
track:Play()