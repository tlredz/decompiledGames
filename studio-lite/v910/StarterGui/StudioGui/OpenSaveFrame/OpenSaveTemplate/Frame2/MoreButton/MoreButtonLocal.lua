local textLabel = game.Players.LocalPlayer.PlayerGui.StudioGui.OpenSaveFrame.TextLabel
local frame2 = script.Parent.Parent.Parent:WaitForChild("Frame2")
local frame3 = script.Parent.Parent.Parent:WaitForChild("Frame3")
local frame4 = script.Parent.Parent.Parent:WaitForChild("Frame4")
frame2:WaitForChild("MoreButton")
local nearMoreTextLabel = frame2:WaitForChild("NearMoreTextLabel")
local nearShareTextLabel = frame4:WaitForChild("NearShareTextLabel")
script.Parent.Activated:Connect(function()
	if frame3.Visible then
		if #nearShareTextLabel.Text > 1 then
			local text = nearMoreTextLabel.Text
			local backgroundColor3 = nearMoreTextLabel.BackgroundColor3
			nearMoreTextLabel.Text = nearShareTextLabel.Text
			nearMoreTextLabel.BackgroundColor3 = nearShareTextLabel.BackgroundColor3
			nearShareTextLabel.Text = text
			nearShareTextLabel.BackgroundColor3 = backgroundColor3
		end

		frame3.Visible = false
		frame4.Visible = false
		script.Parent.Text = "More..."
	else
		if #nearShareTextLabel.Text > 1 then
			local text = nearMoreTextLabel.Text
			local backgroundColor3 = nearMoreTextLabel.BackgroundColor3
			nearMoreTextLabel.Text = nearShareTextLabel.Text
			nearMoreTextLabel.BackgroundColor3 = nearShareTextLabel.BackgroundColor3
			nearShareTextLabel.Text = text
			nearShareTextLabel.BackgroundColor3 = backgroundColor3
		end

		if frame4.ShareButton.Text == "Share" then
			frame4.DeleteButton.Visible = true
		else
			frame4.DeleteButton.Visible = false
		end

		frame3.Visible = true

		if textLabel.Text:sub(1, 7) == "Restore" then
			frame4.Visible = false
		else
			frame4.Visible = true
		end

		script.Parent.Text = "Less..."
	end
end)