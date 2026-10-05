function HandleTextBox(p)
	local function MakeSelectable()
		p.Parent.TextBox.Size = UDim2.new(0, p.Parent.TextBounds.X - p.Parent.Fake.TextBounds.X, 1, 0)
		p.Parent.TextBox.Position = UDim2.fromOffset(p.Parent.Fake.TextBounds.X, 0)
	end

	p.Parent.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		p.Parent.TextBox.Text = p.Parent.TextBox:GetAttribute("TrueText") or ""
	end)
	p.Parent:GetPropertyChangedSignal("TextBounds"):Connect(MakeSelectable)
	MakeSelectable()
end

for _, frame in pairs(script.Parent:GetChildren()) do
	if not frame:IsA("Frame") then
		continue
	end

	task.wait()
	HandleTextBox(frame.ServerName.TextBox)
end