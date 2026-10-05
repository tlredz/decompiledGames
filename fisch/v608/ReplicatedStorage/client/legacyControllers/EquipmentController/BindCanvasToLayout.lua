return function(p, instance, flag: boolean?)
	local v = -1
	local v2 = -1
	local flag2 = false

	local function update()
		if flag2 then
			return
		end

		flag2 = true
		local absoluteContentSize = instance.AbsoluteContentSize
		local padding = instance.Padding

		if instance.FillDirection == Enum.FillDirection.Vertical then
			local Y = math.ceil(absoluteContentSize.Y)

			if Y ~= v then
				v = Y
				p.CanvasSize = UDim2.new(0, 0, 0, Y + (flag and 0 or padding.Offset or 0))
			end
		else
			local X = math.ceil(absoluteContentSize.X)

			if X ~= v2 then
				v2 = X
				p.CanvasSize = UDim2.new(0, X + (flag and 0 or padding.Offset or 0), 0, 0)
			end
		end

		flag2 = false
	end

	update()
	return instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
end