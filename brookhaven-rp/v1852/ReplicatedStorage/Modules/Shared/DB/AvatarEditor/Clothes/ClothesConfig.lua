local ClothesConfig = {
	remoteConfigDirectory = "AvatarEditor/Clothes",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	nameIndexedCfg = {
		cacheRef = "nil",
		map = {},
		indexLookup = {}
	}
}

function ClothesConfig.getConfig()
	while not ClothesConfig.isLoaded do
		task.wait()
	end

	return ClothesConfig.cache
end

function ClothesConfig.getNameIndexedConfig()
	while not ClothesConfig.isLoaded do
		task.wait()
	end

	if not ClothesConfig.cache then
		return
	end

	if tostring(ClothesConfig.cache) == ClothesConfig.nameIndexedCfg.cacheRef then
		return ClothesConfig.nameIndexedCfg.map
	end

	ClothesConfig.nameIndexedCfg.cacheRef = tostring(ClothesConfig.cache)
	ClothesConfig.nameIndexedCfg.map = {}
	ClothesConfig.nameIndexedCfg.indexLookup = {}

	for k, v in ClothesConfig.cache do
		local v2 = {}
		local v3 = {}
		ClothesConfig.nameIndexedCfg.map[k] = v2
		ClothesConfig.nameIndexedCfg.indexLookup[k] = v3

		for k2, v4 in v do
			v3[v4.Name] = k2
			v2[v4.Name] = v4
		end
	end

	return ClothesConfig.nameIndexedCfg.map
end

function ClothesConfig.getNameToConfigIndexLookupMap()
	while not ClothesConfig.isLoaded do
		task.wait()
	end

	if next(ClothesConfig.nameIndexedCfg.indexLookup) == nil then
		ClothesConfig.getNameIndexedConfig()
	end

	return ClothesConfig.nameIndexedCfg.indexLookup
end

return ClothesConfig