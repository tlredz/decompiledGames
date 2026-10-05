local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local modules = script.Parent.Parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local v = not RunService:IsRunning()

local function TopbarOptionsButton(props)
	return Roact.createElement("TextButton", {
		AutoLocalize = false,
		Text = props.ButtonName,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		Font = Enum.Font.Code,
		TextColor3 = props.Theme.Name == "Light" and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
		TextSize = 12,
		BackgroundColor3 = props.Theme:GetColor("ScrollBarBackground"),
		Size = props.Size,
		BorderSizePixel = 0,
		[Roact.Event.Activated] = props.OnClick
	})
end

local extended = Roact.Component:extend("TopbarButtonsGroup")

function extended:init()
	local binding, setMouseHovering = Roact.createBinding(0)
	self.MouseHovering = binding
	self.SetMouseHovering = setMouseHovering
	self.TopbarRef = Roact.createRef()
end

function extended.render(props)
	local props2 = props.props
	local textSize = TextService:GetTextSize(props2.Text, 12, Enum.Font.Code, Vector2.new(10000, 11))
	local X = textSize.X
	local v2 = {}

	for _, option in props2.Options do
		X = math.max(X, TextService:GetTextSize(option.Name, 11, Enum.Font.Code, Vector2.new(10000, 11)).X)
	end

	for _, option in props2.Options do
		table.insert(v2, TopbarOptionsButton({
			ButtonName = option.Name,
			OnClick = option.Callback,
			Theme = props2.Theme,
			Size = UDim2.fromOffset(X, 11)
		}))
	end

	return Roact.createElement("TextLabel", {
		AutoLocalize = false,
		Text = props2.Text,
		TextColor3 = props2.Theme.Name == "Light" and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
		BackgroundColor3 = props.MouseHovering:map(function(p)
			return p > 0 and props2.Theme:GetColor("Light") or props2.Theme:GetColor("ScrollBarBackground")
		end),
		TextSize = 12,
		Font = Enum.Font.Code,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(textSize.X, 10),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		LayoutOrder = props2.LayoutOrder,
		Visible = not v,
		[Roact.Event.MouseEnter] = function()
			props.SetMouseHovering(1)
		end,
		[Roact.Event.MouseLeave] = function()
			task.defer(function()
				if props.MouseHovering:getValue() == 1 then
					props.SetMouseHovering(0)
				end
			end)
		end,
		[Roact.Ref] = props.TopbarRef
	}, {
		OptionsHolder = Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = props.MouseHovering:map(function(p)
				return p > 0
			end),
			Position = UDim2.fromOffset(0, 10),
			[Roact.Event.MouseEnter] = function()
				props.SetMouseHovering(2)
			end,
			[Roact.Event.MouseLeave] = function()
				task.defer(function()
					if props.MouseHovering:getValue() == 2 then
						props.SetMouseHovering(0)
					end
				end)
			end,
			Size = UDim2.fromOffset(X, 0)
		}, {
			OptionsListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top
			}),
			Buttons = Roact.createFragment(v2)
		})
	})
end

return extended