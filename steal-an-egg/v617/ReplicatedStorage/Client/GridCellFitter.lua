local function renderScale(parent)
	local v2 = 1

	while parent ~= nil and not parent:IsA("LayerCollector") do
		local uIScale = parent:FindFirstChildWhichIsA("UIScale")

		if uIScale ~= nil then
			v2 *= uIScale.Scale
		end

		parent = parent.Parent
	end

	if v2 > 0 then
		return v2
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wholePixels(udim: UDim, p: number)
	return (math.floor(udim.Scale * p + udim.Offset))
end

return table.freeze({
	Fit = function(self, p: number, udim: UDim2?)
		local parent = self.Parent
		local v2

		if parent == nil then
			v2 = false
		else
			v2 = parent:IsA("GuiObject")
		end

		assert(v2, (`{self:GetFullName()} needs a GuiObject parent`))
		local v3 = udim or UDim2.new()
		local v4 = p

		local function refit(p2: number?)
			if p2 ~= nil then
				v4 = p2
			end

			assert(v4 >= 1, (`{self:GetFullName()} cannot fit {v4} columns`))
			local v5 = renderScale(parent)
			local v6

			if parent:IsA("ScrollingFrame") then
				v6 = parent
			end

			local v7

			if v6 == nil then
				v7 = parent.AbsoluteSize
			else
				v7 = v6.AbsoluteWindowSize
			end

			local v8 = v7 / v5
			local v9 = wholePixels(v3.X, v8.X) -- equivalent call inferred; original call site unknown
			local v10 = wholePixels(v3.Y, v8.Y) -- equivalent call inferred; original call site unknown
			local v11 = parent.AbsoluteSize.X / v5

			if v6 ~= nil then
				v11 -= v6.ScrollBarThickness
			end

			local v12 = math.max(math.floor(v11 / v4) - v9, 0)
			self.CellPadding = UDim2.fromOffset(v9, v10)
			self.CellSize = UDim2.fromOffset(v12, v12)
		end

		local absoluteSizeChangedConnection = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			refit()
		end)
		self.Destroying:Once(function()
			absoluteSizeChangedConnection:Disconnect()
		end)
		refit()
		return refit
	end
})