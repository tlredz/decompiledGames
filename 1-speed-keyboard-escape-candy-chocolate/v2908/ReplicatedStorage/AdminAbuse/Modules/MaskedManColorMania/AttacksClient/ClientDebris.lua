return function()
	local adminAbuseMaps = workspace:FindFirstChild("AdminAbuseMaps")
	local maskedManColorMania = adminAbuseMaps and adminAbuseMaps:FindFirstChild("MaskedManColorMania")

	if not maskedManColorMania then
		return workspace
	end

	local debris = maskedManColorMania:FindFirstChild("Debris")

	if debris and debris:IsA("Folder") then
		return debris
	end

	local folder = Instance.new("Folder")
	folder.Name = "Debris"
	folder.Parent = maskedManColorMania
	return folder
end