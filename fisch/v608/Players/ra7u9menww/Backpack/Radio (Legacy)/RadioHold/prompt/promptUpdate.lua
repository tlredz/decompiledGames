local music = script.Parent.Parent:WaitForChild("RadioModel"):WaitForChild("MusicPlayer"):WaitForChild("Music")
music.SoundGroup = nil
script.Parent:WaitForChild("confirm").MouseButton1Click:Connect(function()
	script.Parent:WaitForChild("playAudio"):FireServer(script.Parent:WaitForChild("id").Text)
end)
script.Parent:WaitForChild("deny").MouseButton1Click:Connect(function()
	script.Parent:WaitForChild("stopAudio"):FireServer()
end)