script.Parent.MouseButton1Click:Connect(function()
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local splashFrame = studioGui:WaitForChild("SplashFrame")
	local fileMenu = studioGui:WaitForChild("TopBar"):WaitForChild("FileMenu")
	local openSaveFrame = studioGui:WaitForChild("OpenSaveFrame")
	local openSamplesMenu = studioGui.TopBar:WaitForChild("OpenSamplesMenu")
	local saveDetailsFrame = studioGui.TopBar:WaitForChild("SaveDetailsFrame")
	local viewScriptFrame = studioGui:WaitForChild("ViewScriptFrame")
	local toolboxFrame = studioGui:WaitForChild("ToolboxFrame")
	local sel = studioGui:WaitForChild("MainBar"):WaitForChild("sel")
	local insertScriptFrame = studioGui:WaitForChild("InsertScriptFrame")
	local insertLocalScriptFrame = studioGui:WaitForChild("InsertLocalScriptFrame")
	splashFrame.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	viewScriptFrame.Visible = false
	toolboxFrame.Visible = false
	sel.Visible = false
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false

	if fileMenu.Visible then
		fileMenu.Visible = false
		return
	end

	local new = fileMenu:WaitForChild("New")
	new.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local samples = fileMenu:WaitForChild("Samples")
	samples.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local open = fileMenu:WaitForChild("Open")
	open.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local save = fileMenu:WaitForChild("Save")
	save.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Visible = true
end)