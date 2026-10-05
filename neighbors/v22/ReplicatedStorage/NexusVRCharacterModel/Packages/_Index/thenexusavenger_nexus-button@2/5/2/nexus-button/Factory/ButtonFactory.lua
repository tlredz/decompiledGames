local color = Color3.fromRGB(-30, -30, -30)
local Button = require(script.Parent.Parent:WaitForChild("Button"))
local ButtonFactory = {}
ButtonFactory.__index = ButtonFactory

function ButtonFactory.AddColor3(color2: Color3, color3: Color3)
	return Color3.new(
		math.clamp(color2.R + color3.R, 0, 1),
		math.clamp(color2.G + color3.G, 0, 1),
		(math.clamp(color2.B + color3.B, 0, 1))
	)
end

function ButtonFactory.CreateDefault(color2: Color3)
	local v = ButtonFactory.new()
	v:SetDefault("BackgroundColor3", color2)
	v:SetDefault("BorderColor3", ButtonFactory.AddColor3(color2, color))
	v:SetDefault("BorderTransparency", 0.25)
	return v
end

function ButtonFactory.new()
	return (setmetatable({
		Defaults = {}
	}, ButtonFactory))
end

function ButtonFactory.Create(p)
	local defaults = Button.new()

	for k, default in p.Defaults do
		defaults[k] = default
	end

	return defaults
end

function ButtonFactory:SetDefault(p2: string, p3)
	self.Defaults[p2] = p3
end

function ButtonFactory.UnsetDefault(p, p2: string)
	p.Defaults[p2] = nil
end

return ButtonFactory