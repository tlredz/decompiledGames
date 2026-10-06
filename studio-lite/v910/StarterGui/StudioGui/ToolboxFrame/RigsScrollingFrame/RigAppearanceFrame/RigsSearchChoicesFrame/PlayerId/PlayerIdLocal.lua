local parent = script.Parent.Parent.Parent
local rigsSearchChoicesFrame = parent.RigsSearchChoicesFrame
local rigAppearanceTextBox = parent.RigAppearanceTextBox
local rigsSearchChoicesButton = parent.RigsSearchChoicesButton
script.Parent.Activated:Connect(function()
	rigAppearanceTextBox.Text = ""
	rigAppearanceTextBox.PlaceholderText = "Enter Player UserId..."
	rigsSearchChoicesButton.Text = "Player UserId"
	rigsSearchChoicesFrame.Visible = false
end)