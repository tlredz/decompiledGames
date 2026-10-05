local track = script.Parent:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation((script:WaitForChild("Animation")))
track.Looped = true
track:Play()