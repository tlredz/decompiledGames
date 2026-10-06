if not _G.DynamicThumb then
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
	local ColorizeSourceModule = require(studioLiteFolder:WaitForChild("ColorizeSourceModule"))
	script.Parent.Text = ColorizeSourceModule:ColorizeSource(script.Parent.ContentText, false, true)
	script.Parent.Focused:Connect(function()
		script.Parent.Text = script.Parent.ContentText
		script.Parent.CursorPosition = 0
	end)
	script.Parent.FocusLost:Connect(function()
		task.wait()
		local saveChangesTo = script.Parent:WaitForChild("SaveChangesTo")
		saveChangesTo.Value.Text = script.Parent.ContentText
		script.Parent.Text = ColorizeSourceModule:ColorizeSource(script.Parent.ContentText, false, true)
	end)
end