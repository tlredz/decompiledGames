return function()
	local adminAbuseMaps = workspace:FindFirstChild("AdminAbuseMaps")
	local wCFinaleAdminAbuse = adminAbuseMaps and adminAbuseMaps:FindFirstChild("WCFinaleAdminAbuse")

	if not wCFinaleAdminAbuse then
		return workspace
	end

	local debris = wCFinaleAdminAbuse:FindFirstChild("Debris")

	if debris and debris:IsA("Folder") then
		return debris
	end

	local folder = Instance.new("Folder")
	folder.Name = "Debris"
	folder.Parent = wCFinaleAdminAbuse
	return folder
end