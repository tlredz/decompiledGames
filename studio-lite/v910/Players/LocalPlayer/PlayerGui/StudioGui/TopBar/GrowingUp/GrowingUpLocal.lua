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
	local growingUpFrame = studioGui:WaitForChild("GrowingUpFrame")
	local splashFrame = studioGui:WaitForChild("SplashFrame")
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	viewScriptFrame.Visible = false
	toolboxFrame.Visible = false
	sel.Visible = false
	insertScriptFrame.Visible = false
	insertLocalScriptFrame.Visible = false
	splashFrame.Visible = false
	local count = 0

	for _, v in pairs(_G.badgesYN) do
		if v == "Y" then
			count += 1
		end
	end

	local line2 = growingUpFrame:WaitForChild("LinesFrame"):WaitForChild("Line2")

	if count >= 1 then
		line2.Text = "Congratulations!  You completed the age 20 college class in “Growing Up”.  Or you can stay and learn more."
	else
		line2.Text = "You must complete one tutorial here in “Studio Lite” to pass the age 20 college class in “Growing Up”."
	end

	growingUpFrame.Visible = true
end)