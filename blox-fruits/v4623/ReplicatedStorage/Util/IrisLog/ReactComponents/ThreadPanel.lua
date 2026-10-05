local React = require(game.ReplicatedStorage.Packages.React)
local Controls = require(script.Parent.Controls)
local LogText = require(script.Parent.LogText)
local Motion = require(script.Parent.Motion)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement

local function ThreadPanel(p)
	local ref = React.useRef(nil)
	local v = Motion.useMeasuredCollapse(false)
	local v2 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}
	local count = 0

	for k, thread in p.Threads do
		count += 1
		local v3 = thread[1]
		local v4, v5, v6 = debug.info(v3, 1, "sln")
		local v7 = coroutine.status(v3)

		if v7 ~= "dead" then
			thread[2] = tick()
		end

		if v4 then
			thread[3] = v4
		end

		if v5 then
			thread[4] = v5
		end

		if v6 then
			thread[5] = v6
		end

		local formatted = `Thread{count}`
		local v10 = {
			LayoutOrder = count,
			Text = `{k}: {v7} @ {thread[3] or "?"}:{(not thread[5] or thread[5] == "") and "<anonymous>" or thread[5]}:{thread[4] or "?"} (seen {not thread[2] and "<never>" or math.floor(tick() - thread[2])}s ago)`,
			TextColor3 = 0,
			TextSize = 0
		}
		local textColor

		if v7 == "dead" then
			textColor = Theme.TextSubtle
		else
			textColor = Theme.Text
		end

		v10.TextColor3 = textColor
		v10.TextSize = Theme.SecondaryTextSize
		v2[formatted] = createElement(LogText, v10)
	end

	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PanelDark,
		BackgroundTransparency = Theme.PanelTransparency,
		BorderSizePixel = 0,
		LayoutOrder = p.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0)
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Header = createElement("TextButton", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, Theme.ControlHeight),
			Text = "",
			[React.Event.Activated] = v.Toggle,
			[React.Event.MouseEnter] = function()
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.Text
				})
			end,
			[React.Event.MouseLeave] = function()
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.TextMuted
				})
			end
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10)
			}),
			ChevronCell = createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(12, Theme.ControlHeight)
			}, {
				Inner = createElement(Controls.Chevron, {
					Color = Theme.TextMuted,
					Rotation = v.ChevronAngle,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5)
				})
			}),
			Label = createElement("TextLabel", {
				ref = ref,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = Theme.FontBold,
				LayoutOrder = 2,
				RichText = false,
				Size = UDim2.fromOffset(0, 0),
				Text = `Threads ({count})`,
				TextColor3 = Theme.TextMuted,
				TextSize = Theme.ControlTextSize,
				TextStrokeTransparency = 1
			})
		}),
		Body = createElement("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			LayoutOrder = 2,
			Size = v.Height:map(function(p2)
				return UDim2.new(1, 0, 0, (math.max(0, p2)))
			end)
		}, {
			Measure = createElement("Frame", {
				ref = v.MeasureRef,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0)
			}, v2)
		})
	})
end

return React.memo(ThreadPanel)