local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local ColorizeSourceModule = require(studioLiteFolder:WaitForChild("ColorizeSourceModule"))
script.Parent.MouseButton1Click:Connect(function()
	if script.Parent.UIStroke.Color == Color3.new(0, 0, 0) then
		script.Parent.UIStroke.Color = Color3.new(1, 1, 1)
		script.Parent.Parent.ViewScriptTextLabelTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
		script.Parent.Parent.ViewScriptTextLabelTemplate.TextColor3 = Color3.new(0, 0, 0)
	else
		script.Parent.UIStroke.Color = Color3.new(0, 0, 0)
		script.Parent.Parent.ViewScriptTextLabelTemplate.BackgroundColor3 = Color3.new(0, 0, 0)
		script.Parent.Parent.ViewScriptTextLabelTemplate.TextColor3 = Color3.new(1, 1, 1)
	end

	local sL_CodeTextBox = script.Parent.Parent.ScrollingFrame:FindFirstChild("SL_CodeTextBox")

	if sL_CodeTextBox then
		sL_CodeTextBox.Text = ColorizeSourceModule:ColorizeSource(sL_CodeTextBox.ContentText, false, true)
	elseif script.Parent.Parent.ScrollingFrame:FindFirstChild("ViewScriptTextLabelTemplate") then
		local v = ""

		for _, child in pairs(script.Parent.Parent.ScrollingFrame:GetChildren()) do
			if child.Name ~= "ViewScriptTextLabelTemplate" then
				continue
			end

			v ..= child.ContentText .. "\n"
			child:Destroy()
		end

		local colorizeSource = ColorizeSourceModule:ColorizeSource(v, false, true)
		local total = 0

		for _, text in pairs(colorizeSource:split("\n")) do
			local clone = script.Parent.Parent.ViewScriptTextLabelTemplate:Clone()
			clone.Text = text
			clone.Position = UDim2.new(clone.Position.X.Scale, clone.Position.X.Offset, clone.Position.Y.Scale, total)
			clone.Visible = true
			clone.Parent = script.Parent.Parent.ScrollingFrame
			total += 16
		end
	end
end)