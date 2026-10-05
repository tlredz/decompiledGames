local shared = script.Parent.Parent.Parent.Parent.Shared
local React = require(shared.React)

local function Node(props)
	local v = React.useMemo(function()
		local count = 0

		for _, _ in props.children or {} do
			count += 1
		end

		return count
	end, { props.children })
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = props.LayoutOrder or 1
	}, {
		UIListLayout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2)
		}),
		Label = React.createElement("TextLabel", {
			Text = `{props.Name}`,
			RichText = true,
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/LegacyArial.json"),
			Size = UDim2.new(0, 0, 0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 7,
			TextScaled = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1
		}),
		ChildrenContainer = v > 0 and React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 2
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical
			}),
			Indent = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 12)
			})
		}, props.children)
	})
end

local function TreeDebugger(p)
	local v = React.useMemo(function()
		local search

		search = function(p2)
			local function getChildren(p3)
				local result = {}

				for _, v2 in p3.children do
					result[v2.name] = search(v2)
				end

				return result
			end

			local createElement = React.createElement
			local v3 = {
				Name = p2.name
			}
			local v4

			if p2.children then
				v4 = getChildren(p2)
			end

			return (createElement(Node, v3, v4))
		end

		if p.Tree.current then
			return (search(p.Tree.current))
		end

		return {}
	end, { p.TreeUpdated, p.Tree.current })
	return React.createElement("ScrollingFrame", {
		Visible = true,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(1, 10, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 400),
		AutomaticSize = Enum.AutomaticSize.X,
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		CanvasSize = UDim2.new(),
		BorderColor3 = Color3.fromHex("#323232"),
		BackgroundColor3 = Color3.fromHex("#1c1c1c")
	}, {
		UIListLayout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		UIPadding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5)
		}),
		Heading = React.createElement(Node, {
			Name = "<font color=\"#cefeff\" weight=\"900\"><u>Live Output</u></font>",
			LayoutOrder = -1
		})
	}, v)
end

return TreeDebugger