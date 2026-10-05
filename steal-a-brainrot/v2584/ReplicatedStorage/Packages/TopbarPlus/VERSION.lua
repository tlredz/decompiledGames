local VERSION = {
	appVersion = "v3.3.1",
	latestVersion = nil,
	getLatestVersion = function()
		return nil
	end
}

function VERSION.getAppVersion()
	return VERSION.appVersion
end

function VERSION.isUpToDate()
	local latestVersion = VERSION.getLatestVersion()
	local appVersion = VERSION.getAppVersion()
	return latestVersion ~= nil and latestVersion == appVersion
end

return VERSION