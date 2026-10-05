local React = require(game.ReplicatedStorage.Packages.React)
local Motion = require(script.Parent.Motion)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local vector = Vector2.new(0, 0)
local vector2 = Vector2.new(100, 100)

local function splitTitle(value: string)
	local v, v2 = string.match(value, "^%[([%w]+)%]%s*(.*)$")

	if v then
		return v, v2
	end

	return nil, value
end

local function HeaderBar(props)
	local height = props.Height or Theme.HeaderHeight
	local zIndex = props.ZIndex or 20
	local collapsed = props.Collapsed == true
	local title = props.Title
	local text, v2 = string.match(title, "^%[([%w]+)%]%s*(.*)$")

	if text then
		title = v2
	else
		text = nil
	end

	local v3

	if collapsed then
		v3 = math.max(16, height - 14)
	else
		v3 = height - 18
	end

	local v4 = height - 5
	local v5 = (props.OnMinimize and 1 or 0) + (props.OnExit and 1 or 0)
	local v6

	if v5 > 0 then
		v6 = v4 * v5
	else
		v6 = height
	end

	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local v9 = {
		BackgroundColor3 = Theme.Header,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, height),
		ZIndex = zIndex
	}
	local v10 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerWindow)
		}),
		BottomFill = 0,
		Brand = 0,
		Divider = 0,
		HitArea = 0,
		Minimize = 0,
		Exit = 0
	}
	local bottomFill

	if not collapsed then
		bottomFill = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme.Header,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, Theme.CornerWindow),
			ZIndex = zIndex
		})
	end

	v10.BottomFill = bottomFill
	local v14 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(collapsed and 8 or 11, 0),
		Size = UDim2.new(1, -(v6 + (collapsed and 12 or 22)), 1, 0),
		ZIndex = zIndex + 1
	}
	local v15 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Chip = createElement("Frame", {
			BackgroundColor3 = Theme.AccentDim,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(v3, v3),
			ZIndex = zIndex + 1
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			Glyph = createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Theme.FontBold,
				Size = UDim2.fromScale(1, 1),
				Text = "≡",
				TextColor3 = Theme.Accent,
				TextSize = v3 - 4,
				TextStrokeTransparency = 1,
				ZIndex = zIndex + 1
			})
		}),
		Title = 0,
		Badge = 0
	}
	local v18 = {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 2,
		RichText = false,
		Size = UDim2.fromOffset(0, height),
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 0
	}
	local textSize

	if collapsed then
		textSize = Theme.ControlTextSize
	else
		textSize = Theme.HeaderTextSize
	end

	v18.TextSize = textSize
	v18.TextXAlignment = Enum.TextXAlignment.Left
	v18.TextYAlignment = Enum.TextYAlignment.Center
	v18.ZIndex = zIndex + 1
	v15.Title = createElement("TextLabel", v18)
	local badge

	if text and not collapsed then
		badge = createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.PanelDark,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			LayoutOrder = 3,
			RichText = false,
			Size = UDim2.fromOffset(0, 18),
			Text = text,
			TextColor3 = Theme.TextSubtle,
			TextSize = 13,
			TextStrokeTransparency = 1,
			ZIndex = zIndex + 1
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6)
			})
		})
	end

	v15.Badge = badge
	v10.Brand = createElement("Frame", v14, v15)
	local divider

	if not collapsed then
		divider = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme.StrokeSubtle,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = zIndex + 1
		})
	end

	v10.Divider = divider
	v10.HitArea = createElement("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -v6, 1, 0),
		Text = "",
		ZIndex = zIndex + 2,
		[React.Event.Activated] = props.OnActivated,
		[React.Event.InputBegan] = function(_, p)
			if props.OnInputBegan then
				props.OnInputBegan(p)
			end
		end
	})
	local minimize

	if props.OnMinimize then
		minimize = createElement("TextButton", {
			ref = ref3,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Header,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			Position = UDim2.new(1, -v4 * v5, 0, 5),
			Selectable = false,
			Size = UDim2.fromOffset(height - 10, height - 10),
			Text = "_",
			TextColor3 = Theme.TextSubtle,
			TextSize = 22,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = zIndex + 3,
			[React.Event.Activated] = props.OnMinimize,
			[React.Event.MouseEnter] = function()
				Motion.to(ref3.current, Motion.Hover, {
					BackgroundColor3 = Theme.ButtonHover,
					TextColor3 = Theme.Text
				})
			end,
			[React.Event.MouseLeave] = function()
				Motion.to(ref3.current, Motion.Hover, {
					BackgroundColor3 = Theme.Header,
					TextColor3 = Theme.TextSubtle
				})
			end
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			})
		})
	end

	v10.Minimize = minimize
	local exit

	if props.OnExit then
		exit = createElement("TextButton", {
			ref = ref,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Header,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -v4, 0, 5),
			Selectable = false,
			Size = UDim2.fromOffset(height - 10, height - 10),
			Text = "",
			ZIndex = zIndex + 3,
			[React.Event.Activated] = props.OnExit,
			[React.Event.MouseEnter] = function()
				Motion.to(ref.current, Motion.Hover, {
					BackgroundColor3 = Theme.Danger
				})
				Motion.to(ref2.current, Motion.Hover, {
					ImageColor3 = Theme.Text
				})
			end,
			[React.Event.MouseLeave] = function()
				Motion.to(ref.current, Motion.Hover, {
					BackgroundColor3 = Theme.Header
				})
				Motion.to(ref2.current, Motion.Hover, {
					ImageColor3 = Theme.TextSubtle
				})
			end
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			Icon = createElement("ImageLabel", {
				ref = ref2,
				BackgroundTransparency = 1,
				Image = "rbxassetid://127503254560275",
				ImageColor3 = Theme.TextSubtle,
				ImageRectOffset = vector,
				ImageRectSize = vector2,
				Position = UDim2.fromOffset(2, 2),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(1, -4, 1, -4),
				ZIndex = zIndex + 4
			})
		})
	end

	v10.Exit = exit
	return createElement("Frame", v9, v10)
end

return React.memo(HeaderBar)