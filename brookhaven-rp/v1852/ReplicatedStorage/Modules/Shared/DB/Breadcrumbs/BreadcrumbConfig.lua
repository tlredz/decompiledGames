local BreadcrumbConfig = {
	remoteConfigDirectory = "Breadcrumbs/Config",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	collapsedTable = {}
}
BreadcrumbConfig.middlewares = {
	collapseTable = function(items)
		for _, item in items do
			for k, _ in item do
				BreadcrumbConfig.collapsedTable[k] = true
			end
		end

		return items
	end
}

function BreadcrumbConfig.ContainsEmote(p: string)
	while not BreadcrumbConfig.isLoaded do
		task.wait()
	end

	return BreadcrumbConfig.emoteNames[p] ~= nil
end

function BreadcrumbConfig.ContainsItem(p: string)
	while not BreadcrumbConfig.isLoaded do
		task.wait()
	end

	return BreadcrumbConfig.collapsedTable[p] ~= nil
end

function BreadcrumbConfig.GetConfig()
	while not BreadcrumbConfig.isLoaded do
		task.wait()
	end

	return BreadcrumbConfig.cache
end

return BreadcrumbConfig