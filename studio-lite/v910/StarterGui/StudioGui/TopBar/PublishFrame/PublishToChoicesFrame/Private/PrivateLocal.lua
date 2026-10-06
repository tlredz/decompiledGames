local publishFrame = script.Parent.Parent.Parent.Parent.PublishFrame
local publishToButton = publishFrame:WaitForChild("PublishToButton")
local replaceButton = publishFrame:WaitForChild("ReplaceButton")
local privatePlaceIdTextBox = publishFrame:WaitForChild("PrivatePlaceIdTextBox")
local privateUniverseIdTextBox = publishFrame:WaitForChild("PrivateUniverseIdTextBox")
local privatePlaceIdTextLabel = publishFrame:WaitForChild("PrivatePlaceIdTextLabel")
local privateUniverseIdTextLabel = publishFrame:WaitForChild("PrivateUniverseIdTextLabel")
script.Parent.Activated:Connect(function()
	publishToButton.Text = script.Parent.Text
	script.Parent.Parent.Visible = false
	replaceButton.Visible = false
	privatePlaceIdTextBox.Visible = true
	privateUniverseIdTextBox.Visible = true
	privatePlaceIdTextLabel.Visible = true
	privateUniverseIdTextLabel.Visible = true
end)