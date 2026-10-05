for _, part in ipairs(workspace.Region.SafezoneArea:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	part.CanCollide = false
	part.CanQuery = false
end