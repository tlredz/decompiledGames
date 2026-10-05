local Sound = {}

function Sound.Sound(_, instance, p)
	local clone = instance:Clone()

	if typeof(p) == "Vector3" then
		local attachment = Instance.new("Attachment", workspace.Terrain)
		attachment.Position = p
		clone.AncestryChanged:connect(function(_, p2)
			if not p2 then
				attachment:Destroy()
			end
		end)
		clone.Parent = attachment
	else
		clone.Parent = p
	end

	clone:Play()
	clone.Ended:connect(function()
		return clone:Destroy()
	end)
	return clone
end

function Sound.Create(_, instance, p)
	local clone = instance:Clone()

	if typeof(p) == "Vector3" then
		local attachment = Instance.new("Attachment", workspace.Terrain)
		attachment.Position = p
		clone.AncestryChanged:Once(function(_, parent)
			if not parent then
				attachment:Destroy()
			end
		end)
		clone.Parent = attachment
	else
		clone.Parent = p
	end

	clone:Play()
	clone.Ended:Once(function()
		return clone:Destroy()
	end)
	return clone
end

return Sound