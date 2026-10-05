local RolePermissions = {
	remoteConfigDirectory = "Cmdr/RoleCommands",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function RolePermissions.GetConfig()
	while not RolePermissions.isLoaded do
		task.wait()
	end

	return RolePermissions.cache
end

return RolePermissions