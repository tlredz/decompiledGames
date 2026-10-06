local parent = script.Parent.Parent.Parent
local rigsSearchChoicesFrame = parent.RigsSearchChoicesFrame
local rigAppearanceTextBox = parent.RigAppearanceTextBox
local rigsSearchChoicesButton = parent.RigsSearchChoicesButton
script.Parent.Activated:Connect(function()
	rigAppearanceTextBox.Text = ""
	rigAppearanceTextBox.PlaceholderText = "Enter Bundle ID..."
	rigsSearchChoicesButton.Text = "Bundle ID"
	rigsSearchChoicesFrame.Visible = false
end)