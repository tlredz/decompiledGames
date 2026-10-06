local replaceButton = script.Parent.Parent.Parent.ReplaceButton
script.Parent.Activated:Connect(function()
	replaceButton.Text = script.Parent.Text
	replaceButton.universeValue.Value = script.Parent.universeValue.Value
	replaceButton.placeValue.Value = script.Parent.placeValue.Value
	script.Parent.Parent.Visible = false
end)