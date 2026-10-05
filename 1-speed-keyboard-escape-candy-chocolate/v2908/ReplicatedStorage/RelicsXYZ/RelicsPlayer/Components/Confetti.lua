local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)

local function Confetti()
	local ref = React.useRef(nil)
	local v = {}
	local layerCollector = nil

	for _ = 1, 128 do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(20, 8)
		frame.Rotation = math.random() * 360
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.fromHSV(0.6 + math.random() / 4, 0.8 + math.random() / 5, 1)
		frame.Position = UDim2.fromScale(0.4 + math.random() / 5, 0.4 + math.random() / 5)
		v[frame] = {
			Velocity = Vector2.new(-1 + math.random() * 2, -1 + math.random() * 2) * 2,
			RotVelocity = (math.random() * 2 - 1) * 360
		}
	end

	React.useEffect(function()
		local current = ref.current

		if current then
			if layerCollector == nil then
				layerCollector = current:FindFirstAncestorWhichIsA("LayerCollector")
			end

			for k in v do
				k.Parent = current
			end
		end
	end, {})
	useClock(45, function(p)
		local viewportSize = workspace.CurrentCamera.ViewportSize

		for k in v do
			local v3 = v[k]
			local absolutePosition = k.AbsolutePosition
			local velocity = v3.Velocity + Vector2.new(0, p)
			v3.Velocity = velocity
			k.Rotation = (k.Rotation + v3.RotVelocity * p) % 360
			k.Position += UDim2.fromScale(velocity.X * p, velocity.Y * p)

			if not (absolutePosition.X < 0 or absolutePosition.Y < 0 or absolutePosition.X > viewportSize.X or absolutePosition.Y > viewportSize.Y) then
				continue
			end

			k:Destroy()
			v[k] = nil
		end
	end)
	return React.createElement("Frame", {
		ref = ref,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3
	}, {})
end

return Confetti