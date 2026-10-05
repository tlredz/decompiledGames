local ShowcasedItemCategoriesConfig = {
	remoteConfigDirectory = "AvatarEditor/ShowcasedItemCategories",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function ShowcasedItemCategoriesConfig.getConfig()
	while not ShowcasedItemCategoriesConfig.isLoaded do
		task.wait()
	end

	return ShowcasedItemCategoriesConfig.cache
end

return ShowcasedItemCategoriesConfig