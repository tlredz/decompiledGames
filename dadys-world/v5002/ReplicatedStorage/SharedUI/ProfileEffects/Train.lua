local color = Color3.fromRGB(20, 20, 20)
local color2 = Color3.fromRGB(181, 181, 181)
local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return {
	TopImage = "rbxassetid://128156260972011",
	Start = function(data)
		local frame = Instance.new("Frame")
		frame.Name = "Ground"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.ZIndex = data.ZIndex
		frame.Parent = data.Container
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Rail"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Image = "rbxassetid://129476674691131"
		imageLabel.ImageColor3 = color2
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = data.ZIndex + 1
		imageLabel.Parent = data.Container
		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Name = "Train"
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.Image = "rbxassetid://72821742936827"
		imageLabel2.ImageColor3 = color2
		imageLabel2.ScaleType = Enum.ScaleType.Fit
		imageLabel2.Size = UDim2.fromScale(2.39, 0.529)
		imageLabel2.AnchorPoint = Vector2.new(0, 0.85)
		imageLabel2.Position = UDim2.fromScale(1, 0.5)
		imageLabel2.ZIndex = data.ZIndex + 2
		imageLabel2.Visible = false
		imageLabel2.Parent = data.Container
		data.Loop(10, function()
			imageLabel2.Position = UDim2.fromScale(1, 0.5)
			imageLabel2.Visible = true
			data.Tween(imageLabel2, tweenInfo, {
				Position = UDim2.fromScale(-0.6950000000000001, 0.5)
			})
			task.wait(2.5)

			if not data.IsLive() then
				return
			end

			task.wait(4)

			if not data.IsLive() then
				return
			end

			data.Tween(imageLabel2, tweenInfo2, {
				Position = UDim2.fromScale(-2.39, 0.5)
			})
			task.wait(3)
			imageLabel2.Visible = false
		end)
	end
}