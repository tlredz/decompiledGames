local parent = script.Parent and script.Parent.Parent

if parent:IsA("Tool") then
	local flag = false
	parent.Activated:Connect(function()
		if flag then
			return
		end

		script.Parent.Sound:Play()
		flag = true
		task.wait(5)
		flag = false
	end)
end