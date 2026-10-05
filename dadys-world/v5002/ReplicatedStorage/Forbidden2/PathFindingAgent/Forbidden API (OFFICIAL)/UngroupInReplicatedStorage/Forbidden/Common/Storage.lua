local Storage = {}
local folder = nil

function Storage.GetForbiddenTemporaryWorkspaceFolder()
	if folder ~= nil then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = "ForbiddenTemporaryFolder"
	folder.Parent = workspace
	return folder
end

function Storage.GetForbiddenWSPartsFolder()
	local folder2 = Instance.new("Folder")
	folder2.Name = "Common-Parts"
	folder2.Parent = Storage.GetForbiddenTemporaryWorkspaceFolder()
	return nil
end

local folder2 = nil

function Storage.GetForbiddenStorageFolder()
	if folder2 ~= nil then
		return folder2
	end

	folder2 = Instance.new("Folder")
	folder2.Name = "ForbiddenStorageFolder"
	folder2.Parent = workspace
	return folder2
end

return Storage