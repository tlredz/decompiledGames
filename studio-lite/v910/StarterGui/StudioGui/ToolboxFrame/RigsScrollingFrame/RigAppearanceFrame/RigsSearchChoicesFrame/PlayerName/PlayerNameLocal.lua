local parent = script.Parent.Parent.Parent
local rigsSearchChoicesFrame = parent.RigsSearchChoicesFrame
local rigAppearanceTextBox = parent.RigAppearanceTextBox
local rigsSearchChoicesButton = parent.RigsSearchChoicesButton
script.Parent.Activated:Connect(function()
	rigAppearanceTextBox.Text = ""
	rigAppearanceTextBox.PlaceholderText = "Enter Player Name..."
	rigsSearchChoicesButton.Text = "Player Name"
	rigsSearchChoicesFrame.Visible = false
end)