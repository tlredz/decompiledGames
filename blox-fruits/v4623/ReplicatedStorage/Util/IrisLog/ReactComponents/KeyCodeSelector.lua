local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local HotkeyCombo = require(script.Parent.Parent.HotkeyCombo)
local Popout = require(script.Parent.Popout)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement

local function isConfirmKeyCode(p)
	return HotkeyCombo.isConfirmKeyCode(p)
end

local function keyLabel(p: string)
	return HotkeyCombo.label(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function copyCombo(p)
	return HotkeyCombo.copy(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizedValue(p)
	return HotkeyCombo.normalize(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function containsKey(copy, name: string)
	for _, item in copy do
		if item == name then
			return true
		end
	end

	return false
end

local function KeyBubble(props)
	local v2 = {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.ButtonSelected,
		BorderSizePixel = 0,
		Font = Theme.FontBold,
		LayoutOrder = props.LayoutOrder,
		RichText = false,
		Size = UDim2.fromOffset(0, 24),
		Text = 0,
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 0
	}
	local keyCodeName = props.KeyCodeName
	v2.Text = HotkeyCombo.label(keyCodeName)
	v2.TextColor3 = Theme.Text
	v2.TextSize = Theme.ControlTextSize
	v2.TextXAlignment = Enum.TextXAlignment.Center
	v2.TextYAlignment = Enum.TextYAlignment.Center
	v2.ZIndex = props.ZIndex
	return createElement("TextLabel", v2, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(1, 0)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		})
	})
end

