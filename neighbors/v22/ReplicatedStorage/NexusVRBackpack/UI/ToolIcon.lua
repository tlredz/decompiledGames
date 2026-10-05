local ToolIcon = {}
ToolIcon.__index = ToolIcon

function ToolIcon.new(parent, p: number, p2: number)
	local v = {
		Focused = false,
		Players = game:GetService("Players"),
		TweenService = game:GetService("TweenService"),
		RelativePositionX = p * 0.8660254037844386 + 0.5,
		RelativePositionY = p2 * 0.75 + 0.5,
		ToolEvents = {}
	}
	local self = setmetatable(v, ToolIcon)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
	imageLabel.Position = UDim2.new(self.RelativePositionX, 0, self.RelativePositionY, 0)
	imageLabel.Image = "http://www.roblox.com/asset/?id=10708006436"
	imageLabel.ImageColor3 = Color3.new(0.1, 0.1, 0.1)
	imageLabel.ImageTransparency = 0.8
	imageLabel.Parent = parent
	self.Background = imageLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel.Size = UDim2.new(0.625, 0, 0.625, 0)
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Text = ""
	textLabel.TextSize = imageLabel.AbsoluteSize.Y * 0.625 / 4
	textLabel.TextWrapped = true
	textLabel.Visible = false
	textLabel.Parent = imageLabel
	self.ToolText = textLabel
	imageLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		textLabel.TextSize = imageLabel.AbsoluteSize.Y * 0.625 / 4
	end)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel2.Size = UDim2.new(0.625, 0, 0.625, 0)
	imageLabel2.Visible = false
	imageLabel2.Parent = imageLabel
	self.ToolImage = imageLabel2
	return self
end

function ToolIcon:UpdateColor()
	if self.Tool then
		if self.Tool.TextureId == "" then
			self.ToolText.Visible = true
			self.ToolImage.Visible = false
			self.ToolText.Text = self.Tool.Name
		else
			self.ToolText.Visible = false
			self.ToolImage.Visible = true
			self.ToolImage.Image = self.Tool.TextureId
		end
	else
		self.ToolText.Visible = false
		self.ToolImage.Visible = false
	end

	local color = Color3.new(0.1, 0.1, 0.1)
	local imageTransparency = self.Tool and 0.5 or 0.8
	local uDim = self.Tool and self.Focused and UDim2.new(1.05, 0, 1.05, 0) or UDim2.new(0.9, 0, 0.9, 0)

	if self.Tool then
		local localPlayer = self.Players.LocalPlayer

		if localPlayer.Character and localPlayer.Character == self.Tool.Parent then
			if self.Focused then
				color = Color3.new(0.2, 1, 0.2)
			else
				color = Color3.new(0, 0.7, 0)
			end
		elseif self.Focused then
			color = Color3.new(0.2, 0.2, 0.2)
		end
	end

	self.TweenService:Create(self.Background, TweenInfo.new(0.1), {
		Size = uDim,
		ImageColor3 = color,
		ImageTransparency = imageTransparency
	}):Play()
end

function ToolIcon:SetTool(tool)
	if tool == self.Tool then
		return
	end

	self.Tool = tool

	for _, toolEvent in self.ToolEvents do
		toolEvent:Disconnect()
	end

	self.ToolEvents = {}
	self:UpdateColor()

	if not tool then
		return
	end

	table.insert(self.ToolEvents, tool.Changed:Connect(function(p)
		if p ~= "Name" and p ~= "TextureId" and p ~= "Parent" then
			return
		end

		self:UpdateColor()
	end))
end

function ToolIcon:SetFocused(focused: boolean)
	self.Focused = focused
	self:UpdateColor()
end

function ToolIcon:Destroy()
	self.Background:Destroy()

	for _, toolEvent in self.ToolEvents do
		toolEvent:Disconnect()
	end

	self.ToolEvents = {}
end

return ToolIcon