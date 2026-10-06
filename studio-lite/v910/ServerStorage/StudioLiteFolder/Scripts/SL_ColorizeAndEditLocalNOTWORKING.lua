if not _G.DynamicThumb then
	local viewScriptFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("ViewScriptFrame")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
	local ColorizeSourceModule = require(studioLiteFolder:WaitForChild("ColorizeSourceModule"))
	script.Parent.Focused:Connect(function()
		script.Parent.Text = script.Parent.ContentText
	end)

	while not viewScriptFrame.Visible do
		task.wait(0.2)
	end

	while viewScriptFrame.Visible do
		print("SL_ 2 sec update")
		local v = script.Parent.ContentText:match("(.-)\n", script.Parent.CursorPosition) or ""
		script.Parent.Text = ColorizeSourceModule:ColorizeSource(script.Parent.ContentText, false, true)
		local saveChangesTo = script.Parent:WaitForChild("SaveChangesTo")
		saveChangesTo.Value.Text = script.Parent.ContentText
		local v2 = script.Parent.ContentText:match("(.-)\n", script.Parent.CursorPosition) or ""
		script.Parent.CursorPosition += #v2 - #v
		task.wait(2)
	end
end