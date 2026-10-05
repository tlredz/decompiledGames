game:GetService("ReplicatedStorage")
require(script.Parent.Parent.Types)
return function(data, maid, data2, callback)
	assert(data2.PromptType == "Ok")
	data.Description.Text = data2.Description
	data.Title.Text = data2.Title or "Notification"
	maid:Add(data.Ok.Activated:Connect(function()
		callback(true)
	end))
	maid:Add(data.Close.Activated:Connect(function()
		callback(false)
	end))
end