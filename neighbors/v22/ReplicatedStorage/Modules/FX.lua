return {
	FX = function(_, instance, p)
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

		clone:Emit(clone.Rate)
		task.delay(clone.Lifetime.Max + 0.1, function()
			clone:Destroy()
		end)
		return clone
	end
}