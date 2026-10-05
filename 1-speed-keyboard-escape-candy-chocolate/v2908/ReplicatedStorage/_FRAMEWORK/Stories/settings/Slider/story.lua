local Slider = require(ReplicatedStorage.UISystems.Components.Slider)
return {
	summary = "Slider settings : drag (souris/touch) + saisie % au clavier. Fill = RatioFrame, curseur = SliderKnob.",
	controls = {
		Label = "Music AA",
		InitialPercent = 50
	},
	render = function(p)
		local target = p.target
		local frame = Instance.new("Frame")
		frame.Name = "SliderStoryBackdrop"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromOffset(450, 260)
		frame.BackgroundColor3 = Color3.fromRGB(46, 46, 80)
		frame.Parent = target
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 12)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "SliderHolder"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.35)
		frame2.Size = UDim2.new(0.9, 0, 0, 120)
		frame2.BackgroundTransparency = 1
		frame2.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Feedback"
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Position = UDim2.new(0.5, 0, 1, -16)
		textLabel.Size = UDim2.new(0.9, 0, 0, 40)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.Text = "drag / tape une valeur"
		textLabel.Parent = frame
		local v = Slider.Create({
			parent = frame2,
			size = UDim2.fromScale(1, 1),
			label = p.controls.Label,
			min = 0,
			max = 100,
			step = 5,
			suffix = "%",
			initial = math.clamp(p.controls.InitialPercent, 0, 100),
			onChanged = function(p2, p3)
				local text = string.format("%g%%%s", p2, p3 and "  [FINAL]" or "")
				textLabel.Text = text

				if p3 then
					print("[Slider.story]", text)
				end
			end
		})
		return function()
			v:Destroy()
			frame:Destroy()
		end
	end
}