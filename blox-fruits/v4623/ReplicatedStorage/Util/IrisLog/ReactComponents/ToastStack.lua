local React = require(game.ReplicatedStorage.Packages.React)
local Formatter = require(script.Parent.Formatter)
local LogText = require(script.Parent.LogText)
local Motion = require(script.Parent.Motion)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement

local function toastText(line, context)
	local texts = {}

	for _, item in line do
		local text = Formatter.toText(item, context)

		if text and text ~= "" then
			table.insert(texts, text)
		end
	end

	local joined = table.concat(texts)

	if joined == "" then
		return "Open log"
	end

	return joined
end

local memo = React.memo(function(props)
	local state, setState = React.useState(false)
	local v, v2, v3 = Motion.useNumberMotion(0)
	React.useEffect(function()
		local flag = true
		v3(0)
		task.defer(function()
			if flag then
				v2(1, Motion.Pop)
			end
		end)
		task.delay(Theme.ToastLifetime, function()
			if not flag then
				return
			end

			v2(0, Motion.Collapse, function()
				if flag then
					props.OnDismissed(props.Toast.Id)
				end
			end)
		end)
		return function()
			flag = false
		end
	end, { props.Toast.Id })
	local log = props.Toast.Log
	local text = not (log and log.Name) and "IrisLog" or tostring(log.Name)
	local v7 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 200
	}
	local v11 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		AutoButtonColor = false
	}
	local backgroundColor

	if state then
		backgroundColor = Theme.ButtonHover
	else
		backgroundColor = Theme.Panel
	end

	v11.BackgroundColor3 = backgroundColor
	v11.BorderSizePixel = 0
	v11.Position = v:map(function(p: number)
		return UDim2.fromOffset(Theme.ToastSlideOffset * (1 - p), 0)
	end)
	v11.Size = UDim2.new(1, 0, 0, Theme.ToastMinHeight)
	v11.Text = ""
	v11.ZIndex = 201

	v11[React.Event.Activated] = function()
		props.OnActivated(props.Toast)
	end

	v11[React.Event.MouseEnter] = function()
		setState(true)
	end

	v11[React.Event.MouseLeave] = function()
		setState(false)
	end

	return createElement("Frame", v7, {
		Card = createElement("TextButton", v11, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 8)
			}),
			Title = createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = Theme.FontBold,
				LayoutOrder = 1,
				RichText = false,
				Size = UDim2.new(1, 0, 0, 18),
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = Theme.ControlTextSize,
				TextStrokeTransparency = 1,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 202
			}),
			Body = createElement(LogText, {
				Font = Theme.Font,
				LayoutOrder = 2,
				Text = toastText(props.Toast.Line, props.Context),
				TextColor3 = Theme.TextMuted,
				TextOverflowMode = "wrap",
				TextSize = Theme.SecondaryTextSize
			})
		})
	})
end)

local function ToastStack(props)
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		})
	}

	for k, toast in props.Toasts do
		children[`Toast{toast.Id}`] = createElement(memo, {
			Toast = toast,
			Context = props.Context,
			LayoutOrder = k,
			OnActivated = props.OnActivated,
			OnDismissed = props.OnDismissed
		})
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(Theme.ToastWidth, 420),
		ZIndex = 200
	}, children)
end

return React.memo(ToastStack)