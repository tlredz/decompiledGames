local rigTypeCheckboxImageButton = script.Parent:WaitForChild("RigTypeCheckboxImageButton")
local flag = true
rigTypeCheckboxImageButton.Activated:Connect(function()
	if flag then
		flag = false

		if rigTypeCheckboxImageButton.Image:sub(-8) == "48138491" then
			rigTypeCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138474"
			local rigTypeDescTextLabel = script.Parent:WaitForChild("RigTypeDescTextLabel")
			rigTypeDescTextLabel.Text = "R6"
		else
			rigTypeCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138491"
			local rigTypeDescTextLabel_2 = script.Parent:WaitForChild("RigTypeDescTextLabel")
			rigTypeDescTextLabel_2.Text = "R15"
		end

		task.wait(0.5)
		flag = true
	end
end)