local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local shared = script.Parent.Parent.Parent.Parent.Shared
local React = require(shared.React)

local function ListOfTags(p)
	local v = #p.Tags + 1
	local children = {}

	for i = 0, v do
		if i > 38 then
			break
		end

		local tag = p.Tags[i - 1]
		local formatted = `{tag}_{i}`
		local createElement = React.createElement

		if i == 0 and p.Title ~= nil then
			tag = `<font color="#cefeff" weight="900"><u>{p.Title}</u></font>`
		elseif i == 38 and v - i > 0 then
			tag = `<font color="#c6e5e4"><i>...{v - 38} more</i></font>`
		end

		children[formatted] = createElement("TextLabel", {
			Text = tag,
			RichText = true,
			LayoutOrder = i,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json"),
			Size = UDim2.fromOffset(0, 0),
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 7,
			TextScaled = false,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

local function DevTagViewer(props)
	local v = props.Tags ~= nil
	local current = props.Root.current
	local ref = React.useRef(nil)
	local state, setState = React.useState(1)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(UDim2.new())
	local state4, setState4 = React.useState({})

	local function mouseChanged(p: number, p2: number)
		local guiObjectsAtPosition = StarterGui:GetGuiObjectsAtPosition(p, p2)
		local tags = {}

		for _, v2 in guiObjectsAtPosition do
			for _, ancestor in guiObjectsAtPosition do
				if v2:IsDescendantOf(ancestor) then
					break
				end
			end

			table.insert(tags, v2:GetTags())
		end

		local absolutePosition = current.AbsolutePosition
		local v2 = p - absolutePosition.X
		local v3 = p2 - absolutePosition.Y
		setState3(UDim2.fromOffset(v2, v3))

		if #tags > #state4 then
			setState(1)
		end

		setState2(#tags > 0)
		setState4(tags)
	end

	React.useEffect(function()
		if v then
			return
		end

		local mouseMovedConnection = current.MouseMoved:Connect(mouseChanged)
		ContextActionService:BindAction("PreviewSwitch", function()
			local v2 = state + 1
			setState(#state4 < v2 and 1 or v2)
		end, false, Enum.KeyCode.E)
		return function()
			mouseMovedConnection:Disconnect()
			ContextActionService:UnbindAction("PreviewSwitch")
		end
	end, {})
	local tags = props.Tags or state4[state]
	local createElement = React.createElement

	if v then
		state2 = props.Tags and #props.Tags > 0
	end

	local v3 = {
		ref = ref,
		Visible = state2,
		AnchorPoint = Vector2.new(1, 0),
		Position = 0,
		BorderSizePixel = 0,
		Size = 0,
		AutomaticSize = 0,
		BorderColor3 = 0,
		BackgroundColor3 = 0
	}

	if v then
		state3 = UDim2.fromOffset(-10, 0)
	end

	v3.Position = state3
	v3.Size = UDim2.new(0, 0, 0, 400)
	v3.AutomaticSize = Enum.AutomaticSize.X
	v3.BorderColor3 = Color3.fromHex("#323232")
	v3.BackgroundColor3 = Color3.fromHex("#1c1c1c")
	local v4 = {
		UIListLayout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		UIPadding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5)
		}),
		ListOfTags = 0
	}
	local listOfTags

	if tags then
		listOfTags = React.createElement(ListOfTags, {
			Title = props.Title,
			Tags = tags
		})
	end

	v4.ListOfTags = listOfTags
	return createElement("Frame", v3, v4)
end

return DevTagViewer