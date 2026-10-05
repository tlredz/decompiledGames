local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Effects = require(script.Parent.Effects)

local function Icon(props)
	local ref = React.useRef(nil)
	local v

	if props.effect then
		v = Effects[props.effect]
	else
		v = nil
	end

	local position = props.position or UDim2.new()
	React.useEffect(function()
		if not v then
			return
		end

		local total = 0
		local total2 = 1e999
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			total2 += dt

			if total2 < v.interval then
				return
			end

			total2 = 0
			local current = ref.current

			if not current then
				return
			end

			local v2 = math.min(current.AbsoluteSize.X, current.AbsoluteSize.Y)

			if v.offset then
				local offset = v.offset(v2, total)
				current.Position = position + UDim2.fromOffset(offset.X, offset.Y)
			end

			if v.rotation then
				current.Rotation = v.rotation(v2, total)
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { v or false, position })

	if not props.backgroundImage then
		return React.createElement("ImageLabel", {
			ref = ref,
			AnchorPoint = props.anchorPoint,
			BackgroundTransparency = 1,
			Image = props.image,
			ImageRectOffset = props.imageRectOffset,
			ImageRectSize = props.imageRectSize,
			ImageColor3 = props.color,
			ImageTransparency = props.transparency,
			Position = position,
			ScaleType = props.scaleType,
			Size = props.size,
			ZIndex = props.zIndex
		}, {
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
		})
	end

	local zIndex = props.zIndex or 1
	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = props.anchorPoint,
		BackgroundTransparency = 1,
		Position = position,
		Size = props.size,
		ZIndex = props.zIndex
	}, {
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
		background = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.backgroundImage,
			ImageColor3 = props.color,
			ImageRectOffset = props.backgroundImageRectOffset,
			ImageRectSize = props.backgroundImageRectSize,
			ImageTransparency = 0.5,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = props.scaleType,
			Size = UDim2.fromScale(1, 1),
			ZIndex = zIndex
		}),
		foreground = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.image,
			ImageColor3 = props.color,
			ImageRectOffset = props.imageRectOffset,
			ImageRectSize = props.imageRectSize,
			ImageTransparency = props.transparency,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = props.scaleType,
			Size = UDim2.fromScale(1, 1),
			ZIndex = zIndex + 1
		})
	})
end

return Icon