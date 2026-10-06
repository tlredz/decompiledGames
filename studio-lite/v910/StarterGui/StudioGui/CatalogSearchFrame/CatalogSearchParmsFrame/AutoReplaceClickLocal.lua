local autoReplaceCheckboxImageButton = script.Parent:WaitForChild("AutoReplaceCheckboxImageButton")
local flag = true
autoReplaceCheckboxImageButton.Activated:Connect(function()
	if flag then
		flag = false

		if autoReplaceCheckboxImageButton.Image:sub(-8) == "48138491" then
			autoReplaceCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138474"
			local autoReplaceTextLabel = script.Parent:WaitForChild("AutoReplaceTextLabel")
			autoReplaceTextLabel.Text = "Multiple allowed"
		else
			autoReplaceCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138491"
			local autoReplaceTextLabel_2 = script.Parent:WaitForChild("AutoReplaceTextLabel")
			autoReplaceTextLabel_2.Text = "AutoReplace"
		end

		task.wait(0.5)
		flag = true
	end
end)