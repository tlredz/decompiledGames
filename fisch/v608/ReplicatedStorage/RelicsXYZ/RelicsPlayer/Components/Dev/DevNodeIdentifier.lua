local Selection = game:GetService("Selection")
local shared = script.Parent.Parent.Parent.Parent.Shared
local React = require(shared.React)

local function DevNodeIdentifier(p)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local selectionChangedConnection = Selection.SelectionChanged:Connect(function()
			local v = Selection:Get()

			for _, v2 in v do
				if v2 and p.ValidateSelection(v2) then
					setState(v)
				end
			end
		end)
		return function()
			selectionChangedConnection:Disconnect()
		end
	end, {})

	if not state then
		return state
	end

	state = React.createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(206, 254, 255),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0, -5),
		Text = "Identify Node",
		TextColor3 = Color3.new(1, 1, 1),
		TextWrapped = true,
		[React.Event.Activated] = function()
			print(p.GetId(state))
		end
	}, {
		UIPadding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2)
		})
	})
	return state
end

return DevNodeIdentifier