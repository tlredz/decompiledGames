local parent = script.Parent
parent:WaitForChild("UIListLayout")

function UpdateSizes(_, p)
	for _, frame in pairs(parent:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local v = p * 0.25
		local messageFrame = frame:FindFirstChild("MessageFrame")

		if messageFrame then
			v += p * 0.185
			messageFrame.Size = UDim2.new(1, 0, 0, -(p * 0.185))
		end

		frame.Size = UDim2.new(1, 0, 0, v)
		frame.Frame.Size = UDim2.new(1, 0, 0, p * 0.25)
	end
end

function UpdateAbsoluteSize()
	local absoluteSize = parent.AbsoluteSize
	local X = absoluteSize.X
	local Y = absoluteSize.Y
	UpdateSizes(X, Y)
end

parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	wait()
	UpdateAbsoluteSize()
end)