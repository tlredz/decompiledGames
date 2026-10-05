local Defaults = {
	Frame = function(p)
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.Size = UDim2.fromOffset(100, 100)
		p.BorderSizePixel = 0
		p.BorderColor3 = Color3.new(0, 0, 0)
	end,
	BillboardGui = function(p)
		p.Size = UDim2.fromOffset(100, 100)
	end,
	TextLabel = function(p)
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.Size = UDim2.fromOffset(100, 100)
		p.BorderSizePixel = 0
		p.BorderColor3 = Color3.new(0, 0, 0)
		p.Text = ""
	end,
	TextButton = function(p)
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.Size = UDim2.fromOffset(100, 100)
		p.BorderSizePixel = 0
		p.BorderColor3 = Color3.new(0, 0, 0)
		p.Text = ""
	end,
	TextBox = function(p)
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.Size = UDim2.fromOffset(100, 100)
		p.BorderSizePixel = 0
		p.BorderColor3 = Color3.new(0, 0, 0)
		p.Text = ""
	end,
	ScrollingFrame = function(p)
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.Size = UDim2.fromOffset(100, 100)
		p.BorderSizePixel = 0
		p.BorderColor3 = Color3.new(0, 0, 0)
		p.ScrollBarImageColor3 = Color3.new()
	end
}
Defaults.VideoFrame = Defaults.Frame
Defaults.ViewportFrame = Defaults.Frame
Defaults.ImageLabel = Defaults.Frame
Defaults.ImageButton = Defaults.Frame
Defaults.CanvasGroup = Defaults.Frame
return Defaults