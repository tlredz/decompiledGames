local animScriptCheckboxImageButton = script.Parent:WaitForChild("AnimScriptCheckboxImageButton")
local flag = true
animScriptCheckboxImageButton.Activated:Connect(function()
	if flag then
		flag = false

		if animScriptCheckboxImageButton.Image:sub(-8) == "48138491" then
			animScriptCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138474"
			local animScriptTextLabel = script.Parent:WaitForChild("AnimScriptTextLabel")
			animScriptTextLabel.Text = "Don't add script to play this animation."
		else
			animScriptCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138491"
			local animScriptTextLabel_2 = script.Parent:WaitForChild("AnimScriptTextLabel")
			animScriptTextLabel_2.Text = "Add script to rig to play this animation."
		end

		task.wait(0.5)
		flag = true
	end
end)