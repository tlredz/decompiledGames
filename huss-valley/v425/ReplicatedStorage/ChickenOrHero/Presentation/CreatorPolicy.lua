local v = {
	PlayerBlockers = {
		"InMatch",
		"TutorialSession",
		"TutorialRouting",
		"AdminTransferring",
		"ServerBrowserTransferring",
		"ScreenPresentationActive",
		"AdminRefreshActive",
		"GlobalWheelOpen",
		"FairPlayNoticeOpen"
	},
	authorized = function(instance)
		return instance:GetAttribute("CreatorAuthorized") == true
	end
}

function v.lobby(instance, instance2)
	if not v.authorized(instance) or instance:GetAttribute("ClientReady") ~= true or (instance:GetAttribute("GameRole") or "Lobby") ~= "Lobby" then
		return false
	end

	if instance2:GetAttribute("MapChanging") or instance2:GetAttribute("GlobalPaused") then
		return false
	end

	for _, attributeName in v.PlayerBlockers do
		if instance:GetAttribute(attributeName) == true then
			return false
		end
	end

	return true
end

return table.freeze(v)