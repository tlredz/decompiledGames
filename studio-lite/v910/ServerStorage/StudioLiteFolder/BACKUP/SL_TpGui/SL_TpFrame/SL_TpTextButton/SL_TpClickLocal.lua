script.Parent.Visible = false
spawn(function()
	local parent = script.Parent.Parent

	for i = 199, 1, -1 do
		parent.Size = UDim2.new(0, i, 0, i)
		parent.Rotation = (200 - i) * 2
		task.wait()
	end

	parent.Visible = false
	parent.Size = UDim2.new(0, 200, 0, 200)
	parent.Rotation = 0
end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("TpBackToStudioLiteServerFunction"):InvokeServer()