local Toggle = require(ReplicatedStorage.UISystems.Components.Toggle)
return {
	summary = "Toggle settings : pill 2:1, knob tweené gauche (off) ↔ droite (on), label On/Off.",
	controls = {
		Label = "Trophy",
		Initial = false
	},
	render = function(p)
		local target = p.target
		local frame = Instance.new("Frame")
		frame.Name = "ToggleStoryBackdrop"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromOffset(600, 200)
		frame.BackgroundColor3 = Color3.fromRGB(46, 46, 80)
		frame.Parent = target
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 12)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "ToggleHolder"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.35)
		frame2.Size = UDim2.new(0.9, 0, 0, 70)
		frame2.BackgroundTransparency = 1
		frame2.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Feedback"
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Position = UDim2.new(0.5, 0, 1, -16)
		textLabel.Size = UDim2.new(0.9, 0, 0, 35)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.Text = "clique le toggle"
		textLabel.Parent = frame
		local v = Toggle.Create({
			parent = frame2,
			size = UDim2.fromScale(1, 1),
			label = p.controls.Label,
			initial = p.controls.Initial,
			onChanged = function(p2)
				local text = p2 and "ON" or "OFF"
				textLabel.Text = text
				print("[Toggle.story]", text)
			end
		})
		return function()
			v:Destroy()
			frame:Destroy()
		end
	end
}