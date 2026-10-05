local color = Color3.fromRGB(-30, -30, -30)
require(script.Parent.Parent:WaitForChild("Button"))
local ButtonFactory = require(script.Parent:WaitForChild("ButtonFactory"))
local TextButtonFactory = {}
TextButtonFactory.__index = TextButtonFactory
setmetatable(TextButtonFactory, ButtonFactory)

function TextButtonFactory.CreateDefault(color2: Color3)
	local v = TextButtonFactory.new()
	v:SetDefault("BackgroundColor3", color2)
	v:SetDefault("BorderColor3", ButtonFactory.AddColor3(color2, color))
	v:SetDefault("BorderTransparency", 0.25)
	v:SetTextDefault("Font", Enum.Font.SourceSans)
	v:SetTextDefault("TextColor3", Color3.fromRGB(255, 255, 255))
	v:SetTextDefault("TextStrokeColor3", Color3.fromRGB(0, 0, 0))
	v:SetTextDefault("TextStrokeTransparency", 0)
	v:SetTextDefault("TextScaled", true)
	return v
end

function TextButtonFactory.new()
	local self = setmetatable(ButtonFactory.new(), TextButtonFactory)
	self.TextDefaults = {}
	return self
end

function TextButtonFactory.Create(p)
	local v = ButtonFactory.Create(p)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.ZIndex = 5
	textLabel.Parent = v:GetAdornFrame()

	for k, textDefault in p.TextDefaults do
		textLabel[k] = textDefault
	end

	return v, textLabel
end

function TextButtonFactory:SetTextDefault(p2: string, p3)
	self.TextDefaults[p2] = p3
end

function TextButtonFactory.UnsetTextDefault(p, p2: string)
	p.TextDefaults[p2] = nil
end

return TextButtonFactory