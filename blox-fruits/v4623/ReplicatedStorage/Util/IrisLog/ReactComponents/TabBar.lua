local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local InputUtils = require(script.Parent.InputUtils)
local Motion = require(script.Parent.Motion)
local Theme = require(script.Parent.Theme)
local WindowDragContext = require(script.Parent.WindowDragContext)
local createElement = React.createElement

local function isHorizontalTabDrag(point: Vector2)
	return math.abs(point.X) >= 6 and math.abs(point.X) > math.abs(point.Y)
end

local memo = React.memo(function(props)
	local selected = props.Selected
	local ref = React.useRef(nil)
	local v, v2 = Motion.useNumberMotion(0)
	local accent

	if selected then
		accent = Theme.Accent
	else
		accent = Theme.TextSubtle
	end

	React.useEffect(function()
		v2(selected and 1 or 0, Motion.Hover)
	end, { selected })
	local v5 = {
		ref = ref,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0, 0, 1, 0),
		Text = props.Label,
		TextColor3 = accent,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		[React.Tag] = "IrisLogTabButton",
		[React.Event.Activated] = function()
			if props.IsSelectSuppressed() then
				return
			end

			props.OnSelect(props.Index)
		end,
		[React.Event.InputBegan] = function(_, p)
			props.OnDragStart(props.Index, p)
		end,
		[React.Event.MouseEnter] = function()
			if not selected then
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.TextMuted
				})
				v2(1, Motion.Hover)
			end
		end,
		[React.Event.MouseLeave] = function()
			if not selected then
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.TextSubtle
				})
				v2(0, Motion.Hover)
			end
		end
	}
	local v6 = {
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 11),
			PaddingRight = UDim.new(0, 11)
		}),
		Underline = 0
	}
	local v9 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		Position = 0,
		Size = 0,
		BackgroundTransparency = 0
	}
	local backgroundColor

	if selected then
		backgroundColor = Theme.AccentBright
	else
		backgroundColor = Theme.ButtonStroke
	end

	v9.BackgroundColor3 = backgroundColor
	v9.Position = UDim2.new(0.5, 0, 1, 0)
	v9.Size = v:map(function(p: number)
		return UDim2.new(p, p * -6, 0, 2)
	end)
	v9.BackgroundTransparency = v:map(function(p: number)
		return 1 - p
	end)
	v6.Underline = createElement("Frame", v9, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(1, 0)
		})
	})
	return createElement("TextButton", v5, v6)
end)

local function TabBar(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(0)
	local rightControlWidthPx = props.RightControlWidthPx or 0
	local v = React.useContext(WindowDragContext)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function suppressSelect()
		ref2.current = os.clock() + 0.2
	end

	local function isSelectSuppressed()
		return os.clock() < ref2.current
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function beginDetachedWindowDrag(p)
		if v and InputUtils.isPrimaryPointer(p) then
			v(p)
		end
	end

	local function targetIndexAtX(X: number)
		local current = ref.current

		if not current then
			return nil
		end

		local guiObjects = {}

		for _, guiObject in current:GetChildren() do
			if guiObject:IsA("GuiObject") then
				table.insert(guiObjects, guiObject)
			end
		end

		table.sort(guiObjects, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		local layoutOrder = nil

		for _, v2 in guiObjects do
			layoutOrder = v2.LayoutOrder

			if X < v2.AbsolutePosition.X + v2.AbsoluteSize.X * 0.5 then
				return v2.LayoutOrder
			end
		end

		return layoutOrder
	end

	local function beginTabDrag(p: number, p2)
		if not InputUtils.isPrimaryPointer(p2) then
			return
		end

		if v then
			local position = InputUtils.position(p2)
			local inputEndedConnection = nil
			local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if not InputUtils.isPointerMove(input) then
					return
				end

				if (InputUtils.position(input) - position).Magnitude >= 6 then
					suppressSelect() -- equivalent call inferred; original call site unknown
				end
			end)
			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType ~= p2.UserInputType then
					return
				end

				if inputChangedConnection then
					inputChangedConnection:Disconnect()
				end

				if inputEndedConnection then
					inputEndedConnection:Disconnect()
				end
			end)
			beginDetachedWindowDrag(p2) -- equivalent call inferred; original call site unknown
		else
			if not props.OnReorder then
				return
			end

			local position = InputUtils.position(p2)
			local flag = false
			local v2 = false
			local v3 = p
			local inputEndedConnection = nil
			local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if not InputUtils.isPointerMove(input) then
					return
				end

				local position2 = InputUtils.position(input)
				local v4 = position2 - position

				if v4.Magnitude >= 6 then
					flag = true
					suppressSelect() -- equivalent call inferred; original call site unknown
				end

				local v5

				if math.abs(v4.X) >= 6 then
					v5 = math.abs(v4.X) > math.abs(v4.Y)
				else
					v5 = false
				end

				if v5 then
					v2 = true
					v3 = targetIndexAtX(position2.X) or v3
				end
			end)
			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType ~= p2.UserInputType then
					return
				end

				if inputChangedConnection then
					inputChangedConnection:Disconnect()
				end

				if inputEndedConnection then
					inputEndedConnection:Disconnect()
				end

				if v2 and v3 ~= p and props.OnReorder then
					suppressSelect() -- equivalent call inferred; original call site unknown
					props.OnReorder(p, v3)
				elseif flag then
					suppressSelect() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		})
	}

	for k, tab in props.Tabs do
		children[`Tab{k}`] = createElement(memo, {
			Index = k,
			Label = tab.Name,
			Selected = k == props.SelectedIndex,
			LayoutOrder = k,
			OnSelect = props.OnSelect,
			OnDragStart = beginTabDrag,
			IsSelectSuppressed = isSelectSuppressed
		})
	end

	local v4 = {
		Active = v ~= nil,
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = Theme.PanelTransparency,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, Theme.TabBarHeight),
		[React.Event.InputBegan] = function(_, p)
			if v then
				if not InputUtils.isPrimaryPointer(p) then
					return
				end

				v(p)
			end
		end
	}
	local v5 = {
		Divider = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme.StrokeSubtle,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1)
		}),
		Content = createElement("Frame", {
			Active = v ~= nil,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			[React.Event.InputBegan] = function(_, p)
				if v then
					if not InputUtils.isPrimaryPointer(p) then
						return
					end

					v(p)
				end
			end
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8 + rightControlWidthPx)
			}),
			Tabs = createElement("Frame", {
				ref = ref,
				Active = v ~= nil,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				[React.Event.InputBegan] = function(_, p)
					if v then
						if not InputUtils.isPrimaryPointer(p) then
							return
						end

						v(p)
					end
				end
			}, children)
		}),
		RightControl = 0
	}
	local rightControl

	if props.RightControl then
		rightControl = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(rightControlWidthPx, Theme.TabBarHeight),
			ZIndex = 5
		}, {
			Control = props.RightControl
		})
	end

	v5.RightControl = rightControl
	return createElement("Frame", v4, v5)
end

return React.memo(TabBar)