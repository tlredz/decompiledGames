local VERSION = {
	appVersion = "v3.4.0",
	latestVersion = nil
}

function VERSION.getLatestVersion()
	local latestVersion = VERSION.latestVersion

	if latestVersion then
		return latestVersion
	end

	local result

	while true do
		local success
		success, result = pcall(function()
			local MarketplaceService = game:GetService("MarketplaceService")
			return MarketplaceService:GetProductInfo(117501901079852)
		end)

		if success and result then
			break
		end

		task.wait(1)
	end

	local name = result.Name
	local v = string.match(name, "^TopbarPlus (.*)$")
	local latestVersion2 = v and v:gsub("%s+", "")
	VERSION.latestVersion = latestVersion2
	return latestVersion2
end

function VERSION.getAppVersion()
	return VERSION.appVersion
end

function VERSION.isUpToDate()
	local latestVersion = VERSION.getLatestVersion()
	local appVersion = VERSION.getAppVersion()
	return latestVersion ~= nil and latestVersion == appVersion
end

return VERSION