local function KeyCodeSelector(props)
	local state, setState = React.useState(false)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local v = normalizedValue(props.Value) -- equivalent call inferred; original call site unknown
	local state2, setState2 = React.useState(v)
	local ref3 = React.useRef(v)
	local ref4 = React.useRef({})
	local ref5 = React.useRef(0)
	local ref6 = React.useRef(true)
	local zIndex = props.ZIndex or 190

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setDraftCombo(p)
		local current = copyCombo(p) -- equivalent call inferred; original call site unknown
		ref3.current = current
		setState2(current)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resetActiveKeys()
		ref4.current = {}
		ref5.current = 0
		ref6.current = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseCaptureFocus()
		local current = ref2.current

		if current then
			current:ReleaseFocus(false)
		end
	end

	React.useEffect(function()
		if state then
			setDraftCombo(nil) -- equivalent call inferred; original call site unknown
			resetActiveKeys() -- equivalent call inferred; original call site unknown
		else
			local v2 = normalizedValue(props.Value) -- equivalent call inferred; original call site unknown
			setDraftCombo(v2) -- equivalent call inferred; original call site unknown
		end
	end, { state, props.Value or false })
	React.useEffect(function()
		if not state then
			return
		end

		task.defer(function()
			local current = ref2.current

			if current then
				current:CaptureFocus()
			end
		end)
		return function()
			local current = ref2.current

			if current then
				current:ReleaseFocus()
			end
		end
	end, { state })
	React.useEffect(function()
		if not state then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function confirm()
			local v2 = normalizedValue(ref3.current) -- equivalent call inferred; original call site unknown
			resetActiveKeys() -- equivalent call inferred; original call site unknown
			releaseCaptureFocus() -- equivalent call inferred; original call site unknown
			setState(false)
			props.OnChanged(v2)
		end

		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			local keyCode = input.KeyCode

			if HotkeyCombo.isConfirmKeyCode(keyCode) then
				confirm() -- equivalent call inferred; original call site unknown
			elseif input.KeyCode == Enum.KeyCode.Escape then
				resetActiveKeys() -- equivalent call inferred; original call site unknown
				releaseCaptureFocus() -- equivalent call inferred; original call site unknown
				setState(false)
			else
				local name = input.KeyCode.Name

				if not HotkeyCombo.isValidHotkeyKeyCodeName(name) then
					return
				end

				local current = ref4.current
				local current2 = ref6.current or ref5.current == 0

				if not current[name] then
					current[name] = true
					ref5.current += 1
				end

				ref6.current = false
				local copy

				if current2 then
					copy = {}
				else
					local current3 = ref3.current
					copy = HotkeyCombo.copy(current3) or {}
				end

				local v2 = containsKey(copy, name) -- equivalent call inferred; original call site unknown

				if not v2 and #copy < HotkeyCombo.MaxKeys then
					table.insert(copy, name)
				end

				if not (#copy > 0) then
					copy = nil
				end

				setDraftCombo(copy) -- equivalent call inferred; original call site unknown
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			local name = input.KeyCode.Name
			local current = ref4.current

			if not current[name] then
				return
			end

			current[name] = nil
			ref5.current = math.max(0, ref5.current - 1)

			if ref5.current == 0 then
				ref6.current = true
			end
		end)
		return function()
			inputBeganConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, { state, props.OnChanged })
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		})
	}
	local v2 = state2 or {}

	if #v2 == 0 then
		children.Placeholder = createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			LayoutOrder = 1,
			RichText = false,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "Press keys",
			TextColor3 = Theme.TextMuted,
			TextSize = Theme.ControlTextSize,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 202
		})
	else
		for k, keyCodeName in v2 do
			local layoutOrder = k * 2
			children[`Key{k}`] = createElement(KeyBubble, {
				KeyCodeName = keyCodeName,
				LayoutOrder = layoutOrder,
				ZIndex = 203
			})

			if k < #v2 then
				children[`Plus{k}`] = createElement("TextLabel", {
					BackgroundTransparency = 1,
					Font = Theme.FontBold,
					LayoutOrder = layoutOrder + 1,
					RichText = false,
					Size = UDim2.fromOffset(10, 24),
					Text = "+",
					TextColor3 = Theme.TextSubtle,
					TextSize = Theme.ControlTextSize,
					TextStrokeTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 202
				})
			end
		end
	end

	local v5 = {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(props.WidthPx or Theme.KeyCodeSelectorWidth, Theme.ControlHeight),
		ZIndex = zIndex
	}
	local backgroundColor

	if state then
		backgroundColor = Theme.ButtonSelected
	else
		backgroundColor = Theme.Button
	end

	return createElement("Frame", v5, {
		Button = createElement("TextButton", {
			ref = ref,
			AutoButtonColor = false,
			BackgroundColor3 = backgroundColor,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			RichText = false,
			Selectable = false,
			Size = UDim2.fromScale(1, 1),
			Text = "Set input",
			TextColor3 = Theme.Text,
			TextSize = Theme.ControlTextSize,
			TextStrokeTransparency = 1,
			ZIndex = zIndex,
			[React.Event.Activated] = function()
				setState(not state)
			end
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			})
		}),
		CapturePopout = createElement(Popout, {
			Open = state,
			AnchorRef = ref,
			WidthPx = Theme.KeyCapturePopoutWidth,
			HeightPx = Theme.KeyCapturePopoutHeight,
			ConstrainHeightToViewportBottom = true,
			OffsetY = 3,
			HorizontalAlign = "right",
			OnOutsideInput = function()
				resetActiveKeys() -- equivalent call inferred; original call site unknown
				releaseCaptureFocus() -- equivalent call inferred; original call site unknown
				setState(false)
			end,
			ZIndex = 200
		}, {
			Content = createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 201
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8)
				}),
				Keys = createElement("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 28),
					ZIndex = 202
				}, children),
				Instructions = createElement("TextLabel", {
					BackgroundTransparency = 1,
					Font = Theme.Font,
					LayoutOrder = 2,
					RichText = false,
					Size = UDim2.new(1, 0, 0, 18),
					Text = "Enter confirms. Click out cancels.",
					TextColor3 = Theme.TextMuted,
					TextSize = Theme.SecondaryTextSize,
					TextStrokeTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 202
				})
			}),
			FocusSink = createElement("TextBox", {
				ref = ref2,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Theme.Font,
				Position = UDim2.fromOffset(0, 0),
				Selectable = false,
				Size = UDim2.fromOffset(1, 1),
				Text = "",
				TextColor3 = Theme.Text,
				TextSize = 1,
				TextTransparency = 1,
				ZIndex = 201,
				[React.Change.Text] = function(p)
					if p.Text ~= "" then
						p.Text = ""
					end
				end
			})
		})
	})
end

return React.memo(KeyCodeSelector)