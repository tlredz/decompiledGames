script.Parent.MouseButton1Click:Connect(function()
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local splashFrame = studioGui:WaitForChild("SplashFrame")
	local growingUpFrame = studioGui:WaitForChild("GrowingUpFrame")
	local tutorialFrame = studioGui:WaitForChild("TutorialFrame")
	growingUpFrame.Visible = false

	if tutorialFrame.Visible == false then
		splashFrame.Visible = true
	end
end)