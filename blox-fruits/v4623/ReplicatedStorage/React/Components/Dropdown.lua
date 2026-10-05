local GuiService = game:GetService("GuiService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Option = require(script.Option)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(Enum.GuiState.Idle)
	local v = use("InventoryDropdownMenu")
	local v2 = useDrawContext()
	local v3 = useViewportSize()
	useGuiServiceSelect(v, state and v2 == "Default")
	local isDisabled = props.IsDisabled == true
	local ref = React.useRef(nil)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function returnSelectionToButton()
		local current = ref.current
		local parent

		if current then
			parent = current.Parent
		end

		local selectedObject = GuiService.SelectedObject

		if current and parent and selectedObject and selectedObject ~= current and selectedObject:IsDescendantOf(parent) then
			GuiService.SelectedObject = current
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setMenuOpen(flag: boolean)
		setState(flag)

		if flag and not state and props.OnMenuOpen then
			props.OnMenuOpen()
		elseif not flag and state then
			returnSelectionToButton() -- equivalent call inferred; original call site unknown

			if props.OnMenuClose then
				props.OnMenuClose()
			end
		end
	end

	if state and (props.ForceClose == true or isDisabled) then
		setMenuOpen(false) -- equivalent call inferred; original call site unknown
	end

	local v4 = React.useMemo(function()
		local result = {}

		for k in props.Options do
			table.insert(result, k)
		end

		table.sort(result, function(a: string, b: string)
			local layoutOrder = props.Options[a].LayoutOrder or 0
			local layoutOrder2 = props.Options[b].LayoutOrder or 0

			if layoutOrder == layoutOrder2 then
				return a < b
			end

			return layoutOrder < layoutOrder2
		end)
		return result
	end, { props.Options })
	React.useEffect(function()
		setMenuOpen(false) -- equivalent call inferred; original call site unknown
	end, v4)
	local v5

	if isDisabled then
		v5 = 0
	elseif state4 == Enum.GuiState.Hover then
		v5 = 0.1267
	elseif state4 == Enum.GuiState.Press then
		v5 = 0.0532
	else
		v5 = 0
	end

	local option = props.Options[props.SelectedKey]
	local menu

	if state and state2 and state3 then
		local heightPx = props.IsCompact and 19 or 28
		local v8 = #v4 * heightPx + math.max(0, #v4 - 1) * 5
		local children = {}

		for k, v9 in v4 do
			local option2 = props.Options[v9]
			local v10 = v9
			children[`Option-{v9}`] = createElement(Option, {
				HeightPx = heightPx,
				IsSelected = v9 == props.SelectedKey,
				LayoutOrder = option2.LayoutOrder or k,
				OnActivated = function()
					props.OnSelection(v10)
					setMenuOpen(false) -- equivalent call inferred; original call site unknown
				end,
				Text = option2.Text
			})
		end

		menu = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromOffset(state3.X - 2, v8 + 2 + 6)
		}, {
			Outline = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			SizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(1e999, (math.max(0, v3.Y - state2.Y - state3.Y - 7)))
			}),
			Padding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 2)
			}),
			Content = createElement("Frame", {
				[React.Tag] = v,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Selectable = false,
				Size = UDim2.new(1, 0, 0, v8)
			}, {
				Layout = createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Options = createElement(React.Fragment, {}, children)
			})
		})
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, props)
	local v12 = {
		[React.Tag] = props.ButtonTag,
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, v5),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Selectable = props.Selectable,
		Size = UDim2.fromScale(1, 1),
		[React.Event.Activated] = not isDisabled and function(p)
			setState2(p.AbsolutePosition)
			setState3(p.AbsoluteSize)
			setMenuOpen(not state) -- equivalent call inferred; original call site unknown
		end or nil,
		[React.Change.GuiState] = function(p)
			if p.GuiState ~= state4 then
				setState4(p.GuiState)
			end
		end,
		[React.Change.AbsolutePosition] = state and function(p)
			setState2(p.AbsolutePosition)
		end or nil,
		[React.Change.AbsoluteSize] = state and function(p)
			setState3(p.AbsoluteSize)
		end or nil
	}
	local v13 = {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 2)
		}),
		SizeConstraint = createElement("UISizeConstraint", {
			MinSize = Vector2.new(0, 36)
		}),
		Text = 0,
		AfterIcon = 0
	}
	local v16 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		LineHeight = 0,
		Position = UDim2.fromScale(0.04, 0.5),
		Size = UDim2.fromScale(0.78, 0.55),
		Text = not option and "" or option.Text,
		TextColor3 = 0,
		TextScaled = true,
		TextTruncate = 0,
		TextXAlignment = 0
	}
	local textColor

	if isDisabled then
		textColor = CONSTANTS.COLOR.DISABLED.TEXT
	else
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	end

	v16.TextColor3 = textColor
	v16.TextTruncate = Enum.TextTruncate.AtEnd
	v16.TextXAlignment = Enum.TextXAlignment.Left
	v13.Text = createElement("TextLabel", v16, {
		Stroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		})
	})
	local afterIcon

	if not isDisabled then
		afterIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Image = state and "rbxassetid://105014044988846" or "rbxassetid://105170544520180",
			Position = UDim2.fromScale(0.97, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.46, 0.46)
		}, {
			AspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1
			})
		})
	end

	v13.AfterIcon = afterIcon
	return createElement("Frame", mergeFrame, {
		Button = createElement("ImageButton", v12, v13),
		Menu = menu
	})
end