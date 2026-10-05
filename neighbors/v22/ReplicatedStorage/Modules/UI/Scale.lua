local Scale = {
	GetObjectLayout = function(self, instance)
		return instance:FindFirstChildOfClass("UIGridLayout") or instance:FindFirstChildOfClass("UIListLayout")
	end,
	GetAllScalars = function(self, p, options)
		if not p.Parent then
			return
		end

		local uIScales = options or {}
		local uIScale = p.Parent:FindFirstChildOfClass("UIScale")

		if uIScale then
			table.insert(uIScales, uIScale)
		end

		if p.Parent:IsA("ScreenGui") then
			return uIScales
		end

		return self:GetAllScalars(p.Parent, uIScales)
	end,
	GetScaleFactor = function(self, items)
		local v = 1

		for _, item in next, items, nil do
			v *= item.Scale
		end

		return v
	end,
	CorrectAnyScalingIssues = function(self, instance)
		local allScalars = self:GetAllScalars(instance)

		if instance.AutomaticSize == Enum.AutomaticSize.Y then
			local objectLayout = self:GetObjectLayout(instance)
			local uIPadding = instance:FindFirstChildOfClass("UIPadding")

			if objectLayout:IsA("UIGridLayout") then
				objectLayout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
					local v = objectLayout.AbsoluteCellCount.Y * (objectLayout.CellSize.Y.Offset + objectLayout.CellPadding.Y.Offset)
					local v2 = uIPadding and uIPadding.PaddingBottom.Offset + uIPadding.PaddingTop.Offset or 0
					instance.Size = UDim2.new(1, 0, 0, (v + v2) / self:GetScaleFactor(allScalars))
				end)
				instance.AutomaticSize = Enum.AutomaticSize.None
			end
		end
	end
}

function Scale.EnableCustomAutomaticCanvasSize(_, instance)
	if instance.AutomaticCanvasSize == Enum.AutomaticSize.Y then
		local objectLayout = Scale:GetObjectLayout(instance)
		local uIPadding = instance:FindFirstChildOfClass("UIPadding")

		if objectLayout:IsA("UIGridLayout") then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v = objectLayout.AbsoluteCellCount.Y * (objectLayout.CellSize.Y.Offset + objectLayout.CellPadding.Y.Offset)
				local v2 = uIPadding and uIPadding.PaddingBottom.Offset + uIPadding.PaddingTop.Offset or 0
				instance.CanvasSize = UDim2.new(0, 0, 0, v + v2)
			end

			objectLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
			instance.AutomaticCanvasSize = Enum.AutomaticSize.None
		end
	end
end

return Scale