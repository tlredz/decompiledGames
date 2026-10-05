require("@game/ReplicatedStorage/Types/Templates")
return function(instance, p: number)
	local value = instance.TargetAttachment.Value

	if value and value:IsA("Attachment") then
		return ((math.clamp((value.WorldCFrame.Position - instance:GetPivot().Position).Magnitude, 0, 60) - 60) / -60 * -1 + 1) * p
	end

	return nil
end