local React = require(game.ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement

local function ResizeGrip(data)
	local sizePx = data.SizePx or 28
	local zIndex = data.ZIndex or 1

	local function gripLine(p: number, p2: number)
		return createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.TextSubtle,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(sizePx - p, sizePx - p),
			Rotation = -45,
			Size = UDim2.fromOffset(p2, 2),
			ZIndex = zIndex + 1
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		})
	end

	return createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(1, 1),
		Selectable = false,
		Size = UDim2.fromOffset(sizePx, sizePx),
		Text = "",
		ZIndex = zIndex,
		[React.Event.InputBegan] = function(_, p)
			data.OnInputBegan(p)
		end
	}, {
		GripLineA = gripLine(13, 13),
		GripLineB = gripLine(17, 7)
	})
end

return React.memo(ResizeGrip)