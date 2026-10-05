local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local FeatureFlags = require(game.ReplicatedStorage.Modules.FeatureFlags)
local localPlayer = Players.LocalPlayer
local customServerJoin = localPlayer.PlayerGui:WaitForChild("Prompts"):WaitForChild("CustomServerJoin")
local now = 0
local v = {
	hintBgColor = Color3.fromRGB(0, 174, 255)
}
Network:listen("CustomServerGlobalNotification", function(data)
	if not FeatureFlags:IsEnabled("FFlagCustomServerNotifications") or os.time() - now < 20 then
		return
	end

	local success, countryRegionForPlayerAsync = pcall(
		LocalizationService.GetCountryRegionForPlayerAsync,
		LocalizationService,
		localPlayer
	)

	if success and string.lower(countryRegionForPlayerAsync) ~= string.lower(data.Region) then
		return
	end

	now = os.time()
	_G.DisplayText(`🚩 A custom server named {data.Name} has started!`, 7, v):setCallback(function()
		customServerJoin:SetAttribute("TargetPlaceId", data.PlaceId)
		customServerJoin:SetAttribute("TargetReserveId", data.ReserveId)
		customServerJoin:SetAttribute("TargetName", data.Name)
		customServerJoin.Visible = true
	end)
end)