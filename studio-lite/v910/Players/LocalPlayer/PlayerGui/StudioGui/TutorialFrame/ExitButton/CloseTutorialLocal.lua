script.Parent.MouseButton1Click:Connect(function()
	local parent = script.Parent.Parent
	parent.Visible = false
	local teacherPointingFrame = parent.Parent:WaitForChild("TeacherPointingFrame")
	teacherPointingFrame.Visible = false
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(0, parent.AbsolutePosition.X, 0, parent.AbsoluteSize.Y)
	frame.Size = parent.Size
	frame.BackgroundColor3 = parent.BackgroundColor3
	frame.ZIndex = parent.ZIndex
	frame.Parent = parent.Parent
	frame:TweenSizeAndPosition(
		UDim2.new(0, parent.Parent.TopBar.TUTORIALS.AbsoluteSize.X, 0, parent.Parent.TopBar.TUTORIALS.AbsoluteSize.Y),
		UDim2.new(0, parent.Parent.TopBar.TUTORIALS.AbsolutePosition.X, 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.4
	)
	task.wait(0.4)
	frame:Destroy()
end)