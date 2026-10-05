game:GetService("ReplicatedStorage")
require(script.Parent.Parent.Types)
return function(data, maid, data2, callback)
	assert(data2.PromptType == "Accept")
	data.Description.Text = data2.Description
	data.Title.Text = data2.Title or "Notification"
	data.Yes.Label.Text = data2.AcceptButtonText or "Accept"
	data.No.Label.Text = data2.DeclineButtonText or "Decline"
	maid:Add(data.Yes.Activated:Connect(function()
		callback(true)
	end))
	maid:Add(data.No.Activated:Connect(function()
		callback(false)
	end))
	maid:Add(data.Close.Activated:Connect(function()
		callback(false)
	end))
end