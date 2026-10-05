local Ticker = require(script.Parent:WaitForChild("Ticker"))
return {
	attach = function(instance, options)
		local v = options or {}
		local cycle = v.Cycle or 2
		local resolution = v.Resolution or 13
		local hz = v.Hz or 30
		local color = instance.Color
		local colors = v.Colors

		if not colors then
			colors = {}

			for _, keypoint in ipairs(color.Keypoints) do
				colors[#colors + 1] = keypoint.Value
			end

			if #colors < 2 then
				colors = { colors[1] or Color3.new(1, 1, 1), Color3.new(1, 1, 1) }
			end
		end

		local v2 = #colors - 1
		local colorSequenceKeypoints = table.create(resolution + 1)

		local function wrappedColor(p)
			local v3 = p % 1 * v2
			local v4 = math.floor(v3) + 1
			local v5 = math.min(v4 + 1, #colors)
			return colors[v4]:Lerp(colors[v5], v3 % 1)
		end

		local parent = instance.Parent

		while parent and not parent:IsA("GuiObject") do
			parent = parent.Parent
		end

		local whileVisible = Ticker.whileVisible(parent or instance, function()
			local v3 = os.clock() % cycle / cycle

			for i = 0, resolution do
				local v4 = i / resolution
				colorSequenceKeypoints[i + 1] = ColorSequenceKeypoint.new(v4, wrappedColor(v4 * 0.5 - v3))
			end

			instance.Color = ColorSequence.new(colorSequenceKeypoints)
		end, 1 / hz)
		return {
			Stop = function(self)
				whileVisible:Stop()
				instance.Color = color
			end
		}
	end
}