local Tween = require(script:WaitForChild("Tween"))
local v = {
	duration = 0.5,
	style = Enum.EasingStyle.Quint,
	direction = Enum.EasingDirection.Out
}
local v2 = {}
local AutoSize = {
	Disconnect = function(self)
		local v3 = v2[self]

		if v3 then
			for _, connection in pairs(v3.connections) do
				connection:Disconnect()
			end

			v2[self] = nil
		end
	end,
	Update = function(scrollingFrame)
		local v3 = v2[scrollingFrame]
		local uIListLayout = v3 and (scrollingFrame:FindFirstChildWhichIsA("UIListLayout") or scrollingFrame:FindFirstChildWhichIsA("UIGridLayout"))

		if uIListLayout then
			local v4 = scrollingFrame:IsA("ScrollingFrame") and "CanvasSize" or "Size"
			local v5 = scrollingFrame[v4]
			local absoluteContentSize = uIListLayout.AbsoluteContentSize
			local X = table.find(v3.axes, "X") and absoluteContentSize.X or v5.X.Offset
			local Y = table.find(v3.axes, "Y") and absoluteContentSize.Y or v5.Y.Offset
			local uDim = UDim2.new(v5.X.Scale, X, v5.Y.Scale, Y)

			if v3.tweenSettings then
				Tween(scrollingFrame, {
					[v4] = uDim
				}, v3.tweenSettings.duration or v.duration, v3.tweenSettings.style or v.style, v3.tweenSettings.direction or v.direction)
			else
				scrollingFrame[v4] = uDim
			end
		end
	end
}

function AutoSize:Connect(p, tweenSettings)
	local uIListLayout = not v2[self] and (self:FindFirstChildWhichIsA("UIListLayout") or self:FindFirstChildWhichIsA("UIGridLayout"))

	if not uIListLayout then
		return
	end

	local v3 = {
		connections = { uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				AutoSize.Update(self)
			end) },
		tweenSettings = tweenSettings,
		axes = p or { "X", "Y" }
	}
	v2[self] = v3
	return v3
end

return AutoSize