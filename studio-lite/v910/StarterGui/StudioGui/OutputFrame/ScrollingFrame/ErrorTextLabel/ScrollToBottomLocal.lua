local parent = script.Parent.Parent
local parent2 = script.Parent
local flag = true
local count = 0
parent2:GetPropertyChangedSignal("Text"):Connect(function()
	count += 1

	if flag then
		flag = false
		task.wait(0.5)

		if parent2.AbsoluteSize.Y > 125 then
			if count > 200 then
				count = 0
				parent2.Text = ""
				parent.CanvasPosition = Vector2.new(0, 0)
			else
				parent.CanvasPosition = Vector2.new(0, parent2.AbsoluteSize.Y - 125)
			end
		end

		flag = true
	end
end)