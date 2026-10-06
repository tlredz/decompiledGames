local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tpBackToGrowingUpServerFunction = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("TpBackToGrowingUpServerFunction")
script.Parent.Activated:Connect(function()
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local splashFrame = studioGui:WaitForChild("SplashFrame")
	local growingUpFrame = studioGui:WaitForChild("GrowingUpFrame")
	local tutorialFrame = studioGui:WaitForChild("TutorialFrame")
	growingUpFrame.Visible = false
	splashFrame.Visible = false
	local textButton1 = tutorialFrame:WaitForChild("TextButton1")
	textButton1.Visible = false
	local textButton2 = tutorialFrame:WaitForChild("TextButton2")
	textButton2.Visible = false
	local menuFrame = tutorialFrame:WaitForChild("MenuFrame")
	menuFrame.Visible = false
	local lines = tutorialFrame:WaitForChild("LinesFrame"):WaitForChild("Lines")
	lines.Text = "'Growing Up' loading..."
	tutorialFrame.Position = UDim2.new(0.3, 0, 0.35, 0)
	tutorialFrame.Size = UDim2.new(0.4, 0, 0, 80)
	tutorialFrame.Visible = true
	tpBackToGrowingUpServerFunction:InvokeServer()
end)