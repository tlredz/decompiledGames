local _ = game.Players.LocalPlayer
local parent = script.Parent
local service = game:service("TweenService")
service:Create(script.Object.Value, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
	Volume = 0
}):Play()
service:Create(parent, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
	ImageTransparency = 0
}):Play()
task.delay(0.15, function()
	script.Parent.Parent:SetAttribute("Wow", true)
end)
task.wait(0.18)
service:Create(parent, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
	ImageColor3 = Color3.new(1, 1, 1)
}):Play()
task.delay(0.4, function()
	task.delay(0.07, function()
		script.Object.Value:Stop()
	end)
	shared.sfx({
		SoundId = "rbxassetid://11343003352",
		Parent = workspace,
		Volume = 7
	}):Play()
end)