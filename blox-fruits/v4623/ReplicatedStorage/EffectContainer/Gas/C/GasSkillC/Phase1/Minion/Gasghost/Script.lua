script.Parent:WaitForChild("AnimationController"):LoadAnimation(script.Parent:WaitForChild("Animation")):Play(
	0,
	nil,
	1 + math.random() * 0.15
)