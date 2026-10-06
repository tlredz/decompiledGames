local parent = script.Parent
game.TweenService:Create(parent, TweenInfo.new(0.1), {
	TextTransparency = 0,
	TextStrokeTransparency = 0
}):Play()
wait(math.random(30, 40) / 10)
game.TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
	TextTransparency = 1,
	TextStrokeTransparency = 1,
	Size = UDim2.new(1, 0, 0, 0)
}):Play()
wait(0.3)
script:Destroy()