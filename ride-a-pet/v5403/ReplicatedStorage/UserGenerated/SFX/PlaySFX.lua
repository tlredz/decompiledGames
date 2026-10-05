local function PlaySFX(parent, cframe: CFrame, object)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = parent.CFrame:ToObjectSpace(cframe)
	object.Parent = attachment
	attachment.Parent = parent
	object.Ended:Connect(function()
		attachment:Destroy()
	end)
	object:Play()
end

return PlaySFX