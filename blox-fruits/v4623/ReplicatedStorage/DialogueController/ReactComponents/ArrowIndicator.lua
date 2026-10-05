local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local vector = Vector2.new(100, 100)
local v = {
	options = {
		color = Color3.new(1, 1, 1),
		offset = Vector2.new(100, 0),
		scale = 1
	},
	proceed = {
		color = Color3.fromRGB(138, 138, 138),
		offset = Vector2.new(200, 0),
		scale = 0.8
	}
}

local function ArrowIndicator(props)
	local ref = React.useRef(nil)
	local bounce = props.bounce == true
	local visible = props.visible ~= false
	local position = props.position or UDim2.fromScale(0.5, 0.5)
	local v2 = v[props.variant]
	local zIndex = props.zIndex or 5
	React.useEffect(function()
		if not (bounce and visible) then
			return
		end

		local v3 = props.direction == "up" and -1 or 1
		local total = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local current = ref.current

			if not current then
				return
			end

			local v4 = math.abs((math.sin(total * 3.141592653589793 / 0.8))) * current.AbsoluteSize.Y * 0.3
			current.Position = position + UDim2.fromOffset(0, v4 * v3)
		end)
		return function()
			heartbeatConnection:Disconnect()
			local current = ref.current

			if current then
				current.Position = position
			end
		end
	end, {
		bounce,
		visible,
		position,
		props.direction
	})
	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = position,
		Size = props.size or UDim2.fromScale(0.1, 0.1),
		Visible = visible,
		ZIndex = zIndex
	}, {
		arrow = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://127503254560275",
			ImageColor3 = v2.color,
			ImageRectOffset = v2.offset,
			ImageRectSize = vector,
			ImageTransparency = props.transparency or 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = props.variant == "options" and props.direction == "down" and 180 or 0,
			Size = UDim2.fromScale(v2.scale, v2.scale),
			ZIndex = zIndex
		}, {
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Height
			})
		})
	})
end

return ArrowIndicator