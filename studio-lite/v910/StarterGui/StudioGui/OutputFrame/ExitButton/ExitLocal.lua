script.Parent.MouseButton1Click:Connect(function()
	script.Parent.Parent.Visible = false
	script.Parent.Parent.ScrollingFrame.ErrorTextLabel.Text = ""
	script.Parent.Parent.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
end)