local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(script.Parent.Effects)

local function Bubble(props)
	local ref = React.useRef(nil)
	local effect = props.effect
	React.useEffect(function()
		local color = effect and effect.color

		if not color then
			return
		end

		local total = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local current = ref.current

			if current then
				current.BackgroundColor3 = color(current.AbsoluteSize.Y, total)
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { effect or false })
	local v = {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0)
		}),
		uIStroke = 0
	}
	local uIStroke

	if not props.transparent then
		uIStroke = React.createElement("UIStroke", {
			Thickness = math.max(props.size.Y.Offset * 0.04, 1)
		})
	end

	v.uIStroke = uIStroke

	if props.children then
		for k, v3 in props.children do
			v[k] = v3
		end
	end

	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = props.color,
		BackgroundTransparency = props.transparent and 1 or 0,
		Position = props.position,
		Size = props.size,
		Visible = props.visible ~= false,
		ZIndex = props.zIndex
	}, v)
end

return Bubble