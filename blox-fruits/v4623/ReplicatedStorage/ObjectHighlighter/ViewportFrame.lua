game:GetService("Workspace")
local HighlightAdornee = require(game.ReplicatedStorage.Util.HighlightAdornee)
local ViewportFrame = {}
ViewportFrame.__index = ViewportFrame

function ViewportFrame.withReferences(objectRef)
	local object = setmetatable({
		objectRef = objectRef,
		dot = nil,
		rbx = nil
	}, ViewportFrame)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageTransparency = 0.5
	imageLabel.Image = "rbxassetid://2091181653"
	imageLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.new(0, 0, 0, 0)

	if objectRef.worldModel:IsA("Model") then
		local highlight = Instance.new("Highlight", objectRef.worldModel)
		highlight.Adornee = HighlightAdornee(objectRef.worldModel)
		highlight.FillColor = Color3.new(1)
		highlight.OutlineColor = Color3.new(1)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		object.rbx = highlight
		imageLabel:GetPropertyChangedSignal("ImageColor3"):Connect(function()
			object.rbx.FillColor = imageLabel.ImageColor3
			object.rbx.OutlineColor = imageLabel.ImageColor3
		end)
	else
		object.rbx = {}
	end

	object.dot = imageLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Text = ""
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Font = Enum.Font.SourceSansLight
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Size = UDim2.new(0, 1, 0, 1)
	object.name = textLabel
	return object
end

function ViewportFrame.getReference(p)
	return p.objectRef
end

function ViewportFrame.requestParent(p, parent)
	return pcall(function()
		p.dot.Parent = parent
		p.name.Parent = parent
	end)
end

function ViewportFrame.destruct(data)
	pcall(function()
		data.rbx:Destroy()
	end)
	data.dot:Destroy()
	data.name:Destroy()
end

return ViewportFrame