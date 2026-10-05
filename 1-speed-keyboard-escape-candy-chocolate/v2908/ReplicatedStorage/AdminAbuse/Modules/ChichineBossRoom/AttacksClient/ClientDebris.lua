return function()
	local adminAbuseMaps = workspace:FindFirstChild("AdminAbuseMaps")
	local chichineBossRoom = adminAbuseMaps and adminAbuseMaps:FindFirstChild("ChichineBossRoom")

	if not chichineBossRoom then
		return workspace
	end

	local debris = chichineBossRoom:FindFirstChild("Debris")

	if debris and debris:IsA("Folder") then
		return debris
	end

	local folder = Instance.new("Folder")
	folder.Name = "Debris"
	folder.Parent = chichineBossRoom
	return folder
end