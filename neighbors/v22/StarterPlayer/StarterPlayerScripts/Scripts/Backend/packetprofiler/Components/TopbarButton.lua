local modules = script.Parent.Parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)

local function TopbarButton(props)
	return Roact.createElement("TextButton", {
		AutoLocalize = false,
		TextColor3 = props.Theme.Name == "Light" and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(0, 10),
		BackgroundColor3 = props.Theme:GetColor("Item"),
		TextSize = 11,
		BorderSizePixel = 0,
		Font = Enum.Font.Code,
		Text = props.Text,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		LayoutOrder = props.LayoutOrder,
		[Roact.Event.Activated] = props.OnClick
	})
end

return TopbarButton