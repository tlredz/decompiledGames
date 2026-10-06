script.Parent.MouseButton1Click:Connect(function()
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local fileMenu = studioGui:WaitForChild("TopBar"):WaitForChild("FileMenu")
	local openSaveFrame = studioGui:WaitForChild("OpenSaveFrame")
	local openSamplesMenu = studioGui.TopBar:WaitForChild("OpenSamplesMenu")
	local saveDetailsFrame = studioGui.TopBar:WaitForChild("SaveDetailsFrame")
	local viewScriptFrame = studioGui:WaitForChild("ViewScriptFrame")
	local toolboxFrame = studioGui:WaitForChild("ToolboxFrame")
	local sel = studioGui:WaitForChild("MainBar"):WaitForChild("sel")
	local insertScriptFrame = studioGui:WaitForChild("InsertScriptFrame")
	local insertLocalScriptFrame = studioGui:WaitForChild("InsertLocalScriptFrame")
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	viewScriptFrame.Visible = false
	toolboxFrame.Visible = false
	sel.Visible = false
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false
	script.Parent.Parent.Parent.TutorialFrame.Visible = false
	script.Parent.Parent.Parent.TeacherPointingFrame.Visible = false
	script.Parent.Parent.Parent.SplashFrame.Visible = not script.Parent.Parent.Parent.SplashFrame.Visible
end)