return function()
	local attachment = script.Parent.Attachment

	for _, child in pairs(attachment:GetChildren()) do
		child.Enabled = false
		child.Parent = nil
		child.Parent = attachment
	end

	script.Parent.Attachment2.Spark:Emit(3)
	script.Parent.Attachment2.Spark2:Emit(3)
end