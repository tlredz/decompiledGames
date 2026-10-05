local ExclusionConfig = {
	remoteConfigDirectory = "Exclusion/Config",
	isPublic = true,
	isLoaded = false,
	cache = nil
}
local v = {}
local v2 = {}
ExclusionConfig.middlewares = {
	buildIdCache = function(items)
		for k, item in items do
			for k2, v3 in item do
				for k3, _ in v3 do
					v[k3] = {
						typeName = k,
						groupName = k2
					}
					v2[k2] = k
				end
			end
		end

		return items
	end
}

function ExclusionConfig.GetTypeByGroupName(p: string)
	while not ExclusionConfig.isLoaded do
		task.wait()
	end

	return v2[p]
end

function ExclusionConfig.GetGroupById(p: string)
	while not ExclusionConfig.isLoaded do
		task.wait()
	end

	return v[p] and v[p].groupName or nil
end

function ExclusionConfig.GetTypeById(p: string)
	while not ExclusionConfig.isLoaded do
		task.wait()
	end

	return v[p] and v[p].typeName or nil
end

function ExclusionConfig.IsExcluded(p: string, p2: string, p3: string)
	local config = ExclusionConfig.GetConfig()

	if not (config[p] and config[p][p2]) then
		return false
	end

	if config[p][p2][p3] then
		return config[p][p2][p3]
	end

	return false
end

function ExclusionConfig.GetConfig()
	while not ExclusionConfig.isLoaded do
		task.wait()
	end

	return ExclusionConfig.cache
end

return ExclusionConfig